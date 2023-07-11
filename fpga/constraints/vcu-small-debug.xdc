create_debug_core u_ila_0 ila

set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
startgroup 
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0 ]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0 ]
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0 ]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0 ]
endgroup
connect_debug_port u_ila_0/clk [get_nets [list xlnx_ddr4_c0/inst/u_ddr4_infrastructure/addn_ui_clkout1 ]]

set_property port_width 64 [get_debug_ports u_ila_0/probe0]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[0]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[1]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[2]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[3]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[4]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[5]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[6]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[7]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[8]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[9]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[10]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[11]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[12]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[13]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[14]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[15]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[16]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[17]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[18]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[19]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[20]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[21]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[22]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[23]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[24]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[25]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[26]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[27]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[28]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[29]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[30]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[31]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[32]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[33]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[34]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[35]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[36]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[37]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[38]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[39]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[40]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[41]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[42]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[43]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[44]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[45]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[46]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[47]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[48]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[49]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[50]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[51]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[52]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[53]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[54]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[55]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[56]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[57]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[58]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[59]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[60]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[61]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[62]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/PCM[63]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list wallypipelinedsocwrapper/wallypipelinedsoc/core/TrapM ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrValidM ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[0]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[1]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[2]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[3]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[4]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[5]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[6]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[7]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[8]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[9]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[10]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[11]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[12]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[13]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[14]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[15]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[16]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[17]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[18]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[19]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[20]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[21]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[22]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[23]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[24]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[25]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[26]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[27]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[28]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[29]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[30]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/InstrM[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[0]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[1]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[2]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[3]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[4]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[5]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[6]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[7]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[8]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[9]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[10]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[11]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[12]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[13]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[14]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[15]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[16]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[17]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[18]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[19]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[20]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[21]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[22]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[23]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[24]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[25]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[26]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[27]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[28]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[29]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[30]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHADDR[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHREADY ]]

create_debug_port u_ila_0 probe
set_property port_width 64 [get_debug_ports u_ila_0/probe6]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[0]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[1]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[2]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[3]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[4]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[5]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[6]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[7]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[8]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[9]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[10]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[11]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[12]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[13]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[14]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[15]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[16]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[17]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[18]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[19]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[20]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[21]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[22]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[23]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[24]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[25]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[26]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[27]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[28]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[29]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[30]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[31]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[32]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[33]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[34]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[35]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[36]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[37]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[38]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[39]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[40]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[41]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[42]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[43]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[44]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[45]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[46]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[47]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[48]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[49]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[50]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[51]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[52]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[53]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[54]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[55]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[56]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[57]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[58]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[59]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[60]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[61]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[62]} {wallypipelinedsocwrapper/wallypipelinedsoc/core/lsu/LSUHWDATA[63]} ]]
