#!/bin/bash

# Script para compilar e criar pacote .deb do Linux Image Editor
# Uso: bash .sh/build-deb.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Informações do pacote
APP_NAME="linux_image_editor"
APP_DISPLAY_NAME="Linux Image Editor"
APP_VERSION="1.0.0"
APP_DESCRIPTION="Editor de imagens rápido para Linux"
APP_MAINTAINER="Vandre <vandre@example.com>"
APP_HOMEPAGE="https://github.com/vandre/linux-image-editor"

# Diretórios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
DEB_DIR="$BUILD_DIR/deb"
DEB_PKG_DIR="$DEB_DIR/${APP_NAME}_${APP_VERSION}_amd64"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Linux Image Editor - Build .deb${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Limpa build anterior
echo -e "${YELLOW}🧹 Limpando builds anteriores...${NC}"
cd "$SCRIPT_DIR"
flutter clean
rm -rf "$DEB_DIR"

# Obtém dependências
echo -e "${YELLOW}📦 Obtendo dependências...${NC}"
flutter pub get

# Compila o aplicativo
echo -e "${YELLOW}🔨 Compilando aplicativo Flutter...${NC}"
flutter build linux --release

# Verifica se a compilação foi bem-sucedida
if [ ! -f "$BUILD_DIR/linux/x64/release/bundle/${APP_NAME}" ] && [ ! -f "$BUILD_DIR/linux/x64/release/bundle/simple_print_tool" ]; then
    echo -e "${RED}❌ Erro: Executável não encontrado!${NC}"
    exit 1
fi

# Detecta o nome do executável
if [ -f "$BUILD_DIR/linux/x64/release/bundle/simple_print_tool" ]; then
    EXEC_NAME="simple_print_tool"
else
    EXEC_NAME="${APP_NAME}"
fi

echo -e "${YELLOW}📦 Criando estrutura do pacote .deb...${NC}"

# Cria estrutura de diretórios do pacote .deb
mkdir -p "$DEB_PKG_DIR/DEBIAN"
mkdir -p "$DEB_PKG_DIR/opt/$APP_NAME"
mkdir -p "$DEB_PKG_DIR/usr/share/applications"
mkdir -p "$DEB_PKG_DIR/usr/share/pixmaps"
mkdir -p "$DEB_PKG_DIR/usr/local/bin"

# Copia o bundle completo
echo -e "${YELLOW}  → Copiando arquivos do aplicativo...${NC}"
cp -r "$BUILD_DIR/linux/x64/release/bundle"/* "$DEB_PKG_DIR/opt/$APP_NAME/"

# Renomeia o executável se necessário
if [ "$EXEC_NAME" != "$APP_NAME" ]; then
    mv "$DEB_PKG_DIR/opt/$APP_NAME/$EXEC_NAME" "$DEB_PKG_DIR/opt/$APP_NAME/$APP_NAME"
fi

# Cria script para definir como aplicativo padrão
echo -e "${YELLOW}  → Criando script set-default.sh...${NC}"
cat > "$DEB_PKG_DIR/opt/$APP_NAME/set-default.sh" <<'SETDEFAULT'
#!/bin/bash

# Script para configurar Linux Image Editor como aplicativo padrão para imagens

DESKTOP_FILE="linux_image_editor.desktop"

echo "========================================"
echo "  Configurando aplicativo padrão"
echo "========================================"
echo ""

# Lista de tipos MIME para imagens
MIME_TYPES=(
    "image/png"
    "image/jpeg"
    "image/jpg"
    "image/bmp"
    "image/gif"
    "image/webp"
    "image/tiff"
    "image/svg+xml"
)

# Configura cada tipo MIME
for mime_type in "${MIME_TYPES[@]}"; do
    echo "Configurando $mime_type..."
    xdg-mime default "$DESKTOP_FILE" "$mime_type" 2>/dev/null || true
done

echo ""
echo "✓ Linux Image Editor configurado como aplicativo padrão!"
echo ""
echo "Você pode verificar com:"
echo "  xdg-mime query default image/png"
echo ""
SETDEFAULT

chmod +x "$DEB_PKG_DIR/opt/$APP_NAME/set-default.sh"

# Cria arquivo de controle do .deb
echo -e "${YELLOW}  → Criando arquivo de controle...${NC}"
cat > "$DEB_PKG_DIR/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $APP_VERSION
Section: graphics
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libglib2.0-0, libc6
Maintainer: $APP_MAINTAINER
Description: $APP_DESCRIPTION
 Editor de imagens simples e rápido desenvolvido em Flutter.
 Permite abrir, editar e anotar imagens com ferramentas básicas.
Homepage: $APP_HOMEPAGE
EOF

# Cria script de pós-instalação
echo -e "${YELLOW}  → Criando scripts de instalação...${NC}"
cat > "$DEB_PKG_DIR/DEBIAN/postinst" <<'EOF'
#!/bin/bash
set -e

# Cria link simbólico
if [ ! -L /usr/local/bin/linux_image_editor ]; then
    ln -sf /opt/linux_image_editor/linux_image_editor /usr/local/bin/linux_image_editor
fi

# Atualiza cache de aplicativos
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications || true
fi

# Atualiza cache MIME
if command -v update-mime-database >/dev/null 2>&1; then
    update-mime-database /usr/share/mime || true
fi

echo ""
echo "✓ Linux Image Editor instalado com sucesso!"
echo "  Execute com: linux_image_editor"
echo ""
echo "Para definir como aplicativo padrão para imagens:"
echo "  linux_image_editor --set-default"
echo "  ou execute: bash /opt/linux_image_editor/set-default.sh"
echo ""

exit 0
EOF

chmod +x "$DEB_PKG_DIR/DEBIAN/postinst"

# Cria script de remoção
cat > "$DEB_PKG_DIR/DEBIAN/prerm" <<'EOF'
#!/bin/bash
set -e

# Remove link simbólico
if [ -L /usr/local/bin/linux_image_editor ]; then
    rm -f /usr/local/bin/linux_image_editor
fi

exit 0
EOF

chmod +x "$DEB_PKG_DIR/DEBIAN/prerm"

# Cria arquivo .desktop
echo -e "${YELLOW}  → Criando arquivo .desktop...${NC}"
cat > "$DEB_PKG_DIR/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_DISPLAY_NAME
Comment=$APP_DESCRIPTION
Exec=/opt/$APP_NAME/$APP_NAME %f
Icon=$APP_NAME
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;Viewer;
MimeType=image/png;image/jpeg;image/jpg;image/bmp;image/gif;image/webp;image/tiff;image/svg+xml;image/x-bmp;image/x-png;image/x-ico;
StartupNotify=true
StartupWMClass=$APP_NAME
Keywords=image;photo;picture;edit;editor;viewer;
EOF

# Cria ícone (placeholder - você pode substituir por um ícone real)
echo -e "${YELLOW}  → Criando ícone...${NC}"
# Cria um ícone SVG simples como placeholder
cat > "$DEB_PKG_DIR/usr/share/pixmaps/$APP_NAME.svg" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <rect width="64" height="64" rx="8" fill="#4A90E2"/>
  <path d="M20 16 L44 16 L44 48 L20 48 Z" fill="white" opacity="0.9"/>
  <path d="M24 22 L40 22 M24 28 L40 28 M24 34 L35 34" stroke="#4A90E2" stroke-width="2" stroke-linecap="round"/>
  <circle cx="48" cy="48" r="12" fill="#E94235"/>
  <path d="M44 48 L52 48 M48 44 L48 52" stroke="white" stroke-width="2" stroke-linecap="round"/>
</svg>
EOF

# Define permissões corretas
echo -e "${YELLOW}  → Configurando permissões...${NC}"
chmod +x "$DEB_PKG_DIR/opt/$APP_NAME/$APP_NAME"
find "$DEB_PKG_DIR" -type d -exec chmod 755 {} \;
find "$DEB_PKG_DIR" -type f -exec chmod 644 {} \;
chmod +x "$DEB_PKG_DIR/opt/$APP_NAME/$APP_NAME"
chmod +x "$DEB_PKG_DIR/DEBIAN/postinst"
chmod +x "$DEB_PKG_DIR/DEBIAN/prerm"

# Constrói o pacote .deb
echo -e "${YELLOW}🔧 Construindo pacote .deb...${NC}"
cd "$DEB_DIR"
dpkg-deb --build --root-owner-group "${APP_NAME}_${APP_VERSION}_amd64"

# Verifica se o pacote foi criado
DEB_FILE="$DEB_DIR/${APP_NAME}_${APP_VERSION}_amd64.deb"
if [ -f "$DEB_FILE" ]; then
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}   ✓ Pacote .deb criado com sucesso!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo -e "${BLUE}Localização:${NC} $DEB_FILE"
    echo -e "${BLUE}Tamanho:${NC} $(du -h "$DEB_FILE" | cut -f1)"
    echo ""
    echo -e "${YELLOW}Para instalar:${NC}"
    echo -e "  sudo dpkg -i $DEB_FILE"
    echo -e "  sudo apt-get install -f  ${NC}# Se houver dependências faltando"
    echo ""
    echo -e "${YELLOW}Para desinstalar:${NC}"
    echo -e "  sudo apt-get remove $APP_NAME"
    echo ""
    
    # Informações do pacote
    echo -e "${BLUE}Informações do pacote:${NC}"
    dpkg-deb --info "$DEB_FILE"
else
    echo -e "${RED}❌ Erro ao criar pacote .deb${NC}"
    exit 1
fi
