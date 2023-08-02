# Lambda LibreOffice Conversion Service

This project contains a Lambda function that converts documents to PDF using LibreOffice. The conversion service runs inside a custom AWS Lambda Docker container. 

## Docker Images

This project uses two Dockerfiles:

1. `base.dockerfile`: This Dockerfile is used to create the base image that installs and configures LibreOffice.
2. `lambda.dockerfile`: This Dockerfile is used to create the Lambda image that contains the conversion service.

The conversion service runs as a Python script (`main.py`). The script downloads a document from an S3 bucket, converts it to PDF using LibreOffice, and uploads the resulting PDF back to S3.

## How to Use

### Building Docker Images

The base image can be built using the command:
```
docker build --no-cache -t <image name> -f base.dockerfile .
```

The Lambda image can be built using the command:

```
docker build --no-cache -t lambda-image -f lambda.dockerfile .
```

### Deploying to AWS

1. Tag the Docker images:

```
docker tag <image name>:latest <account id>.dkr.ecr.<region>.amazonaws.com/<image name>:base
docker tag lambda-image:latest <account_id>.dkr.ecr.<region>.amazonaws.com/libreoffice-image:lambda
```

2. Log in to AWS ECR:

```
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account id>.dkr.ecr.<region>.amazonaws.com
```

3. Push the Docker images to ECR:

```
docker push <account id>.dkr.ecr.<region>.amazonaws.com/<image name>:base
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/libreoffice-image:lambda
```

Please see the comments in the Dockerfiles for more detailed instructions and useful Docker commands.

## Environment Variables

The Lambda function uses the following environment variables:

- `OBJECT_KEY`: The key of the S3 object to be converted.
- `INPUT_BUCKET_NAME`: The name of the S3 bucket where the document to be converted is stored.
- `OUTPUT_BUCKET_NAME`: The name of the S3 bucket where the converted PDF should be uploaded.

## Running the Lambda Function Locally

To run the Lambda function locally, use the command:

```
docker run -d --name test lambda-image
docker exec -it test /bin/sh
```

## License

This project is open source and available under the [MIT License](LICENSE).
