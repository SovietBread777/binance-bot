FROM postgres:latest

# Установка Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Копирование скриптов и файла requirements.txt
COPY . /app

# Переход в директорию /app
WORKDIR /app

# Установка зависимостей Python
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Создание пользователя и базы данных
RUN createuser --interactive --pwprompt --username=postgres && \
    createdb --owner=postgres db

# Экспозиция порта PostgreSQL
EXPOSE 5432

# Запуск скриптов
CMD ["sh", "-c", "psql -U postgres db < setup.sql && python3 parser.py & python3 main.py"]
