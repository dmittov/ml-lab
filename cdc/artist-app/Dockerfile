FROM python:3.11 AS base

ARG USERNAME=unpriviledged
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-psycopg2=2.8.6-2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd \
        --uid $USER_UID \
        --gid $USER_GID \
        -m $USERNAME
USER $USERNAME
WORKDIR /opt/app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip==23.1.2 \
    && pip install --no-cache-dir -r requirements.txt

##### Testing image
FROM base AS testing

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql=13+225 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN usermod -a -G postgres "${USERNAME}"
USER $USERNAME
COPY requirements-tests.txt .
RUN pip install --no-cache-dir -r requirements-tests.txt
COPY ./ .

# python -m bandit -r src/
# python -m pytest -n auto --cov

##### Default image
FROM base
COPY ./src .
ENTRYPOINT [ "uvicorn" ]
CMD [ "app.main:app", "--port", "8080"]
EXPOSE 8080
