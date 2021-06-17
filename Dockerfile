# FROM gcr.io/distroless/nodejs-debian10 as extension
FROM node:16-buster as extension
ARG VSCODE_RUST_VERSION
ARG RUST_ANALYZER_VERSION

WORKDIR /rust
RUN git clone https://github.com/rust-lang/vscode-rust.git \
 && cd ./vscode-rust \
 && git checkout "v${VSCODE_RUST_VERSION}" \
 && npm install --silent \
 && npm audit fix --force \
 && npm cache clean --force \
 && rm -rf node_modules package-lock.json \
 && npm install --silent \
 && npm install -g vsce --silent \
 && vsce package \
 && npm cache clean --force \
 && rm -rf ~/.npm \
 && mv *.vsix ../ \
 && cd ../ \
 && rm -rf /rust/vscode-rust

RUN git clone https://github.com/rust-analyzer/rust-analyzer.git \
 && cd ./rust-analyzer/editors/code \
 && git checkout "${RUST_ANALYZER_VERSION}" \
 && npm install --silent \
 && npm audit fix --force \
 && npm cache clean --force \
 && rm -rf node_modules package-lock.json \
 && npm install --silent \
 && npm install -g vsce --silent \
 && vsce package \
 && npm cache clean --force \
 && rm -rf ~/.npm \
 && mv *.vsix ../../../ \
 && cd ../../../ \
 && rm -rf /rust/rust-analyzer

FROM codercom/code-server:latest
ARG VCS_REF
ARG VSCODE_RUST_VERSION
ARG RUST_ANALYZER_VERSION
ARG RUST_VERSION
ARG RUSTUP_VERSION
ARG rustArch
ARG rustupSha256

LABEL maintainer="Novs Yama"
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/frost-tb-voo/docker-code-server-rs"

USER root
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=${RUST_VERSION} \
    RUSTUP_VERSION=${RUSTUP_VERSION}

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${rustArch}/rustup-init"; \
    curl -o rustup-init "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;
# linker cc is required
RUN apt-get -qq update \
 && apt-get -qq -y install --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
        libssl-dev \
 && apt-get -q -y autoclean \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists

ADD settings.json /home/coder/.local/share/code-server/User/settings.json
ADD settings.json /home/coder/.local/share/code-server/Machine
ADD settings.json /home/coder/project/.vscode/settings.json
COPY --from=extension /rust/rust-${VSCODE_RUST_VERSION}.vsix /home/coder/
COPY --from=extension /rust/rust-analyzer-0.4.0-dev.vsix /home/coder/
RUN chown -hR coder /home/coder

USER coder
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=$RUSTUP_HOME/bin:$CARGO_HOME/bin:~/.local/bin:$PATH

WORKDIR /home/coder/project
RUN code-server --install-extension /home/coder/rust-${VSCODE_RUST_VERSION}.vsix \
 && code-server --install-extension /home/coder/rust-analyzer-0.4.0-dev.vsix

RUN rustup -q component add rust-analysis --toolchain 1.52.1-x86_64-unknown-linux-gnu \
 && rustup -q component add rust-src --toolchain 1.52.1-x86_64-unknown-linux-gnu \
 && rustup -q component add rls --toolchain 1.52.1-x86_64-unknown-linux-gnu \
 && cargo -q install cargo-edit
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git \
 && cd ./rust-analyzer \
 && git checkout "${RUST_ANALYZER_VERSION}" \
 && cargo -q xtask install --server \
 && cd .. \
 && rm -rf ./rust-analyzer
# RUN mkdir -p ~/.local/bin \
#  && curl -L https://github.com/rust-analyzer/rust-analyzer/releases/download/2021-06-14/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer \
#  && chmod +x ~/.local/bin/rust-analyzer
