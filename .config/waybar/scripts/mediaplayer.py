#!/usr/bin/env python3
"""Waybar custom/media source.

Watches every MPRIS player through playerctl and prints one JSON line per
change, for waybar's `return-type: json`.

The output carries playback state two ways, because colour never carries a
state on its own in this desktop (docs/design/RICE-GUIDE.md):

  alt    -- "playing" / "paused" / "stopped", which common.jsonc maps to a
            glyph through format-icons
  class  -- the same state plus the player's own name, so style.css can dim a
            paused track and, if ever needed, style one player differently

Text is left raw: common.jsonc sets "escape": true, so waybar escapes it for
Pango. Escaping here as well would double it and print a literal &amp;.
"""
import argparse
import json
import logging
import os
import signal
import sys
from typing import List, Optional

import gi

gi.require_version("Playerctl", "2.0")
from gi.repository import GLib, Playerctl  # noqa: E402
from gi.repository.Playerctl import Player  # noqa: E402

logger = logging.getLogger(__name__)

# MPRIS playback status -> the key common.jsonc's format-icons is written against
STATUS_ALT = {
    "Playing": "playing",
    "Paused": "paused",
    "Stopped": "stopped",
}


def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    sys.exit(0)


class PlayerManager:
    def __init__(self, selected_player=None, excluded_player=None):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.manager.connect("name-appeared", lambda *args: self.on_player_appeared(*args))
        self.manager.connect("player-vanished", lambda *args: self.on_player_vanished(*args))

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
        self.selected_player = selected_player
        self.excluded_player = excluded_player.split(",") if excluded_player else []

        self.init_players()

    def init_players(self):
        for player in self.manager.props.player_names:
            if player.name in self.excluded_player:
                continue
            if self.selected_player is not None and self.selected_player != player.name:
                logger.debug(f"{player.name} is not the filtered player, skipping it")
                continue
            self.init_player(player)

    def run(self):
        logger.info("Starting main loop")
        self.loop.run()

    def init_player(self, player):
        logger.info(f"Initialize new player: {player.name}")
        player = Playerctl.Player.new_from_name(player)
        player.connect("playback-status", self.on_playback_status_changed, None)
        player.connect("metadata", self.on_metadata_changed, None)
        self.manager.manage_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def get_players(self) -> List[Player]:
        return self.manager.props.players

    def write_output(self, text: str, player, status: str):
        logger.debug(f"Writing output: {text}")
        name = player.props.player_name
        alt = STATUS_ALT.get(status, "playing")

        output = {
            "text": text,
            "alt": alt,
            "tooltip": f"{name}: {text}" if text else name,
            "class": [alt, f"player-{name}"],
        }

        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        sys.stdout.write("\n")
        sys.stdout.flush()

    def on_playback_status_changed(self, player, status, _=None):
        logger.debug(f"Playback status changed for {player.props.player_name}: {status}")
        self.on_metadata_changed(player, player.props.metadata)

    def get_first_playing_player(self) -> Optional[Player]:
        players = self.get_players()
        logger.debug(f"Getting first playing player from {len(players)} players")
        if not players:
            logger.debug("No players found")
            return None
        # Reverse order, so the most recently added player wins.
        for player in players[::-1]:
            if player.props.status == "Playing":
                return player
        return players[0]

    def show_most_important_player(self):
        logger.debug("Showing most important player")
        current_player = self.get_first_playing_player()
        if current_player is not None:
            self.on_metadata_changed(current_player, current_player.props.metadata)
        else:
            self.clear_output()

    @staticmethod
    def build_track_info(player, metadata) -> str:
        """Artist - Title, tolerating players that report neither.

        get_title()/get_artist() return None for streams and some web players;
        the previous version called .replace() straight on the title and threw
        an AttributeError the moment one of those appeared.
        """
        player_name = player.props.player_name
        artist = player.get_artist()
        title = player.get_title()

        trackid = metadata["mpris:trackid"] if "mpris:trackid" in metadata.keys() else ""
        if player_name == "spotify" and ":ad:" in str(trackid):
            return "Advertisement"
        if artist and title:
            return f"{artist} - {title}"
        return title or artist or ""

    def on_metadata_changed(self, player, metadata, _=None):
        logger.debug(f"Metadata changed for player {player.props.player_name}")
        track_info = self.build_track_info(player, metadata)

        # Only print if no other player is playing.
        current_playing = self.get_first_playing_player()
        if current_playing is not None and current_playing.props.player_name != player.props.player_name:
            logger.debug(f"Other player {current_playing.props.player_name} is playing, skipping")
            return

        # A player with no track to name is not worth a slot in the bar.
        if not track_info:
            self.clear_output()
            return

        self.write_output(track_info, player, player.props.status)

    def on_player_appeared(self, _, player):
        logger.info(f"Player has appeared: {player.name}")
        if player.name in self.excluded_player:
            logger.debug("New player appeared, but it's excluded, skipping")
            return
        if player is not None and (self.selected_player is None or player.name == self.selected_player):
            self.init_player(player)
        else:
            logger.debug("New player appeared, but it's not the selected player, skipping")

    def on_player_vanished(self, _, player):
        logger.info(f"Player {player.props.player_name} has vanished")
        self.show_most_important_player()


def parse_arguments():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)
    # This used to pass the description as a third option string rather than
    # help=, which argparse silently accepted as a bogus option named
    # "- Comma-separated list of excluded player".
    parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded players")
    parser.add_argument("--player", help="Only listen to this player")
    parser.add_argument("--enable-logging", action="store_true")

    return parser.parse_args()


def main():
    arguments = parse_arguments()

    if arguments.enable_logging:
        logfile = os.path.join(os.path.dirname(os.path.realpath(__file__)), "media-player.log")
        logging.basicConfig(
            filename=logfile,
            level=logging.DEBUG,
            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s",
        )

    # Logging defaults to WARN and higher; every -v lowers it one step.
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info(f"Filtering for player: {arguments.player}")
    if arguments.exclude:
        logger.info(f"Excluding players: {arguments.exclude}")

    player = PlayerManager(arguments.player, arguments.exclude)
    player.run()


if __name__ == "__main__":
    main()
