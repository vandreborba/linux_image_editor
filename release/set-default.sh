#!/bin/bash

# Script para configurar Linux Image Editor como aplicativo padrão para imagens
# Uso: bash .sh/set-default.sh

DESKTOP_FILE="linux-image-editor.desktop"

echo "========================================"
echo "  Linux Image Editor - Configuração"
echo "========================================"
echo ""

# Verifica se o aplicativo está instalado
if [ ! -f "/usr/share/applications/$DESKTOP_FILE" ]; then
    echo "❌ Linux Image Editor não está instalado!"
    echo ""
    echo "Instale primeiro com:"
    echo "  bash .sh/build-deb.sh"
    echo "  sudo dpkg -i build/deb/linux-image-editor_*.deb"
    echo ""
    read -p "Pressione Enter para fechar..."
    exit 1
fi

echo "✓ Aplicativo encontrado"
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
    "image/x-bmp"
    "image/x-png"
    "image/x-ico"
)

echo "Configurando tipos MIME..."
echo ""

# Configura cada tipo MIME
for mime_type in "${MIME_TYPES[@]}"; do
    echo "  → $mime_type"
    xdg-mime default "$DESKTOP_FILE" "$mime_type" 2>/dev/null || true
done

echo ""
echo "✓ Configuração concluída!"
echo ""
echo "Linux Image Editor agora é o aplicativo padrão para abrir imagens."
echo ""
echo "Você pode verificar com:"
echo "  xdg-mime query default image/png"
echo "  xdg-mime query default image/jpeg"
echo ""
echo "Para reverter, use o gerenciador de aplicativos do seu sistema"
echo "ou execute: xdg-mime default <outro-app>.desktop image/png"
echo ""
read -p "Pressione Enter para fechar..."
