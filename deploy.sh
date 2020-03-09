#!/bin/sh
git pull

sudo supervisorctl restart hugo-web
