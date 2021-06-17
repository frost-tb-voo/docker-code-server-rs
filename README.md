# docker-code-server-rs
[![](https://img.shields.io/travis/frost-tb-voo/docker-code-server-rs/master.svg?style=flat-square)](https://travis-ci.org/frost-tb-voo/docker-code-server-rs/)
[![GitHub stars](https://img.shields.io/github/stars/frost-tb-voo/docker-code-server-rs.svg?style=flat-square)](https://github.com/frost-tb-voo/docker-code-server-rs/stargazers)
[![GitHub license](https://img.shields.io/github/license/frost-tb-voo/docker-code-server-rs.svg?style=flat-square)](https://github.com/frost-tb-voo/docker-code-server-rs/blob/master/LICENSE)
[![Docker pulls](https://img.shields.io/docker/pulls/novsyama/code-server-rs.svg?style=flat-square)](https://hub.docker.com/r/novsyama/code-server-rs)
[![Docker image-size](https://img.shields.io/docker/image-size/novsyama/code-server-rs.svg?style=flat-square)](https://hub.docker.com/r/novsyama/code-server-rs)
[![Docker layers](https://img.shields.io/microbadger/layers/novsyama/code-server-rs.svg?style=flat-square)](https://microbadger.com/images/novsyama/code-server-rs)

An unofficial extended VSCode [code-server](https://github.com/cdr/code-server) image for latest rust with [vscode-rust](https://github.com/rust-lang/vscode-rust) and [rust-analyzer](https://github.com/rust-analyzer).
See [novsyama/code-server-rs](https://hub.docker.com/r/novsyama/code-server-rs/)

## How

```bash
PROJECT_DIR=<workspace absolute path>

sudo docker pull novsyama/code-server-rs
sudo docker run --name=vscode --net=host -d \
 -v "${PROJECT_DIR}:/home/coder/project" \
 -w /home/coder/project \
 --security-opt "seccomp:unconfined" \
 novsyama/code-server-rs \
 code-server \
 --auth none
```

And open http://localhost:8080 with your favorites browser.
For detail options, see [code-server](https://github.com/cdr/code-server).

### Pathes of vscode code-server
If you want to preserve the settings and extensions, please mount following pathes with `-v` option of `docker run` command.

- Home : /home/coder
- Extension path : ~/.local/share/code-server/extensions
- Settings path : ~/.local/share/code-server/User/settings.json
- RUSTUP_HOME=/usr/local/rustup
- CARGO_HOME=/usr/local/cargo

### Install more extensions
- Download .vsix file from https://marketplace.visualstudio.com/.
- Put .vsix file into your project directory.
- Start the code-server container.
- Go to http://localhost:8080 and open the terminal and type
  - `code-server --install-extension $vsix_filepath`

## Similar official functionality in vscode
[Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)

This requires local installed visual studio code.

## Contact
Please open an issue:

https://github.com/frost-tb-voo/docker-code-server-rs/issues

And mension to @frost-tb-voo.
