# Выберите базовый образ
FROM debian

# Обновление списка пакетов и установка необходимых инструментов
RUN apt-get update && \
    apt-get install -y software-properties-common python3 python3-pip python3-dev build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Создание виртуального окружения и активация
RUN python3 -m venv /opt/myapp
ENV PATH="/opt/myapp/bin:$PATH"

# Копирование requirements.txt в контейнер
COPY requirements.txt .

# Установка зависимостей из requirements.txt в виртуальном окружении
RUN pip install --no-cache-dir -r requirements.txt

# Копирование остальных файлов приложения
COPY . .

CMD ["python3 parser.py & python3 main.py"]