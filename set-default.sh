#!/bin/bash

# Script para configurar Simple Print Tool como editor padrão de imagens

echo "========================================="
echo "Configurar como Editor Padrão"
echo "========================================="
echo ""

# Lista de tipos de imagem
TYPES=(
    "image/png"
    "image/jpeg"
    "image/jpg"
    "image/bmp"
    "image/gif"
    "image/webp"
)

echo "Configurando Simple Print Tool como editor padrão para:"
for type in "${TYPES[@]}"; do
    echo "  → $type"
    xdg-mime default simple_print_tool.desktop "$type"
done

echo ""
echo "✅ Configurado com sucesso!"
echo ""
echo "Agora quando você clicar em uma imagem no gerenciador de arquivos,"
echo "ela abrirá automaticamente no Simple Print Tool."
echo ""
