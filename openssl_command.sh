#!/bin/bash
mkdir -p /file/gitrepo
mkdir -p /file/ca

git clone https://github.com/liupingok/bulletproof-tls.git /file/gitrepo/bulletproof-tls

cd /file/ca
mkdir root-ca
cd root-ca
cp /file/gitrepo/bulletproof-tls/private-ca/root-ca.conf ./
mkdir certs db private
chmod 700 private
touch db/index
openssl rand -hex 16  > db/serial
echo 1001 > db/crlnumber

openssl genrsa -aes256 -out private/rootca.key 2048
openssl req -new -key private/rootca.key -config root-ca.conf -out rootca.csr
openssl ca -selfsign -config root-ca.conf -in rootca.csr -out rootca.crt -extensions ca_ext

cd ..
mkdir sub-ca
echo `pwd`
cd sub-ca/
cp /file/gitrepo/bulletproof-tls/private-ca/sub-ca.conf /file/ca/sub-ca/
mkdir certs private db

openssl genrsa -aes256 -out private/subca.key 2048
openssl rsa -in private/subca.key -pubout -out public.key
openssl req -new -config sub-ca.conf -key private/subca.key -out subca.csr

cd /file/ca/root-ca/
openssl ca -config root-ca.conf -in /file/ca/sub-ca/subca.csr -out /file/ca/sub-ca/subca.crt -extensions sub_ca_ext
