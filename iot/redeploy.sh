#!/bin/sh
yarn install
sudo /home/pi/.yarn/bin/pm2 delete iot
sudo /home/pi/.yarn/bin/pm2 start ./pm2_config.yaml
sudo /home/pi/.yarn/bin/pm2 save
