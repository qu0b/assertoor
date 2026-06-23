# syntax=docker/dockerfile:1
FROM node:20-slim AS ui-builder
WORKDIR /src
COPY web-ui/package.json web-ui/package-lock.json ./web-ui/
RUN cd web-ui && npm ci
COPY web-ui/ ./web-ui/
COPY pkg/web/static/embed.go ./pkg/web/static/
RUN cd web-ui && npm run build

FROM golang:1.25 AS builder
WORKDIR /src
COPY go.sum go.mod ./
RUN go mod download
COPY . .
COPY --from=ui-builder /src/pkg/web/static/ ./pkg/web/static/
RUN make build

FROM ubuntu:latest
RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
  libssl-dev \
  ca-certificates \
  jq \
  git \
  curl \
  make \
  sudo \
  python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates
# Pre-install foundry to /opt/foundry so assertoor tests skip the runtime download
RUN /bin/bash -c '\
    mkdir -p /opt/foundry && \
    export HOME=/opt/foundry && \
    export SHELL=/bin/bash && \
    curl -L https://foundry.paradigm.xyz | bash && \
    /opt/foundry/.foundry/bin/foundryup && \
    ln -sf /opt/foundry/.foundry/bin/cast /usr/local/bin/cast && \
    ln -sf /opt/foundry/.foundry/bin/forge /usr/local/bin/forge && \
    ln -sf /opt/foundry/.foundry/bin/anvil /usr/local/bin/anvil && \
    chmod -R a+rx /opt/foundry/.foundry/bin/'
RUN groupadd -g 10001 assertoor && useradd -m -u 10001 -g assertoor assertoor
RUN echo "assertoor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/assertoor
WORKDIR /app
COPY --from=builder /src/bin/* /app/
RUN chown -R assertoor:assertoor /app
USER assertoor
ENTRYPOINT ["/app/assertoor"]
