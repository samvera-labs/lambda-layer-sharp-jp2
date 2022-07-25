FROM amazonlinux:2-with-sources

WORKDIR /build

RUN curl --silent --location https://rpm.nodesource.com/setup_16.x | bash -

RUN yum -y install nodejs

COPY * ./

RUN npm --no-optional --no-audit --progress=false install

RUN node ./node_modules/webpack/bin/webpack.js

RUN node -e "console.log(require('sharp'))"

RUN mkdir /dist && \
  echo "cp /build/dist/sharp-layer.zip /dist/sharp-layer.$(uname -m).zip" > /entrypoint.sh && \
  chmod +x /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"