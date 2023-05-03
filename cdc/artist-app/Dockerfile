FROM python:3.11 as base

ARG USERNAME=unpriviledged
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apt-get update && \
    apt-get install -y \
        python3-psycopg2
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd \
        --uid $USER_UID \
        --gid $USER_GID \
        -m $USERNAME
USER $USERNAME
WORKDIR /opt/app
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -U -r requirements.txt

##### Testing image
FROM base as testing

USER root
RUN apt-get update && \
    apt-get install -y \
        postgresql
RUN usermod -a -G postgres $USERNAME
USER $USERNAME
COPY requirements-tests.txt .
RUN pip install --upgrade pip && \
    pip install -U -r requirements-tests.txt
COPY ./ .

# python -m bandit src/
# python -m pytest -n auto --cov

##### Default image
FROM base 
ENTRYPOINT [ "uvicorn" ]
CMD [ "app.main:app", "--port", "8080"]
EXPOSE 8080
