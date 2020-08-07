`ifndef VX_PRINT_INSTR
`define VX_PRINT_INSTR

`include "VX_define.vh"

task print_ex_type;
    input [`EX_BITS-1:0] ex;
    begin     
        case (ex)
            `EX_ALU: $write("ALU");     
            `EX_LSU: $write("LSU");
            `EX_CSR: $write("CSR");
            `EX_MUL: $write("MUL");
            `EX_FPU: $write("FPU");
            `EX_GPU: $write("GPU");
            default: $write("NOP");
        endcase
    end      
endtask

task print_ex_op;
  input [`EX_BITS-1:0] ex;
  input [`OP_BITS-1:0] op;
  begin
      case (ex)
        `EX_ALU: begin
            case (`ALU_BITS'(op))
                `ALU_ADD:   $write("ADD");
                `ALU_SUB:   $write("SUB");
                `ALU_SLL:   $write("SLL");
                `ALU_SRL:   $write("SRL");
                `ALU_SRA:   $write("SRA");
                `ALU_SLT:   $write("SLT");
                `ALU_SLTU:  $write("SLTU");
                `ALU_XOR:   $write("XOR");
                `ALU_OR:    $write("OR");
                `ALU_AND:   $write("AND");
                `ALU_LUI:   $write("LUI");
                `ALU_AUIPC: $write("AUIPC");
                `ALU_BEQ:   $write("BEQ");
                `ALU_BNE:   $write("BNE");
                `ALU_BLT:   $write("BLT");
                `ALU_BGE:   $write("BGE");
                `ALU_BLTU:  $write("BLTU");
                `ALU_BGEU:  $write("BGEU");           
                `ALU_JAL:   $write("JAL");
                `ALU_JALR:  $write("JALR");
                `ALU_ECALL: $write("ECALL");
                `ALU_EBREAK:$write("EBREAK");    
                `ALU_MRET:  $write("MRET");    
                `ALU_SRET:  $write("SRET");    
                `ALU_DRET:  $write("DRET");    
                default:    $write("?");
            endcase
        end        
        `EX_LSU: begin
            case (`LSU_BITS'(op))
                `LSU_LB:  $write("LB");
                `LSU_LH:  $write("LH");
                `LSU_LW:  $write("LW");
                `LSU_LBU: $write("LBU");
                `LSU_LHU: $write("LHU");
                `LSU_SB:  $write("SB");
                `LSU_SH:  $write("SH");
                `LSU_SW:  $write("SW");
                `LSU_SBU: $write("SBU");
                `LSU_SHU: $write("SHU");
                default:  $write("?");
            endcase
        end
        `EX_CSR: begin
            case (`CSR_BITS'(op))
                `CSR_RW: $write("CSRW");
                `CSR_RS: $write("CSRS");
                `CSR_RC: $write("CSRC");
                default: $write("?");
            endcase
        end
        `EX_MUL: begin
            case (`MUL_BITS'(op))
                `MUL_MUL:   $write("MUL");
                `MUL_MULH:  $write("MULH");
                `MUL_MULHSU:$write("MULHSU");
                `MUL_MULHU: $write("MULHU");
                `MUL_DIV:   $write("DIV");
                `MUL_DIVU:  $write("DIVU");
                `MUL_REM:   $write("REM");
                `MUL_REMU:  $write("REMU");
                default:    $write("?");
            endcase
        end
        `EX_FPU: begin
            case (`FPU_BITS'(op))
                `FPU_ADD:   $write("ADD");
                `FPU_SUB:   $write("SUB");
                `FPU_MUL:   $write("MUL");
                `FPU_DIV:   $write("DIV");
                `FPU_SQRT:  $write("SQRT");
                `FPU_MADD:  $write("MADD");
                `FPU_NMSUB: $write("NMSUB");
                `FPU_NMADD: $write("NMADD");
                `FPU_SGNJ:  $write("SGNJ");
                `FPU_SGNJN: $write("SGNJN");
                `FPU_SGNJX: $write("SGNJX");
                `FPU_MIN:   $write("MIN");
                `FPU_MAX:   $write("MAX");
                `FPU_CVTWS: $write("CVTWS");
                `FPU_CVTWUS:$write("CVTWUS");
                `FPU_CVTSW: $write("CVTSW");
                `FPU_CVTSWU:$write("CVTSWU");
                `FPU_MVXW:  $write("MVXW");
                `FPU_MVWX:  $write("MVWX");
                `FPU_CLASS: $write("CLASS");
                `FPU_CMP:   $write("CMP");
                default:    $write("?");
            endcase
        end
        `EX_GPU: begin
            case (`GPU_BITS'(op))
                `GPU_TMC:   $write("TMC");
                `GPU_WSPAWN:$write("WSPAWN");
                `GPU_SPLIT: $write("SPLIT");
                `GPU_JOIN:  $write("JOIN");
                `GPU_BAR:   $write("BAR");
                default:    $write("?");
            endcase
        end    
        default:;    
    endcase        
  end
endtask

task print_frm;
    input [`FRM_BITS-1:0] frm;
    begin     
        case (frm)
            `FRM_RNE: $write("RNE");     
            `FRM_RTZ: $write("RTZ");
            `FRM_RDN: $write("RDN");
            `FRM_RUP: $write("RUP");
            `FRM_RMM: $write("RMM");
            `FRM_DYN: $write("DYN");
            default: $write("?");
        endcase
    end      
endtask

`endif