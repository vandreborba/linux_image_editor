# Guia de Release Automático

Este projeto usa GitHub Actions para automaticamente criar releases com o pacote .deb quando você cria uma tag.

## Forma Mais Fácil: Script Automático ⭐

Use o script que faz tudo automaticamente:

```bash
bash .sh/create-release.sh
```

O script vai:
1. ✅ Mostrar a versão atual
2. ✅ Pedir a nova versão
3. ✅ Atualizar o `build-deb.sh`
4. ✅ Criar commit
5. ✅ Criar e enviar a tag
6. ✅ Fazer push para o GitHub

Depois é só aguardar o GitHub Actions construir a release!

---

## Forma Manual

### 1. Atualize a versão no código

Edite `.sh/build-deb.sh` e atualize a versão:

```bash
APP_VERSION="1.2.0"  # Atualize para a nova versão
```

### 2. Commit e push das mudanças

```bash
git add .
git commit -m "Bump version to 1.2.0"
git push origin main
```

### 3. Crie e envie a tag

```bash
# Cria a tag (use o mesmo número da versão com 'v' na frente)
git tag v1.2.0

# Envia a tag para o GitHub
git push origin v1.2.0
```

---

## O que Acontece Automaticamente

O GitHub Actions vai automaticamente:
- ✅ Compilar o aplicativo Flutter
- ✅ Criar o pacote .deb
- ✅ Criar uma release no GitHub
- ✅ Fazer upload do .deb e set-default.sh

Você pode acompanhar o progresso em: `Actions` → `Build and Release`

A release estará disponível em:
```
https://github.com/vandreborba/linux_image_editor/releases/latest
```

---

## Verificar Releases Existentes

Liste todas as tags:
```bash
git tag -l
```

Deletar uma tag local (se necessário):
```bash
git tag -d v1.2.0
```

Deletar uma tag remota (se necessário):
```bash
git push origin --delete v1.2.0
```

## Formato de Versionamento

Use [Semantic Versioning](https://semver.org/):

- `v1.0.0` - Release inicial
- `v1.0.1` - Bug fixes
- `v1.1.0` - Novas funcionalidades (compatível)
- `v2.0.0` - Mudanças incompatíveis

## Troubleshooting

Se o workflow falhar, verifique:
1. A tag foi criada com `v` na frente? (ex: `v1.2.0`)
2. O arquivo `.sh/build-deb.sh` tem a mesma versão?
3. Verifique os logs em `Actions` no GitHub

## Releases Manualmente (sem automation)

Se preferir criar releases manualmente:

1. Build local: `bash .sh/build-deb.sh`
2. Vá em `Releases` → `Create a new release`
3. Escolha ou crie uma tag
4. Faça upload do .deb manualmente
5. Publique a release
