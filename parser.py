import requests
from bs4 import BeautifulSoup
import psycopg2
from dotenv import load_dotenv, dotenv_values
import time

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

def main():
    while True:
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

        conn = connect_to_db()
        if conn:
            clear_table(conn)
            create_table(conn)
            insert_data(conn, data)
            conn.close()
        
        time.sleep(300)

if __name__ == "__main__":
    main()
