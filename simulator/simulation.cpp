#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <cstddef>                 
#include <cstdint>                 
#include <cstring>                 
#include <vector>   
#include <stdint.h>
#include <stdio.h>
//#define LOG__SPI_COMM

#define OP___SEND_MEMORY_TO_RISCV 2
#define OP___RECV_MEMORY_FROM_RISCV 3

VerilatedVcdC *trace;
VerilatedContext *context;                         
// Gera um clock no testbench
int time_lapse;     
void spi_tick(Vtop* top) {   
    for(int i=0;i<80;i++){   
        time_lapse=time_lapse+13; 
        context->timeInc(5);  // Delay de 5 unidades  
        top->I_clk = 1;                
        top->eval();      
        trace->dump(context->time());             
        context->timeInc(5);  // Delay de 5 unidades                                
        top->I_clk = 0;                
        top->eval();     
        trace->dump(context->time());     
    }
}
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
static bool spi_read_bit(Vtop* top) {     
    return (static_cast<uint8_t>(top->GPIO) >> 2) & 1;                       
}                       
namespace {                        


uint8_t gpio_read(Vtop* top) {     
    return static_cast<uint8_t>(top->GPIO); 
}                                  

void gpio_write(Vtop* top, uint8_t value) { 
    top->GPIO = value;             
}                                  

void spi_set_pins(Vtop* top, bool cs_pin, bool sclk_pin, bool mosi_pin) {      
    uint8_t g = gpio_read(top);    

    // Mantém apenas o bit 2 (MISO)
    g &= 0x04;                     

    // GPIO[0] = cs                
    if (cs_pin) {                  
        g |= 0x01;                 
    }                              

    // GPIO[1] = sclk              
    if (sclk_pin) {                
        g |= 0x02;                 
    }                              

    // GPIO[3] = mosi              
    if (mosi_pin) {                
        g |= 0x08;                 
    }                              

    gpio_write(top, g);            
    top->eval();                   
}                                  

} // namespace                     

// --------------------------------------------------------------------------- 
// Início de transação SPI         
//                                 
// Assumindo CS ativo baixo:       
//   idle: CS alto                 
//   start: CS baixo               
// --------------------------------------------------------------------------- 
void spi_begin(Vtop* top) {        
    // Idle: CS alto, SCLK baixo, MOSI baixo
    spi_set_pins(top, true, false, false);  
    spi_tick(top);                 

    // Assert CS: CS baixo         
    spi_set_pins(top, false, false, false); 
    spi_tick(top);                 
}                                  

// --------------------------------------------------------------------------- 
// Fim de transação SPI            
//                                 
// CS volta para alto              
// --------------------------------------------------------------------------- 
void spi_end(Vtop* top) {          
    spi_set_pins(top, true, false, false);  
    spi_tick(top);                 
}                                  
int popcount8(uint8_t value) {
    return __builtin_popcount(value);
}
// --------------------------------------------------------------------------- 
// Envia 1 byte pelo SPI           
//                                 
// Assumindo:                      
//   - MSB first                   
//   - MOSI muda com SCLK baixo    
//   - SCLK sobe para amostrar o bit        
// --------------------------------------------------------------------------- 
uint8_t spi_transfer_byte(Vtop* top, uint8_t byte) {
    uint8_t received = 0;

    for (int bit = 7; bit >= 0; --bit) {
        const bool b = (byte >> bit) & 1;

        // MOSI muda com SCLK baixo
        spi_set_pins(top, false, false, b);
        spi_tick(top);

        // Borda de subida do SCLK
        spi_set_pins(top, false, true, b);
        spi_tick(top);

        // Lê o bit recebido pelo MISO
        received = (received << 1) | spi_read_bit(top);

    }

    return received;
}                      
bool check_if_data_was_sent_with_success(Vtop* top,uint8_t *crc_out){
  uint8_t crc_in[4];
  bool success=true;
  for(int i=0;i<4;i++){
    crc_in[i]=spi_transfer_byte(top,crc_out[i]);
  }

  for(int i=0;i<4;i++){
    if(crc_in[i]!=crc_out[i]){
      success=false;
      break;
    }
  }
  uint8_t result;
  if(success)
    result= spi_transfer_byte(top,0x0f);
  else
    result= spi_transfer_byte(top,0xf0);
  if(popcount8(result ^ 0x0f)>3)
    success=false;
  
  #ifdef LOG__SPI_COMM
  for(int i=0;i<4;i++){
    printf("%d",crc_in[i]);  printf("|"); printf("%d\n",crc_out[i]);
  }
  printf("-------------\n");
  #endif
  return success;
}


