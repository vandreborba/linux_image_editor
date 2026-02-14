#!/bin/bash

# Script para empacotar o Linux Image Editor para distribuição
# Execute: bash package.sh

set -e

echo "========================================="
echo "   Empacotando Linux Image Editor"
echo "========================================="
echo ""

# Obtém o diretório atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="1.0.0"
PACKAGE_NAME="simple_print_tool_${VERSION}_linux_x64"
PACKAGE_DIR="$SCRIPT_DIR/$PACKAGE_NAME"

# Verifica se o build existe, senão compila
if [ ! -f "$SCRIPT_DIR/build/linux/x64/release/bundle/simple_print_tool" ]; then
    echo "📦 Build não encontrado. Compilando..."
    flutter build linux --release
    
    if [ $? -ne 0 ]; then
        echo "❌ Falha na compilação!"
        exit 1
    fi
    echo ""
fi

# Remove pacote anterior se existir
rm -rf "$PACKAGE_DIR"
rm -f "$PACKAGE_DIR.tar.gz"

# Cria estrutura do pacote
echo "📁 Criando estrutura do pacote..."
mkdir -p "$PACKAGE_DIR"

# Copia bundle compilado
cp -r "$SCRIPT_DIR/build/linux/x64/release/bundle"/* "$PACKAGE_DIR/"

# Copia scripts de instalação
cp "$SCRIPT_DIR/install.sh" "$PACKAGE_DIR/"
cp "$SCRIPT_DIR/README.md" "$PACKAGE_DIR/"

# Cria README de instalação simplificado
cat > "$PACKAGE_DIR/INSTALL.txt" <<'EOF'
========================================
Linux Image Editor - INSTALAÇÃO
========================================

REQUISITOS:
- Ubuntu 22.04+ (ou distribuição baseada em Debian/Ubuntu)
- GTK3 instalado (geralmente já vem instalado)

INSTALAÇÃO:

1. Extraia este arquivo

2. Abra o terminal nesta pasta

3. Execute:
   sudo bash install.sh

4. (Opcional) Configure como editor padrão:
   xdg-mime default simple_print_tool.desktop image/png
   xdg-mime default simple_print_tool.desktop image/jpeg

5. Pronto! Execute com:
   simple-print-tool
   
   Ou procure "Linux Image Editor" no menu de aplicativos

COMO USAR:
- Tire um screenshot (Print Screen)
- Abra o Linux Image Editor
- A imagem será colada automaticamente
- Edite e salve (Ctrl+S)

========================================
EOF

# Compacta tudo
echo "📦 Compactando pacote..."
cd "$SCRIPT_DIR"
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"

# Calcula tamanho
SIZE=$(du -h "$PACKAGE_NAME.tar.gz" | cut -f1)

echo ""
echo "========================================="
echo "✅ Pacote criado com sucesso!"
echo "========================================="
echo ""
echo "📦 Arquivo: $PACKAGE_NAME.tar.gz"
echo "💾 Tamanho: $SIZE"
echo "📍 Local: $SCRIPT_DIR"
echo ""
echo "Para instalar em outro PC:"
echo "1. Copie o arquivo .tar.gz para o outro PC"
echo "2. Extraia: tar -xzf $PACKAGE_NAME.tar.gz"
echo "3. Entre na pasta: cd $PACKAGE_NAME"
echo "4. Instale: sudo bash install.sh"
echo ""

# Remove diretório temporário (mantém só o .tar.gz)
rm -rf "$PACKAGE_DIR"
