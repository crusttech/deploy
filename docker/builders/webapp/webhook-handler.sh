#!/usr/bin/env bash

set -eu

# parse endpoint (only works for POST)
read request
url="${request#POST }"
url="${url% HTTP/*}"

hmac=
digest=
clen=

# parse http headers
while [ 1 ]; do
  read header
  [[ "$header" =~ 'X-Hub-Signature' ]] && hmac=$(echo $header | cut -d= -f2 | tr -d ' \n\r');
  [[ "$header" =~ 'Content-Length'  ]] && clen=$(echo $header | cut -d: -f2 | tr -d ' \n\r');
  [[ "$header" == $'\r' ]] && break;
done

# read http payload
read -r -t 10 -n ${clen:-"0"} payload


# calculate sha1-hmac digest
digest=$(echo -n $payload | openssl sha1 -hmac $TRIGGER_TOKEN | cut -d= -f2 | tr -d ' \n')

if [[ $hmac == $digest ]]; then
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"
  echo "I'm Crust.\r\n\r\n"
  exit 0
fi;

echo -e "HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain\r\n\r\n"
echo "I'm not Crust.\r\n\r\n"
exit 1
