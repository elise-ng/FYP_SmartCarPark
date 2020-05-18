# Final Year Project: Smart Car Park

Project ID: LIX2

Supervisor: Dr Cindy Xin LI 

By: Cheung Ka Yi Grace // Ng Chi Him // Wong Hiu Nam // Wong Ho Yan Veronica

---

This repository contains all source code for Year 2019-20 Group LIX2's Final Year Project: Smart Car Park.

Source code for different components of the system are stored in their own respectively folders.

Please refer to READMEs in the respective folders for setup, usage and more.

## Kiosk App / Client App

Source code located in `mobile/`

Flutter is used as the main framework for building both apps

The kiosk app and the client app shares the same codebase. To switch between the two modes, change the `isKioskMode` boolean flag located in `/lib/main.dart`

## IoT Device

Source code located in `iot/`

Scripts are written in TypeScript and transpiled to JavaScript to run in NodeJS. Controls ultrasonic distance sensor, manages IoT device state, takes snapshots and sync data to backend

Notice that [Yarn package manager](https://yarnpkg.com/getting-started) must be used for Raspiberry Pi Zero W (arm6l) compatibility

## Web

Source code located in `web/`

Web Admin Panel for monitoring and controlling car park. Also provides demo functionalities and data visualization. Based on [Vue.js](https://vuejs.org/)

## Backend (Cloud Functions)

Source code located in `backend/`

Cloud functions are separated into their own respective folders in `functions/src`:

- `cv/` - License Plate Recognition
- `iot/` - Handles IoT devices' snapshot uploads and database iotStates changes
- `stripe/` - Calculate parking fee, generate payment secrets and provides webhook for Stripe events
- `users/` - Handles Stripe ID generation after user creation

- `common/` - Common modules and objects shared across different cloud functions

## License Recognition Experiments

Source code located in `license-experiments/`

Obsolete code for experimenting with different approaches to license plate recognition.

For production implementation, refer to `backend/functions/src/cv/`