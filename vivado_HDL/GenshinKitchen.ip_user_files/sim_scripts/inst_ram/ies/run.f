-makelib ies_lib/xil_defaultlib -sv \
  "E:/program/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "E:/program/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_1 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../GenshinKitchen.srcs/sources_1/ip/inst_ram/sim/inst_ram.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

