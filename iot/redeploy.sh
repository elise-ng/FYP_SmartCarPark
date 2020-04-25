#!/bin/sh
yarn install
sudo /home/pi/.yarn/bin/pm2 restart ./pm2_config.yaml --update-env
