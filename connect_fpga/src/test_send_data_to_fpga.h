#ifndef test_send_data_to_fpga
#define test_send_data_to_fpga
#include <Arduino.h>
#include "spi_pins.h"
#include "communication_with_fpga_over_spi.h"
void send_header_for____test_comm_over_spi3(){
  uint8_t data_out[9];
  uint8_t data_in[9];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  data_out[0] =2;
  data_out[1] =0;
  data_out[2] =0; 
  data_out[3] =0;   
  data_out[4] =0;
  data_out[5] =0;
  data_out[6] =0;
  data_out[7] =UINT8_C(0x09);  
  data_out[8] =UINT8_C(0x00);


  uint32_t crc_out_uint32=calc_crc(data_out, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<9;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  delay(1);
  for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  delay(1);
  uint8_t result= SPI.transfer(0x0f);
  /**
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i],HEX);
    Serial.print("|");
    Serial.println(crc_out[i],HEX);
  }
  ***/
  ///Serial.print("crc_check_in_fpga:"); Serial.println(result);
  
}

void send_body_for____test_comm_over_spi3(){
  uint8_t data_out[1024];
  uint8_t data_in[1024];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  int32_t seed=342;
  for(int i=0;i<0x900;i++){
    seed=((seed*3457)+47129)%103291;
    data_out[i]=(uint8_t)(seed%128);
  }
  uint32_t crc_out_uint32=calc_crc(data_out, 0x900);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<0x900;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  delay(1);

 for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(213);
  }
  delay(1);

  uint8_t result= SPI.transfer(0x0f);
  
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i],HEX);
    Serial.print("|");
    Serial.println(crc_out[i],HEX);
  }
  
  Serial.print("crc_check_in_fpga3:"); Serial.println(result);

}
void test_comm_over_spi3(){
  digitalWrite(CS, HIGH); // CS começa HIGH
  delay(1);
  digitalWrite(CS, LOW); // CS começa HIGH
  delay(1);
  unsigned long ms1 = millis();
  send_header_for____test_comm_over_spi3();
  send_body_for____test_comm_over_spi3();
  unsigned long ms2 = millis();
  Serial.print("Current time spended:"); Serial.println((ms2-ms1));
  delay(1);

  digitalWrite(CS, HIGH); // CS começa HIGH
}
void send_header_for____test_comm_over_spi4(){
  uint8_t data_out[9];
  uint8_t data_in[9];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  data_out[0] =1;
  data_out[1] =0;
  data_out[2] =0; 
  data_out[3] =0;   
  data_out[4] =0;
  data_out[5] =0;
  data_out[6] =0;
  data_out[7] =UINT8_C(0x00);  
  data_out[8] =UINT8_C(0x0f);


  uint32_t crc_out_uint32=calc_crc(data_out, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<9;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  delay(1);
  for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  delay(1);
  uint8_t result= SPI.transfer(0x0f);
  /**
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i],HEX);
    Serial.print("|");
    Serial.println(crc_out[i],HEX);
  }
  ***/
  ///Serial.print("crc_check_in_fpga:"); Serial.println(result);
  
}



void send_body_for____test_comm_over_spi4(){
  uint8_t data_out[25];
  uint8_t data_in[25];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  int32_t seed=342;
  for(int i=0;i<25;i++){
    seed=((seed*3457)+47129)%103291;
    data_out[i]=(uint8_t)(seed%128);
  }
  uint32_t crc_out_uint32=calc_crc(data_out, 25);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<15;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  delay(1);

 for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  delay(1);

  uint8_t result= SPI.transfer(0x0f);
  
  for(int i=0;i<15;i++){
    Serial.print(data_in[i]);
    Serial.print("|");
    Serial.println(data_in[i]);
  }
  
  Serial.print("crc_check_in_fpga4:"); Serial.println(result);

}
void test_comm_over_spi4(){

  digitalWrite(CS, HIGH); // CS começa HIGH
  delay(1);
  digitalWrite(CS, LOW); // CS começa HIGH
  delay(1);
  unsigned long ms1 = millis();
  //test_comm_over_spi2();
  send_header_for____test_comm_over_spi4();
  send_body_for____test_comm_over_spi4();
  unsigned long ms2 = millis();
  Serial.print("Current time spended:"); Serial.println((ms2-ms1));
  delay(1);

  digitalWrite(CS, HIGH); // CS começa HIGH


}

void send_header_for____test_comm_over_spi5(){
  uint8_t data_out[9];
  uint8_t data_in[9];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  data_out[0] =2;
  data_out[1] =0;
  data_out[2] =0; 
  data_out[3] =128;   
  data_out[4] =0;
  data_out[5] =0;
  data_out[6] =0;
  data_out[7] =UINT8_C(0x01);  
  data_out[8] =UINT8_C(0x00);


  uint32_t crc_out_uint32=calc_crc(data_out, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<9;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  //delay(1);
  for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  //delay(1);
  uint8_t result= SPI.transfer(0x0f);
  
  Serial.println("********************");
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i],HEX);
    Serial.print("|");
    Serial.println(crc_out[i],HEX);
  }
  Serial.println("********************");
  Serial.print("crc_check_in_fpga:"); Serial.println(result);
}
void send_body_for____test_comm_over_spi5(){
  uint8_t data_out[256];
  uint8_t data_in[256];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  int32_t seed=342;
  for(int i=0;i<256;i++){
    seed=((seed*3457)+47129)%103291;
    data_out[i]=(uint8_t)(seed%128);
  }
  uint32_t crc_out_uint32=calc_crc(data_out, 256);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<256;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  //delay(1);

 for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  //delay(1);

  uint8_t result= SPI.transfer(0x0f);

  for(int i=0;i<256;i++){
    Serial.print(data_in[i]);
    Serial.print("|");
    Serial.println(data_out[i]);
  }
  Serial.println("-------------------");
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i]);
    Serial.print("|");
    Serial.println(crc_out[i]);
  }

  Serial.print("crc_check_in_fpga5:"); Serial.println(result);
}
void test_comm_over_spi5(){

  digitalWrite(CS, HIGH); // CS começa HIGH
  delayMicroseconds(10);
  digitalWrite(CS, LOW); // CS começa HIGH
  delayMicroseconds(10);
  unsigned long ms1 = micros();
  //test_comm_over_spi2();
  send_header_for____test_comm_over_spi5();
  send_body_for____test_comm_over_spi5();
  unsigned long ms2 = micros();
  Serial.print("Current time spended in micros:"); Serial.println((ms2-ms1));
  delay(1);

  digitalWrite(CS, HIGH); // CS começa HIGH
}



