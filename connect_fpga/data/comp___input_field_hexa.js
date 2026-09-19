function comp___input_field_hexadecimal(options) {

    if (!('block_input_value' in options) || options.block_input_value == null)
        options['block_input_value'] = false;


    return {
        label: options.label,
        buttonText: options.buttonText,
        block_input_value: options.block_input_value,
        input_value: options.initial_input_value ?? "",
        action: options.action,
        validate(e) {

            let v = e.target.value.toUpperCase().replace(/[^0-9A-F]/g, '');

            if (v.length > 6)
                v = v.slice(0, 6);

            if (v && parseInt(v, 16) > 0x200000)
                v = '1FFFFF';
            if (this.block_input_value) {
                this.input_value = options.initial_input_value;
                e.target.value = options.initial_input_value;
            }
            else {
                this.input_value = v;
                e.target.value = v;
            }
        }
    };
}