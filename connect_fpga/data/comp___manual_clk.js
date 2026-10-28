function comp___manual_clk_____sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function comp___manual_clk(options) {

    return {
        manual_clock: false,
        error: false,
        async change_clock_type() {
            var end_point = "enable_manual_clk";
            if (this.manual_clock == false)
                end_point = "/disable_manual_clk";

            try {
                var response = await fetch(addr_serv + end_point, {
                    method: "GET",
                });
            } catch {
                this.error = true;
                return;
            }
            var code = response.status;
            if (code != 200) {
                this.error = true;
                return;
            }
        },
        async clock_signal() {
            try {
                var response = await fetch(addr_serv + "/set_manual_clk_off", {
                    method: "GET",
                });
            } catch {
                this.error = true;
                return;
            }
            var code = response.status;
            if (code != 200) {
                this.error = true;
                return;
            }
            await comp___manual_clk_____sleep(100);
            try {
                var response = await fetch(addr_serv + "/set_manual_clk_on", {
                    method: "GET",
                });
            } catch {
                this.error = true;
                return;
            }
            var code = response.status;
            if (code != 200) {
                this.error = true;
                return;
            }

        }
    }
}