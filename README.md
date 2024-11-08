# Deprecation Notice

To account for the new build and packaging systems used by `sharp` (>= v0.33.0) and `libvips` (>= v8.14.0), this repo has been superseded by [samvera-labs/sharp-jp2-lambda-layer ](https://github.com/samvera-labs/sharp-jp2-lambda-layer).

# AWS Lambda layer for Sharp
![Releases](https://img.shields.io/github/v/release/samvera-labs/lambda-layer-sharp-jp2.svg)
![Build Layer ZIP](https://github.com/samvera-labs/lambda-layer-sharp-jp2/workflows/Build%20Layer%20ZIP/badge.svg)

This AWS Lambda layer contains a pre-built [Sharp](https://www.npmjs.com/package/sharp) binary. New releases are automatically published in this repository on each Sharp update.

## Download

A pre-built layer zip file is available on the [Releases page](https://github.com/samvera-labs/lambda-layer-sharp-jp2/releases), alongside the size of the layer. Zip files for both x86_64 and arm64 are available.

## Shared Public Layer

A public version of this layer is always available at `arn:aws:lambda:us-east-1:$REGION:layer:libvips-sharp-jp2:$VERSION`, where `$REGION` is any valid AWS region, and `$VERSION` is the layer version. The available versions can be listed using the AWS CLI command:
```
aws lambda list-layer-versions \
    --layer-name arn:aws:lambda:$REGION:625046682746:layer:libvips-sharp-jp2 \
    --query 'LayerVersions[*].LayerVersionArn' \
    --output text
```

## Build

### Dependencies

* Docker

### Steps

1. Clone the repo:
    ```sh
    git clone git@github.com:samvera-labs/lambda-layer-sharp-jp2.git
    cd lambda-layer-sharp-jp2/
    ```
1. Build the layer:
    ```sh
    bin/build
    ```
1. Import created layer into your AWS account:
    ```sh
    aws lambda publish-layer-version --layer-name sharp-jp2 --description "Sharp layer with JP2 Support" --license-info "Apache License 2.0" --zip-file fileb://dist/sharp-layer.zip --compatible-runtimes nodejs16.x
    ```

## Auto-publish

The [build Github Action](/.github/workflows/docker-workflow.yml) is automatically triggered by [Dependabot](/.github/dependabot.yml), merged by [Mergify](/.mergify.yml) and then published by the same Github Action.

## Credits

Originally forked from [Umkus/lambda-layer-sharp-jp2](https://github.com/Umkus/lambda-layer-sharp-jp2). Auto build by [bubblydoo](https://github.com/bubblydoo/lambda-layer-sharp)