bool send_header_to____fpga_comm_over_spi(Vtop* top,uint8_t op,uint32_t addr,uint32_t len){
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
    spi_transfer_byte(top,header[i]);
  }

  return check_if_data_was_sent_with_success(top,crc_out);
}

         
bool send_body_to____fpga_comm_over_spi(Vtop* top,uint8_t *body,uint32_t len){
  uint8_t crc_in[4];
  uint8_t crc_out[4];
 
  uint32_t crc_out_uint32=calc_crc(body, len);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);
  for(int i=0;i<len;i++)
    spi_transfer_byte(top,body[i]);

  #ifdef LOG__SPI_COMM
  printf("send_body_to____fpga_comm_over_spi\n");
  #endif
  return check_if_data_was_sent_with_success(top,crc_out);
}

bool recv_body_from____fpga_comm_over_spi(Vtop* top,uint8_t *body,uint32_t len){
  uint8_t crc_in[4];
  uint8_t crc_out[4];
 
 
  for(int i=0;i<len;i++){
    body[i]=spi_transfer_byte(top,0);
  }
  uint32_t crc_out_uint32=calc_crc(body, len);
  uint32_to_vector_uint8(crc_out_uint32, crc_out);

  
  #ifdef LOG__SPI_COMM
  printf("recv_body_from____fpga_comm_over_spi\n");
  #endif
  return check_if_data_was_sent_with_success(top,crc_out);
}

bool send_uint8_vector_to_fpga(Vtop* top,uint32_t addr,uint8_t *body,uint32_t length){

    for(int i=0;i<10;i++) spi_tick(top);
    spi_begin(top);
    for(int i=0;i<10;i++) spi_tick(top);

    bool success=send_header_to____fpga_comm_over_spi(top,OP___SEND_MEMORY_TO_RISCV,addr,length); 
    if(success)
        success=send_body_to____fpga_comm_over_spi(top,body,length);
    for(int i=0;i<10;i++) spi_tick(top);
    spi_end(top);
    for(int i=0;i<10;i++) spi_tick(top);


    return success;
}


bool recv_uint8_vector_from_fpga(Vtop* top,uint32_t addr,uint8_t *body,uint32_t length){
    for(int i=0;i<10;i++) spi_tick(top);
    spi_begin(top);
    for(int i=0;i<10;i++) spi_tick(top);
    bool success=send_header_to____fpga_comm_over_spi(top,OP___RECV_MEMORY_FROM_RISCV,addr,length); 
    if(success)
        success=recv_body_from____fpga_comm_over_spi(top,body,length);
    for(int i=0;i<10;i++) spi_tick(top);
    spi_end(top);
    for(int i=0;i<10;i++) spi_tick(top);

    return success;
}
void test_sram_access(Vtop *top){
    uint8_t buffer[] = {0x01, 0x02, 0xAB, 0xFF,0x01, 0x02, 0xAB, 0xFF};
    send_uint8_vector_to_fpga(top,0x20000000, buffer,8);
    uint8_t buffer2[] = {0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00};
    recv_uint8_vector_from_fpga(top,0x20000000, buffer2,8);
    for(int i=0;i<8;i++)
        printf("%x\n",buffer2[i]);
}
void put_data_in_sdram_buffer(Vtop *top, uint8_t* data,uint32_t length){
    uint32_t addr_to_set_buffer=(UINT32_C(1)<<28)+(UINT32_C(1) << 22) + (UINT32_C(0x101) << 13);
    send_uint8_vector_to_fpga(top,addr_to_set_buffer, data,length);
}
void send_buffer_to_sdram(Vtop *top, uint32_t sdram_addr,uint32_t length){
    uint32_t op_write=1;
    uint32_t addr_to_send_cmd_to_sdram_store_data=(UINT32_C(1)<<28)+(UINT32_C(1) << 22) + (UINT32_C(1) << 21);
    uint32_t sdram_write_command=(sdram_addr<<9)|(length << 2) | op_write;
    uint32_t command_bytes=sdram_write_command;
    uint8_t sdram_write_command_bytes[]={
        (command_bytes >> 24) & 0xFF, 
        (command_bytes >> 16) & 0xFF, 
        (command_bytes >> 8) & 0xFF,
        command_bytes & 0xFF
     };
    send_uint8_vector_to_fpga(top,addr_to_send_cmd_to_sdram_store_data, sdram_write_command_bytes,4);
}
uint8_t* get_data_from_buffer(Vtop *top, int length){
    uint32_t addr_to_get_buffer=(UINT32_C(1)<<28)+(UINT32_C(1) << 22);
    uint8_t *buffer = new  uint8_t[256];
    recv_uint8_vector_from_fpga(top,addr_to_get_buffer, buffer,length);
    return buffer;
}
void get_sdram_data_and_put_in_buffer(Vtop *top, uint32_t sdram_addr,uint32_t length){
    uint32_t op_read=0;
    uint32_t addr_to_send_cmd_to_sdram_store_data=(UINT32_C(1)<<28)+(UINT32_C(1) << 22) + (UINT32_C(1) << 21);
    uint32_t sdram_write_command=(sdram_addr<<9)|(length << 2) | op_read;
    uint32_t command_bytes=sdram_write_command;
    uint8_t sdram_write_command_bytes[]={
        (command_bytes >> 24) & 0xFF, 
        (command_bytes >> 16) & 0xFF, 
        (command_bytes >> 8) & 0xFF,
        command_bytes & 0xFF
     };
    send_uint8_vector_to_fpga(top,addr_to_send_cmd_to_sdram_store_data, sdram_write_command_bytes,4);
}

