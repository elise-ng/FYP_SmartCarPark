# IoT Device

Scripts are written in TypeScript and transpiled to JavaScript to run in NodeJS. 

Controls ultrasonic distance sensor, manages IoT device state, takes snapshots and sync data to backend

The transpile action happens automatically when you run `yarn run start` or `yarn run test`

## One step deploy on a new Raspberry Pi

Just run:

```sh
./setup.sh
```

This will install:

- TeamViewer - Remote access
- NodeJS 10.x
- Yarn Package Manager
- PM2

and handles necessary configuations

After running the script, be sure to run `raspi-config` in terminal and enable SSH, VNC and the Camera interface.

---

Alternatively, follow the steps below for manual configurations

## Setting up NodeJS Environment

- Install [Yarn package manager](https://yarnpkg.com/getting-started)
- Install [NodeJS 10](https://nodejs.org/en/download/)

Then:

```sh
yarn install
```

## Deployment and configuation

[PM2](https://pm2.keymetrics.io/) is used for instance deployment and management. To install:

```sh
yarn global add pm2
```

Script accepts arguments provided to PM2 to configure to different modes. Edit `pm2_config.yaml` for configurations.

Example for IoT (Parking Space) mode:

```yaml
apps:
  - script: ./dist/index.js
    name: 'iot'
    env:
      mode: 'iot'
      deviceId: 'test1'
```

Example for Gate mode:

```yaml
apps:
  - script: ./dist/index.js
    name: 'iot'
    env:
      mode: 'gate'
      gateMode: 'entry'
      deviceId: 'test1'
```

Finally to deploy:

```sh
./redeploy.sh
```