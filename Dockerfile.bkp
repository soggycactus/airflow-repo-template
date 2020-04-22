FROM python:3.7.6
WORKDIR /root
COPY airflow.requirements.txt /root/airflow.requirements.txt
RUN pip install --no-deps --trusted-host pypi.python.org -r airflow.requirements.txt
