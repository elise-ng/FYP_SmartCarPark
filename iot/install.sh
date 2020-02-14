#!/bin/bash

tput setaf 2; echo "Setting up virtual python environment for IoT project..."
tput sgr0;

pip3 install virtualenv
virtualenv -p python3 iot-project
source iot-project/bin/activate
iot-project/bin/pip install -r ./requirements.txt

tput setaf 2; echo "Please put your service account credential json in the folder of the project, and rename it 'credentials.json'";
