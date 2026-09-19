import json
import re



def x(i):
    return f"x{i}"

def parse_reg(r):
    return f"x{int(r, 16)}"

def u32(v):
    return v & 0xFFFFFFFF

def is_store(instr):
    return "sw" in instr or "sh" in instr or "sb" in instr

def is_load(instr):
    return "lw" in instr or "lh" in instr or "lb" in instr

def is_branch(instr):
    return instr.startswith("b")

def is_jal(instr):
    return "jal" in instr and "jal" not in instr

def is_jalr(instr):
    return "jalr" in instr

def extract_offset(asm):
    m = re.search(r"([+-]?\s*0x[0-9a-fA-F]+)", asm)
    if m:
        return int(m.group(1).replace(" ", ""), 16)
    return 0

import re

def get_register_usage(instruction):
    """
    Analyzes a RISC-V instruction and determines if rd, rs1, and rs2 are utilized.
    Returns a dictionary with boolean flags for each register type.
    """
    # Normalize instruction: remove commas and split by whitespace
    tokens = re.sub(r',', ' ', instruction).split()
    
    if not tokens:
        return None
    
    opcode = tokens[0].lower()
    
    # Mapping table: (uses_rd, uses_rs1, uses_rs2)
    # Based on RISC-V ISA instruction formats (R, I, S, B, U, J)
    instruction_usage_map = {
        # R-Type: Uses rd (destination), rs1 (source 1), and rs2 (source 2)
        "add":   (True, True, True),
        "sub":   (True, True, True),
        "sll":   (True, True, True),
        "slt":   (True, True, True),
        "sltu":  (True, True, True),
        "xor":   (True, True, True),
        "srl":   (True, True, True),
        "sra":   (True, True, True),
        "or":    (True, True, True),
        "and":   (True, True, True),

        # I-Type: Uses rd, rs1, and an immediate (No rs2)
        "addi":  (True, True, False),
        "slti":  (True, True, False),
        "sltiu": (True, True, False),
        "xori":  (True, True, False),
        "ori":   (True, True, False),
        "andi":  (True, True, False),
        "slli":  (True, True, False),
        "srli":  (True, True, False),
        "srai":  (True, True, False),
        "jalr":  (True, True, False),
        "lb":    (True, True, False),
        "lh":    (True, True, False),
        "lw":    (True, True, False),
        "lbu":    (True, True, False),
        "lhu":    (True, True, False),

        # U-Type: Uses rd and a large immediate (No rs1, No rs2)
        "lui":   (True, False, False),
        "auipc": (True, False, False),

        # J-Type: Uses rd to store Return Address (No rs1, No rs2)
        "jal":   (True, False, False),
        "j":   (True, False, False),


        # B-Type: No rd (destination), uses rs1 and rs2 for comparison
        "beq":   (False, True, True),
        "bne":   (False, True, True),
        "blt":   (False, True, True),
        "bge":   (False, True, True),
        "bltu":  (False, True, True),
        "bgeu":  (False, True, True),

        # S-Type (Store): No rd, uses rs1 (base address) and rs2 (value to save)
        "sw":    (False, True, True),
        "sb":    (False, True, True),
        "sh":    (False, True, True),
    }

    if opcode in instruction_usage_map:
        rd_active, rs1_active, rs2_active = instruction_usage_map[opcode]
        return {
            "opcode": opcode,
            "uses_rd": rd_active,
            "uses_rs1": rs1_active,
            "uses_rs2": rs2_active
        }
    
    return {"error": f"Opcode '{opcode}' not supported."}


def get_pc_tid_instr_rd_val_rd(line):
    parts = line.split()

    tid = int(parts[0].replace("#", ""))
    pc = int(parts[3], 16)
    instr_hex = parts[4]

    rd_raw = parts[6] if parts[5] == "r" else None
    rd_val = int(parts[7], 16) if len(parts) > 7 else None
    asm = " ".join(parts[8:])

    rd = parse_reg(rd_raw) if rd_raw else None
    return tid,pc,instr_hex,asm,rd,rd_val


import re

def process_val(val):
    """Garante que o valor permaneça no escopo de 32 bits assinado."""
    val = val & 0xFFFFFFFF
    if val & 0x80000000: # Se o bit 31 estiver ativo, é negativo
        return val - 0x100000000
    return val





