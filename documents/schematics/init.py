import zipfile
import os
import base64

# CONFIGURAÇÕES INICIAIS
foto_entrada = "tangNano20k.svg"  # O seu arquivo SVG original
nome_peca = "Sipeed_Tang_Nano_20K"
id_unico = "Sipeed_Tang_Nano_20K_FPGA_2026"

if not os.path.exists(foto_entrada):
    print(f"Erro: O arquivo '{foto_entrada}' não foi encontrado nesta pasta!")
    exit()

# 1. LER O CONTEÚDO DO SEU SVG E CONVERTER PARA BASE64
with open(foto_entrada, "rb") as svg_file:
    dados_binarios = svg_file.read()
    base64_encoded = base64.b64encode(dados_binarios).decode('utf-8')

# Criar a URI de dados informando que o conteúdo é um vetor SVG estruturado
image_data_uri = f"data:image/svg+xml;base64,{base64_encoded}"

# 2. LISTA DE PINOS DA TANG NANO 20K
pinos = [
    "GND", "VCC_5V", "IO0", "IO1", "IO2", "IO3", "IO4", "IO5", 
    "IO6", "IO7", "IO8", "IO9", "IO10", "IO11", "IO12", "IO13", 
    "IO14", "IO15", "SYS_CLK", "MODE",
    "3V3", "RST", "IO16", "IO17", "IO18", "IO19", "IO20", "IO21", 
    "IO22", "IO23", "IO24", "IO25", "IO26", "IO27", "IO28", "IO29", 
    "IO30", "IO31", "DONE", "GND"
]

# 3. GERAÇÃO COORDENADAS DOS PINOS
x_inicial = 4.50
y_superior = 1.36
passo_x = 2.53
y_inferior = 21

svg_elements_breadboard = ""
svg_elements_schematic = ""
svg_elements_pcb = ""

for i in range(20):
    x_pos = x_inicial + (i * passo_x)
    j = i + 20
    
    # Breadboard (Círculos dourados com IDs de conexão)
    svg_elements_breadboard += f'  <circle id="connector{i}pin" cx="{x_pos}mm" cy="{y_superior}mm" r="0.5mm" fill="none" stroke="#FFD700" stroke-width="0.2"/>\n'
    svg_elements_breadboard += f'  <circle id="connector{j}pin" cx="{x_pos}mm" cy="{y_inferior}mm" r="0.5mm" fill="none" stroke="#FFD700" stroke-width="0.2"/>\n'
    
    # Schematic
    y_sch_pos = 5 + (i * 2.54)
    svg_elements_schematic += f'  <line id="connector{i}pin" x1="0" y1="{y_sch_pos}" x2="5" y2="{y_sch_pos}" stroke="#858585" stroke-width="0.5"/>\n'
    svg_elements_schematic += f'  <line id="connector{j}pin" x1="35" y1="{y_sch_pos}" x2="40" y2="{y_sch_pos}" stroke="#858585" stroke-width="0.5"/>\n'

    # PCB
    svg_elements_pcb += f'    <circle id="connector{i}pad" cx="{x_pos}" cy="{y_superior}" r="0.8" fill="none" stroke="#F7A000" stroke-width="0.6"/>\n'
    svg_elements_pcb += f'    <circle id="connector{j}pad" cx="{x_pos}" cy="{y_inferior}" r="0.8" fill="none" stroke="#F7A000" stroke-width="0.6"/>\n'

# 4. CRIAÇÃO DOS ARQUIVOS COMPILADOS
svg_breadboard_content = f"""<svg xmlns="http://w3.org" xmlns:xlink="http://w3.org" width="58mm" height="22.55mm" viewBox="0 0 58 22.55">
  <g id="breadboard">
    <!-- SEU SVG EMBUTIDO EM TEXTO DE FORMA ISOLADA E PROTEGIDA -->
    <image x="0" y="0" width="58mm" height="22.55mm" xlink:href="{image_data_uri}"/>
    
    <!-- PINOS GERADOS POR CIMA -->
{svg_elements_breadboard}  </g>
</svg>"""

svg_schematic_content = f"""<svg xmlns="http://w3.org" width="40mm" height="60mm" viewBox="0 0 40 60">
  <g id="schematic">
    <rect x="5" y="2" width="30" height="55" fill="#FFFFFF" stroke="#000000" stroke-width="0.6"/>
    <text x="20" y="30" font-family="Arial" font-size="3" text-anchor="middle">Tang Nano 20K</text>
{svg_elements_schematic}  </g>
</svg>"""

