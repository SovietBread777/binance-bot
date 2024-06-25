FROM postgres:latest

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY . /app

WORKDIR /app

RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

ENV PGPASSWORD changeme
RUN createuser --interactive --username=username -y && \
    createdb db

EXPOSE 5432

CMD ["sh", "-c", "psql -U postgres db < setup.sql && python3 parser.py & python3 main.py"]