# Scripts de Build e Configuração - LinuxImageQuickEdit

Esta pasta contém scripts para compilar, empacotar e configurar o LinuxImageQuickEdit.

## Scripts disponíveis

### 1. `build-deb.sh` - Compilar e criar pacote .deb

Compila o aplicativo Flutter e cria um pacote .deb pronto para instalação.

```bash
bash .sh/build-deb.sh
```

**O que faz:**
- Limpa builds anteriores
- Obtém dependências do Flutter
- Compila o app para Linux (release)
- Cria estrutura do pacote .deb
- Gera scripts de instalação/remoção
- Cria ícone e arquivo .desktop
- Gera o pacote final em `build/deb/liqe_1.0.0_amd64.deb`

### 2. `set-default.sh` - Configurar como aplicativo padrão

Define o LinuxImageQuickEdit como aplicativo padrão para abrir imagens.

```bash
bash .sh/set-default.sh
```

**Pré-requisito:** O aplicativo deve estar instalado primeiro.

## Fluxo completo de instalação

```bash
# 1. Compilar e criar pacote .deb
bash .sh/build-deb.sh

# 2. Instalar o pacote
sudo dpkg -i build/deb/liqe_1.0.0_amd64.deb

# 3. (Opcional) Configurar como aplicativo padrão
bash .sh/set-default.sh
# OU
bash /opt/liqe/set-default.sh
```

## Comandos após instalação

```bash
# Executar o aplicativo
liqe

# Abrir uma imagem específica
liqe /caminho/para/imagem.png

# Verificar aplicativo padrão atual
xdg-mime query default image/png

# Desinstalar
sudo apt-get remove liqe
```

## Formatos de imagem suportados

O aplicativo será configurado como padrão para:
- PNG (image/png)
- JPEG/JPG (image/jpeg)
- BMP (image/bmp)
- GIF (image/gif)
- WebP (image/webp)
- TIFF (image/tiff)
- SVG (image/svg+xml)
- ICO (image/x-ico)

## Informações do pacote

- **Nome do pacote:** liqe
- **Nome de exibição:** LinuxImageQuickEdit
- **Comando:** liqe
- **Instalação:** /opt/liqe/
- **Versão:** 1.0.0

## Troubleshooting

### Erro ao instalar: dependências faltando
```bash
sudo apt-get install -f
```

### Aplicativo não abre imagens por padrão
```bash
bash .sh/set-default.sh
```

### Remover configuração de aplicativo padrão
Use as configurações do sistema ou execute:
```bash
xdg-mime default org.gnome.eog.desktop image/png  # Exemplo com Eye of GNOME
```
