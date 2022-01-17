#!/usr/bin/env bash
set -e
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source "$SCRIPT_DIR/.env"

create_certificates()
{
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  # Generating public and private keys for token signing
  echo "Generating public and private keys for token signing"
  docker run -v ${DIR}/security/:/etc/kafka/secrets/ -u0 confluentinc/cp-server:${CONFLUENT_VERSION} bash -c "mkdir -p /etc/kafka/secrets/keypair; openssl genrsa -out /etc/kafka/secrets/keypair/keypair.pem 2048; openssl rsa -in /etc/kafka/secrets/keypair/keypair.pem -outform PEM -pubout -out /etc/kafka/secrets/keypair/public.pem && chown -R $(id -u $USER):$(id -g $USER) /etc/kafka/secrets/keypair"

  # Enable Docker appuser to read files when created by a different UID
  echo -e "Setting insecure permissions on some files in ${DIR}/../security for demo purposes\n"
  chmod 644 ${DIR}/security/keypair/keypair.pem
}

create_certificates