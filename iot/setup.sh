#!/bin/sh
# Update
echo "Updating"
sudo apt-get update
sudo apt-get upgrade

#TeamViewer
echo "Installing TeamViewer"
wget https://download.teamviewer.com/download/linux/teamviewer-host_armhf.deb
sudo dpkg -i teamviewer-host_armhf.deb
sudo apt --fix-broken install
sudo teamviewer setup

# NodeJS
echo "Installing NodeJS"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v

# Yarn
echo "Installing Yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn

# Project
echo 'export PATH="$PATH:`yarn global bin`"' >> ~/.bashrc
export PATH="$PATH:`yarn global bin`"
yarn install
yarn run tsc

# PM2
echo "Setting up Daemon"
yarn global add pm2
sudo /home/pi/.yarn/bin/pm2 startup
sudo /home/pi/.yarn/bin/pm2 run /home/pi/Documents/iot/dist/index.js
sudo /home/pi/.yarn/bin/pm2 save

echo "Setup completed"