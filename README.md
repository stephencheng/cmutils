# cmutils

Collection of apps.

## cmenvrc

Manage app secrets via Bitwarden Secrets Manager with encrypted local caching. Replaces hardcoded secrets in `.envrc` / shell rc files.

### Install

```bash
curl -sSfL https://raw.githubusercontent.com/stephencheng/cmutils/main/install-cmenvrc.sh | bash
```

Options:

```bash
# Install a specific version
VERSION=v0.1.0 curl -sSfL https://raw.githubusercontent.com/stephencheng/cmutils/main/install-cmenvrc.sh | bash

# Install to a custom directory
INSTALL_DIR=~/.local/bin curl -sSfL https://raw.githubusercontent.com/stephencheng/cmutils/main/install-cmenvrc.sh | bash
```

### Quick start

```bash
cmenvrc login            # set up access token + org ID
cmenvrc migrate .envrc   # auto-detect secrets, generate .cmenvrc.yaml + onboarding script
cmenvrc pull             # fetch secrets and cache locally
eval "$(cmenvrc env)"    # export secrets into current shell
cmenvrc --help           # see all commands
```
