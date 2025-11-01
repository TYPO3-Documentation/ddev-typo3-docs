[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/TYPO3-Documentation/ddev-typo3-docs/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/TYPO3-Documentation/ddev-typo3-docs/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/TYPO3-Documentation/ddev-typo3-docs)](https://github.com/TYPO3-Documentation/ddev-typo3-docs/commits)
[![release](https://img.shields.io/github/v/release/TYPO3-Documentation/ddev-typo3-docs)](https://github.com/TYPO3-Documentation/ddev-typo3-docs/releases/latest)

# DDEV TYPO3 Documentation (standalone)

## Overview

TYPO3 projects and extensions can use a common TYPO3 Documentation
rendering. It is based on the [ReST](https://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html) markup syntax
standard.

The documentation is rendered via the
[render-guides](https://docs.typo3.org/other/t3docs/render-guides/main/en-us/Index.html)
project, which is a PHP-based customization of the [phpDocumentor guides](https://github.com/phpDocumentor/guides)
sub-project.

**render-guides** offers a convenient docker image which allows to perform
local rendering.

That docker image is utilized by this DDEV addon to provide a documentation component to a
project.

Any documentation of a DDEV project adhering to the TYPO3 ReST syntax within a subdirectory `Documentation`
can then be accessed via the `https://<project>.ddev.site:1337/` sub-domain
and will show that rendered documentation.

The local server providing this rendered documentation is capable of
**hot-reloading**. That means, any changes made to the raw source `*.rst` files
will be immediately reflected in the browser.

That way, you do not need to manually re-trigger rendering of documentation
after every change, and you can have a browser-window next to your editing
interface of the ReST files to see your results in real-time, like WYSIWYG
(What You See Is What You Get).

## Installation

> [!CAUTION]
> The live rendering is currently experimental. Use at your own risk.
> Side effects can be: Deletion of files in `/Documentation/`, memory
> leaks on long runtime, resource exhaustion.
> Please report any bugs you find!


Prerequisites:

- A DDEV project directory with existing or fresh configuration
- A `Documentation/` subdirectory with ReST files as shown in
  [TYPO3 How To Document](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Index.html)
- A bash shell in your project directory ready to execute the following
  command:

```bash
ddev add-on get ddev/ddev-typo3-docs
ddev restart
```

> ![IMPORTANT]
> For now this add-on is not yet pushed to the official DDEV add-on
> registry, so you need to install it via:
> ```bash
> ddev add-on get https://github.com/TYPO3-Documentation/ddev-typo3-docs
> ```

> ![IMPORTANT]
> Also, the official docker image is not yet released with support of
> hot-reloading. To enable it, the project needs to be locally built
> and delivered with a local "typo3-docs:local" container (via `make
> vendor`). And then that container needs to be utilized:
> ```bash
> ddev dotenv set .ddev/.env.typo3-docs-build --render-guides-base-image="typo3-docs:local"
> ```

After installation, make sure to commit the `.ddev` directory to version control.

Then you can see your rendered documentation via:

```bash
ddev launch :1337
```

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev launch :1337` | Open rendered documentation in your browser (`https://<project>.ddev.site:1337`) |
| `ddev describe` | View service status and used ports for documentation |
| `ddev logs -s typo3-docs` | Check documentation logs |

## Configuration

Everything is aimed to be executed with zero-configuration.

However, you can adapt:

- HTTP(s) port of the local rendering server (default: 1337)
- Target documentation directory (default: Documentation)
- Additional "render-guides" CLI arguments
- Use Docker container (to test with local container builds)

This is achieved via ENV (Environment) variables
in your `.ddev/config.yaml` file:

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `RENDER_GUIDES_BASE_IMAGE` | `--render-guides-base-image` | `ghcr.io/typo3-documentation/render-guides:latest` |
| `RENDER_GUIDES_PORT` | `--render-guides-port` | `1337` |
| `RENDER_GUIDES_DOCS_PATH` | `--render-guides-docs-path` | `Documentation` |
| `RENDER_GUIDES_ARGS` | `--render-guides-args` | `--verbose` |

You can set these environment variables inside a file like
`.ddev/env.typo3-docs-build`:

```
RENDER_GUIDES_BASE_IMAGE="typo3-docs:local"
RENDER_GUIDES_PORT=4711
RENDER_GUIDES_DOCS_PATH=docs
RENDER_GUIDES_ARGS="--verbose --no-progress"
```

All arguments that can be passed through `RENDER_GUIDES_ARGS` on to
the container can be seen via:

```bash
docker run --rm -it --entrypoint sh -v ./:/project/ ghcr.io/typo3-documentation/render-guides:latest
php /opt/guides/bin/guides --help
```

## Credits

**Maintained by [@TYPO3-Documentation](https://github.com/TYPO3-Documentation)**