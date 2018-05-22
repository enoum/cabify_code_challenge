FROM bitwalker/alpine-elixir:1.6.1

ENV MIX_ENV=dev

WORKDIR /opt/app

COPY mix.* ./
COPY config ./config
RUN mix deps.get
RUN mix deps.compile

COPY . .
RUN mix compile

RUN mix escript.build

ENTRYPOINT ["/opt/app/cabify"]
