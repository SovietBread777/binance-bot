# Шаг 1: Выбор базового образа
FROM debian

# Обновление списка пакетов и установка необходимых инструментов
RUN apt-get update && \
    apt-get install -y postgresql postgresql-contrib python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Шаг 2: Настройка PostgreSQL
# Создаем директорию для хранения данных PostgreSQL
RUN mkdir /var/lib/postgresql/data

RUN service postgresql start && \
    su - postgres -c "PGHOST=/var/run/postgresql psql -c \"CREATE DATABASE db;\"" && \
    su - postgres -c "PGHOST=/var/run/postgresql psql -c \"CREATE USER username WITH PASSWORD 'changeme';\"" && \
    su - postgres -c "PGHOST=/var/run/postgresql psql -c \"GRANT ALL PRIVILEGES ON DATABASE db TO username;\""

# Шаг 3: Установка Python и зависимостей
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Копирование остальных файлов приложения
COPY . .

# Запуск приложения (замените CMD на команду запуска вашего приложения)
CMD ["python3", "your_app.py"]
