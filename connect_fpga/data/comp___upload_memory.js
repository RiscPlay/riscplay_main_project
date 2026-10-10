

function transform_bmp_pallet_and_8bit_pixels_in_array_of_uint32(pixels, palette) {
    var uint32_data = 0;
    var n_uint8_stored__in__uint32_to_transform_in_hex = 0;
    const img = new Uint32Array(256 + pixels.length * pixels[0].length);
    let point_to_write_in_img = 0;
    for (let i = 0; i < palette.length; i++) {
        img[i] = ((palette[i].r << 16) >>> 0) + ((palette[i].g << 8) >>> 0) + (palette[i].b >>> 0);
    }
    for (let i = 0; i < pixels.length; i++) {
        for (let j = 0; j < pixels[i].length; j++) {
            uint32_data = ((uint32_data << 8) >>> 0) + pixels[i][j];
            n_uint8_stored__in__uint32_to_transform_in_hex = n_uint8_stored__in__uint32_to_transform_in_hex + 1;
            if (n_uint8_stored__in__uint32_to_transform_in_hex == 4) {
                n_uint8_stored__in__uint32_to_transform_in_hex = 0;
                img[256 + point_to_write_in_img] = uint32_data;
                point_to_write_in_img = point_to_write_in_img + 1;
                uint32_data = 0;
            }
        }
    }
    return img.slice(0, point_to_write_in_img + 256);
}
function drawBMPInCanvas(pixels, palette, canvasID) {
    const canvas = document.getElementById(canvasID);
    if (canvas == null) return;
    if (pixels[0].length == 0) return;

    canvas.width = pixels[0].length;
    canvas.height = pixels.length;

    const ctx = canvas.getContext("2d");

    const imageData = ctx.createImageData(pixels[0].length, pixels.length);
    for (let i = 0; i < pixels.length; i++) {
        for (let j = 0; j < pixels[0].length; j++) {
            imageData.data[((i * pixels[0].length + j) * 4) + 0] = palette[pixels[i][j]].r;
            imageData.data[((i * pixels[0].length + j) * 4) + 1] = palette[pixels[i][j]].g;
            imageData.data[((i * pixels[0].length + j) * 4) + 2] = palette[pixels[i][j]].b;
            imageData.data[((i * pixels[0].length + j) * 4) + 3] = 255;
        }
    }
    ctx.putImageData(imageData, 0, 0);
}

