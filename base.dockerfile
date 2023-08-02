FROM public.ecr.aws/lambda/python:3.10

RUN yum update -y
RUN yum install -y wget tar gzip libXinerama dbus-libs cairo cups-libs unoconv python3 python3-pip java-1.8.0-openjdk

RUN python3 -m venv venv && \
    venv/bin/pip install --upgrade pip && \
    venv/bin/pip install --no-cache-dir awslambdaric boto3
ENV PATH="/var/task/venv/bin:${PATH}"

WORKDIR /usr/local
# This link can be out of date. Check the latest version at https://www.libreoffice.org/download/download/
RUN wget https://download.documentfoundation.org/libreoffice/stable/7.5.5/rpm/x86_64/LibreOffice_7.5.5_Linux_x86-64_rpm.tar.gz
RUN tar -xzf LibreOffice_7.5.5_Linux_x86-64_rpm.tar.gz
WORKDIR /usr/local/LibreOffice_7.5.5.2_Linux_x86-64_rpm/RPMS
RUN yum localinstall *.rpm -y
RUN rm -rf /usr/local/LibreOffice_7.5.5_Linux_x86-64_rpm.tar.gz /usr/local/LibreOffice_7.5.5.2_Linux_x86-64_rpm

# Set environment variables for LibreOffice
ENV PATH="/usr/local/LibreOffice_7.5.5.2_Linux_x86-64_rpm/RPMS/desktop-integration:${PATH}"
ENV LIBREOFFICE_PATH="/usr/local/LibreOffice_7.5.5.2_Linux_x86-64_rpm/RPMS/desktop-integration"

# THE NEXT TWO LINES ARE FOR LOCAL TESTING
# ENTRYPOINT []
# CMD ["tail", "-f", "/dev/null"]
# THE NEXT TWO LINES ARE SUPPOSED TO WORK FOR CREATING THE IMAGE AND PUSHING TO ECR
COPY main.py ${LAMBDA_TASK_ROOT}
CMD ["main.handler"]


# Below are steps that assist with creating, and deploying the docker images based on this docker file.

# Helpful docker commands for reference
# docker images                                           <- see docker images
# docker rmi <image id>                                   <- remove image (no container running)
# docker ps                                               <- running containers
# docker ps -a                                            <- all containers
# docker run -d --name <container name> <image name>      <- create a container based on an image
# docker start <container name>                           <- start container after it has been created
# docker stop <container name>                            <- stop container
# docker rm <container id>                                <- remove container (not running)
# docker rm -f <container id>                             <- remove container forced
# docker exec -it <container name> /bin/sh                <- run shell inside of the container

# STEPS:
#
# 1. Build image
#       docker build --no-cache -t <image name> . | docker build --no-cache -t <image name> -f <docker file name> . 
# 2. Run container
#       docker run -d --name container base-image  
# 2.1. Go into container (optional)
#       docker exec -it <container name> /bin/sh
# 2.2. When inside the container run:
#       > export AWS_ACCESS_KEY_ID=<ACCESS KEY ID>
#       > export AWS_SECRET_ACCESS_KEY=<SECRET ACCESS KEY>
# 2.3. The conversion worked using the command (insert file that you downloaded locally):
#       > /opt/libreoffice7.5/program/soffice --headless --nologo --nodefault --nofirststartwizard --convert-to pdf /app/filename.ext --outdir /app
#
# ---
# Steps below have not been properly validated, but describe how to get the image to ECR
#
# 3. Tag container
#       docker tag <image name>:latest <account id>.dkr.ecr.<region>.amazonaws.com/<image name>:base
# 4. Login to AWS ECR
#       aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account id>.dkr.ecr.<region>.amazonaws.com
# 5. Delete previous image
#       aws ecr batch-delete-image --repository-name libreoffice-image --image-ids imageTag=base   
# 6. Push image to ECR
#       docker push <account id>.dkr.ecr.<region>.amazonaws.com/<image name>:base

