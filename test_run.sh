#!/bin/bash

# Script de teste rápido do Simple Print Tool
# Este script cria uma imagem de teste e abre no editor

echo "==================================="
echo "Simple Print Tool - Teste Rápido"
echo "==================================="
echo ""

# Verifica se o ImageMagick está instalado
if ! command -v convert &> /dev/null; then
    echo "⚠️  ImageMagick não encontrado. Instalando..."
    sudo apt-get install imagemagick -y
fi

# Cria uma imagem de teste
TEST_IMAGE="/tmp/test_screenshot.png"

echo "📸 Criando imagem de teste..."
convert -size 800x600 xc:white \
    -fill black -pointsize 48 -gravity center \
    -annotate +0-100 "Simple Print Tool" \
    -annotate +0-50 "Teste de Edição" \
    -annotate +0+0 "🎨" \
    -annotate +0+50 "Desenhe aqui!" \
    "$TEST_IMAGE"

echo "✅ Imagem de teste criada: $TEST_IMAGE"
echo ""
echo "🚀 Abrindo Simple Print Tool..."
echo ""

# Executa o app
flutter run -d linux lib/main.dart -- "$TEST_IMAGE"
