# ✨ Dotfiles

Este repositório contém meus **dotfiles** pessoais e um script de gerenciamento para facilitar a instalação, sincronização e restauração desses arquivos em múltiplas máquinas. Com ele, você pode manter suas configurações sempre consistentes e sincronizadas entre diferentes dispositivos.

## 📂 Conteúdo

Este repositório gerencia as configurações para:

- **Bash** (`~/.bashrc`)
- **Starship** (`~/.config/starship.toml`)
- **Fish** (`~/.config/fish/`)
- **Foot** (`~/.config/foot/`)
- **Hyprland** (`~/.config/hypr/`)
- **Neovim** (`~/.config/nvim/`)
- **Sway** (`~/.config/sway/`)
- **Waybar** (`~/.config/waybar/`)

## 🚀 Funcionalidades do Script

O script `manage.sh` permite gerenciar seus dotfiles de forma simples e eficaz. Aqui estão as principais funcionalidades:

### ⚙️ Inicializar
Este comando inicializa o diretório de dotfiles e configura o Git.
```bash
./manage.sh init
```

### ➕ Adicionar arquivos/diretórios
Move os arquivos/diretórios listados no `dotfiles.conf` para o diretório `.dotfiles`, cria symlinks na home folder e sugere um commit no Git.
```bash
./manage.sh add
```

### 🔄 Restaurar dotfiles
Restaura um arquivo ou diretório específico do repositório `.dotfiles` para seu local original na home folder.
```bash
./manage.sh restore ~/.bashrc
```

### 🔍 Verificar symlinks
Verifica se todos os symlinks dos dotfiles estão corretamente configurados.
```bash
./manage.sh check
```

## 🖥️ Configuração em uma Nova Máquina

Para configurar seus dotfiles em uma nova máquina, siga os passos abaixo:

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/seu-usuario/dotfiles.git ~/.dotfiles
   ```

2. **Navegue até a pasta `scripts` e execute o script de inicialização**:
   ```bash
   cd ~/.dotfiles/scripts
   ./manage.sh init
   ```

3. **Adicione os arquivos conforme definidos no `dotfiles.conf`**:
   ```bash
   ./manage.sh add
   ```

Isso moverá os arquivos para o repositório `.dotfiles` e criará symlinks nos locais apropriados.

## 🛠️ Personalização

Para adicionar novos arquivos ou diretórios ao repositório:

1. **Edite o arquivo `dotfiles.conf`** adicionando os caminhos completos dos arquivos ou diretórios desejados.

   Exemplo:
   ```bash
   # Adicionando configurações do Zsh
   ~/.zshrc
   ```

2. **Execute o comando `add`** novamente para que os novos arquivos sejam gerenciados:
   ```bash
   ./manage.sh add
   ```

## 📝 Contribuindo

Se você tem sugestões, melhorias ou encontrou problemas, sinta-se à vontade para abrir um pull request ou relatar um problema!

## 🛡️ Licença

Este projeto é licenciado sob a [MIT License](LICENSE). Sinta-se à vontade para usar e modificar conforme necessário.