uint32_t* convert_big_endian(const uint8_t* data, uint32_t length)
{
    if (length % 4 != 0)
        return nullptr;

    uint32_t count = length / 4;
    uint32_t* result = new uint32_t[count];

    for (uint32_t i = 0; i < count; i++) {
        uint32_t j = i * 4;

        result[i] = ((uint32_t)data[j]     << 24) |
                    ((uint32_t)data[j + 1] << 16) |
                    ((uint32_t)data[j + 2] <<  8) |
                    ((uint32_t)data[j + 3]);
    }

    return result;
}
uint8_t* convert_uint32_big_endian__to_uint8(const uint32_t* data, uint32_t length)
{
    uint8_t* result = new uint8_t[length * 4];

    for (uint32_t i = 0; i < length; i++) {
        result[i * 4]     = (data[i] >> 24) & 0xFF;
        result[i * 4 + 1] = (data[i] >> 16) & 0xFF;
        result[i * 4 + 2] = (data[i] >> 8)  & 0xFF;
        result[i * 4 + 3] = data[i] & 0xFF;
    }

    return result;
}

uint8_t* get_subarray_with_limit_of_256_elements_from_array(uint8_t *array, int array__length,int i){
    uint8_t* result = new uint8_t[256];
    int length___buffer_to_send=0;
    for(int j=0;j<256;j++){
        if(i+j>= array__length)
            break;
        result[j]=array[i+j];
        length___buffer_to_send++;
    }
    return result;
}
bool send_data_to_sdram(Vtop *top,uint32_t sdram_addr,uint8_t* data,uint32_t length){
    if((length%4)!=0)
        return false;
    int i=0;
    while(i<length){
        uint8_t *chunck=get_subarray_with_limit_of_256_elements_from_array(data, length,i);
        i=i+256;
        int chunck_length=256;
        if(i>=length)
            chunck_length=length%256;

        for(int i=0;i<40;i++) spi_tick(top);
        put_data_in_sdram_buffer(top,chunck,chunck_length);
        for(int i=0;i<40;i++) spi_tick(top);
        send_buffer_to_sdram(top, sdram_addr,chunck_length/4);
        for(int i=0;i<40;i++) spi_tick(top);

        sdram_addr=sdram_addr+64;
        delete chunck;
        if(i>=length) break;
    }
    return true;
}

bool get_data_from_sdram(Vtop *top,uint32_t sdram_addr,uint8_t *buffer,int length){
    if((length%4)!=0)
        return false;
    int i=0;
    while(i<length){
        int i_prev=i;
        i=i+256;
        int chunck_length=256;
        if(i>=length)
            chunck_length=length%256;
        get_sdram_data_and_put_in_buffer(top, sdram_addr,chunck_length/4);
        for(int i=0;i<40;i++) spi_tick(top);
        uint8_t *chunck=get_data_from_buffer(top,chunck_length);
        for(int i=0;i<40;i++) spi_tick(top);

        for(int j=0;j<chunck_length;j++){
            buffer[i_prev+j]=chunck[j];
        }
        sdram_addr=sdram_addr+64;
        delete chunck;
        if(i>=length) break;
    }
    return true;
}
class LCG {
private:
    uint32_t seed;

public:
    explicit LCG(uint32_t initial_seed) : seed(initial_seed) {}

    uint8_t random() {
        seed = 1664525u * seed + 1013904223u;
        return static_cast<uint8_t>(seed >> 24);
    }
};
void test_sdram_access(Vtop *top){
    int length_buffer=1234*4;
    LCG rng(12345);
    uint8_t *buffer = new uint8_t[length_buffer];
    for(int i=0;i<length_buffer;i++)
        buffer[i]=rng.random();
    send_data_to_sdram(top,0x0, buffer,length_buffer);
    uint8_t *buffer2= new uint8_t[length_buffer];
    get_data_from_sdram(top,0x0, buffer2,length_buffer);
    for(int i=0;i<length_buffer;i++){
        if(buffer[i]!= buffer2[i]){
            printf("erro\n");
        }
    }
}
int main(int argc, char** argv) {  
    Verilated::commandArgs(argc, argv); 
    VerilatedVcdC trace1;   
    VerilatedContext context1;
    trace=&trace1;
    context=&context1;
    context->traceEverOn(true);  
    Vtop top(context);   
                        
    top.trace(trace, 20);
    top.eval();
    trace->open("wave.vcd");
    //test_sram_access(&top);
    test_sdram_access(&top);
    trace->close();

    top.final();
    printf("%d\n",time_lapse);
    return 0;
}            