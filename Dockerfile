FROM trenpixster/elixir

RUN mkdir /nodejs && curl https://nodejs.org/dist/v6.3.0/node-v6.3.0-linux-x64.tar.gz | tar xvzf - -C /nodejs --strip-components=1

ENV PATH $PATH:/nodejs/bin:/elixir/bin
ENV HOME /tanx
ENV MIX_ENV prod
WORKDIR ${HOME}

COPY mix.* ${HOME}/
RUN /elixir/bin/mix local.hex --force && \
    /elixir/bin/mix local.rebar --force && \
    /elixir/bin/mix deps.get && \
    /elixir/bin/mix deps.compile

COPY package.json ${HOME}/
RUN /nodejs/bin/npm install

COPY . ${HOME}
RUN /elixir/bin/mix compile && \
    ./node_modules/brunch/bin/brunch build --production && \
    /elixir/bin/mix phoenix.digest

EXPOSE 8080
ENTRYPOINT /elixir/bin/mix phoenix.server

ARG TANX_BUILD_ID=unknown
ENV TANX_BUILD_ID ${TANX_BUILD_ID:-unknown}
