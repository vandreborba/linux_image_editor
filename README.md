# Simple Print Tool

Editor de imagens simples e rápido para Linux, perfeito para editar screenshots com anotações.

![Flutter](https://img.shields.io/badge/Flutter-Linux-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 📋 Recursos

- 🎯 **Fluxo de Trabalho Rápido**
  - **Cola automaticamente** ao abrir sem argumentos - tire um screenshot, abra o app e está pronto!
  - Recebe imagens via linha de comando
  - Botão "Colar" para importar da área de transferência a qualquer momento

- ✏️ **Ferramentas de Desenho**
  - Pincel com cores e espessuras personalizáveis
  - Highlighter (marcador semi-transparente) para destacar texto
  - Setas e retângulos para anotações
  - Ferramenta de texto
  - Borracha

- 🖼️ **Ferramentas de Edição**
  - Cortar imagens (crop)
  - Desfazer/Refazer (Ctrl+Z / Ctrl+Y)

- 💾 **Opções de Salvamento**
  - Salvar (sobrescrever arquivo original)
  - Salvar Como (escolher novo local/nome)
  - Copiar para área de transferência

- ⌨️ **Atalhos de Teclado**
  - `Ctrl+O`: Abrir imagem
  - `Ctrl+V`: Colar da área de transferência
  - `Ctrl+S`: Salvar
  - `Ctrl+Shift+S`: Salvar Como
  - `Ctrl+C`: Copiar para área de transferência
  - `Ctrl+Z`: Desfazer
  - `Ctrl+Y`: Refazer

## 🚀 Instalação

### Pré-requisitos

- Flutter SDK (3.10.8 ou superior)
- Linux com GTK3
- Git

### Compilação

```bash
# Clone o repositório
git clone <repository-url>
cd simple_print_tool

# Instale as dependências
flutter pub get

# Compile para Linux
flutter build linux --release
```

### Instalação no Sistema

**Método 1 - Script Automático (Recomendado):**

```bash
# Compila e instala automaticamente
sudo bash install.sh
```

**Método 2 - Criar Pacote para Distribuir:**

```bash
# Cria um arquivo .tar.gz para levar para outro PC
bash package.sh

# Isso gera um arquivo: simple_print_tool_1.0.0_linux_x64.tar.gz
# Copie este arquivo para outro PC e extraia:
tar -xzf simple_print_tool_1.0.0_linux_x64.tar.gz
cd simple_print_tool_1.0.0_linux_x64
sudo bash install.sh
```

**Método 3 - Manual:**

```bash
# Copie o executável para /usr/local/bin
sudo cp -r build/linux/x64/release/bundle /opt/simple_print_tool

# Crie link simbólico
sudo ln -s /opt/simple_print_tool/simple_print_tool /usr/local/bin/simple-print-tool

# Instale o arquivo .desktop
mkdir -p ~/.local/share/applications
cp simple_print_tool.desktop ~/.local/share/applications/

# Atualize o banco de dados de aplicativos
update-desktop-database ~/.local/share/applications/
```

**Nota**: Edite o arquivo `simple_print_tool.desktop` para ajustar o caminho do `Exec` se você instalou em um local diferente.

## 🔧 Configurar como Editor Padrão

**Método Automático:**

```bash
bash set-default.sh
```

**Método Manual:**

Para configurar o Simple Print Tool como editor padrão de imagens no Linux:

```bash
# Para PNG
xdg-mime default simple_print_tool.desktop image/png

# Para JPEG
xdg-mime default simple_print_tool.desktop image/jpeg

# Para todos os formatos suportados
xdg-mime default simple_print_tool.desktop image/png
xdg-mime default simple_print_tool.desktop image/jpeg
xdg-mime default simple_print_tool.desktop image/bmp
xdg-mime default simple_print_tool.desktop image/gif
xdg-mime default simple_print_tool.desktop image/webp
```

Agora, quando você tirar um screenshot e salvá-lo, pode clicar com o botão direito e abrir com Simple Print Tool, ou ele abrirá automaticamente ao dar duplo clique.

## 📖 Como Usar

### ⚡ Workflow Rápido (Recomendado)

**Para editar screenshots rapidamente:**

1. Tire um screenshot (geralmente `Print Screen` ou `Shift+Print Screen`)
2. Abra o Simple Print Tool (sem argumentos)
3. A imagem da área de transferência será carregada automaticamente
4. Edite conforme necessário
5. Pressione `Ctrl+S` para salvar ou `Ctrl+C` para copiar

**Workflow alternativo com Ctrl+V:**
- Abra o app
- Tire um screenshot
- Pressione `Ctrl+V` no app ou clique no botão "Colar"

### Abrir uma Imagem

1. **Via linha de comando**: `simple_print_tool /caminho/para/imagem.png`
2. **Pelo aplicativo**: Clique no botão "Abrir Imagem" ou pressione `Ctrl+O`
3. **Do gerenciador de arquivos**: Clique com botão direito na imagem → "Abrir com" → Simple Print Tool
4. **Da área de transferência**: Pressione `Ctrl+V` ou clique no botão "Colar"

### Editar

1. Selecione uma ferramenta na barra lateral esquerda
2. Escolha uma cor na paleta
3. Ajuste a espessura do traço usando o controle deslizante
4. Desenhe na imagem

### Salvar

- **Salvar** (`Ctrl+S`): Sobrescreve o arquivo original
- **Salvar Como** (`Ctrl+Shift+S`): Salva em um novo arquivo
- **Copiar** (`Ctrl+C`): Copia a imagem editada para a área de transferência

## 🛠️ Desenvolvimento

### Estrutura do Projeto

```
lib/
├── main.dart                           # Ponto de entrada
├── models/
│   ├── editor_mode.dart               # Enums para modos (draw, crop)
│   └── editor_tool.dart               # Enums para ferramentas
├── screens/
│   └── image_editor_screen.dart       # Tela principal do editor
└── widgets/
    └── toolbar.dart                   # Barra de ferramentas lateral
```

### Dependências Principais

- **flutter_painter_v2**: Ferramentas de desenho e anotação (versão melhorada e atualizada)
- **crop_your_image**: Funcionalidade de corte
- **file_picker**: Seleção de arquivos com diálogos nativos
- **pasteboard**: Operações de área de transferência
- **path_provider**: Acesso aos diretórios do sistema

### Executar em Desenvolvimento

```bash
flutter run -d linux
```

### Testar com uma Imagem

```bash
flutter run -d linux lib/main.dart -- /caminho/para/screenshot.png
```

## 🐛 Problemas Conhecidos

- Em algumas distribuições Linux, a integração com área de transferência pode ter atrasos
- Imagens muito grandes (>4K) podem ter desempenho reduzido

## 📝 Licença

Este projeto é de código aberto. Consulte o arquivo LICENSE para mais detalhes.

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## 📧 Contato

Para dúvidas ou sugestões, abra uma issue no repositório.