svg_pcb_content = f"""<svg xmlns="http://w3.org" width="58mm" height="22.55mm" viewBox="0 0 58 22.55">
  <g id="silkscreen">
    <rect x="0" y="0" width="58" height="22.55" fill="none" stroke="#FFFFFF" stroke-width="0.2"/>
  </g>
  <g id="copper1">
    <g id="copper0">
{svg_elements_pcb}    </g>
  </g>
</svg>"""

svg_icon_content = """<svg xmlns="http://w3.org" width="10mm" height="10mm" viewBox="0 0 10 10">
  <g id="icon">
    <rect x="0" y="0" width="10" height="10" fill="#333333"/>
    <text x="5" y="6" font-family="Arial" font-size="2" fill="#FFFFFF" text-anchor="middle">20K</text>
  </g>
</svg>"""

# Gravação dos arquivos provisórios
with open("tmp_b.svg", "w", encoding="utf-8") as f: f.write(svg_breadboard_content)
with open("tmp_s.svg", "w", encoding="utf-8") as f: f.write(svg_schematic_content)
with open("tmp_p.svg", "w", encoding="utf-8") as f: f.write(svg_pcb_content)
with open("tmp_i.svg", "w", encoding="utf-8") as f: f.write(svg_icon_content)

# 5. GERAR O XML .FZP DO FRITZING
xml_connectors = ""
for i, nome_pino in enumerate(pinos):
    xml_connectors += f"""
    <connector id="connector{i}" name="{nome_pino}" type="male">
      <description>{nome_pino}</description>
      <views>
        <breadboardView><p layer="breadboard" svgId="connector{i}pin"/></breadboardView>
        <schematicView><p layer="schematic" svgId="connector{i}pin"/></schematicView>
        <pcbView>
          <p layer="copper0" svgId="connector{i}pad"/>
          <p layer="copper1" svgId="connector{i}pad"/>
        </pcbView>
      </views>
    </connector>"""

fzp_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<module fritzingVersion="0.9.3b" moduleId="{id_unico}">
  <version>1.0</version>
  <author>Python AutoGen</author>
  <title>Sipeed Tang Nano 20K</title>
  <label>FPGA</label>
  <date>2026-09-29</date>
  <tags><tag>Sipeed</tag><tag>Tang Nano</tag></tags>
  <properties><property name="family">Tang Nano</property><property name="variant">20K</property></properties>
  <views>
    <breadboardView><layers image="breadboard/{nome_peca}_breadboard.svg"><layer layerId="breadboard"/></layers></breadboardView>
    <schematicView><layers image="schematic/{nome_peca}_schematic.svg"><layer layerId="schematic"/></layers></schematicView>
    <pcbView><layers image="pcb/{nome_peca}_pcb.svg"><layer layerId="copper0"/><layer layerId="copper1"/><layer layerId="silkscreen"/></layers></pcbView>
    <iconView><layers image="icon/{nome_peca}_icon.svg"><layer layerId="icon"/></layers></iconView>
  </views>
  <connectors>{xml_connectors}</connectors>
</module>"""

fzp_filename = f"part.{id_unico}.fzp"
with open(fzp_filename, "w", encoding="utf-8") as f: f.write(fzp_content)

# 6. ENCAPSULAMENTO NO ZIP FINAL (.FZPZ)
fzpz_filename = f"{nome_peca}.fzpz"
with zipfile.ZipFile(fzpz_filename, 'w', zipfile.ZIP_DEFLATED) as arquivo_fzpz:
    arquivo_fzpz.write(fzp_filename, f"part.{id_unico}.fzp")
    arquivo_fzpz.write("tmp_b.svg", f"svg.breadboard.{nome_peca}_breadboard.svg")
    arquivo_fzpz.write("tmp_s.svg", f"svg.schematic.{nome_peca}_schematic.svg")
    arquivo_fzpz.write("tmp_p.svg", f"svg.pcb.{nome_peca}_pcb.svg")
    arquivo_fzpz.write("Sipeed_Tang_Nano_20K.svg", f"svg.icon.{nome_peca}_icon.svg")

# Limpeza final
os.remove(fzp_filename)
for f_temp in ["tmp_b.svg", "tmp_s.svg", "tmp_p.svg", "tmp_i.svg"]: os.remove(f_temp)

print(f"Sucesso! Componente com vetor protegido gerado: {fzpz_filename}")
