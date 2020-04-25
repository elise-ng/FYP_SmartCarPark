#!/bin/sh
yarn install
sudo /home/pi/.yarn/bin/pm2 restart iot --update-env
