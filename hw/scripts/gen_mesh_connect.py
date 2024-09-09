import os
import sys
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', "--input", default='none', help='generated NoC folder')
parser.add_argument('-o', "--output", default='none', help='mesh.mk (MESH_CONNECTION)')
parser.add_argument('-en', "--mesh_enable", default=0, help='Generate mesh')
parser.add_argument('-n', "--nodes", default=1, help='number of nodes generated')

args = parser.parse_args()

if args.input == 'none' or args.output == 'none':
    print('Error: invalid arguments')
    sys.exit()

nodes = int(args.nodes)
#genereted_folder = "gpumesh.test.TestHarness.TLMesh01" #TLMesh01
#noc_src_dir = os.getcwd() + "/../generated/" + genereted_folder + "/gen-collateral"
#noc_src_dir = "/home/user/poly/gpumesh_global/chipyard/sims/verilator/generated-src/gpumesh.test.TestHarness.TLMesh01" + "/gen-collateral"
noc_src_dir = args.input + "/gen-collateral"
all_files = [noc_src_dir + "/" + x for x in os.listdir(noc_src_dir)]
#noc_tester = noc_src_dir + "/AXI4NoCTester.sv"
noc = noc_src_dir + "/NoC.sv"
#protocol_noc = noc_src_dir + "/ProtocolNoC.sv"

#Generating connection
with open(noc, "r") as f:
    datafile = f.readlines()

singnals_on_noc = []

in_module = False
for line in datafile:
    if in_module and (")" in line):
        in_module = False

    if in_module:
        
        regex = r"\b(?:input|output)?\s*(?:\[\d+:\d+\]\s*)?([a-zA-Z0-9_]+)"
        signal_names = re.findall(regex, line)
        if len(signal_names)==0:
            print("line in NoC.sv is not recognized")
        
        singnals_on_noc.append(signal_names[0])

    if (not in_module) and ("module NoC(" in line):
        in_module = True
    
def useSignal(collection, signal, verbal=True):
    try:
        collection.remove(signal)
        return True
    except ValueError as e:
        if verbal:
            print("Didnt find noc signal " + signal)
        return False

with open(args.output, 'w') as out:
    useSignal(singnals_on_noc, "clock")
    out.write("`define MESH_CONNECTION .clock(clk), \\\n")
    useSignal(singnals_on_noc, "reset")
    out.write(".reset(req_xbar_reset), \\\n")

    def noc_to_vx(x):
        return x

    head_tail = [
        ("io_ingress_","_flit_bits_head","1'b1"),
        ("io_ingress_","_flit_bits_tail","1'b1"),
        ("io_egress_", "_flit_bits_head",""),
        ("io_egress_", "_flit_bits_tail",""),
    ]

    noc_io = [
        ("io_ingress_", "_flit_ready", "core_req_ready"),
        ("io_ingress_", "_flit_valid", "core_req_valid"),
        ("io_ingress_", "_flit_bits_payload", "core_req_data_in"),
        ("io_ingress_", "_flit_bits_egress_id", "core_req_bid"),
        ("io_egress_", "_flit_ready", "per_bank_core_req_ready"),
        ("io_egress_", "_flit_valid", "per_bank_core_req_valid"),
        ("io_egress_", "_flit_bits_payload", "core_req_data_out"),
        ("io_egress_", "_flit_bits_ingress_id", "per_bank_core_req_idx")
    ]

    for n in range(nodes):
        for io in noc_io:
            useSignal(singnals_on_noc,io[0] + str(n) + io[1])
            out.write("." + io[0] + str(n) + io[1] + "(" + io[2] + "[" + str(noc_to_vx(n)) + "]), \\\n")
        for ht in head_tail:
            useSignal(singnals_on_noc,ht[0] + str(n) + ht[1])
            out.write("." + ht[0] + str(n) + ht[1] + "(" + ht[2] +"), \\\n")


    clock_i = 0
    while(useSignal(singnals_on_noc, "io_router_clocks_" + str(clock_i) + "_clock", verbal=False)):
        useSignal(singnals_on_noc, "io_router_clocks_" + str(clock_i) + "_reset")
        clock_i +=1

    for i in range(clock_i-1):
        out.write(".io_router_clocks_" + str(i) + "_clock(clk), \\\n")
        out.write(".io_router_clocks_" + str(i) + "_reset(req_xbar_reset), \\\n")
    out.write(".io_router_clocks_" + str(clock_i-1) + "_clock(clk), \\\n")
    out.write(".io_router_clocks_" + str(clock_i-1) + "_reset(req_xbar_reset)\n")

    if len(singnals_on_noc) != 0:
        print("Unconnected signals: ",singnals_on_noc)
