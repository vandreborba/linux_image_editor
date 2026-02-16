#!/bin/bash

# Script para criar uma nova release automaticamente
# Uso: bash .sh/create-release.sh

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Criar Nova Release${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Verifica se está no repositório git
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Erro: Não é um repositório git!${NC}"
    exit 1
fi

# Verifica se tem mudanças não commitadas
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠ Você tem mudanças não commitadas:${NC}"
    git status -s
    echo ""
    read -p "Deseja continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}Release cancelada.${NC}"
        exit 0
    fi
fi

# Pega a versão atual
CURRENT_VERSION=$(grep "APP_VERSION=" .sh/build-deb.sh | cut -d'"' -f2)
echo -e "${BLUE}Versão atual: ${CURRENT_VERSION}${NC}"
echo ""

# Pergunta a nova versão
echo -e "${YELLOW}Digite a nova versão (ex: 1.2.0):${NC}"
read -p "Nova versão: " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}❌ Versão não pode ser vazia!${NC}"
    exit 1
fi

# Valida formato da versão (x.y.z)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Formato inválido! Use o formato x.y.z (ex: 1.2.0)${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Resumo da release:${NC}"
echo -e "  Versão atual: ${CURRENT_VERSION}"
echo -e "  Nova versão:  ${NEW_VERSION}"
echo -e "  Tag:          v${NEW_VERSION}"
echo ""

read -p "Confirma a criação da release? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Release cancelada.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}📝 Atualizando versão no build-deb.sh...${NC}"

# Atualiza a versão no build-deb.sh
sed -i "s/APP_VERSION=\".*\"/APP_VERSION=\"$NEW_VERSION\"/" .sh/build-deb.sh

echo -e "${GREEN}✓ Versão atualizada${NC}"

# Mensagem de commit
COMMIT_MSG="Release v${NEW_VERSION}"

echo ""
echo -e "${YELLOW}Digite a mensagem de commit (ou Enter para usar '${COMMIT_MSG}'):${NC}"
read -p "Mensagem: " CUSTOM_MSG

if [ ! -z "$CUSTOM_MSG" ]; then
    COMMIT_MSG="$CUSTOM_MSG"
fi

echo ""
echo -e "${YELLOW}📦 Fazendo commit das mudanças...${NC}"

# Adiciona e commita
git add .sh/build-deb.sh
git commit -m "$COMMIT_MSG" || {
    echo -e "${YELLOW}⚠ Nada para commitar${NC}"
}

echo -e "${GREEN}✓ Commit criado${NC}"

echo ""
echo -e "${YELLOW}🏷️  Criando tag v${NEW_VERSION}...${NC}"

# Cria a tag
git tag -a "v${NEW_VERSION}" -m "Release v${NEW_VERSION}"

echo -e "${GREEN}✓ Tag criada${NC}"

echo ""
echo -e "${YELLOW}🚀 Enviando para o GitHub...${NC}"

# Push do commit
git push origin main || git push origin master || {
    echo -e "${RED}❌ Erro ao fazer push. Verifique o nome da branch principal.${NC}"
    exit 1
}

# Push da tag
git push origin "v${NEW_VERSION}"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ✓ Release criada com sucesso!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}O GitHub Actions está construindo a release agora.${NC}"
echo -e "${BLUE}Acompanhe em:${NC}"
echo -e "  ${YELLOW}https://github.com/vandreborba/linux_image_editor/actions${NC}"
echo ""
echo -e "${BLUE}A release estará disponível em:${NC}"
echo -e "  ${YELLOW}https://github.com/vandreborba/linux_image_editor/releases/tag/v${NEW_VERSION}${NC}"
echo ""

read -p "Pressione Enter para fechar..."
