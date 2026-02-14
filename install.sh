#!/bin/bash

# Script de instalação do Linux Image Editor
# Execute com: sudo bash install.sh

set -e

echo "========================================="
echo "   Linux Image Editor - Instalação"
echo "========================================="
echo ""

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Por favor, execute como root (sudo bash install.sh)"
    exit 1
fi

# Obtém o diretório atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verifica se o build existe
if [ ! -f "$SCRIPT_DIR/build/linux/x64/release/bundle/simple_print_tool" ]; then
    echo "❌ Executável não encontrado!"
    echo ""
    echo "Compilando agora..."
    sudo -u ${SUDO_USER:-$USER} flutter build linux --release
    
    if [ $? -ne 0 ]; then
        echo "❌ Falha na compilação!"
        exit 1
    fi
fi

echo "📦 Instalando no sistema..."
# Remove instalação anterior se existir
rm -rf /opt/simple_print_tool

# Cria diretório de instalação
mkdir -p /opt/simple_print_tool

# Copia todo o bundle
echo "  → Copiando arquivos..."
cp -r "$SCRIPT_DIR/build/linux/x64/release/bundle"/* /opt/simple_print_tool/

# Cria script wrapper em /usr/local/bin
echo "📝 Criando comando global..."
cat > /usr/local/bin/simple-print-tool <<'EOF'
#!/bin/bash
cd /opt/simple_print_tool
exec ./simple_print_tool "$@"
EOF

chmod +x /usr/local/bin/simple-print-tool

# Obtém o nome de usuário real (não root)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$REAL_USER)

# Cria/atualiza arquivo .desktop
echo "🖥️  Instalando atalho do menu..."
cat > "$USER_HOME/.local/share/applications/simple_print_tool.desktop" <<EOF
[Desktop Entry]
Name=Linux Image Editor
GenericName=Image Editor
Comment=Editor de imagens simples para screenshots
Exec=/usr/local/bin/simple-print-tool %f
Icon=simple_print_tool
Terminal=false
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;
MimeType=image/png;image/jpeg;image/jpg;image/bmp;image/gif;image/webp;
Keywords=screenshot;image;editor;paint;annotate;
StartupNotify=true
EOF

chown $REAL_USER:$REAL_USER "$USER_HOME/.local/share/applications/simple_print_tool.desktop"
chmod +x "$USER_HOME/.local/share/applications/simple_print_tool.desktop"

# Atualiza banco de dados de aplicativos
echo "🔄 Atualizando sistema..."
sudo -u $REAL_USER update-desktop-database "$USER_HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo "========================================="
echo "✅ Instalação concluída com sucesso!"
echo "========================================="
echo ""
echo "📍 Instalado em: /opt/simple_print_tool"
echo "🚀 Comando: simple-print-tool"
echo ""
echo "Para configurar como editor padrão:"
echo "  xdg-mime default simple_print_tool.desktop image/png"
echo "  xdg-mime default simple_print_tool.desktop image/jpeg"
echo ""
echo "Ou execute este comando para configurar tudo:"
echo "  sudo bash install.sh --set-default"
echo ""
