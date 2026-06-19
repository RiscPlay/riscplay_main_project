#ifndef communication_with_fpga_over_spi
#define communication_with_fpga_over_spi
#define LOG__SPI_COMM
//#define PUT_DELAY_AMONG_TRANSFFERS
#include <stdint.h>
#include <Arduino.h>
#include "spi_pins.h"
#include <SPI.h>
#define OP___SEND_MEMORY_TO_RISCV 2
#define OP___RECV_MEMORY_FROM_RISCV 3


uint32_t calc_crc(uint8_t *data_in, int len){
  uint32_t crc = 0xFFFFFFFF;
  for(int i=0;i<len;i++){
    crc ^= (uint32_t)data_in[i];
    for(int j=0;j<8;j++){
        if(crc & 1)
            crc = (crc >> 1) ^ 0xEDB88320;
        else
            crc >>= 1;
    }
  }
  crc ^= 0xFFFFFFFF;
  return crc;
}
void hexToBytes(String hex,uint8_t *bytes_vector) {
  int count = 0;

  for (int i = 0; i < hex.length(); i += 2) {
    bytes_vector[count++] = (uint8_t)strtol(hex.substring(i, i+2).c_str(), NULL, 16);
  }
}

void uint32_to_vector_uint8(uint32_t data, uint8_t * bytes_vector){
    bytes_vector[0]=(uint8_t)((data>>24) &UINT32_C(0xff));
    bytes_vector[1]=(uint8_t)((data>>16) &UINT32_C(0xff));
    bytes_vector[2]=(uint8_t)((data>>8) &UINT32_C(0xff));
    bytes_vector[3]=(uint8_t)(data &UINT32_C(0xff));
}

uint32_t vector_uint8_to_uint32(uint8_t *bytes_vector){
    uint32_t data;
    data=((uint32_t)bytes_vector[0])<<24;
    data=(((uint32_t)bytes_vector[1])<<16)|data;
    data=(((uint32_t)bytes_vector[2])<<8)|data;
    data=(((uint32_t)bytes_vector[3]))|data;
    return data;
}



uint8_t popcount8(uint8_t x)
{
    x = x - ((x >> 1) & 0x55);
    x = (x & 0x33) + ((x >> 2) & 0x33);
    x = (x + (x >> 4)) & 0x0F;
    return x;
}

