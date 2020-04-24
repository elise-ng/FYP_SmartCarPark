#!/bin/sh
yarn install
yarn run tsc
sudo /home/pi/.yarn/bin/pm2 restart iot