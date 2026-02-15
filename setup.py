# setup.py
import os
import sys
import subprocess
import mysql.connector
from mysql.connector import Error

def create_database():
    """Membuat database dan tabel"""
    try:
        # Koneksi ke MySQL (tanpa database)
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password=''
        )
        
        if connection.is_connected():
            cursor = connection.cursor()
            
            # Baca file SQL
            with open('database.sql', 'r', encoding='utf-8') as file:
                sql_script = file.read()
            
            # Eksekusi perintah SQL
            for statement in sql_script.split(';'):
                if statement.strip():
                    cursor.execute(statement)
            
            print("✅ Database berhasil dibuat!")
            cursor.close()
            
    except Error as e:
        print(f"❌ Error: {e}")
    finally:
        if connection.is_connected():
            connection.close()

def install_dependencies():
    """Install dependencies dari requirements.txt"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Dependencies berhasil diinstall!")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error install dependencies: {e}")

def create_folders():
    """Membuat folder yang diperlukan"""
    folders = ['static/css', 'static/js', 'templates']
    
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder)
            print(f"✅ Folder '{folder}' berhasil dibuat!")
        else:
            print(f"📁 Folder '{folder}' sudah ada")

if __name__ == "__main__":
    print("=== SETUP APLIKASI INVENTARIS SPPG ===")
    print("1. Membuat folder...")
    create_folders()
    
    print("\n2. Install dependencies...")
    install_dependencies()
    
    print("\n3. Membuat database...")
    create_database()
    
    print("\n" + "="*40)
    print("✅ Setup selesai!")
    print("\nJalankan aplikasi dengan:")
    print("  python app.py")
    print("\nAkses aplikasi di: http://localhost:5000")
    print("\nLogin dengan:")
    print("  Username: admin")
    print("  Password: admin123")