#!/bin/sh

cd /home/dev/hugo.yusank.space && git pull

sudo supervisorctl restart hugo-web
