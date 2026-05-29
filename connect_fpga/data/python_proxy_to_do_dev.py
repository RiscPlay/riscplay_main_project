from flask import Flask, request, Response
from flask_cors import CORS
import requests

app = Flask(__name__)
# Habilita o CORS para o Flask aceitar chamadas do seu site (localhost:8000)
CORS(app)

# O IP do seu ESP32
ESP32_URL = "http://192.168.4.101"

@app.route('/<path:path>', methods=['GET', 'POST', 'OPTIONS'])
def proxy(path):
    # Constrói a URL de destino no ESP32
    url = f"{ESP32_URL}/{path}"
    
    # Repassa os parâmetros da query string (ex: ?n=256&addr=20)
    params = request.args
    
    try:
        # Faz a requisição ao ESP32
        if request.method == 'GET':
            resp = requests.get(url, params=params, timeout=5)
        elif request.method == 'POST':
            resp = requests.post(url, data=request.data, headers=request.headers, timeout=5)
        
        # Cria a resposta para o navegador com os dados do ESP32
        # O Flask-CORS cuidará de adicionar os headers de permissão automaticamente
        return Response(resp.content, resp.status_code, resp.headers.items())

    except requests.exceptions.RequestException as e:
        return f"Erro ao conectar no ESP32: {e}", 500

if __name__ == "__main__":
    # Roda na porta 5000 por padrão
    print(f"Proxy ativo! Aponte seu fetch para: http://localhost:5000")
    app.run(host='0.0.0.0', port=5000)