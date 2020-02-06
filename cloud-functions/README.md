# Cloud Functions

## Setting up dev env

### Install firebase cli tools

```sh
npm install -g firebase-tools
```

### Login with firebase cli tools

```sh
firebase login
```

### Install node deps

> remember to aloways work with npm in `./functions` dir

```sh
cd functions
npm i
```

## Dev workflow

### Deploy to cloud

```sh
firebase deploy --only functions
```

### Invoke functions locally

```sh
export GOOGLE_APPLICATION_CREDENTIALS="path_to_firebase_service_acc_key.json"
firebase functions:shell
```
