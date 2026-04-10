#include <WiFi.h>
#include <WebServer.h>
#include "SPIFFS.h"
#include "stdint.h"
#include <SPI.h>
#include "test_send_data_to_fpga.h"
#include "communication_with_fpga_over_spi.h"

const char* ssid = "casa_do_anderson_2";
const char* password = "1124849295";
WebServer server(80);

void connect_wifi(){
  
  // Conectar Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao Wi-Fi");
  while(WiFi.status() != WL_CONNECTED){
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.println("Wi-Fi conectado: " + WiFi.localIP().toString());

  // Montar SPIFFS
  if(!SPIFFS.begin(true)){
    Serial.println("Erro ao montar SPIFFS");
    return;
  }

}

void create_server(){
  // Configurar rotas
  server.on("/", HTTP_GET, handleRoot);
  server.on("/alpinejs.js", HTTP_GET, handleAlpinejs);

  server.on("/send_data", HTTP_POST, handleSendData);
  server.on("/stop_processor", HTTP_GET, handleStopProcessor);
  server.on("/enable_processor", HTTP_GET, handleEnableProcessor);


  server.onNotFound(handleNotFound);

  // Iniciar servidor
  server.begin();
  Serial.println("Servidor HTTP iniciado!");
}

void handleRoot() {
  File f = SPIFFS.open("/index.html", "r");
  if(!f){
    server.send(404, "text/plain", "Arquivo nao encontrado");
    return;
  }
  server.streamFile(f, "text/html");
  f.close();
}
void handleAlpinejs(){
  File f = SPIFFS.open("/alpinejs.js", "r");
  if(!f){
    server.send(404, "text/plain", "Arquivo nao encontrado");
    return;
  }
  server.streamFile(f, "text/javascript");
  f.close();
}
void handleEnableProcessor(){
  if(shutdown_or_up_processor_v2(true)){
      server.send(200, "text/plain", "ok");
  }
  else{
    server.send(400, "text/plain", "Nenhuma mensagem recebida");
  }
}
void handleStopProcessor(){
  if(shutdown_or_up_processor_v2(false)){
      server.send(200, "text/plain", "ok");
  }
  else{
    server.send(400, "text/plain", "Nenhuma mensagem recebida");
  }
}
// Receber dados POST
void handleSendData() {
  if(server.hasArg("plain")) {
    String data = server.arg("plain");
    uint8_t uint8_from_post[260];
    hexToBytes(data,uint8_from_post);
    uint8_t *body=&uint8_from_post[4];
    uint32_t addr=vector_uint8_to_uint32(uint8_from_post);

    uint32_t length_uint8_from_post=(uint32_t)((data.length()/2)-4);
    bool success=send_uint8_vector_to_fpga(addr,body,length_uint8_from_post);
    if(success)
      server.send(200, "text/plain", "ok");
    else
       server.send(401, "text/plain", "Nenhuma mensagem recebida");
  } else {
    server.send(400, "text/plain", "Nenhuma mensagem recebida");
  }
}

// Rota para páginas não encontradas
void handleNotFound() {
  server.send(404, "text/plain", "Pagina nao encontrada");
}




void setup() {

  Serial.begin(115200);
  connect_wifi();
  create_server();
  
  pinMode(CS, OUTPUT);

  SPI.begin(SCLK, MISO, MOSI, CS);
  
  //SPI.beginTransaction(SPISettings(6000000, MSBFIRST, SPI_MODE0));
  //SPI.endTransaction();
  
}


void loop() {
  server.handleClient();
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