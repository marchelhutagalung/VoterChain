#!/bin/bash
cat ../header
cd ../..
echo "[+] Check Homebrew"
brew -v > /dev/null
if [ $? -ne 0 ]
then
    echo "[!] Homebrew not found"
    echo "[!] Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "[+] Homebrew found"
fi
echo "[+] Checking Node.js"
node -v > /dev/null
if [ $? -ne 0 ]
then
    echo "[!] Node.js not found"
    echo "[!] Installing Node.js"
    brew install node
else
    echo "[+] Node.js found"
fi
echo "[+] Installing dependencies"
npm install > /dev/null
echo "[+] Dependencies installed"
if [[ ! -d ssl ]]
then
mkdir ssl
fi
if [[ ! -f ./ssl/mydomain.csr || ! -f ./ssl/private.key || ! -f ./ssl/private.crt ]] 
then
echo "[+] Generating SSL files"
openssl req -new -newkey rsa:2048 -nodes -out ./ssl/mydomain.csr -keyout ./ssl/private.key
openssl x509 -signkey ./ssl/private.key -in ./ssl/mydomain.csr -req -days 1000 -out ./ssl/private.crt
echo "[+] SSL files generated"
fi
if [[ ! -f ./ssl/blockchain.key ]]
then
echo "[+] Generating cryptofiles"
openssl enc -aes-256-cfb -P -md sha256 | tail -2 | head -1 | cut -d"=" -f2 > ./ssl/blockchain.key
echo "[+] Generated cryptofiles"
fi
if [[ ! -f ./js/config.js && ! -f ./admin-web/js/config.js ]]
then
echo "[+] Generating Firebase config"
read -p "Enter apiKey: " apiKey
read -p "Enter authDomain: " authDomain
read -p "Enter databaseURL: " databaseURL
read -p "Enter projectId: " projectId
read -p "Enter storageBucket: " storageBucket
read -p "Enter messagingSenderId: " messagingSenderId
echo "var config = {apiKey: \"$apiKey\",authDomain: \"$authDomain\",databaseURL: \"$databaseURL\",projectId: \"$projectId\",storageBucket: \"$storageBucket\",messagingSenderId: \"$messagingSenderId\"};firebase.initializeApp(config);" > ./admin-web/js/config.js
echo "var config = {apiKey: \"$apiKey\",authDomain: \"$authDomain\",databaseURL: \"$databaseURL\",projectId: \"$projectId\",storageBucket: \"$storageBucket\",messagingSenderId: \"$messagingSenderId\"};module.exports = {config: config};" > ./js/config.js
echo "[+] Generated files"
fi