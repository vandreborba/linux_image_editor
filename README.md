# Linux Image Editor

A lightweight and fast image editor for Linux with drawing tools (brush, highlighter, arrows, shapes), text annotations, crop, resize, and file navigation. Perfect for quick edits after screenshots with keyboard shortcuts support.

Editor de imagens leve e rápido para Linux com ferramentas de desenho (pincel, marca-texto, setas, formas), anotações de texto, corte, redimensionamento e navegação de arquivos. Perfeito para edições rápidas após print screens com suporte a atalhos de teclado.

![Flutter](https://img.shields.io/badge/Flutter-Linux-blue)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)

[English](#english) | [Português](#português)

## English

![Linux Image Editor Screenshot](assets/screenshot/Screenshot1.png)

A feature-rich image editor designed for quick edits. Load images from file or clipboard, annotate with various tools, crop, resize, and save your work—all with intuitive keyboard shortcuts.

### Installation

Download the latest `.deb` package from [Releases](https://github.com/vandreborba/linux_image_editor/releases/latest).

```bash
sudo dpkg -i linux-image-editor_*.deb
```

### Set as Default Image Viewer

After installing, run the included script:

```bash
/opt/linux-image-editor/set-default.sh
```

### Development

```bash
flutter pub get
flutter run -d linux
```

### License

GPL-3.0. See LICENSE.

## Português

![Linux Image Editor Screenshot](assets/screenshot/Screenshot1.png)

Um editor de imagens completo projetado para edições rápidas. Carregue imagens de arquivos ou da área de transferência, anote com várias ferramentas, corte, redimensione e salve seu trabalho—tudo com atalhos de teclado intuitivos.

### Instalação

Baixe o pacote `.deb` mais recente em [Releases](https://github.com/vandreborba/linux_image_editor/releases/latest).

```bash
sudo dpkg -i linux-image-editor_*.deb
```

### Definir como Visualizador Padrão

Após instalar, execute o script incluído:

```bash
/opt/linux-image-editor/set-default.sh
```

### Desenvolvimento

```bash
flutter pub get
flutter run -d linux
```

### Licença

GPL-3.0. Veja LICENSE.
