FROM python:3.8-slim-buster


RUN apt update
# Install Airflow pre-requisites: https://airflow.apache.org/docs/apache-airflow/2.0.0/installation.html#getting-airflow
RUN apt install build-essential -y
# Install Airflow system dependencies: https://airflow.apache.org/docs/apache-airflow/stable/installation.html#system-dependencies
# NOTE: we have changed krb5-user to libkrb5-dev for a non-interactive installation
RUN apt-get install -y --no-install-recommends \
    freetds-bin \
    ldap-utils \
    libffi6 \
    libkrb5-dev \
    libsasl2-2 \
    libsasl2-modules \
    libssl1.1 \
    locales  \
    lsb-release \
    sasl2-bin \
    sqlite3 \
    unixodbc

# Install Airflow and any additonal dependencies
WORKDIR /root

COPY Makefile /root/Makefile
COPY airflow.requirements.txt /root/airflow.requirements.txt

RUN make internal-install-airflow
RUN make internal-install-deps