def parse_riscv_registers(instruction):
    # Remove vírgulas e espaços extras para normalizar a string
    clean_inst = instruction.replace(',', ' ').split()
    if not clean_inst:
        return None

    opcode = clean_inst[0]
    args = clean_inst[1:]

    # Dicionário de retorno padrão
    result = {"opcode": opcode, "rs1": None, "rs2": None, "rd": None}

    # Lógica baseada no formato da instrução
    if opcode in ['addi', 'slti','sltiu', 'andi', 'ori', 'xori','slli','srli','srai']:
        # Formato: op rd, rs1, imm
        result['rd'] = args[0]
        result['rs1'] = args[1]
    
    elif opcode in ['bge', 'beq', 'bne', 'blt', 'bgeu', 'bltu']:
        # Formato: op rs1, rs2, label
        result['rs1'] = args[0]
        result['rs2'] = args[1]

    elif opcode in ['add', 'sub', 'sll','sltu','xor','srl','sra', 'or', 'and']:
        # Formato: op rd, rs1, rs2
        result['rd'] = args[0]
        result['rs1'] = args[1]
        result['rs2'] = args[2]

    elif opcode in ['jal', 'auipc', 'lui']:
        # Formato: op rd, imm/label (Não possuem rs1 ou rs2)
        result['rd'] = args[0]

    elif opcode in ['sw','sb','sh']:
        result['rs2'] = args[0]
        result['rs1'] = args[1].split("(")[1][:-1]
    elif opcode in ['lw','lb','lh','lbu','lhu']:
        result['rd'] = args[0]
        result['rs1'] = args[1].split("(")[1][:-1]
    return result

    
def get_rs1_rs2(asm,regs):
    regs_in_asm = parse_riscv_registers(asm)
    rs1=None
    rs2=None
    if "rs1" in regs_in_asm:
        rs1=regs_in_asm["rs1"]
    if "rs2" in regs_in_asm:
        rs2=regs_in_asm["rs2"]        
    
    rs1_val = regs[rs1] if rs1 else None
    rs2_val = regs[rs2] if rs2 else None
    return rs1,rs2,rs1_val,rs2_val

def get_branch_taken(asm,rs1,rs2,rs1_val,rs2_val):
    branch_taken = None

    if is_branch(asm) and rs1 and rs2:

        a = rs1_val
        b = rs2_val

        if "beq" in asm:
            branch_taken = (a == b)

        elif "bne" in asm:
            branch_taken = (a != b)

        elif "blt" in asm:
            branch_taken = (a < b)

        elif "bge" in asm:
            branch_taken = (a >= b)

        elif "bltu" in asm:
            branch_taken = (u32(a) < u32(b))

        elif "bgeu" in asm:
            branch_taken = (u32(a) >= u32(b))
    return branch_taken

def get_jal_and_jalr_flag_and_and_branch_taken_target_pc(asm,branch_taken,regs,rd,rs1_val,pc):
    target_pc = None
    is_jal_flag = False
    is_jalr_flag = False

    if is_jal(asm):

        is_jal_flag = True
        offset = extract_offset(asm)

        # salva retorno
        if rd and rd!="x0":
            regs[rd] = pc + 4

        # salto
        target_pc = pc + offset
        pc = target_pc
        branch_taken = True
        
    if is_jalr(asm):

        is_jalr_flag = True

        # heurística: rs1 + offset
        offset = extract_offset(asm)

        base = rs1_val if rs1_val is not None else 0
        target_pc = base + offset

        if rd and rd!="x0":
            regs[rd] = pc + 4

        branch_taken = True
    return is_jal_flag,is_jalr_flag,target_pc,branch_taken

def get_mem_addr_mem_op_mem_data_and_update_regs_in_memory_step(asm,regs,rs2,rd,mem):
    mem_addr = None
    mem_op = None
    mem_data = None

    mem_match = re.search(r"\[(0x[0-9a-fA-F]+)\]", asm)
    if mem_match:
        mem_addr = int(mem_match.group(1), 16)

    if is_store(asm) and rs2:
        mem[mem_addr] = regs[rs2]
        mem_op = "store"
        mem_data = regs[rs2]

    if is_load(asm) and rd:
        mem_op = "load"
        mem_data = mem.get(mem_addr, 0)
        if(rd!="x0"):
            regs[rd] = mem_data
    return mem_addr,mem_op,mem_op,mem_data

