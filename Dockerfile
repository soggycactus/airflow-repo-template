FROM python:3.7.6

WORKDIR /root
COPY airflow.requirements.txt /root/airflow.requirements.txt
RUN pip install --no-deps --trusted-host pypi.python.org -r airflow.requirements.txt

RUN echo 'deb http://cloud.r-project.org/bin/linux/debian buster-cran35/' >> /etc/apt/sources.list
RUN apt-get install dirmngr
RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    r-base \
    r-base-dev \
    littler \
    git-core \
    libssl-dev \
    default-jdk \
    libcurl4-openssl-dev \
    libxml2-dev \
    libpq-dev -y

RUN R -e "install.packages('devtools')"
RUN R -e "install.packages('tidyverse')"

WORKDIR /home/scripts
