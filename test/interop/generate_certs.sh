#!/bin/bash
set -e
mkdir -p test/interop/certs
cd test/interop/certs

# Generate CA
openssl req -x509 -newkey rsa:4096 -keyout ca_key.pem -out ca_cert.pem -days 365 -nodes -subj "/C=US/ST=Test/L=Test/O=Capnp/OU=Test/CN=Test CA"

# Generate Server Cert
openssl req -newkey rsa:4096 -keyout server_key.pem -out server_req.pem -nodes -subj "/C=US/ST=Test/L=Test/O=Capnp/OU=Test/CN=localhost"
openssl x509 -req -in server_req.pem -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial -out server_cert.pem -days 365 -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1")

# Combine server cert and key for stunnel
cat server_cert.pem server_key.pem > stunnel.pem

# Generate Client Cert
openssl req -newkey rsa:4096 -keyout client_key.pem -out client_req.pem -nodes -subj "/C=US/ST=Test/L=Test/O=Capnp/OU=Test/CN=Test Client"
openssl x509 -req -in client_req.pem -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial -out client_cert.pem -days 365
