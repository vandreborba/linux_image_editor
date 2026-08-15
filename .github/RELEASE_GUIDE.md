# Guia de Release

Um comando cria bump de versão, build Linux, build Windows e publica a release no GitHub.

## Release automática

```bash
bash .sh/release.sh
```

O script vai:

1. Incrementar a versão automaticamente (patch + build number) no `pubspec.yaml`
   - Exemplo: `1.0.0+6` → `1.0.1+7`
2. Pedir confirmação (`[S/n]`)
3. Commitar alterações de código + versão e fazer push em `main`
4. Compilar o pacote `.deb` localmente
5. Disparar o build Windows no GitHub Actions e aguardar (~10–15 min)
6. Criar a release no GitHub com:
   - `linux-image-editor_X.Y.Z_amd64.deb`
   - `linux-image-editor_windows_X.Y.Z.zip`
   - `set-default.sh`

Requisitos:

- Flutter instalado
- `gh` autenticado (`gh auth login`)
- `dpkg-deb` (pacote `dpkg-dev`)

Release disponível em:

```
https://github.com/vandreborba/linux_image_editor/releases/latest
```

## Builds individuais

```bash
# Apenas .deb (Linux)
bash .sh/build-deb.sh

# Apenas Windows (via GitHub Actions)
bash .sh/build-windows.sh
```

**Importante:** o build Windows usa o código do último push em `main`. O `release.sh` faz o push antes do build Windows automaticamente.

## Versionamento

- Fonte única: `pubspec.yaml` (`version: X.Y.Z+N`)
- Tag da release: `vX.Y.Z` (sem build number)
- O `release.sh` incrementa sempre o patch (`+0.0.1`) e o build number (`+1`)

## Binários no git

Os arquivos `.deb` e `.zip` **não** são commitados — ficam em `release/` localmente e são enviados direto na release do GitHub.

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `gh` não autenticado | `gh auth login` |
| Build Windows falhou | Ver logs em Actions → Build Windows |
| Release já existe | A tag `vX.Y.Z` já foi publicada; bump nova versão |
| `.deb` não encontrado | Verificar `flutter build linux` e `dpkg-deb` |

## Formato de versionamento

[Semantic Versioning](https://semver.org/):

- `v1.0.0` — release inicial
- `v1.0.1` — correções
- `v1.1.0` — novas funcionalidades
- `v2.0.0` — mudanças incompatíveis

O `release.sh` usa incremento **patch** por padrão.
