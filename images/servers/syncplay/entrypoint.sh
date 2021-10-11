#!/bin/bash

args=()

if [ -n "${SALT:-}" ]; then
  args+="--salt=$SALT"
fi

if [ -n "${PORT:-}" ]; then
  args+="--port=$PORT"
fi

if [ -n "${ISOLATE:-}" ]; then
  args+="--isolate-rooms"
fi

if [ -n "${MOTD:-}" ]; then
  echo "$MOTD" >> /motd
  args+="--motd-file=/motd"
fi

if [ -n "${PASSWORD:-}" ]; then
  args+="--password=$PASSWORD"
fi

exec "syncplay-server" "${args[@]}" "$@"
