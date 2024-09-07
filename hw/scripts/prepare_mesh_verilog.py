import os
import sys
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', "--input", default='none', help='generated NoC folder')

args = parser.parse_args()

if args.input == 'none':
    print('Error: invalid arguments')
    sys.exit()

noc_src_dir = args.input + "/gen-collateral"
all_files = [noc_src_dir + "/" + x for x in os.listdir(noc_src_dir)]
#noc_tester = noc_src_dir + "/AXI4NoCTester.sv"
noc = noc_src_dir + "/NoC.sv"
#protocol_noc = noc_src_dir + "/ProtocolNoC.sv"


#Removing plus args
placeholder = "// plusargs lines deleted by gen_connect.py\n"

prev_line_flag = False
inside_block_flag = False
for file in all_files:
    if(not os.path.isdir(file)):
        with open(file, "r") as f:
            datafile = f.readlines()
        
        with open(file, "r") as f:
            full_file = f.read()

        file_changed = False
        cur_block = ""

        for line in datafile:
            if prev_line_flag and "begin" in line:
                inside_block_flag = True
            else:
                if prev_line_flag:
                    full_file = full_file.replace(cur_block, placeholder)
                    cur_block = ""
            
            prev_line_flag = False

            if inside_block_flag:
                cur_block = cur_block + line
                if "    end" in line:
                    full_file = full_file.replace(cur_block, placeholder)
                    cur_block = ""
                    inside_block_flag = False
            else:
                prev_line_flag = False
                if( "$plusargs" in line ):
                    cur_block = cur_block + line
                    #full_file = full_file.replace(line, placeholder)
                    file_changed = True
                    prev_line_flag = True
                
        
        if file_changed:
            with open(file, "w") as f:
                f.write(full_file)
            print("removed plusargs from ", file)