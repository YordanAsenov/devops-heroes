#!/bin/sh
echo "Set the variables"
CONFIG_FILE="/etc/ssl/openssl.cnf"
DAYS_VALID=365
CA_DIR="/ca"
CERTS_DIR="$CA_DIR/certs"
CSR_DIR="$CA_DIR/csr"

DOMAIN_NAME="devops-heroes.com"
CA_PRIVATE_KEY_DIR="/certificate-authority"
CA_KEY="$CA_PRIVATE_KEY_DIR/ca.key"
CA_CRT="$CERTS_DIR/ca.crt"

GITLAB_DOMAIN_NAME="gitlab.devops-heroes.com"
GITLAB_PRIVATE_KEY_DIR="/gitlab"
GITLAB_CERT_KEY="$GITLAB_PRIVATE_KEY_DIR/$GITLAB_DOMAIN_NAME.key"
GITLAB_CERT_CSR="$CSR_DIR/$GITLAB_DOMAIN_NAME.csr"
GITLAB_CERT_CRT="$CERTS_DIR/$GITLAB_DOMAIN_NAME.crt"
GITLAB_FULL_CHAIN_CERT_CRT="$CERTS_DIR/$GITLAB_DOMAIN_NAME.full-chain.crt"

REGISTRY_DOMAIN_NAME="registry.devops-heroes.com"
REGISTRY_PRIVATE_KEY_DIR="/registry"
REGISTRY_CERT_KEY="$REGISTRY_PRIVATE_KEY_DIR/$REGISTRY_DOMAIN_NAME.key"
REGISTRY_CERT_CSR="$CSR_DIR/$REGISTRY_DOMAIN_NAME.csr"
REGISTRY_CERT_CRT="$CERTS_DIR/$REGISTRY_DOMAIN_NAME.crt"
REGISTRY_FULL_CHAIN_CERT_CRT="$CERTS_DIR/$REGISTRY_DOMAIN_NAME.full-chain.crt"

# Check if certificates already exist
if [ -f "$GITLAB_CERT_CRT" ] && [ -f "$GITLAB_FULL_CHAIN_CERT_CRT" ] && [ -f "$REGISTRY_CERT_CRT" ] && [ -f "$REGISTRY_FULL_CHAIN_CERT_CRT" ]; then
  echo "Certificates already exist. Exiting."
  exit 0
fi

echo "Create the necessary directories"
mkdir -p $CA_PRIVATE_KEY_DIR $GITLAB_PRIVATE_KEY_DIR $REGISTRY_PRIVATE_KEY_DIR $CSR_DIR $CERTS_DIR

# --- Create the certificate authority  ---
echo "Generate the CA private key and certificate"
openssl genrsa -out "$CA_KEY" 4096
openssl req \
  -new -x509 \
  -days $DAYS_VALID \
  -key "$CA_KEY" \
  -out "$CA_CRT" \
  -config "$CONFIG_FILE" \
  -extensions v3_ca

sleep 1

# --- Create the Gitlab certificate ---
echo "Generate the private key and the CSR for Gitlab"
openssl genrsa -out "$GITLAB_CERT_KEY" 4096
openssl req \
  -new \
  -key "$GITLAB_CERT_KEY" \
  -out "$GITLAB_CERT_CSR" \
  -config "$CONFIG_FILE" \
  -subj "/CN=$GITLAB_DOMAIN_NAME"

echo "Sign the Gitlab certificate with the CA"
openssl x509 \
  -req \
  -days $DAYS_VALID \
  -in "$GITLAB_CERT_CSR" \
  -CA "$CA_CRT" \
  -CAkey "$CA_KEY" \
  -CAcreateserial \
  -out "$GITLAB_CERT_CRT" \
  -extfile "$CONFIG_FILE" \
  -extensions v3_gitlab

sleep 1

# --- Create the Registry certificate ---
echo "Generate the private key and the CSR for Registry"
openssl genrsa -out "$REGISTRY_CERT_KEY" 4096
openssl req \
  -new \
  -key "$REGISTRY_CERT_KEY" \
  -out "$REGISTRY_CERT_CSR" \
  -config "$CONFIG_FILE" \
  -subj "/CN=$REGISTRY_DOMAIN_NAME"

echo "Sign the Registry certificate with the CA"
openssl x509 \
  -req \
  -days $DAYS_VALID \
  -in "$REGISTRY_CERT_CSR" \
  -CA "$CA_CRT" \
  -CAkey "$CA_KEY" \
  -CAcreateserial \
  -out "$REGISTRY_CERT_CRT" \
  -extfile "$CONFIG_FILE" \
  -extensions v3_registry

sleep 1

# --- Create full chain certificates ---
echo "Creating full chain certificates"
cat $GITLAB_CERT_CRT $CA_CRT > $GITLAB_FULL_CHAIN_CERT_CRT
cat $REGISTRY_CERT_CRT $CA_CRT > $REGISTRY_FULL_CHAIN_CERT_CRT

# --- Print result  ---
echo
echo "Certificates generated in $CERTS_DIR:"
ls -l "$CERTS_DIR"

# --- Show checksum  ---
echo
echo $GITLAB_CERT_CRT: $(openssl x509 -noout -modulus -in $GITLAB_CERT_CRT | openssl md5)
echo $GITLAB_FULL_CHAIN_CERT_CRT: $(openssl x509 -noout -modulus -in $GITLAB_FULL_CHAIN_CERT_CRT | openssl md5)
echo $GITLAB_CERT_KEY: $(openssl rsa -noout -modulus -in $GITLAB_CERT_KEY | openssl md5)
echo $REGISTRY_CERT_CRT: $(openssl x509 -noout -modulus -in $REGISTRY_CERT_CRT | openssl md5)
echo $REGISTRY_FULL_CHAIN_CERT_CRT: $(openssl x509 -noout -modulus -in $REGISTRY_FULL_CHAIN_CERT_CRT | openssl md5)
echo $REGISTRY_CERT_KEY: $(openssl rsa -noout -modulus -in $REGISTRY_CERT_KEY | openssl md5)