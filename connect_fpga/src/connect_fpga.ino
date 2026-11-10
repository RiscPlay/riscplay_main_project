#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include "SPIFFS.h"
#include "stdint.h"
#include <SPI.h>
#include "test_send_data_to_fpga.h"
#include "communication_with_fpga_over_spi.h"
#include "string.h"

const char *ssid = "casa_do_anderson_2";
const char *password = "1124849295";
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");
void connect_wifi()
{

  // Conectar Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.println("Wi-Fi conectado: " + WiFi.localIP().toString());

  // Montar SPIFFS
  if (!SPIFFS.begin(true))
  {
    Serial.println("Erro ao montar SPIFFS");
    return;
  }
}

void create_server()
{
  // Configurar rotas
  server.on("/", HTTP_GET, handleRoot);
  server.on("/send_data", HTTP_POST, HandleSendData__FINISH_REQUEST, NULL,handleSendData__Recv_Body_from_POST);
  server.on("/stop_processor", HTTP_GET, handleStopProcessor);
  server.on("/enable_processor", HTTP_GET, handleEnableProcessor);
  server.on("/recv_data", HTTP_GET, handleRecvData);
  server.on("/enable_manual_clk", HTTP_GET, handleEnableManualClk);
  server.on("/disable_manual_clk", HTTP_GET, handleDisableManualClk);
  server.on("/set_manual_clk_on", HTTP_GET, handleSetManualClkOn);
  server.on("/set_manual_clk_off", HTTP_GET, handleSetManualClkOff);

  server.serveStatic("/", SPIFFS, "/");

  server.onNotFound(handleNotFound);

  // Iniciar servidor
  server.begin();
  Serial.println("Servidor HTTP iniciado!");
}

void handleRoot(AsyncWebServerRequest *request)
{
    if (!SPIFFS.exists("/index.html")) {
        request->send(404, "text/plain", "Arquivo nao encontrado");
        return;
    }

    request->send(SPIFFS, "/index.html", "text/html");
}
void handleAlpinejs(AsyncWebServerRequest *request)
{
    if (!SPIFFS.exists("/alpinejs.js"))
    {
        request->send(404, "text/plain", "Arquivo nao encontrado");
        return;
    }

    request->send(SPIFFS, "/alpinejs.js", "text/javascript");
}
void handleEnableProcessor(AsyncWebServerRequest *request)
{
    if (shutdown_or_up_processor_v2(true))
    {
        request->send(200, "text/plain", "ok");
    }
    else
    {
        request->send(400, "text/plain", "Nenhuma mensagem recebida");
    }
}
void handleStopProcessor(AsyncWebServerRequest *request)
{
    if (shutdown_or_up_processor_v2(false))
    {
        request->send(200, "text/plain", "ok");
    }
    else
    {
        request->send(400, "text/plain", "Nenhuma mensagem recebida");
    }
}
void handleEnableManualClk(AsyncWebServerRequest *request)
{
    if (enable_or_disable_manual_clk(true))
    {
        request->send(200, "text/plain", "ok");
    }
    else
    {
        request->send(400, "text/plain", "Nenhuma mensagem recebida");
    }
}
void handleDisableManualClk(AsyncWebServerRequest *request)
{
    if (enable_or_disable_manual_clk(false))
    {
        request->send(200, "text/plain", "ok");
    }
    else
    {
        request->send(400, "text/plain", "Nenhuma mensagem recebida");
    }
}
void handleSetManualClkOn(AsyncWebServerRequest *request)
{
    if (set_manual_clk(true))
    {
        request->send(200, "text/plain", "ok");
    }
    else
    {
        request->send(400, "text/plain", "Nenhuma mensagem recebida");
    }
}

void handleSetManualClkOff(AsyncWebServerRequest *request)
{
    if (set_manual_clk(false))
    {
        request->send(200, "text/plain", "ok");
    }
    else
    {
        request->send(400, "text/plain", "Nenhuma mensagem recebida");
    }
}
// Receber dados POST


void handleRecvData(AsyncWebServerRequest *request)
{
    if (request->hasParam("n", true) && request->hasParam("addr", true)){
        static uint8_t body[256];

        int length = request->getParam("n", true)->value().toInt();

        uint32_t addr = strtoul(request->getParam("addr", true)->value().c_str(),NULL,16);

        if (length <= 0 || length > 256)
        {
            request->send(400, "text/plain", "Invalid length");
            return;
        }

        bool success = recv_uint8_vector_from_fpga(addr, body, length);

        if (success)
            request->send(200,"application/octet-stream",body,length);
        
        else
          request->send(401, "text/plain","Nenhuma mensagem recebida");
        
    }
    else
      request->send(400, "text/plain","Nenhuma mensagem recebida");
    
}


