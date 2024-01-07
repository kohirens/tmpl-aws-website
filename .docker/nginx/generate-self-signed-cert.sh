#!/bin/bash -e
#
# This is a modified version of, see:
#   https://samcaldwell.net/index.php/technical-articles/3-how-to-articles/173-how-to-generate-self-signed-ssltls-certificates-with-no-user-interaction
# generateSelfSignedCert
# (c) 2014 Sam Caldwell. Public Domain
#
# See later: https://security.stackexchange.com/questions/74345/provide-subjectaltname-to-openssl-directly-on-the-command-line
# To add SANS, see: https://security.stackexchange.com/a/159537

KEY_FILE=/etc/ssl/private/self-signed-key.pem
CSR_FILE=/etc/ssl/self-signed-request.pem
CRT_FILE=/etc/ssl/certs/self-signed-cert.pem
OS_CA_FILE=/etc/ssl/certs/ca-certificates.crt
CA_CRT=/etc/ssl/certs/ca.crt
CA_KEY=/etc/ssl/certs/ca.key
SUBJ="/C=US/ST=Michigan/L=Detroit/O=Acme, Inc/OU=Team Ultra/CN=nginx.docker"
CA_SUBJ="/C=US/ST=Michigan/L=Detroit/O=Acme, LLC/CN=Acme Root CA"
SANS="subjectAltName=DNS:nginx.docker,DNS:localhost,DNS:localhost.dev"
DAYS=365
EC_LEVEL=2048

mkdir -p /etc/ssl/private/ /etc/ssl/certs/

printf "\n%s\n" "make a CA key and crt..."
openssl genrsa -out "${CA_KEY}" "${EC_LEVEL}"
openssl req -new -x509 -days "${DAYS}" -key "${CA_KEY}" -subj "${CA_SUBJ}" -out "${CA_CRT}"

# NOTE: The `-addext` currently does not do anything as I still have to pass the SAN to the signing.
printf "\n%s" "make a CSR...\n"
openssl req \
    -newkey rsa:"${EC_LEVEL}" \
    -nodes \
    -addext "${SANS}" \
    -keyout ${KEY_FILE} \
    -subj "${SUBJ}" \
    -out "${CSR_FILE}" || exit 1

# Debug: Show whats in the request
openssl req -in ${CSR_FILE} -text -noout

printf "\n%s\n" "signing CSR..."

openssl x509 \
    -req \
    -extfile <(printf "${SANS}") \
    -days "${DAYS}" \
    -in "${CSR_FILE}" \
    -CA "${CA_CRT}" \
    -CAkey "${CA_KEY}" \
    -CAcreateserial \
    -out "${CRT_FILE}" || exit 1

# Debug: Show whats in the cert
openssl x509 -in "${CRT_FILE}" -text -noout

chmod 0744 "${KEY_FILE}"
chmod 0744 "${CSR_FILE}"
chmod 0744 "${CRT_FILE}"

# Add the cert to the OS chain, which prevent curl SSL errors inside the
# container. Not necessary, but cool to use -v and see cURL succeed.
cat "${CRT_FILE}" >> "${OS_CA_FILE}"
echo "" >> /etc/ssl/certs/ca-certificates.crt

echo ""
echo "Generated self-signed certificate"
echo "   KEY_FILE: ${KEY_FILE}"
echo "   CSR_FILE: ${CSR_FILE}"
echo "   CRT_FILE: ${CRT_FILE}"
echo ""
