function comp___input_field_hexadecimal(options) {

    if (!('block_input_value' in options) || options.block_input_value == null)
        options['block_input_value'] = false;

    var display_button_to_call_action = true;
    if (!('action' in options)) {
        options['action'] = () => { };
        display_button_to_call_action = false;
    }
    if (!('function_to_call_when___input_value___changed' in options)) {
        options['function_to_call_when___input_value___changed'] = (x) => { };
    }
    return {
        label: options.label,
        buttonText: options.buttonText,
        block_input_value: options.block_input_value,
        input_value: options.initial_input_value ?? "",
        action: options.action,
        display_button_to_call_action: display_button_to_call_action,
        function_to_call_when___input_value___changed: options.function_to_call_when___input_value___changed,
        validate(e) {

            let v = e.target.value.toUpperCase().replace(/[^0-9A-F]/g, '');

            if (v.length > 6)
                v = v.slice(0, 6);

            if (v && parseInt(v, 16) > 0x200000)
                v = '1FFFFF';
            if (this.block_input_value) {
                this.input_value = options.initial_input_value;
                e.target.value = options.initial_input_value;
                this.function_to_call_when___input_value___changed(this.input_value);

            }
            else {
                this.input_value = v;
                e.target.value = v;
                this.function_to_call_when___input_value___changed(this.input_value);

            }
        }
    };
}