FROM postgres:latest

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY . .

RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

ENV POSTGRES_USER=username
ENV POSTGRES_PASSWORD=changeme
ENV POSTGRES_DB=db

EXPOSE 5432

RUN useradd -m -U postgres
USER postgres

CMD ["sh", "-c", "postgres -c 'logging_collector=on' && python3 parser.py & python3 main.py"]