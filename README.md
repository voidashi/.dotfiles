# Dotfiles

Este repositório contém meus arquivos de configuração pessoais (**dotfiles**) e um script de gerenciamento que facilita a instalação, sincronização e restauração desses arquivos em diferentes máquinas.

## Conteúdo

Este repositório armazena configurações para:

- **Bash** (`.bashrc`)
- **Starship** (`~/.config/starship.toml`)
- **Fish** (`~/.config/fish/`)
- **Foot** (`~/.config/foot/`)
- **Hyprland** (`~/.config/hypr/`)
- **Neovim** (`~/.config/nvim/`)
- **Sway** (`~/.config/sway/`)
- **Waybar** (`~/.config/waybar/`)

## Estrutura do Repositório

- **dotfiles.conf**: Arquivo de configuração que lista todos os arquivos e diretórios que serão gerenciados.
- **manage.sh**: Script para adicionar, restaurar e verificar os dotfiles. Facilita a criação de symlinks e a sincronização com este repositório.

## Funcionalidades do Script

O script `manage.sh` oferece as seguintes funções:

1. **init**: Inicializa o diretório de dotfiles e configura o Git.
   ```bash
   ./manage.sh init
   ```

2. **add**: Move os arquivos listados no `dotfiles.conf` para o diretório `.dotfiles`, cria symlinks na home folder e sugere um commit no Git.
   ```bash
   ./manage.sh add
   ```

3. **restore [arquivo]**: Restaura um arquivo ou diretório específico da pasta `.dotfiles` para o local original.
   ```bash
   ./manage.sh restore ~/.bashrc
   ```

4. **check**: Verifica se os symlinks dos dotfiles estão configurados corretamente.
   ```bash
   ./manage.sh check
   ```

## Configuração em uma Nova Máquina

Para configurar seus dotfiles em uma nova máquina:

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/dotfiles.git ~/.dotfiles
   ```

2. Navegue até a pasta `scripts` e execute o script de inicialização:
   ```bash
   cd ~/.dotfiles/scripts
   ./manage.sh init
   ```

3. Adicione os arquivos conforme definidos no `dotfiles.conf`:
   ```bash
   ./manage.sh add
   ```

Isso moverá os arquivos para o repositório `.dotfiles` e criará symlinks nos locais apropriados.

## Personalizando

Se você quiser adicionar mais arquivos para serem gerenciados, basta editar o arquivo `dotfiles.conf` adicionando os caminhos completos dos arquivos ou diretórios desejados.

Exemplo:
```bash
# Adicionando configurações do Zsh
~/.zshrc
```

Depois de editar o `dotfiles.conf`, execute novamente:
```bash
./manage.sh add
```

## Contribuindo

Se você tem sugestões ou melhorias para o repositório ou o script de gerenciamento, sinta-se à vontade para abrir um pull request ou relatar um problema.

## Licença

Este repositório é licenciado sob a [MIT License](LICENSE).
