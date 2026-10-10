function comp___make_program(options) {
    var components_of_type___upload_memory = [];
    components_of_type___upload_memory.push({
        "comp_uuid": uuidv4(),
        "type": COMP___UPLOAD_MEMORY__IS_FILE,
        "addr": "20000000",
        "value": "",
        "addr_mem": toHex32(0x20000000),
    });
    return {
        error: false,
        error_msg: "",
        n_total_words: 0,
        n_words_sent: 0,
        sending_data: false,
        addr_serv: options.addr_serv,
        enable_make_program_interface: false,
        components_of_type___upload_memory: components_of_type___upload_memory,
        add_component___upload_memory(type) {
            var comp_uuid = uuidv4();
            var comp = {
                "comp_uuid": comp_uuid,
                "type": type,
                "addr": "",
                "value": ""
            }
            if (type == COMP___UPLOAD_MEMORY__IS_SPRITE) {
                comp["pixels"] = "[[]]";
                comp["palette"] = "[]";
            }
            this.components_of_type___upload_memory.push(comp);
            return comp_uuid;
        },
        update_addr_value(comp_uuid, addr) {
            for (var i = 0; i < this.components_of_type___upload_memory.length; i++) {
                if (this.components_of_type___upload_memory[i]["comp_uuid"] == comp_uuid) {
                    this.components_of_type___upload_memory[i]["addr"] = addr;
                    break;
                }
            }
        }
        ,
        update_data_value(comp_uuid, type, data) {
            for (var i = 0; i < this.components_of_type___upload_memory.length; i++) {
                if (this.components_of_type___upload_memory[i]["comp_uuid"] == comp_uuid) {
                    this.components_of_type___upload_memory[i]['type'] = type;
                    if (type == COMP___UPLOAD_MEMORY__IS_FILE)
                        this.components_of_type___upload_memory[i]["value"] = data;
                    else if (type == COMP___UPLOAD_MEMORY__IS_SPRITE) {
                        this.components_of_type___upload_memory[i]['value'] = JSON.stringify(Array.from(data.dataToSend));
                        this.components_of_type___upload_memory[i]['pixels'] = JSON.stringify(data.pixels);
                        this.components_of_type___upload_memory[i]['palette'] = JSON.stringify(data.palette);
                    }
                    break;
                }

            }
        },
        remove_component(comp_uuid) {
            this.components_of_type___upload_memory = this.components_of_type___upload_memory.filter(item => item.comp_uuid !== comp_uuid);
        },
        check_if___generate_file___and___upload_program_and_data_to_fpga___can_be_called() {
            for (var i = 0; i < this.components_of_type___upload_memory.length; i++) {
                if (this.components_of_type___upload_memory[i]['value'] == "") {
                    return false;
                }
                if (this.components_of_type___upload_memory[i]['addr'] == "") {
                    return false;
                }
            }
            return true;
        },
        generate_file() {
            if (this.check_if___generate_file___and___upload_program_and_data_to_fpga___can_be_called() == false)
                return;

            const blob = new Blob(
                [JSON.stringify(this.components_of_type___upload_memory, null, 2)],
                { type: 'application/json' }
            );

            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');

            link.href = url;
            link.download = 'program.json.prog';
            link.click();

            URL.revokeObjectURL(url);
        },
        async upload_program_and_data_to_fpga() {
            this.sending_data = true;
            this.n_total_words = 0;
            for (var i = 0; i < this.components_of_type___upload_memory.length; i++) {
                var comp = this.components_of_type___upload_memory[i];
                if (comp.type == COMP___UPLOAD_MEMORY__IS_FILE) {
                    this.n_total_words = this.n_total_words + Math.round(comp.value.length / 8);
                }
                else if (comp.type == COMP___UPLOAD_MEMORY__IS_SPRITE) {
                    this.n_total_words = this.n_total_words + (new Uint32Array(Array.from(JSON.parse(comp.value)))).length;
                }
            }
            this.n_words_sent = 0;
            var n_words_sent_for_previus_components = this.n_words_sent;
            for (var i = this.components_of_type___upload_memory.length - 1; i >= 0; i--) {
                var comp = this.components_of_type___upload_memory[i];
                var progress_func = (n) => { if (this.n_words_sent < (n_words_sent_for_previus_components + n)) this.n_words_sent = n_words_sent_for_previus_components + n }
                await new Promise(resolve => setTimeout(resolve, 3000));
                if (comp.type == COMP___UPLOAD_MEMORY__IS_FILE) {
                    var data_to_send = comp.value;
                    await this.upload_file_to_memory(true, data_to_send, comp.addr, progress_func);
                }

                else if (comp.type == COMP___UPLOAD_MEMORY__IS_SPRITE) {
                    var data_to_send = (new Uint32Array(Array.from(JSON.parse(comp.value))));
                    await this.upload_data_to_sdram(data_to_send, comp.addr, progress_func);
                }
                n_words_sent_for_previus_components = this.n_words_sent;
            }
            this.n_words_sent = this.n_total_words;
            this.sending_data = false;

        },
        async uploadProgram(event) {
            var file = event.target.files[0] ?? null;

            if (!file) return;

            try {
                const texto = await file.text();
                const json = JSON.parse(texto);
                while (this.components_of_type___upload_memory.length > 0)
                    this.components_of_type___upload_memory.pop();
                for (var i = 0; i < json.length; i++) {
                    if (json[i].type == COMP___UPLOAD_MEMORY__IS_FILE) {
                        components_of_type___upload_memory.push({
                            "comp_uuid": json[i].comp_uuid,
                            "type": COMP___UPLOAD_MEMORY__IS_FILE,
                            "addr": "20000000",
                            "value": json[i].value,
                            "addr_mem": toHex32(0x20000000),
                        });
                    }
                    if (json[i].type == COMP___UPLOAD_MEMORY__IS_SPRITE) {
                        components_of_type___upload_memory.push({
                            "comp_uuid": json[i].comp_uuid,
                            "type": COMP___UPLOAD_MEMORY__IS_SPRITE,
                            "addr": json[i].addr,
                            "value": json[i].value,
                            "pixels": json[i].pixels,
                            "palette": json[i].palette,
                            "addr_mem": json[i].addr,
                        });
                    }
                }

                this.memoria = new Uint32Array(json.memoria);
            } catch (erro) {
                console.error("Erro ao carregar JSON:", erro);
            }
        },
        async upload_data_to_sdram(data, addr, update_progress) {
            if (typeof addr === "string") {
                addr = parseInt(addr, 16);
            }
            if (data == null) {
                this.error = true;
                this.error = "Need to select a IMG FILE or a Sprite file";
                return;
            }
            //this.data_total_words = data.length;
            try {
                this.error = false;
                sendUINT32ArrayToSDRAM(data, start_addr = addr, (n) => update_progress(n));
                this.error = false;
            }
            catch (e) {
                this.error = true;
                this.error_msg = e.message;
            }
        },
        async upload_file_to_memory(stop_processor_while_upload_data, dataToSend__HexFormat, addr, update_progress) {

            if (stop_processor_while_upload_data) {
                try {
                    await enable_or_stop_processor(FUNCTION__ENABLE_OR_STOP_PROCESSOR___STOP_PROCESSOR);
                }
                catch (e) {
                    this.error_msg = e.message;
                    this.error = true;
                    return;
                }
                this.error = false;
            }

            var chuncks = split512(dataToSend__HexFormat);
            //this.data_total_words = String(Math.round(dataToSend__HexFormat.length / 8));
            if (typeof addr === "string") {
                addr = parseInt(addr, 16);
            }

            for (let i = 0; i < chuncks.length; i++) {
                var addr_hex = toHex32(addr + (i * 64));
                try {
                    var response = await fetch(this.addr_serv + "/send_data", {
                        method: "POST",
                        body: addr_hex + chuncks[i]
                    });
                } catch {
                    this.error = true;
                    this.error_msg = "Error to access the endpoint " + this.addr_serv + "/send_data";
                    return;
                }
                var code = response.status;
                if (code != 200) {
                    this.error_msg = "Code " + code + " returned from endpoint: " + this.addr_serv + "/send_data, the expected is 200";
                    this.error = true;
                    return;
                }
                this.error = false;
                update_progress(Math.round((i * 64)));

            }
            update_progress(Math.round(dataToSend__HexFormat.length / 8));

            if (stop_processor_while_upload_data) {
                try {
                    await enable_or_stop_processor(FUNCTION__ENABLE_OR_STOP_PROCESSOR___ENABLE_PROCESSOR);
                }
                catch (e) {
                    this.error_msg = e.message;
                    this.error = true;
                }
                this.error = false;

            }
        }
    }
}