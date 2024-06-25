from dotenv import load_dotenv, dotenv_values
import psycopg2
import telebot
from telebot.types import ReplyKeyboardMarkup, KeyboardButton
import requests
from bs4 import BeautifulSoup
import schedule
import time

load_dotenv()
env_config = dotenv_values(".env")

def connect_to_db():
    conn = None
    try:
        conn = psycopg2.connect(
            host=env_config["DATABASE_HOST"],
            database=env_config["DATABASE_NAME"],
            user=env_config["DATABASE_USER"],
            password=env_config["DATABASE_PASSWORD"]
        )
    except Exception as e:
        print(f"Cannot connect to PostgreSQL DB: {e}")
        raise Exception("Failed to connect to the database")
    return conn

def create_table(conn):
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS crypto_prices (
            name TEXT,
            price TEXT
        );
    """)
    conn.commit()

def clear_table(conn):
    cur = conn.cursor()
    cur.execute("DELETE FROM crypto_prices;")
    conn.commit()

def insert_data(conn, data):
    cur = conn.cursor()
    for row in data:
        cur.execute("INSERT INTO crypto_prices (name, price) VALUES (%s, %s)", row)
    conn.commit()

def fetch_and_update_crypto_prices():
    print("сработало")
    conn = connect_to_db()
    if conn:
        url = "https://www.binance.com/ru/price"
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')

        elements = soup.select('#__APP > div.css-j6lmlr > div.css-1u8jyrs > div.css-1maq07w > div.css-3tf3mo > a.css-tnlu7m')
        data = []

        for element in elements[:10]:
            price_url = f"https://www.binance.com{element.get('href')}"
            price_response = requests.get(price_url)
            price_soup = BeautifulSoup(price_response.text, 'html.parser')

            name_div = element.find('div', class_='css-1anqryw').find('div', class_='css-18nenqa').find('div', class_='css-11aussz')
            name = name_div.text.strip() if name_div else ""

            price_element = price_soup.select_one('body > div#__APP > section.css-2tpvhp > div.css-1ovykgb > div.css-1xmcoai > div.css-197puc0 > div.css-1267ixm > div.css-1bwgsh3')
            price = price_element.text.strip().replace(" ", "") if price_element else ""

            data.append((name, price))

        clear_table(conn)
        create_table(conn)
        insert_data(conn, data)
        conn.close()

if __name__ == "__main__":
    try:
        db_conn = connect_to_db()

        fetch_and_update_crypto_prices()
        schedule.every(5).minutes.do(fetch_and_update_crypto_prices)
        
        token = env_config["TOKEN"]
        
        bot = telebot.TeleBot(token)
        
        @bot.message_handler(commands=['start'])
        def send_welcome(message):
            chat_id = message.chat.id
            
            keyboard = ReplyKeyboardMarkup(resize_keyboard=True).add(KeyboardButton("Курс Binance"))
            
            welcome_message = "Нажмите \"Курс Binance\", чтобы получить курс топ-10 криптовалют с Binance.\n\nℹ️ Курс обновляется каждые 5 минут"
            
            bot.send_message(chat_id, welcome_message, reply_markup=keyboard)
        
        @bot.message_handler(func=lambda message: True)
        def get_crypto_prices(message):
            chat_id = message.chat.id
            
            cursor = db_conn.cursor()
            cursor.execute("SELECT name, price FROM crypto_prices ORDER BY price DESC LIMIT 10;")
            prices_data = cursor.fetchall()
            
            prices_str = "\n".join([f"{row[0]}: {row[1]}" for row in prices_data])
            bot.send_message(chat_id, prices_str)
        
        while True:
            bot.polling(none_stop=True)
            schedule.run_pending()
            time.sleep(1)
    except Exception as e:
        print(f"Error starting bot: {e}")