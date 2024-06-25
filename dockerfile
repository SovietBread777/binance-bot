FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common wget lsb-release gnupg curl && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql postgresql-contrib python3 python3-pip && \
    curl https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install --upgrade pip && \
    pip3 install -r requirements.txt && \
    service postgresql start && \
    psql --command "CREATE USER ${POSTGRES_USER} WITH SUPERUSER PASSWORD '${POSTGRES_PASSWORD}';" && \
    createdb -O ${POSTGRES_USER} ${POSTGRES_DB}

ENV POSTGRES_USER=username POSTGRES_PASSWORD=changeme POSTGRES_DB=db

COPY..

CMD ["bash", "-c", "service postgresql start && python3 parser.py & python3 main.py"]
