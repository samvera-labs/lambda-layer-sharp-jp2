# AWS Lambda layer for Sharp

![Releases](https://img.shields.io/github/v/release/bubblydoo/lambda-layer-sharp.svg)
![Build Layer ZIP](https://github.com/bubblydoo/lambda-layer-sharp/workflows/Build%20Layer%20ZIP/badge.svg)

This AWS Lambda layer contains a pre-built [Sharp](https://www.npmjs.com/package/sharp) binary. New releases are automatically published in this repository on each Sharp update.

## Download

A pre-built layer zip file is available on the [Releases page](https://github.com/bubblydoo/lambda-layer-sharp/releases), alongside the size of the layer.

## Build

### Dependencies

* Docker

### Steps

1. Clone the repo: 
    ```sh
    git clone git@github.com:bubblydoo/lambda-layer-sharp.git
    cd lambda-layer-sharp/
    ```
1. Install dependencies:
    ```sh
    docker run -v "$PWD":/var/task lambci/lambda:build-nodejs12.x npm --no-optional --no-audit --progress=false install
    ```
1. Build the layer:
    ```sh
    docker run -v "$PWD":/var/task lambci/lambda:build-nodejs12.x node ./node_modules/webpack/bin/webpack.js
    ```
1. Perform a smoke-test:
    ```sh
    docker run -w /var/task/dist/nodejs -v "$PWD":/var/task lambci/lambda:build-nodejs12.x node -e "console.log(require('sharp'))"
    ```
1. Import created layer into your AWS account:
    ```sh
    aws lambda publish-layer-version --layer-name sharp --description "Sharp layer" --license-info "Apache License 2.0" --zip-file fileb://dist/sharp-layer.zip --compatible-runtimes nodejs12.x
    ```

## Auto-publish

The [build Github Action](/.github/workflows/docker-workflow.yml) is automatically triggered by [Dependabot](/.github/dependabot.yml), merged by [Mergify](/.mergify.yml) and then published by the same Github Action.

## Credits

Originally forked from [Umkus/lambda-layer-sharp](https://github.com/Umkus/lambda-layer-sharp).