bool check_if_data_was_sent_with_success(uint8_t *crc_out){
  uint8_t crc_in[4];
  bool success=true;
  for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  #ifdef PUT_DELAY_AMONG_TRANSFFERS
  delay(1);
  #endif
  for(int i=0;i<4;i++){
    if(crc_in[i]!=crc_out[i]){
      success=false;
      break;
    }
  }
  uint8_t result;
  if(success)
    result= SPI.transfer(0x0f);
  else
    result= SPI.transfer(0xf0);
  if(popcount8(result ^ 0x0f)>3)
    success=false;
  
  #ifdef LOG__SPI_COMM
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i]);  Serial.print("|"); Serial.println(crc_out[i]);
  }
  Serial.println("-------------");
  #endif
  return success;

}
bool shutdown_or_up_processor(bool enable){
  uint8_t header[9];
  uint8_t crc_out[4];
  header[0] =9;
  header[1] =0;
  header[2] =0; 
  header[3] =0;   
  header[4] =0;
  header[5] =0;
  header[6] =0;
  header[7] =0;  
  header[8] =(uint32_t)enable;


  uint32_t crc_out_uint32=calc_crc(header, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  for(int i=0;i<9;i++){
    SPI.transfer(header[i]);
  }
  #ifdef PUT_DELAY_AMONG_TRANSFFERS
  delay(1);
  #endif

  return check_if_data_was_sent_with_success(crc_out);
}

bool send_header_to____fpga_comm_over_spi(uint8_t op,uint32_t addr,uint32_t len){
  uint8_t header[9];
  uint8_t crc_out[4];
  header[0] =op;
  header[1] =0;
  header[2] =0; 
  header[3] =(uint8_t)((addr>>24)&UINT32_C(255));   
  header[4] =(uint8_t)((addr>>16)&UINT32_C(255));
  header[5] =(uint8_t)((addr>>8)&UINT32_C(255));
  header[6] =(uint8_t)(addr&UINT32_C(255));
  header[7] =(uint8_t)((len>>8)&UINT32_C(255));  
  header[8] =(uint8_t)(len&UINT32_C(255));


  uint32_t crc_out_uint32=calc_crc(header, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  for(int i=0;i<9;i++){
    SPI.transfer(header[i]);
  }
  #ifdef PUT_DELAY_AMONG_TRANSFFERS
  delay(1);
  #endif

  #ifdef LOG__SPI_COMM
  Serial.println("send_header_to____fpga_comm_over_spi");
  #endif
  return check_if_data_was_sent_with_success(crc_out);
}




bool send_body_to____fpga_comm_over_spi(uint8_t *body,uint32_t len){
  uint8_t crc_in[4];
  uint8_t crc_out[4];
 
  uint32_t crc_out_uint32=calc_crc(body, len);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  SPI.transferBytes(body,nullptr,len);
  /*
  for(int i=0;i<len;i++){
    
    SPI.transfer(body[i]);
  }
  */
  #ifdef PUT_DELAY_AMONG_TRANSFFERS
  delay(1);
  #endif
  #ifdef LOG__SPI_COMM
  Serial.println("send_body_to____fpga_comm_over_spi");
  #endif
  return check_if_data_was_sent_with_success(crc_out);
}

bool recv_body_from____fpga_comm_over_spi(uint8_t *body,uint32_t len){
  uint8_t crc_in[4];
  uint8_t crc_out[4];
 
 
  //delay(50);
  for(int i=0;i<len;i++){
    body[i]=SPI.transfer(0);
  }
  uint32_t crc_out_uint32=calc_crc(body, len);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  #ifdef PUT_DELAY_AMONG_TRANSFFERS
  delay(1);
  #endif
  
  #ifdef LOG__SPI_COMM
  Serial.println("recv_body_from____fpga_comm_over_spi");
  #endif
  return check_if_data_was_sent_with_success(crc_out);
}
bool send_uint8_vector_to_fpga(uint32_t addr,uint8_t *body,uint32_t length){
  /*uint8_t body_v[256];
  for(int i=0;i<(length/4);i++){
    for(int j=0;j<4;j++){
      body_v[(i*4)+(3-j)]=body[(i*4)+j];
    }
  }*/
  SPI.beginTransaction(SPISettings(6000000, MSBFIRST, SPI_MODE0));
  digitalWrite(CS, LOW); // CS começa HIGH
  delayMicroseconds(10);
  bool success=send_header_to____fpga_comm_over_spi(OP___SEND_MEMORY_TO_RISCV,addr,length); 
  if(success)
    success=send_body_to____fpga_comm_over_spi(body,length);
  delayMicroseconds(10);
  digitalWrite(CS, HIGH);
  SPI.endTransaction();
  
  return success;
}


bool recv_uint8_vector_from_fpga(uint32_t addr,uint8_t *body,uint32_t length){
  SPI.beginTransaction(SPISettings(6000000, MSBFIRST, SPI_MODE0));
  digitalWrite(CS, LOW); // CS começa HIGH
  delayMicroseconds(10);
  bool success=send_header_to____fpga_comm_over_spi(OP___RECV_MEMORY_FROM_RISCV,addr,length); 
  if(success)
    success=recv_body_from____fpga_comm_over_spi(body,length);
  delayMicroseconds(10);
  digitalWrite(CS, HIGH);
  SPI.endTransaction();
  return success;
}



bool shutdown_or_up_processor_v2(bool enable){
  uint8_t body[4];
  body[0]=0;
  body[1]=0;
  body[2]=0;
  body[3]=(uint8_t)enable;
  return send_uint8_vector_to_fpga(UINT32_C(0x100),body,4);
}
#endif