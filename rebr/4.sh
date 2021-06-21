#!/bin/sh

cd /opt/
wget https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
tar -xzf go1.16.5.linux-amd64.tar.gz
rm go1.16.5.linux-amd64.tar.gz

export GOROOT=/opt/go
export PATH=$PATH:$GOROOT/bin

apt update
apt upgrade -y
apt install git -y
git clone https://github.com/bee42/whoamI.git whoami

mkdir -p app/src/app
sed -e 's/"port", "80"/"port", "9292"/g' whoami/app.go > app/src/app/app.go

export GOPATH=/opt/app

cd app/src/app
go mod init
go get
go build -o app app.go

echo "

  - job_name: 'whoami'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9292']
        labels:
          env: 'prod'
" >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

./app
