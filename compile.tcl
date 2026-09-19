# =============================================================
# Gowin FPGA - Build existing .gprj project from command line
# =============================================================

puts "=== Opening existing project ==="
open_project riscplay_main_project.gprj

# Optional: Change device if needed (uncomment and adjust)
# set_device -name GW1N-LV9LQ144C6/I5

# Optional: Override top module if necessary
# set_option -top_module your_top_module_name

puts "=== Running full synthesis + Place & Route + Bitstream ==="
run all





puts "=== Build finished! ==="
puts "Bitstream location: impl/pnr/your_project.fs"