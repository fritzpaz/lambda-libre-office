# TO BUILD FROM LOCALLY STORED DIRECTORY
FROM base-image:latest
# TO BUILD FROM ECR URL
FROM 299862984411.dkr.ecr.us-west-2.amazonaws.com/microservice-docx2pdf:base


WORKDIR ${LAMBDA_TASK_ROOT}

RUN echo $(pwd)

COPY main.py requirements.txt ${LAMBDA_TASK_ROOT}/
#COPY helpers ${LAMBDA_TASK_ROOT}/helpers

RUN PYTHON_VERSION=$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2) && \
    pip install -r requirements.txt -t /var/lang/lib/python${PYTHON_VERSION}/site-packages/

ENV PATH="/var/task/venv/bin:${PATH}"

# # TO ACCESS THE CONTAINER LOCALLY REMOVE THIS LINE AND UNCOMMENT THE NEXT TWO
CMD [ "main.handler" ]
# ENTRYPOINT []
# CMD ["tail", "-f", "/dev/null"]



# TO DEPLOY THE LAMBDA WITH THE LATEST CODE AND LATEST ENV VARS
# aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com  
# docker build --no-cache -t lambda-image -f lambda.dockerfile . 
# docker tag lambda-image:latest <account_id>.dkr.ecr.<region>.amazonaws.com/libreoffice-image:lambda
# aws ecr batch-delete-image --repository-name libreoffice-image --image-ids imageTag=lambda        
# docker push <account_id>.dkr.ecr.<region>.amazonaws.com/libreoffice-image:lambda

# TO GO INTO THE CONTAINER FOR EXAMINATION
# docker run -d --name test lambda-image
# docker exec -it test /bin/sh