// Receber dados POST
bool handleSendData(String data)
{

    uint8_t uint8_from_post[260];
    hexToBytes(data, uint8_from_post);
    uint8_t *body = &uint8_from_post[4];
    uint32_t addr = vector_uint8_to_uint32(uint8_from_post);

    uint32_t length_uint8_from_post = (uint32_t)((data.length() / 2) - 4);
    bool success = send_uint8_vector_to_fpga(addr, body, length_uint8_from_post);
    return success;
   
  
}


void HandleSendData__FINISH_REQUEST(AsyncWebServerRequest *request) {
  if (request->contentLength() == 0) {
    request->send(400, "text/plain", "Nenhuma mensagem recebida");
  }
}


void handleSendData__Recv_Body_from_POST(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
  static char hexBuffer[521];
  static AsyncWebServerRequest *activeRequest = NULL;
  if (total < 8 || total > 520) {
    if (index == 0) {
      request->send(400, "text/plain", "Tamanho de payload invalido");
    }
    return;
  }

  if (activeRequest != NULL && activeRequest != request) {
    if (index == 0) {
      request->send(503, "text/plain", "Servidor ocupado recebendo outro pacote");
    }
    return;
  }

  if (index == 0) {
    activeRequest = request;
    // FAIL-SAFE: If this client disconnects mid-fragmentation,
    // immediately free the buffer so the server doesn't get stuck.
    request->onDisconnect([request]() {
      if (activeRequest == request) {
        activeRequest = NULL;
      }
    });
  }

  // 4. Proteção extra contra estouro de índice (caso o cliente envie mais bytes que o declarado)
  if (index + len > 520) {
    activeRequest = NULL;
    request->send(400, "text/plain", "Estouro de buffer");
    return;
  }

  // 5. Copia o fragmento atual para a posição exata no buffer estático
  memcpy(&hexBuffer[index], data, len);

  if (index + len == total) {
    hexBuffer[total] = '\0'; 
    String payload = String(hexBuffer);
    bool success=handleSendData(payload);
    if (success)
      request->send(200, "text/plain", "ok");
    else
      request->send(401, "text/plain", "Nenhuma mensagem recebida");
  }
}

void handleNotFound(AsyncWebServerRequest *request)
{
  request->send(404, "text/plain", "Pagina nao encontrada");
}


void onWebSocketEvent(AsyncWebSocket *server,AsyncWebSocketClient *client,AwsEventType type,void *arg,uint8_t *data,size_t len) {
    static char hexBuffer[521];
    for(int i=0;i<521;i++) hexBuffer[i]='\0';
    if (type == WS_EVT_CONNECT) {
        Serial.println("Client connected");
    }

    if (type == WS_EVT_DISCONNECT) {
        Serial.println("Client disconnected");
    }

    if (type == WS_EVT_DATA) {
        if(len==0){
            client->text("ERROR: in header");
            return;
        }
        char body_is_of_type_recv[]="RECV____";
        char body_that_exist_in_data[9];
        body_that_exist_in_data[8]='\0';
        for (size_t i = 0; i < 8; i++) 
          body_that_exist_in_data[i]=data[i];
        if(strcmp(body_that_exist_in_data,body_is_of_type_recv)!=0){
          client->text("ERROR: in header");
          return;
        }

        for (size_t i = 0; i < (len-8); i++) 
            hexBuffer[i] = data[i+8];

        String payload = String(hexBuffer);
        bool success=handleSendData(payload);
        if (success)
          client->text("OK");
        else
          client->text("ERROR: to send data to FPGA");
    }
}


void setup()
{

  Serial.begin(115200);
  connect_wifi();
  create_server();

  pinMode(CS, OUTPUT);

  SPI.begin(SCLK, MISO, MOSI, CS);
  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);

  server.begin();

  // SPI.beginTransaction(SPISettings(6000000, MSBFIRST, SPI_MODE0));
  // SPI.endTransaction();
}

void loop()
{
  /*
  if (Serial.available()) {
    char c = Serial.read();
    if (c == 'r') {
      ESP.restart();
    }
    if( c=='c'){
      digitalWrite(CS, HIGH);
      Serial.println("high");
    }
    if( c=='v'){
      digitalWrite(CS, LOW);
      Serial.println("low");

    }
  }
  */
  /**
  Serial.print("change: "); Serial.println(diff_among_changes);
  delay(60000);
  **/
}