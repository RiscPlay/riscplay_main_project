import os
import subprocess

SRC_DIR = "src"
EXCLUDE_DIRS = {"dvi_tx","ppu", "gowin_sp", "gowin_rpll"}

def is_excluded(path):
    parts = path.split(os.sep)
    return any(p in EXCLUDE_DIRS for p in parts)

def main():
    original_dir = os.getcwd()
    os.chdir(SRC_DIR)
    try:
        os.remove("sim.out")
        os.remove("tb.vcd")
    except:
        pass
    
    files = []

    for root, dirs, filenames in os.walk("."):
        # remove dirs excluídos da recursão
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

        for f in filenames:
            if (f.endswith(".v") or f.endswith(".sv")) and not f.endswith("tb_test___math_moules__fibonacci.v") and not f.endswith("tb_test___recvdata.v") and not f.endswith("fifo__tb.v") and not f.endswith("hex_to_7seg_de1soc.v") and not f.endswith("fifo_debug.v"):
                full_path = os.path.join(root, f)
                if not is_excluded(full_path):
                    files.append(full_path)



    # monta comando
    cmd = ["iverilog", "-g2012", "-DSIM", "-o", "sim.out"] + files

   
    print(" ".join(cmd))

    subprocess.run(cmd)
    subprocess.run(["vvp","sim.out"])
    os.chdir(original_dir)


if __name__ == "__main__":
    main()