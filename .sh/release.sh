#!/bin/bash
# Release unificado: bump de versão, build Linux, build Windows (GitHub) e publicação.
#
# Uso:
#   bash .sh/release.sh
#
# Requisitos:
#   - Flutter instalado
#   - gh autenticado (gh auth login)
#   - dpkg-deb

set -e

# shellcheck disable=SC1090
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

export PATH="$HOME/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
# shellcheck source=.sh/lib/version.sh
source "$SCRIPT_DIR/.sh/lib/version.sh"

GITHUB_REPO="vandreborba/linux_image_editor"
GITHUB_BRANCH="main"
APP_NAME="linux-image-editor"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$SCRIPT_DIR"

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Linux Image Editor - Release${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# ---------------------------------------------------------------------------
# Verificar gh
# ---------------------------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
    echo -e "${RED}ERRO: 'gh' não instalado. Instale: sudo apt install gh${NC}"
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo -e "${RED}ERRO: 'gh' não autenticado. Execute: gh auth login${NC}"
    exit 1
fi

# ---------------------------------------------------------------------------
# Bump automático de versão
# ---------------------------------------------------------------------------
CURRENT_FULL="$(get_pubspec_version_line)"
CURRENT_SEMVER="$(get_app_version "$CURRENT_FULL")"
CURRENT_BUILD="$(get_build_number "$CURRENT_FULL")"
NEW_SEMVER="$(bump_version_patch "$CURRENT_SEMVER")"
NEW_BUILD="$(bump_build_number "$CURRENT_BUILD")"
NEW_FULL="${NEW_SEMVER}+${NEW_BUILD}"

echo -e "${BLUE}Versão atual:${NC}  $CURRENT_FULL"
echo -e "${BLUE}Nova versão:${NC}   $NEW_FULL  (patch automático)"
echo ""
read -r -p "Continuar com a release? [S/n] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[sS]?$ ]] && [[ -n "$CONFIRM" ]]; then
    echo "Release cancelada."
    exit 0
fi
echo ""

set_pubspec_version "$SCRIPT_DIR" "$NEW_SEMVER" "$NEW_BUILD"
echo -e "${GREEN}✓ pubspec.yaml atualizado para $NEW_FULL${NC}"
echo ""

# ---------------------------------------------------------------------------
# Commit e push (código + versão, sem binários)
# ---------------------------------------------------------------------------
echo -e "${YELLOW}=== Commit e push ===${NC}"

# Restaurar binários ignorados se estavam staged
git reset HEAD -- release/*.deb release/windows/*.zip 2>/dev/null || true

git add -A
# Remover binários do staging
git reset HEAD -- release/*.deb release/windows/*.zip 2>/dev/null || true

if git diff --cached --quiet; then
    echo -e "${YELLOW}Nenhuma alteração de código para commitar (apenas versão).${NC}"
    git add pubspec.yaml
fi

if ! git diff --cached --quiet; then
    git commit -m "$(cat <<EOF
Bump versão para $NEW_FULL

EOF
)"
    echo -e "${GREEN}✓ Commit criado${NC}"
else
    echo -e "${YELLOW}Nada novo para commitar.${NC}"
fi

echo -e "${YELLOW}Enviando para origin/$GITHUB_BRANCH...${NC}"
git push origin "$GITHUB_BRANCH"
echo -e "${GREEN}✓ Push concluído${NC}"
echo ""

# ---------------------------------------------------------------------------
# Build Linux (.deb)
# ---------------------------------------------------------------------------
echo -e "${YELLOW}=== Build Linux (.deb) ===${NC}"
SKIP_OPEN_FOLDER=1 bash "$SCRIPT_DIR/.sh/build-deb.sh"
echo ""

# ---------------------------------------------------------------------------
# Build Windows (GitHub Actions)
# ---------------------------------------------------------------------------
echo -e "${YELLOW}=== Build Windows (GitHub Actions) ===${NC}"
bash "$SCRIPT_DIR/.sh/build-windows.sh" --no-prompt
echo ""

# ---------------------------------------------------------------------------
# Validar artefatos
# ---------------------------------------------------------------------------
DEB_FILE="$SCRIPT_DIR/release/${APP_NAME}_${NEW_SEMVER}_amd64.deb"
ZIP_FILE="$SCRIPT_DIR/release/windows/${APP_NAME}_windows_${NEW_SEMVER}.zip"
SET_DEFAULT="$SCRIPT_DIR/.sh/set-default.sh"
TAG="v${NEW_SEMVER}"

echo -e "${YELLOW}=== Validando artefatos ===${NC}"

MISSING=0
if [[ ! -f "$DEB_FILE" ]]; then
    echo -e "${RED}✗ .deb não encontrado: $DEB_FILE${NC}"
    MISSING=1
else
    echo -e "${GREEN}✓ $(basename "$DEB_FILE")${NC}"
fi

if [[ ! -f "$ZIP_FILE" ]]; then
    echo -e "${RED}✗ ZIP não encontrado: $ZIP_FILE${NC}"
    MISSING=1
else
    echo -e "${GREEN}✓ $(basename "$ZIP_FILE")${NC}"
fi

if [[ ! -f "$SET_DEFAULT" ]]; then
    echo -e "${RED}✗ set-default.sh não encontrado${NC}"
    MISSING=1
else
    echo -e "${GREEN}✓ set-default.sh${NC}"
fi

if [[ "$MISSING" -eq 1 ]]; then
    echo -e "${RED}ERRO: artefatos faltando. Release não criada.${NC}"
    exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# Criar release no GitHub
# ---------------------------------------------------------------------------
echo -e "${YELLOW}=== Criando release $TAG no GitHub ===${NC}"

NOTES_FILE="$(mktemp)"
cat > "$NOTES_FILE" <<EOF
## Linux Image Editor $TAG

### Linux

Baixe o `.deb` e instale com:

\`\`\`bash
sudo dpkg -i linux-image-editor_${NEW_SEMVER}_amd64.deb
\`\`\`

### Windows

Baixe o ZIP, extraia e execute o `.exe`.

### Definir como visualizador padrão (Linux)

\`\`\`bash
/opt/linux-image-editor/set-default.sh
\`\`\`
EOF

if gh release view "$TAG" --repo "$GITHUB_REPO" >/dev/null 2>&1; then
    echo -e "${RED}ERRO: release $TAG já existe no GitHub.${NC}"
    rm -f "$NOTES_FILE"
    exit 1
fi

gh release create "$TAG" \
    --repo "$GITHUB_REPO" \
    --title "Linux Image Editor $TAG" \
    --notes-file "$NOTES_FILE" \
    "$DEB_FILE" \
    "$ZIP_FILE" \
    "$SET_DEFAULT"

rm -f "$NOTES_FILE"

RELEASE_URL="https://github.com/$GITHUB_REPO/releases/tag/$TAG"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ✓ Release publicada com sucesso!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}URL:${NC} $RELEASE_URL"
echo ""
