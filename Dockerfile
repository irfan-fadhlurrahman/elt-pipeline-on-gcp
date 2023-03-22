FROM prefecthq/prefect:2.8.5-python3.9

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    ssh-client \
    software-properties-common \
    make \
    build-essential \
    ca-certificates \
    libpq-dev \
    wget \
    unzip

COPY requirements.txt .

RUN pip install -r requirements.txt \
    --no-cache-dir \
    --trusted-host pypi.python.org 

COPY prefect /opt/prefect
COPY .google /.google

ENV PYTHONPATH "${PYTHONPATH}:/opt/prefect"