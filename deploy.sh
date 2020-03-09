#!/bin/sh
su dev

git pull

sudo supervisorctl restart hugo-web
