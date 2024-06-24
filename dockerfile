FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common wget lsb-release gnupg

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && \
    apt-get install -y postgresql postgresql-contrib

RUN apt-get install -y python3 python3-pip

COPY requirements.txt.
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

COPY . .

CMD ["bash", "-c", "service postgresql start && python3 app.py"]