import os

def export_verilog_to_markdown(directory, output_md="verilog_dump.md"):
    verilog_files = []

    # Coleta arquivos .v e .vh
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".v") or file.endswith(".vh"):
                full_path = os.path.join(root, file)
                verilog_files.append(full_path)

    verilog_files.sort()

    with open(output_md, "w", encoding="utf-8") as md:
        md.write("# Verilog Project Dump\n\n")

        for file_path in verilog_files:
            rel_path = os.path.relpath(file_path, directory)

            md.write(f"## 📄 {rel_path}\n\n")
            md.write("```verilog\n")

            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    md.write(f.read())
            except Exception as e:
                md.write(f"// ERROR reading file: {e}\n")

            md.write("\n```\n\n")

    print(f"Markdown gerado: {output_md}")


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Uso: python export.py <diretorio>")
        exit(1)

    export_verilog_to_markdown(sys.argv[1])