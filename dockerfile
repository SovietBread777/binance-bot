FROM postgres:latest

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY . /app

WORKDIR /app

RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

RUN createuser --interactive --pwprompt --yes --username=postgres && \
    createdb --owner=postgres db

EXPOSE 5432

# Запуск скриптов
CMD ["sh", "-c", "psql -U postgres db < setup.sql && python3 parser.py & python3 main.py"]
