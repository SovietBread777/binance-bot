# Используем официальный образ PostgreSQL
FROM postgres:latest

# Устанавливаем рабочий каталог в контейнере
WORKDIR /app

# Обновляем список пакетов и устанавливаем Python и pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip

# Копируем файлы конфигурации (если есть)
COPY./config/* /etc/postgresql/

# Создаем базу данных и пользователя
RUN echo "CREATE DATABASE db;" > init.sql && \
    echo "CREATE USER username WITH PASSWORD 'changeme';" >> init.sql && \
    echo "GRANT ALL PRIVILEGES ON DATABASE db TO username;" >> init.sql && \
    echo "ALTER USER username CREATEDB;" >> init.sql && \
    psql -U postgres < init.sql

# Копируем файл requirements.txt в контейнер
COPY requirements.txt.

# Устанавливаем зависимости Python
RUN pip3 install --no-cache-dir -r requirements.txt

# Открываем порт 5432 для подключения к PostgreSQL
EXPOSE 5432

# Команда запуска при старте контейнера
CMD ["sh", "-c", "postgres -c listen_addresses='*' -p 5432 & python3 parser.py & python3 main.py"]
