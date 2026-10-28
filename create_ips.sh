#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GOWIN_IDE="$(find /opt /usr/local /home -type f -name 'gw_sh' -print -quit 2>/dev/null)"
PROJECT_DIR=$SCRIPT_DIR
IPC_FILE="$PROJECT_DIR/src/sdram_ip/sdram_controller_hs.ipc"
echo $IPC_FILE
cd "$PROJECT_DIR"
PROJECT_FILE="$PROJECT_DIR/riscplay_main_project.gprj"
TCL_FILE="$(mktemp --suffix=.tcl)"
trap 'rm -f "$TCL_FILE"' EXIT

cat > "$TCL_FILE" <<EOF
puts "IPs disponíveis: [get_ips *]"

puts "=== Abrindo projeto ==="
open_project {$PROJECT_FILE}

puts "=== Carregando configuracao SDRAM ==="
read_ipc {$IPC_FILE}

puts "=== Localizando IP ==="
set ip [get_ips SDRAM_Controller_HS_Top]
puts "IP encontrado: \$ip"

puts "=== Gerando IP ==="
generate_target \$ip -force

puts "=== Concluido ==="
exit
EOF

"$GOWIN_IDE" "$TCL_FILE"