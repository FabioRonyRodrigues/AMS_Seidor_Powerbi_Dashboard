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
        
        # Executar a query SQL para pegar os Tipos
        cursor.execute("""SELECT DISTINCT tipo FROM prd.stg_chamado_sd""")
        resultados = cursor.fetchall()
        
        # Criar tabela temporária, se não existir
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS dim_trad_tipo (
                tipo TEXT,
                tipo_eng TEXT,
                tipo_spa TEXT
            )
        """)
        
        # Limpar a tabela antes de inserir novos dados
        cursor.execute("DELETE FROM dim_trad_tipo")
        
        # Traduzir e inserir dados
        for (tipo,) in resultados:
            # Esperar pelas traduções em inglês e espanhol
            tipo_eng, tipo_spa = await asyncio.gather(
                traduzir_texto(tipo, "en"),  # Tradução para inglês
                traduzir_texto(tipo, "es")   # Tradução para espanhol
            )
            
            # Log para verificar os dados antes de inserir
            print(f"Inserindo tipo '{tipo}' com traduções: {tipo_eng} (Inglês), {tipo_spa} (Espanhol)")
            
            cursor.execute("""
                INSERT INTO dim_trad_tipo (tipo, tipo_eng, tipo_spa)
                VALUES (%s, %s, %s)
            """, (tipo, tipo_eng, tipo_spa))
        
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