void send_header_for____test_comm_over_spi6(){
  uint8_t data_out[9];
  uint8_t data_in[9];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  data_out[0] =3;
  data_out[1] =0;
  data_out[2] =0; 
  data_out[3] =128;   
  data_out[4] =0;
  data_out[5] =0;
  data_out[6] =0;
  data_out[7] =UINT8_C(0x01);  
  data_out[8] =UINT8_C(0x00);


  uint32_t crc_out_uint32=calc_crc(data_out, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<9;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  //delay(1);
  for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  //delay(1);
  uint8_t result= SPI.transfer(0x0f);
  /*****
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i],HEX);
    Serial.print("|");
    Serial.println(crc_out[i],HEX);
  }
  Serial.println("********************");
  Serial.print("crc_check_in_fpga:"); Serial.println(result);
  ******/
  
}
void send_body_for____test_comm_over_spi6(){
  uint8_t data_out[256];
  uint8_t data_in[256];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  int32_t seed=342;
  for(int i=0;i<256;i++){
    seed=((seed*3457)+47129)%103291;
    data_out[i]=(uint8_t)(seed%128);
  }
  uint32_t crc_out_uint32=calc_crc(data_out, 256);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<256;i++){
    data_in[i]=SPI.transfer(0);
  }
  //delay(1);

 for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  //delay(1);

  uint8_t result= SPI.transfer(0x0f);

  for(int i=0;i<256;i++){
    Serial.print(data_in[i]);
    Serial.print("|");
    Serial.println(data_out[i]);
  }
  Serial.println("-------------------");
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i]);
    Serial.print("|");
    Serial.println(crc_out[i]);
  }
  Serial.print("crc_check_in_fpga6:"); Serial.println(result);

}
void test_comm_over_spi6(){

  digitalWrite(CS, HIGH); // CS começa HIGH
  delayMicroseconds(10);
  digitalWrite(CS, LOW); // CS começa HIGH
  delayMicroseconds(10);
  unsigned long ms1 = micros();
  //test_comm_over_spi2();
  send_header_for____test_comm_over_spi6();
  send_body_for____test_comm_over_spi6();
  unsigned long ms2 = micros();
  Serial.print("Current time spended in micros:"); Serial.println((ms2-ms1));
  delayMicroseconds(10);

  digitalWrite(CS, HIGH); // CS começa HIGH
}

void send_header_for____test_comm_over_spi7(){
  uint8_t data_out[9];
  uint8_t data_in[9];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  data_out[0] =2;
  data_out[1] =0;
  data_out[2] =0; 
  data_out[3] =0;   
  data_out[4] =0;
  data_out[5] =0;
  data_out[6] =64;
  data_out[7] =UINT8_C(0x00);  
  data_out[8] =UINT8_C(0x18);


  uint32_t crc_out_uint32=calc_crc(data_out, 9);

  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<9;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  //delay(1);
  for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  //delay(1);
  uint8_t result= SPI.transfer(0x0f);
  
  Serial.println("********************");
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i],HEX);
    Serial.print("|");
    Serial.println(crc_out[i],HEX);
  }
  Serial.println("********************");
  Serial.print("crc_check_in_fpga:"); Serial.println(result);
  
}
void send_body_for____test_comm_over_spi7(){
  uint8_t data_out[24];
  uint8_t data_in[24];
  uint8_t crc_in[4];
  uint8_t crc_out[4];
  for(int i=0;i<24;i++)
    data_out[i]=1;
  uint32_t crc_out_uint32=calc_crc(data_out, 24);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  //delay(50);
  for(int i=0;i<24;i++){
    data_in[i]=SPI.transfer(data_out[i]);
  }
  //delay(1);

 for(int i=0;i<4;i++){
    crc_in[i]=SPI.transfer(crc_out[i]);
  }
  //delay(1);

  uint8_t result= SPI.transfer(0x0f);
  
  for(int i=0;i<24;i++){
    Serial.print(data_in[i]);
    Serial.print("|");
    Serial.println(data_out[i]);
  }
  Serial.println("-------------------");
  for(int i=0;i<4;i++){
    Serial.print(crc_in[i]);
    Serial.print("|");
    Serial.println(crc_out[i]);
  }

  Serial.print("crc_check_in_fpga7:"); Serial.println(result);

}
void test_comm_over_spi7(){

  digitalWrite(CS, HIGH); // CS começa HIGH
  delayMicroseconds(10);
  digitalWrite(CS, LOW); // CS começa HIGH
  delayMicroseconds(10);
  unsigned long ms1 = micros();
  //test_comm_over_spi2();
  send_header_for____test_comm_over_spi7();
  send_body_for____test_comm_over_spi7();
  unsigned long ms2 = micros();
  Serial.print("Current time spended in micros:"); Serial.println((ms2-ms1));
  delay(1);

  digitalWrite(CS, HIGH); // CS começa HIGH
}
#endif