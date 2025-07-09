FROM registry.drycc.cc/drycc/go-dev

ENV HUGO_REPO=https://github.com/gohugoio/hugo \
  NODE_VERSION=22 \
  HUGO_VERSION=0.133.1

RUN install-stack node ${NODE_VERSION} \
  && curl -s -L ${HUGO_REPO}/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-$(dpkg --print-architecture).tar.gz | tar xvz -C /usr/local/bin hugo

CMD ["bash", "-c", "npm install postcss-cli; hugo"]
