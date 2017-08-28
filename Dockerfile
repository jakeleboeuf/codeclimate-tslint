FROM mhart/alpine-node:6
LABEL maintainer "Kyle Holzinger <kylelholzinger@gmail.com>"

RUN adduser -u 9000 -D app

WORKDIR /usr/src/app

COPY engine.json package.json yarn.lock ./
COPY ./bin/ ./bin/

RUN npm install --global yarn && \
  apk --update add git jq && \
  yarn install && \
  jq <engine.json ".version = \"$(bin/version tslint)\"" > /tmp/engine.json && \
  mv {/tmp/,}engine.json && \
  bin/get-tslint-rules && \
  chown -R app:app . && \
  apk del --purge git jq && \
  rm -rf /var/cache/apk/* /tmp/* ~/.npm && \
  npm uninstall --global yarn

USER app

COPY . ./
RUN npm run build

VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/bin/analyze"]
