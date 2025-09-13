FROM --platform=linux/amd64 docker.io/dagster/user-code-example:latest

RUN python -m pip install pandas
