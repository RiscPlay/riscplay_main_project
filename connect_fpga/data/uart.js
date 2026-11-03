function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
async function UART_Connection() {
    var port = await navigator.serial.requestPort();

    await port.open({
        baudRate: 9600,
        dataBits: 8,
        stopBits: 1,
        parity: "none"
    });

    var reader = port.readable.getReader();
    var writer = port.writable.getWriter();

    console.log("UART conectada.");
    var buffer = [];
    return {

        async sendArray(data) {
            if (!(data instanceof Uint8Array)) {
                throw new TypeError("data must to be Uint8Array");
            }
            await writer.write(data);
        },

        async recvArray(size) {
            const data = new Uint8Array(size);
            let offset = 0;
            for (let i = 0; i < size; i++) {
                if (buffer.length == 0) {
                    const { value, done } = await reader.read();
                    buffer.push(...value);
                }
                data[i] = buffer.shift();
            }
            return data;
        },
        async close() {
            await reader.cancel();
            reader.releaseLock();

            writer.releaseLock();

            await port.close();

            console.log("UART desconectada.");
        }
    }
}
async function CommunicationProtocolOverUART(con) {
    let OP___SEND_MEMORY_TO_RISCV = 2;
    let OP___RECV_MEMORY_FROM_RISCV = 3;
    let calc_crc = (data_in, len) => {
        let crc = 0xFFFFFFFF;

        for (let i = 0; i < len; i++) {
            crc ^= data_in[i];

            for (let j = 0; j < 8; j++) {
                if (crc & 1) {
                    crc = (crc >>> 1) ^ 0xEDB88320;
                } else {
                    crc >>>= 1;
                }
            }
        }

        crc = (crc ^ 0xFFFFFFFF) >>> 0;

        return crc;
    }
    let check_if_data_was_sent_with_success = async (crc_out) => {
        console.log("check_if_data_was_sent_with_success");

        const crc_in = new Uint8Array(4);
        let success = true;
        console.log("----send crc-----");

        for (let i = 0; i < 4; i++) {
            await con.sendArray(new Uint8Array([crc_out[i]]));
        }
        console.log("----send finished-----");
        await sleep(30);
        console.log("----recv crc-----");

        // Envia os 4 bytes do CRC e recebe a resposta da UART.
        for (let i = 0; i < 4; i++) {
            const response = await con.recvArray(1);
            crc_in[i] = response[0];

        }
        console.log("----recv finished-----");



        // Compara o CRC recebido com o enviado.
        for (let i = 0; i < 4; i++) {
            if (crc_in[i] !== crc_out[i]) {
                success = false;
                break;
            }
        }

        // Envia o comando de confirmação.
        const command = success ? 0x0F : 0xF0;

        await con.sendArray(new Uint8Array([command]));

        const response = await con.recvArray(1);
        const result = response[0];

        // Equivalente ao popcount8(result ^ 0x0F).
        let value = result ^ 0x0F;
        let count = 0;

        while (value !== 0) {
            count += value & 1;
            value >>>= 1;
        }

        if (count > 3) {
            success = false;
        }

        // Log equivalente ao código C++.
        for (let i = 0; i < 4; i++) {
            console.log(`${crc_in[i]}|${crc_out[i]}`);
        }

        console.log("-------------");

        return success;
    }
    let send_header_to_fpga_comm_over_uart = async (op, addr, len) => {
        const header = new Uint8Array(9);

        header[0] = op;
        header[1] = 0;
        header[2] = 0;
        header[3] = (addr >>> 24) & 0xFF;
        header[4] = (addr >>> 16) & 0xFF;
        header[5] = (addr >>> 8) & 0xFF;
        header[6] = addr & 0xFF;
        header[7] = (len >>> 8) & 0xFF;
        header[8] = len & 0xFF;

        const crc_out_uint32 = calc_crc(header, 9);

        const crc_out = new Uint8Array([
            (crc_out_uint32 >>> 24) & 0xFF,
            (crc_out_uint32 >>> 16) & 0xFF,
            (crc_out_uint32 >>> 8) & 0xFF,
            crc_out_uint32 & 0xFF
        ]);

        await con.sendArray(header);

        return await check_if_data_was_sent_with_success(crc_out);
    }
    let send_body_to_fpga_comm_over_uart = async (body, len) => {
        console.log("send_body_to_fpga_comm_over_uart");

        if (!(body instanceof Uint8Array)) {
            throw new TypeError("body must to be Uint8Array");
        }

        if (!Number.isInteger(len) || len < 0 || len > body.length) {
            throw new RangeError("len inválido");
        }

        const data = body.subarray(0, len);
        const crc_out_uint32 = calc_crc(data, len);

        const crc_out = new Uint8Array([
            (crc_out_uint32 >>> 24) & 0xFF,
            (crc_out_uint32 >>> 16) & 0xFF,
            (crc_out_uint32 >>> 8) & 0xFF,
            crc_out_uint32 & 0xFF
        ]);

        await con.sendArray(data);


        return await check_if_data_was_sent_with_success(crc_out);
    }

    let recv_body_from_fpga_comm_over_uart = async (len) => {
        console.log("recv_body_from_fpga_comm_over_uart");

        const body_promise = con.recvArray(len);
        //const trash = new Uint8Array(len);
        //const promise_send = con.sendArray(trash);
        const body = await body_promise;
        //await promise_send;
        await sleep(30);
        const crc_out_uint32 = calc_crc(body, len);

        const crc_out = new Uint8Array([
            (crc_out_uint32 >>> 24) & 0xFF,
            (crc_out_uint32 >>> 16) & 0xFF,
            (crc_out_uint32 >>> 8) & 0xFF,
            crc_out_uint32 & 0xFF
        ]);


        const success = await check_if_data_was_sent_with_success(crc_out);
        await sleep(30);

        return {
            success,
            body
        };
    }

    return {
        async send_uint8_vector_to_fpga(addr, body, length) {
            if (!(body instanceof Uint8Array)) {
                throw new TypeError("body must to be Uint8Array");
            }

            if (!Number.isInteger(length) || length < 0 || length > body.length || length > 0xFFFF) {
                throw new RangeError("length inválido");
            }
            console.log("send header")
            const headerSuccess = await send_header_to_fpga_comm_over_uart(OP___SEND_MEMORY_TO_RISCV, addr, length);

            if (!headerSuccess) {
                console.log("error to send header")
                return false;
            }

            return await send_body_to_fpga_comm_over_uart(body, length);
        },
        async recv_uint8_vector_from_fpga(addr, length) {
            if (!Number.isInteger(length) || length < 0 || length > 0xFFFF) {
                throw new RangeError("length inválido");
            }
            console.log("send header")
            const headerSuccess = await send_header_to_fpga_comm_over_uart(
                OP___RECV_MEMORY_FROM_RISCV,
                addr,
                length
            );

            if (!headerSuccess) {
                console.log("error to send header")
                return { success: false, body: new Uint8Array(0) };
            }

            return await recv_body_from_fpga_comm_over_uart(length);
        }
    }
}
__UART_ADDR__ = "ART//"
async function connect_to_uart() {
    uart_con = await UART_Connection();
    uart_protocol = await CommunicationProtocolOverUART(uart_con);
}
async function test_sram_access(uart_con) {

    let con = await CommunicationProtocolOverUART(uart_con);
    for (var j = 0; j < 10; j++) {
        const buffer = new Uint8Array([
            0x01, 0x0A, 0xA2, 0xF1,
            0x01, 0x02, 0xAB, 0xFF
        ]);

        const sendSuccess = await con.send_uint8_vector_to_fpga(
            0x20000000,
            buffer,
            8
        );

        if (!sendSuccess) {
            console.error("Erro ao escrever na SRAM.");
            return;
        }
        const result = await con.recv_uint8_vector_from_fpga(
            0x20000000,
            8
        );

        if (!result.success) {
            console.error("Erro ao ler a SRAM.");
            return;
        }

        for (let i = 0; i < result.body.length; i++) {
            console.log(result.body[i].toString(16).padStart(2, "0"));
        }
    }
}