def update_regs_in_WRITEBACK_step(regs,rd,is_jal_flag,is_jalr_flag,rd_val):
    if rd and not is_jal_flag and not is_jalr_flag and rd!="x0":
        regs[rd] = rd_val if rd_val is not None else regs[rd]
        
def process_one_line(line,regs,mem):

    tid,pc,instr_hex,asm,rd,rd_val= get_pc_tid_instr_rd_val_rd(line)
    if(hex(pc)=='0x80000134'):
            print("hello")
    rs1,rs2,rs1_val,rs2_val=get_rs1_rs2(asm,regs)
    #result_of_execute=execute_rv32i_instruction_over_registers(asm, regs.deepcopy(),pc)
    branch_taken=get_branch_taken(asm,rs1,rs2,rs1_val,rs2_val)
    is_jal_flag,is_jalr_flag,target_pc,branch_taken=get_jal_and_jalr_flag_and_and_branch_taken_target_pc(asm,branch_taken,regs,rd,rs1_val,pc)

    
    mem_addr,mem_op,mem_op,mem_data=get_mem_addr_mem_op_mem_data_and_update_regs_in_memory_step(asm,regs,rs2,rd,mem)
    update_regs_in_WRITEBACK_step(regs,rd,is_jal_flag,is_jalr_flag,rd_val)
    
    
    return {
            "id": tid,
            "pc": hex(pc),
            "instr": instr_hex,
            "asm": asm,

            "rs1": rs1,
            "rs1_val": hex(rs1_val) if rs1_val!=None else "xxxxxx",

            "rs2": rs2,
            "rs2_val": hex(rs2_val) if rs2_val!=None else "xxxxxx",

            "rd": rd,
            "rd_val": hex(rd_val) if rd_val!=None else "xxxxxx",

            "branch_taken": branch_taken,

            "is_jal": is_jal_flag,
            "is_jalr": is_jalr_flag,

            "target_pc": hex(target_pc) if target_pc is not None else "xxxxx",

            "mem_op": mem_op,
            "mem_addr": hex(mem_addr) if mem_addr else "xxxx",
            "mem_data": mem_data,

            "regs_snapshot": dict(regs)
        }
    
def get_register_id(register_name):
    
    if(register_name==None):
        id="No"
    else:
        id=int(register_name[1:])
        id=f"{id:02d}"
    return id

def format_register_value(value):
    if(value==None or value=="xxxxxx"):
        return "None    "
    else:
        int_val = int(value, 16)
        return f"{int_val:08x}"
    
def print_trace_dict_to_csv(trace):
    fp = open("whispere_out.txt", "w")
    fp.write("pc      ,rs1_val ,r1,rs2_val ,r2,rd_val  ,rd\n")

    for line in trace:
        if(line['pc']=='0x80000134'):
            print("hello")
        use_of_register=get_register_usage(line['asm'])
        if(use_of_register['uses_rs1']):
            rs1_id=get_register_id(line["rs1"])
        else:
            rs1_id="No"
        if(use_of_register['uses_rs2']):
            rs2_id=get_register_id(line["rs2"])
        else:
            rs2_id="No"
        if(use_of_register['uses_rd']):
            rd_id=get_register_id(line["rd"])
        else:
            rd_id="No"
        if(use_of_register['uses_rs1']):
            rs1_val=format_register_value(line['rs1_val'])
        else:
            rs1_val="None    "
        if(use_of_register['uses_rs2']):
            rs2_val=format_register_value(line['rs2_val'])
        else:
            rs2_val="None    "
        if(use_of_register['uses_rd']):
            rd_val=format_register_value(line['rd_val'])
        else:
            rd_val="None    "

        pc=format_register_value(line['pc'])
        line_out=f"{pc},{rs1_val},{rs1_id},{rs2_val},{rs2_id},{rd_val},{rd_id}"
        fp.write(line_out+"\n")
    fp.close()
    
def process_lines():
    trace_out = []
    with open("tests\\test_c\\bubble_sort.simulation.whisper.txt") as f:
        regs = {f"x{i}": 0 for i in range(32)}
        mem = {}
        for line in f:
            if not line.strip():
                continue
            trace_out.append(process_one_line(line,regs,mem))
    print_trace_dict_to_csv(trace_out)
    
    #with open("trace_full.json", "w") as f:
    #    json.dump(trace_out, f, indent=2)
process_lines()