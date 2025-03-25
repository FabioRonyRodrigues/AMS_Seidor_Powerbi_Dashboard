import mysql.connector
from mysql.connector import Error
import asyncio
from googletrans import Translator

# Configuração do banco de dados
mysql_config = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "zz32#RzaD$O3GJ", 
    "database": "prd"
}

# Inicializar o tradutor do Google
translator = Translator()

async def traduzir_texto(texto, idioma):
    try:
        # Log para ver o que está sendo traduzido
        print(f"Traduzindo '{texto}' para {idioma}...")
        traducao = await translator.translate(texto, dest=idioma)
        print(f"Tradução de '{texto}' para {idioma}: {traducao.text}")
        return traducao.text
    except Exception as e:
        print(f"Erro na tradução: {e}")
        return texto  # Retorna o texto original em caso de erro

async def processar_traducoes():
    try:
        # Conectar ao banco de dados
        conn = mysql.connector.connect(**mysql_config)
        cursor = conn.cursor()
        
        # Executar a query SQL para pegar os status
        cursor.execute("""SELECT DISTINCT status FROM prd.stg_chamado_sd""")
        resultados = cursor.fetchall()
        
        # Criar tabela temporária, se não existir
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS dim_trad_status (
                status TEXT,
                status_eng TEXT,
                status_spa TEXT
            )
        """)
        
        # Limpar a tabela antes de inserir novos dados
        cursor.execute("DELETE FROM dim_trad_status")
        
        # Traduzir e inserir dados
        for (status,) in resultados:
            # Esperar pelas traduções em inglês e espanhol
            status_eng, status_spa = await asyncio.gather(
                traduzir_texto(status, "en"),  # Tradução para inglês
                traduzir_texto(status, "es")   # Tradução para espanhol
            )
            
            # Log para verificar os dados antes de inserir
            print(f"Inserindo status '{status}' com traduções: {status_eng} (Inglês), {status_spa} (Espanhol)")
            
            cursor.execute("""
                INSERT INTO dim_trad_status (status, status_eng, status_spa)
                VALUES (%s, %s, %s)
            """, (status, status_eng, status_spa))
        
        conn.commit()
        print("Tabela preenchida com sucesso!")

    except Error as e:
        print(f"Erro no banco de dados: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# Chamar a função assíncrona principal
if __name__ == "__main__":
    asyncio.run(processar_traducoes())