function comp___upload_memory(options) {

    if (!('block_input_value' in options))
        options['block_input_value'] = false;
    if (!("addr_mem" in options))
        options["addr_mem"] = ""
    var display_canvas = false;
    if (!('comp_uuid' in options))
        var comp_uuid = uuidv4();
    else
        var comp_uuid = options.comp_uuid;

    if (options.type == COMP___UPLOAD_MEMORY__IS_IMAGE || options.type == COMP___UPLOAD_MEMORY__IS_SPRITE)
        display_canvas = true;
    if (!("canvas_w" in options))
        options["canvas_w"] = 320;
    if (!("canvas_h" in options))
        options["canvas_h"] = 180;
    if (!('func_to_call_when_data_is_updated' in options)) {
        options['func_to_call_when_data_is_updated'] = (comp_uuid, type, data) => { };
    }
    if (!('func_to_call_when_addr_is_updated' in options)) {
        options['func_to_call_when_addr_is_updated'] = (comp_uuid, addr) => { };
    }

    if (!('block_action_send' in options)) {
        options['block_action_send'] = false;
    }
    if (!("show_warnings_about_addr_or_file_need_to_be_selected" in options)) {
        options['show_warnings_about_addr_or_file_need_to_be_selected'] = false;
    }

    if (!("pixels" in options))
        options['pixels'] = [[]];
    else
        options['pixels'] = JSON.parse(options.pixels);

    if (!("palette" in options))
        options['palette'] = [];
    else
        options['palette'] = JSON.parse(options.palette);
    if (!("dataToSend__HexFormat" in options))
        options['dataToSend__HexFormat'] = null;
    if (options.dataToSend__HexFormat == "")
        options.dataToSend__HexFormat = null;
    if (!("dataToSend" in options))
        options['dataToSend'] = null;
    if (options.dataToSend == "")
        options.dataToSend = null;
    if (options.dataToSend != null)
        options.dataToSend = new Uint32Array(JSON.parse(options.dataToSend));
    if (!("block_remove_action" in options))
        options.block_remove_action = true;
    if (!("remove_component" in options)) {
        options.remove_component = (comp_uuid) => { };
    }
    return {
        label: options.label,
        addr_mem: options.addr_mem,
        addr_serv: options.addr_serv,
        block_input_value: options.block_input_value,
        error: false,
        canvas_w: options.canvas_w,
        canvas_h: options.canvas_h,
        canvasID: uuidv4(),
        fileInputID: uuidv4(),
        type: options.type,
        dataToSend: options.dataToSend,
        dataToSend__HexFormat: options.dataToSend__HexFormat,
        data_words_sent: 0,
        data_total_words: 0,
        error_msg: "",
        file_name_sel: "",
        display_canvas: display_canvas,
        palette: options.palette,
        pixels: options.pixels,
        block_remove_action: options.block_remove_action,
        remove_component: options.remove_component,
        func_to_call_when_addr_is_updated___from_parent: options.func_to_call_when_addr_is_updated,
        func_to_call_when_data_is_updated: options.func_to_call_when_data_is_updated,
        comp_uuid: options.comp_uuid,
        block_action_send: options.block_action_send,
        show_warnings_about_addr_or_file_need_to_be_selected: options.show_warnings_about_addr_or_file_need_to_be_selected,
        async file_upload_box____click_event() {
            document.getElementById(this.fileInputID).click()
        },
        async func_to_call_when_addr_is_updated(addr) {
            this.addr_mem = addr;
            this.func_to_call_when_addr_is_updated___from_parent(this.comp_uuid, addr);
        },
        async upload_data_to_memory(data, addr) {
            if (this.dataToSend__HexFormat == null) {
                this.error = true;
                this.error = "Need to select a file";
                return;
            }
            this.error = false;
            try {
                this.sendFile(true, dataToSend__HexFormat);
            }
            catch (e) {
                this.error = true;
                this.error_msg = e.message;
            }
        },
        async upload_data_to_sdram(data, addr) {
            if (typeof addr === "string") {
                addr = parseInt(addr, 16);
            }
            if (data == null) {
                this.error = true;
                this.error = "Need to select a IMG FILE or a Sprite file";
                return;
            }
            this.data_total_words = data.length;
            try {
                this.error = false;
                sendUINT32ArrayToSDRAM(data, start_addr = addr, (n) => { this.data_words_sent = n });
                this.error = false;
            }
            catch (e) {
                this.error = true;
                this.error_msg = e.message;
            }
        },
        async uploadDataToFPGA(addr) {
            if (this.type == COMP___UPLOAD_MEMORY__IS_IMAGE || this.type == COMP___UPLOAD_MEMORY__IS_SPRITE)
                await this.upload_data_to_sdram(this.dataToSend, addr)
            else if (this.type == COMP___UPLOAD_MEMORY__IS_FILE)
                await this.upload_file_to_memory(true, this.dataToSend__HexFormat, addr);
            else {
                this.error = true;
                this.error_msg = "Wrong option for  upload type. Option code:" + this.type;
            }
        },
        async action_send_file_to_js_browser_memory(event) {
            try {
                const file = event.target.files[0];
                if (this.type == COMP___UPLOAD_MEMORY__IS_FILE) {
                    this.dataToSend__HexFormat = await this.loadfile(file);
                    this.func_to_call_when_data_is_updated(comp_uuid, COMP___UPLOAD_MEMORY__IS_FILE, this.dataToSend__HexFormat);
                }
                else if (this.type == COMP___UPLOAD_MEMORY__IS_IMAGE) {
                    this.dataToSend = await this.loadIMG(file);
                    this.func_to_call_when_data_is_updated(comp_uuid, COMP___UPLOAD_MEMORY__IS_IMAGE, this.dataToSend);
                }
                else if (this.type == COMP___UPLOAD_MEMORY__IS_SPRITE) {
                    var data = await this.loadBMP(file);
                    this.dataToSend = data["dataToSend"];
                    this.func_to_call_when_data_is_updated(comp_uuid, COMP___UPLOAD_MEMORY__IS_SPRITE, data);
                }
                else {
                    this.error = true;
                    this.error_msg = "Wrong option for  upload type. Option code:" + this.type;
                    return;
                }
            }
            catch (e) {
                this.error = true;
                this.error_msg = e.message;
                return;
            }
            this.error = false;

        },
        async upload_file_to_memory(stop_processor_while_upload_data, dataToSend__HexFormat, addr) {

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
            this.data_total_words = String(Math.round(dataToSend__HexFormat.length / 8));
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
                this.data_words_sent = String(Math.round((i * 64)));

            }
            this.data_words_sent = String(Math.round(dataToSend__HexFormat.length / 8));
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
        },
        async loadfile(file) {
            this.file_name_sel = file ? file.name : "File don't selected";
            const buffer = await file.arrayBuffer();
            const bytes = new Uint8Array(buffer);

            let hex = "";
            for (let b of bytes) {
                hex += b.toString(16).padStart(2, "0");
            }

            return hex;
        },
        async loadBMP(file) {
            var data;
            if (!file) return;
            try {
                data = await parseBMP(file);
            }
            catch {
                throw new Error("Wrong format to sprite. The correct format is BMP 8 bits");
            }

            var uint32_data = 0;
            var n_uint8_stored__in__uint32_to_transform_in_hex = 0;
            const img = transform_bmp_pallet_and_8bit_pixels_in_array_of_uint32(data.pixels, data.palette)

            await this.$nextTick();
            drawBMPInCanvas(data.pixels, data.palette, this.canvasID);
            return { "dataToSend": img, "pixels": data.pixels, "palette": data.palette };
        },
        async loadIMG(file) {
            if (!file) return;

            const img = new Image();
            img.src = URL.createObjectURL(file);

            await img.decode();
            const canvas = document.getElementById(this.canvasID);
            const ctx = canvas.getContext("2d");
            canvas.width = 640;
            canvas.height = 360;
            ctx.drawImage(img, 0, 0, 640, 360);

            const imageData = ctx.getImageData(0, 0, 640, 360);
            const pixels = imageData.data;
            const framebuffer = new Uint32Array(230400); //(640*360)

            for (let i = 0; i < pixels.length; i += 4) {
                framebuffer[Math.floor(i / 4)] = (pixels[i] << 16) | (pixels[i + 1] << 8) | (pixels[i + 2]);
            }
            return framebuffer;
        }
    };
}