create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 65536 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN true [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0 ]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0 ]
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0 ]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0 ]
create_debug_port u_ila_0  trig_in
create_debug_port u_ila_0  trig_in_ack  
connect_debug_port u_ila_0/trig_in [get_nets IlaTrigger]
connect_debug_port u_ila_0/clk [get_nets CPUCLK]

set_property port_width 64 [get_debug_ports u_ila_0/probe0]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {wallypipelinedsoc/core/PCM[0]} {wallypipelinedsoc/core/PCM[1]} {wallypipelinedsoc/core/PCM[2]} {wallypipelinedsoc/core/PCM[3]} {wallypipelinedsoc/core/PCM[4]} {wallypipelinedsoc/core/PCM[5]} {wallypipelinedsoc/core/PCM[6]} {wallypipelinedsoc/core/PCM[7]} {wallypipelinedsoc/core/PCM[8]} {wallypipelinedsoc/core/PCM[9]} {wallypipelinedsoc/core/PCM[10]} {wallypipelinedsoc/core/PCM[11]} {wallypipelinedsoc/core/PCM[12]} {wallypipelinedsoc/core/PCM[13]} {wallypipelinedsoc/core/PCM[14]} {wallypipelinedsoc/core/PCM[15]} {wallypipelinedsoc/core/PCM[16]} {wallypipelinedsoc/core/PCM[17]} {wallypipelinedsoc/core/PCM[18]} {wallypipelinedsoc/core/PCM[19]} {wallypipelinedsoc/core/PCM[20]} {wallypipelinedsoc/core/PCM[21]} {wallypipelinedsoc/core/PCM[22]} {wallypipelinedsoc/core/PCM[23]} {wallypipelinedsoc/core/PCM[24]} {wallypipelinedsoc/core/PCM[25]} {wallypipelinedsoc/core/PCM[26]} {wallypipelinedsoc/core/PCM[27]} {wallypipelinedsoc/core/PCM[28]} {wallypipelinedsoc/core/PCM[29]} {wallypipelinedsoc/core/PCM[30]} {wallypipelinedsoc/core/PCM[31]} {wallypipelinedsoc/core/PCM[32]} {wallypipelinedsoc/core/PCM[33]} {wallypipelinedsoc/core/PCM[34]} {wallypipelinedsoc/core/PCM[35]} {wallypipelinedsoc/core/PCM[36]} {wallypipelinedsoc/core/PCM[37]} {wallypipelinedsoc/core/PCM[38]} {wallypipelinedsoc/core/PCM[39]} {wallypipelinedsoc/core/PCM[40]} {wallypipelinedsoc/core/PCM[41]} {wallypipelinedsoc/core/PCM[42]} {wallypipelinedsoc/core/PCM[43]} {wallypipelinedsoc/core/PCM[44]} {wallypipelinedsoc/core/PCM[45]} {wallypipelinedsoc/core/PCM[46]} {wallypipelinedsoc/core/PCM[47]} {wallypipelinedsoc/core/PCM[48]} {wallypipelinedsoc/core/PCM[49]} {wallypipelinedsoc/core/PCM[50]} {wallypipelinedsoc/core/PCM[51]} {wallypipelinedsoc/core/PCM[52]} {wallypipelinedsoc/core/PCM[53]} {wallypipelinedsoc/core/PCM[54]} {wallypipelinedsoc/core/PCM[55]} {wallypipelinedsoc/core/PCM[56]} {wallypipelinedsoc/core/PCM[57]} {wallypipelinedsoc/core/PCM[58]} {wallypipelinedsoc/core/PCM[59]} {wallypipelinedsoc/core/PCM[60]} {wallypipelinedsoc/core/PCM[61]} {wallypipelinedsoc/core/PCM[62]} {wallypipelinedsoc/core/PCM[63]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list wallypipelinedsoc/core/TrapM ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list wallypipelinedsoc/core/InstrValidM ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {wallypipelinedsoc/core/InstrM[0]} {wallypipelinedsoc/core/InstrM[1]} {wallypipelinedsoc/core/InstrM[2]} {wallypipelinedsoc/core/InstrM[3]} {wallypipelinedsoc/core/InstrM[4]} {wallypipelinedsoc/core/InstrM[5]} {wallypipelinedsoc/core/InstrM[6]} {wallypipelinedsoc/core/InstrM[7]} {wallypipelinedsoc/core/InstrM[8]} {wallypipelinedsoc/core/InstrM[9]} {wallypipelinedsoc/core/InstrM[10]} {wallypipelinedsoc/core/InstrM[11]} {wallypipelinedsoc/core/InstrM[12]} {wallypipelinedsoc/core/InstrM[13]} {wallypipelinedsoc/core/InstrM[14]} {wallypipelinedsoc/core/InstrM[15]} {wallypipelinedsoc/core/InstrM[16]} {wallypipelinedsoc/core/InstrM[17]} {wallypipelinedsoc/core/InstrM[18]} {wallypipelinedsoc/core/InstrM[19]} {wallypipelinedsoc/core/InstrM[20]} {wallypipelinedsoc/core/InstrM[21]} {wallypipelinedsoc/core/InstrM[22]} {wallypipelinedsoc/core/InstrM[23]} {wallypipelinedsoc/core/InstrM[24]} {wallypipelinedsoc/core/InstrM[25]} {wallypipelinedsoc/core/InstrM[26]} {wallypipelinedsoc/core/InstrM[27]} {wallypipelinedsoc/core/InstrM[28]} {wallypipelinedsoc/core/InstrM[29]} {wallypipelinedsoc/core/InstrM[30]} {wallypipelinedsoc/core/InstrM[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {wallypipelinedsoc/core/lsu/MemRWM[0]} {wallypipelinedsoc/core/lsu/MemRWM[1]} ]]

create_debug_port u_ila_0 probe
set_property port_width 64 [get_debug_ports u_ila_0/probe5]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {wallypipelinedsoc/core/lsu/IEUAdrM[0]} {wallypipelinedsoc/core/lsu/IEUAdrM[1]} {wallypipelinedsoc/core/lsu/IEUAdrM[2]} {wallypipelinedsoc/core/lsu/IEUAdrM[3]} {wallypipelinedsoc/core/lsu/IEUAdrM[4]} {wallypipelinedsoc/core/lsu/IEUAdrM[5]} {wallypipelinedsoc/core/lsu/IEUAdrM[6]} {wallypipelinedsoc/core/lsu/IEUAdrM[7]} {wallypipelinedsoc/core/lsu/IEUAdrM[8]} {wallypipelinedsoc/core/lsu/IEUAdrM[9]} {wallypipelinedsoc/core/lsu/IEUAdrM[10]} {wallypipelinedsoc/core/lsu/IEUAdrM[11]} {wallypipelinedsoc/core/lsu/IEUAdrM[12]} {wallypipelinedsoc/core/lsu/IEUAdrM[13]} {wallypipelinedsoc/core/lsu/IEUAdrM[14]} {wallypipelinedsoc/core/lsu/IEUAdrM[15]} {wallypipelinedsoc/core/lsu/IEUAdrM[16]} {wallypipelinedsoc/core/lsu/IEUAdrM[17]} {wallypipelinedsoc/core/lsu/IEUAdrM[18]} {wallypipelinedsoc/core/lsu/IEUAdrM[19]} {wallypipelinedsoc/core/lsu/IEUAdrM[20]} {wallypipelinedsoc/core/lsu/IEUAdrM[21]} {wallypipelinedsoc/core/lsu/IEUAdrM[22]} {wallypipelinedsoc/core/lsu/IEUAdrM[23]} {wallypipelinedsoc/core/lsu/IEUAdrM[24]} {wallypipelinedsoc/core/lsu/IEUAdrM[25]} {wallypipelinedsoc/core/lsu/IEUAdrM[26]} {wallypipelinedsoc/core/lsu/IEUAdrM[27]} {wallypipelinedsoc/core/lsu/IEUAdrM[28]} {wallypipelinedsoc/core/lsu/IEUAdrM[29]} {wallypipelinedsoc/core/lsu/IEUAdrM[30]} {wallypipelinedsoc/core/lsu/IEUAdrM[31]} {wallypipelinedsoc/core/lsu/IEUAdrM[32]} {wallypipelinedsoc/core/lsu/IEUAdrM[33]} {wallypipelinedsoc/core/lsu/IEUAdrM[34]} {wallypipelinedsoc/core/lsu/IEUAdrM[35]} {wallypipelinedsoc/core/lsu/IEUAdrM[36]} {wallypipelinedsoc/core/lsu/IEUAdrM[37]} {wallypipelinedsoc/core/lsu/IEUAdrM[38]} {wallypipelinedsoc/core/lsu/IEUAdrM[39]} {wallypipelinedsoc/core/lsu/IEUAdrM[40]} {wallypipelinedsoc/core/lsu/IEUAdrM[41]} {wallypipelinedsoc/core/lsu/IEUAdrM[42]} {wallypipelinedsoc/core/lsu/IEUAdrM[43]} {wallypipelinedsoc/core/lsu/IEUAdrM[44]} {wallypipelinedsoc/core/lsu/IEUAdrM[45]} {wallypipelinedsoc/core/lsu/IEUAdrM[46]} {wallypipelinedsoc/core/lsu/IEUAdrM[47]} {wallypipelinedsoc/core/lsu/IEUAdrM[48]} {wallypipelinedsoc/core/lsu/IEUAdrM[49]} {wallypipelinedsoc/core/lsu/IEUAdrM[50]} {wallypipelinedsoc/core/lsu/IEUAdrM[51]} {wallypipelinedsoc/core/lsu/IEUAdrM[52]} {wallypipelinedsoc/core/lsu/IEUAdrM[53]} {wallypipelinedsoc/core/lsu/IEUAdrM[54]} {wallypipelinedsoc/core/lsu/IEUAdrM[55]} {wallypipelinedsoc/core/lsu/IEUAdrM[56]} {wallypipelinedsoc/core/lsu/IEUAdrM[57]} {wallypipelinedsoc/core/lsu/IEUAdrM[58]} {wallypipelinedsoc/core/lsu/IEUAdrM[59]} {wallypipelinedsoc/core/lsu/IEUAdrM[60]} {wallypipelinedsoc/core/lsu/IEUAdrM[61]} {wallypipelinedsoc/core/lsu/IEUAdrM[62]} {wallypipelinedsoc/core/lsu/IEUAdrM[63]} ]]

create_debug_port u_ila_0 probe
set_property port_width 64 [get_debug_ports u_ila_0/probe6]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {wallypipelinedsoc/core/lsu/ReadDataM[0]} {wallypipelinedsoc/core/lsu/ReadDataM[1]} {wallypipelinedsoc/core/lsu/ReadDataM[2]} {wallypipelinedsoc/core/lsu/ReadDataM[3]} {wallypipelinedsoc/core/lsu/ReadDataM[4]} {wallypipelinedsoc/core/lsu/ReadDataM[5]} {wallypipelinedsoc/core/lsu/ReadDataM[6]} {wallypipelinedsoc/core/lsu/ReadDataM[7]} {wallypipelinedsoc/core/lsu/ReadDataM[8]} {wallypipelinedsoc/core/lsu/ReadDataM[9]} {wallypipelinedsoc/core/lsu/ReadDataM[10]} {wallypipelinedsoc/core/lsu/ReadDataM[11]} {wallypipelinedsoc/core/lsu/ReadDataM[12]} {wallypipelinedsoc/core/lsu/ReadDataM[13]} {wallypipelinedsoc/core/lsu/ReadDataM[14]} {wallypipelinedsoc/core/lsu/ReadDataM[15]} {wallypipelinedsoc/core/lsu/ReadDataM[16]} {wallypipelinedsoc/core/lsu/ReadDataM[17]} {wallypipelinedsoc/core/lsu/ReadDataM[18]} {wallypipelinedsoc/core/lsu/ReadDataM[19]} {wallypipelinedsoc/core/lsu/ReadDataM[20]} {wallypipelinedsoc/core/lsu/ReadDataM[21]} {wallypipelinedsoc/core/lsu/ReadDataM[22]} {wallypipelinedsoc/core/lsu/ReadDataM[23]} {wallypipelinedsoc/core/lsu/ReadDataM[24]} {wallypipelinedsoc/core/lsu/ReadDataM[25]} {wallypipelinedsoc/core/lsu/ReadDataM[26]} {wallypipelinedsoc/core/lsu/ReadDataM[27]} {wallypipelinedsoc/core/lsu/ReadDataM[28]} {wallypipelinedsoc/core/lsu/ReadDataM[29]} {wallypipelinedsoc/core/lsu/ReadDataM[30]} {wallypipelinedsoc/core/lsu/ReadDataM[31]} {wallypipelinedsoc/core/lsu/ReadDataM[32]} {wallypipelinedsoc/core/lsu/ReadDataM[33]} {wallypipelinedsoc/core/lsu/ReadDataM[34]} {wallypipelinedsoc/core/lsu/ReadDataM[35]} {wallypipelinedsoc/core/lsu/ReadDataM[36]} {wallypipelinedsoc/core/lsu/ReadDataM[37]} {wallypipelinedsoc/core/lsu/ReadDataM[38]} {wallypipelinedsoc/core/lsu/ReadDataM[39]} {wallypipelinedsoc/core/lsu/ReadDataM[40]} {wallypipelinedsoc/core/lsu/ReadDataM[41]} {wallypipelinedsoc/core/lsu/ReadDataM[42]} {wallypipelinedsoc/core/lsu/ReadDataM[43]} {wallypipelinedsoc/core/lsu/ReadDataM[44]} {wallypipelinedsoc/core/lsu/ReadDataM[45]} {wallypipelinedsoc/core/lsu/ReadDataM[46]} {wallypipelinedsoc/core/lsu/ReadDataM[47]} {wallypipelinedsoc/core/lsu/ReadDataM[48]} {wallypipelinedsoc/core/lsu/ReadDataM[49]} {wallypipelinedsoc/core/lsu/ReadDataM[50]} {wallypipelinedsoc/core/lsu/ReadDataM[51]} {wallypipelinedsoc/core/lsu/ReadDataM[52]} {wallypipelinedsoc/core/lsu/ReadDataM[53]} {wallypipelinedsoc/core/lsu/ReadDataM[54]} {wallypipelinedsoc/core/lsu/ReadDataM[55]} {wallypipelinedsoc/core/lsu/ReadDataM[56]} {wallypipelinedsoc/core/lsu/ReadDataM[57]} {wallypipelinedsoc/core/lsu/ReadDataM[58]} {wallypipelinedsoc/core/lsu/ReadDataM[59]} {wallypipelinedsoc/core/lsu/ReadDataM[60]} {wallypipelinedsoc/core/lsu/ReadDataM[61]} {wallypipelinedsoc/core/lsu/ReadDataM[62]} {wallypipelinedsoc/core/lsu/ReadDataM[63]} ]]

create_debug_port u_ila_0 probe
set_property port_width 64 [get_debug_ports u_ila_0/probe7]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {wallypipelinedsoc/core/lsu/WriteDataM[0]} {wallypipelinedsoc/core/lsu/WriteDataM[1]} {wallypipelinedsoc/core/lsu/WriteDataM[2]} {wallypipelinedsoc/core/lsu/WriteDataM[3]} {wallypipelinedsoc/core/lsu/WriteDataM[4]} {wallypipelinedsoc/core/lsu/WriteDataM[5]} {wallypipelinedsoc/core/lsu/WriteDataM[6]} {wallypipelinedsoc/core/lsu/WriteDataM[7]} {wallypipelinedsoc/core/lsu/WriteDataM[8]} {wallypipelinedsoc/core/lsu/WriteDataM[9]} {wallypipelinedsoc/core/lsu/WriteDataM[10]} {wallypipelinedsoc/core/lsu/WriteDataM[11]} {wallypipelinedsoc/core/lsu/WriteDataM[12]} {wallypipelinedsoc/core/lsu/WriteDataM[13]} {wallypipelinedsoc/core/lsu/WriteDataM[14]} {wallypipelinedsoc/core/lsu/WriteDataM[15]} {wallypipelinedsoc/core/lsu/WriteDataM[16]} {wallypipelinedsoc/core/lsu/WriteDataM[17]} {wallypipelinedsoc/core/lsu/WriteDataM[18]} {wallypipelinedsoc/core/lsu/WriteDataM[19]} {wallypipelinedsoc/core/lsu/WriteDataM[20]} {wallypipelinedsoc/core/lsu/WriteDataM[21]} {wallypipelinedsoc/core/lsu/WriteDataM[22]} {wallypipelinedsoc/core/lsu/WriteDataM[23]} {wallypipelinedsoc/core/lsu/WriteDataM[24]} {wallypipelinedsoc/core/lsu/WriteDataM[25]} {wallypipelinedsoc/core/lsu/WriteDataM[26]} {wallypipelinedsoc/core/lsu/WriteDataM[27]} {wallypipelinedsoc/core/lsu/WriteDataM[28]} {wallypipelinedsoc/core/lsu/WriteDataM[29]} {wallypipelinedsoc/core/lsu/WriteDataM[30]} {wallypipelinedsoc/core/lsu/WriteDataM[31]} {wallypipelinedsoc/core/lsu/WriteDataM[32]} {wallypipelinedsoc/core/lsu/WriteDataM[33]} {wallypipelinedsoc/core/lsu/WriteDataM[34]} {wallypipelinedsoc/core/lsu/WriteDataM[35]} {wallypipelinedsoc/core/lsu/WriteDataM[36]} {wallypipelinedsoc/core/lsu/WriteDataM[37]} {wallypipelinedsoc/core/lsu/WriteDataM[38]} {wallypipelinedsoc/core/lsu/WriteDataM[39]} {wallypipelinedsoc/core/lsu/WriteDataM[40]} {wallypipelinedsoc/core/lsu/WriteDataM[41]} {wallypipelinedsoc/core/lsu/WriteDataM[42]} {wallypipelinedsoc/core/lsu/WriteDataM[43]} {wallypipelinedsoc/core/lsu/WriteDataM[44]} {wallypipelinedsoc/core/lsu/WriteDataM[45]} {wallypipelinedsoc/core/lsu/WriteDataM[46]} {wallypipelinedsoc/core/lsu/WriteDataM[47]} {wallypipelinedsoc/core/lsu/WriteDataM[48]} {wallypipelinedsoc/core/lsu/WriteDataM[49]} {wallypipelinedsoc/core/lsu/WriteDataM[50]} {wallypipelinedsoc/core/lsu/WriteDataM[51]} {wallypipelinedsoc/core/lsu/WriteDataM[52]} {wallypipelinedsoc/core/lsu/WriteDataM[53]} {wallypipelinedsoc/core/lsu/WriteDataM[54]} {wallypipelinedsoc/core/lsu/WriteDataM[55]} {wallypipelinedsoc/core/lsu/WriteDataM[56]} {wallypipelinedsoc/core/lsu/WriteDataM[57]} {wallypipelinedsoc/core/lsu/WriteDataM[58]} {wallypipelinedsoc/core/lsu/WriteDataM[59]} {wallypipelinedsoc/core/lsu/WriteDataM[60]} {wallypipelinedsoc/core/lsu/WriteDataM[61]} {wallypipelinedsoc/core/lsu/WriteDataM[62]} {wallypipelinedsoc/core/lsu/WriteDataM[63]} ]]


create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][0]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][1]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][2]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][3]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][4]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][5]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][6]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][7]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][8]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][9]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][10]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][11]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][12]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][13]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][14]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][15]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][16]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][17]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][18]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][19]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][20]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][21]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][22]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][23]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][24]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][25]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][26]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][27]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][28]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][29]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][30]} {wallypipelinedsoc/core/priv.priv/csr/HPMCOUNTER_REGW[0][31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe9]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {rvvi_synth.acev/RvviAxiRdata[0]} {rvvi_synth.acev/RvviAxiRdata[1]} {rvvi_synth.acev/RvviAxiRdata[2]} {rvvi_synth.acev/RvviAxiRdata[3]} {rvvi_synth.acev/RvviAxiRdata[4]} {rvvi_synth.acev/RvviAxiRdata[5]} {rvvi_synth.acev/RvviAxiRdata[6]} {rvvi_synth.acev/RvviAxiRdata[7]} {rvvi_synth.acev/RvviAxiRdata[8]} {rvvi_synth.acev/RvviAxiRdata[9]} {rvvi_synth.acev/RvviAxiRdata[10]} {rvvi_synth.acev/RvviAxiRdata[11]} {rvvi_synth.acev/RvviAxiRdata[12]} {rvvi_synth.acev/RvviAxiRdata[13]} {rvvi_synth.acev/RvviAxiRdata[14]} {rvvi_synth.acev/RvviAxiRdata[15]} {rvvi_synth.acev/RvviAxiRdata[16]} {rvvi_synth.acev/RvviAxiRdata[17]} {rvvi_synth.acev/RvviAxiRdata[18]} {rvvi_synth.acev/RvviAxiRdata[19]} {rvvi_synth.acev/RvviAxiRdata[20]} {rvvi_synth.acev/RvviAxiRdata[21]} {rvvi_synth.acev/RvviAxiRdata[22]} {rvvi_synth.acev/RvviAxiRdata[23]} {rvvi_synth.acev/RvviAxiRdata[24]} {rvvi_synth.acev/RvviAxiRdata[25]} {rvvi_synth.acev/RvviAxiRdata[26]} {rvvi_synth.acev/RvviAxiRdata[27]} {rvvi_synth.acev/RvviAxiRdata[28]} {rvvi_synth.acev/RvviAxiRdata[29]} {rvvi_synth.acev/RvviAxiRdata[30]} {rvvi_synth.acev/RvviAxiRdata[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe10]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {rvvi_synth.acev/RvviAxiRstrb[0]} {rvvi_synth.acev/RvviAxiRstrb[1]} {rvvi_synth.acev/RvviAxiRstrb[2]} {rvvi_synth.acev/RvviAxiRstrb[3]}  ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {rvvi_synth.acev/RvviAxiRlast}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {rvvi_synth.acev/RvviAxiRvalid}]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {rvvi_synth.acev/RvviAxiRdata[0]} {rvvi_synth.acev/RvviAxiRdata[1]} {rvvi_synth.acev/HostFiFoFillAmt[2]} {rvvi_synth.acev/HostFiFoFillAmt[3]} {rvvi_synth.acev/HostFiFoFillAmt[4]} {rvvi_synth.acev/HostFiFoFillAmt[5]} {rvvi_synth.acev/HostFiFoFillAmt[6]} {rvvi_synth.acev/HostFiFoFillAmt[7]} {rvvi_synth.acev/HostFiFoFillAmt[8]} {rvvi_synth.acev/HostFiFoFillAmt[9]} {rvvi_synth.acev/HostFiFoFillAmt[10]} {rvvi_synth.acev/HostFiFoFillAmt[11]} {rvvi_synth.acev/HostFiFoFillAmt[12]} {rvvi_synth.acev/HostFiFoFillAmt[13]} {rvvi_synth.acev/HostFiFoFillAmt[14]} {rvvi_synth.acev/HostFiFoFillAmt[15]} {rvvi_synth.acev/HostFiFoFillAmt[16]} {rvvi_synth.acev/HostFiFoFillAmt[17]} {rvvi_synth.acev/HostFiFoFillAmt[18]} {rvvi_synth.acev/HostFiFoFillAmt[19]} {rvvi_synth.acev/HostFiFoFillAmt[20]} {rvvi_synth.acev/HostFiFoFillAmt[21]} {rvvi_synth.acev/HostFiFoFillAmt[22]} {rvvi_synth.acev/HostFiFoFillAmt[23]} {rvvi_synth.acev/HostFiFoFillAmt[24]} {rvvi_synth.acev/HostFiFoFillAmt[25]} {rvvi_synth.acev/HostFiFoFillAmt[26]} {rvvi_synth.acev/HostFiFoFillAmt[27]} {rvvi_synth.acev/HostFiFoFillAmt[28]} {rvvi_synth.acev/HostFiFoFillAmt[29]} {rvvi_synth.acev/HostFiFoFillAmt[30]} {rvvi_synth.acev/HostFiFoFillAmt[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {ExternalStall}]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe15]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {rvvi_synth.acev/phy_txd[0]} {rvvi_synth.acev/phy_txd[1]} {rvvi_synth.acev/phy_txd[2]} {rvvi_synth.acev/phy_txd[3]} {rvvi_synth.acev/phy_txd[4]} {rvvi_synth.acev/phy_txd[5]} {rvvi_synth.acev/phy_txd[6]} {rvvi_synth.acev/phy_txd[7]}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {rvvi_synth.acev/phy_tx_en}]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe17]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {rvvi_synth.acev/RvviAxiWdata[0]} {rvvi_synth.acev/RvviAxiWdata[1]} {rvvi_synth.acev/RvviAxiWdata[2]} {rvvi_synth.acev/RvviAxiWdata[3]} {rvvi_synth.acev/RvviAxiWdata[4]} {rvvi_synth.acev/RvviAxiWdata[5]} {rvvi_synth.acev/RvviAxiWdata[6]} {rvvi_synth.acev/RvviAxiWdata[7]} {rvvi_synth.acev/RvviAxiWdata[8]} {rvvi_synth.acev/RvviAxiWdata[9]} {rvvi_synth.acev/RvviAxiWdata[10]} {rvvi_synth.acev/RvviAxiWdata[11]} {rvvi_synth.acev/RvviAxiWdata[12]} {rvvi_synth.acev/RvviAxiWdata[13]} {rvvi_synth.acev/RvviAxiWdata[14]} {rvvi_synth.acev/RvviAxiWdata[15]} {rvvi_synth.acev/RvviAxiWdata[16]} {rvvi_synth.acev/RvviAxiWdata[17]} {rvvi_synth.acev/RvviAxiWdata[18]} {rvvi_synth.acev/RvviAxiWdata[19]} {rvvi_synth.acev/RvviAxiWdata[20]} {rvvi_synth.acev/RvviAxiWdata[21]} {rvvi_synth.acev/RvviAxiWdata[22]} {rvvi_synth.acev/RvviAxiWdata[23]} {rvvi_synth.acev/RvviAxiWdata[24]} {rvvi_synth.acev/RvviAxiWdata[25]} {rvvi_synth.acev/RvviAxiWdata[26]} {rvvi_synth.acev/RvviAxiWdata[27]} {rvvi_synth.acev/RvviAxiWdata[28]} {rvvi_synth.acev/RvviAxiWdata[29]} {rvvi_synth.acev/RvviAxiWdata[30]} {rvvi_synth.acev/RvviAxiWdata[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {rvvi_synth.acev/RvviAxiWlast}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {rvvi_synth.acev/RvviAxiWvalid}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {rvvi_synth.acev/RvviAxiWready}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {rvvi_synth.acev/phy_tx_er}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {rvvi_synth.acev/HostRequestSlowDown}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {rvvi_synth.acev/genslowframe/PendingHostRequest}]]

create_debug_port u_ila_0 probe
set_property port_width 10 [get_debug_ports u_ila_0/probe24]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {rvvi_synth.acev/genslowframe/ConcurrentCount[0]} {rvvi_synth.acev/genslowframe/ConcurrentCount[1]} {rvvi_synth.acev/genslowframe/ConcurrentCount[2]} {rvvi_synth.acev/genslowframe/ConcurrentCount[3]} {rvvi_synth.acev/genslowframe/ConcurrentCount[4]} {rvvi_synth.acev/genslowframe/ConcurrentCount[5]} {rvvi_synth.acev/genslowframe/ConcurrentCount[6]} {rvvi_synth.acev/genslowframe/ConcurrentCount[7]} {rvvi_synth.acev/genslowframe/ConcurrentCount[8]} {rvvi_synth.acev/genslowframe/ConcurrentCount[9]}]]

create_debug_port u_ila_0 probe
set_property port_width 17 [get_debug_ports u_ila_0/probe25]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {rvvi_synth.acev/genslowframe/Count[0]} {rvvi_synth.acev/genslowframe/Count[1]} {rvvi_synth.acev/genslowframe/Count[2]} {rvvi_synth.acev/genslowframe/Count[3]} {rvvi_synth.acev/genslowframe/Count[4]} {rvvi_synth.acev/genslowframe/Count[5]} {rvvi_synth.acev/genslowframe/Count[6]} {rvvi_synth.acev/genslowframe/Count[7]} {rvvi_synth.acev/genslowframe/Count[8]} {rvvi_synth.acev/genslowframe/Count[9]} {rvvi_synth.acev/genslowframe/Count[10]} {rvvi_synth.acev/genslowframe/Count[11]} {rvvi_synth.acev/genslowframe/Count[12]} {rvvi_synth.acev/genslowframe/Count[13]} {rvvi_synth.acev/genslowframe/Count[14]} {rvvi_synth.acev/genslowframe/Count[15]} {rvvi_synth.acev/genslowframe/Count[16]} ]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe26]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {rvvi_synth.acev/genslowframe/CurrState[0]} {rvvi_synth.acev/genslowframe/CurrState[1]} {rvvi_synth.acev/genslowframe/CurrState[2]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {rvvi_synth.acev/RVVIStall}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {rvvi_synth.acev/HostStall}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {rvvi_synth.acev/packetizer/DelayFlag}]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe30]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {rvvi_synth.acev/packetizer/RstCount[0]} {rvvi_synth.acev/packetizer/RstCount[1]} {rvvi_synth.acev/packetizer/RstCount[2]} {rvvi_synth.acev/packetizer/RstCount[3]} {rvvi_synth.acev/packetizer/RstCount[4]} {rvvi_synth.acev/packetizer/RstCount[5]} {rvvi_synth.acev/packetizer/RstCount[6]} {rvvi_synth.acev/packetizer/RstCount[7]} {rvvi_synth.acev/packetizer/RstCount[8]} {rvvi_synth.acev/packetizer/RstCount[9]} {rvvi_synth.acev/packetizer/RstCount[10]} {rvvi_synth.acev/packetizer/RstCount[11]} {rvvi_synth.acev/packetizer/RstCount[12]} {rvvi_synth.acev/packetizer/RstCount[13]} {rvvi_synth.acev/packetizer/RstCount[14]} {rvvi_synth.acev/packetizer/RstCount[15]} {rvvi_synth.acev/packetizer/RstCount[16]} {rvvi_synth.acev/packetizer/RstCount[17]} {rvvi_synth.acev/packetizer/RstCount[18]} {rvvi_synth.acev/packetizer/RstCount[19]} {rvvi_synth.acev/packetizer/RstCount[20]} {rvvi_synth.acev/packetizer/RstCount[21]} {rvvi_synth.acev/packetizer/RstCount[22]} {rvvi_synth.acev/packetizer/RstCount[23]} {rvvi_synth.acev/packetizer/RstCount[24]} {rvvi_synth.acev/packetizer/RstCount[25]} {rvvi_synth.acev/packetizer/RstCount[26]} {rvvi_synth.acev/packetizer/RstCount[27]} {rvvi_synth.acev/packetizer/RstCount[28]} {rvvi_synth.acev/packetizer/RstCount[29]} {rvvi_synth.acev/packetizer/RstCount[30]} {rvvi_synth.acev/packetizer/RstCount[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe31]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {rvvi_synth.acev/packetizer/InnerPktDelay[0]} {rvvi_synth.acev/packetizer/InnerPktDelay[1]} {rvvi_synth.acev/packetizer/InnerPktDelay[2]} {rvvi_synth.acev/packetizer/InnerPktDelay[3]} {rvvi_synth.acev/packetizer/InnerPktDelay[4]} {rvvi_synth.acev/packetizer/InnerPktDelay[5]} {rvvi_synth.acev/packetizer/InnerPktDelay[6]} {rvvi_synth.acev/packetizer/InnerPktDelay[7]} {rvvi_synth.acev/packetizer/InnerPktDelay[8]} {rvvi_synth.acev/packetizer/InnerPktDelay[9]} {rvvi_synth.acev/packetizer/InnerPktDelay[10]} {rvvi_synth.acev/packetizer/InnerPktDelay[11]} {rvvi_synth.acev/packetizer/InnerPktDelay[12]} {rvvi_synth.acev/packetizer/InnerPktDelay[13]} {rvvi_synth.acev/packetizer/InnerPktDelay[14]} {rvvi_synth.acev/packetizer/InnerPktDelay[15]} {rvvi_synth.acev/packetizer/InnerPktDelay[16]} {rvvi_synth.acev/packetizer/InnerPktDelay[17]} {rvvi_synth.acev/packetizer/InnerPktDelay[18]} {rvvi_synth.acev/packetizer/InnerPktDelay[19]} {rvvi_synth.acev/packetizer/InnerPktDelay[20]} {rvvi_synth.acev/packetizer/InnerPktDelay[21]} {rvvi_synth.acev/packetizer/InnerPktDelay[22]} {rvvi_synth.acev/packetizer/InnerPktDelay[23]} {rvvi_synth.acev/packetizer/InnerPktDelay[24]} {rvvi_synth.acev/packetizer/InnerPktDelay[25]} {rvvi_synth.acev/packetizer/InnerPktDelay[26]} {rvvi_synth.acev/packetizer/InnerPktDelay[27]} {rvvi_synth.acev/packetizer/InnerPktDelay[28]} {rvvi_synth.acev/packetizer/InnerPktDelay[29]} {rvvi_synth.acev/packetizer/InnerPktDelay[30]} {rvvi_synth.acev/packetizer/InnerPktDelay[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe32]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {rvvi_synth.acev/rateset/RvviAxiRdataDelay[0]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[1]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[2]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[3]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[4]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[5]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[6]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[7]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[8]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[9]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[10]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[11]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[12]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[13]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[14]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[15]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[16]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[17]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[18]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[19]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[20]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[21]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[22]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[23]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[24]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[25]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[26]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[27]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[28]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[29]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[30]} {rvvi_synth.acev/rateset/RvviAxiRdataDelay[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe33]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {rvvi_synth.acev/rateset/CurrState[0]} {rvvi_synth.acev/rateset/CurrState[1]} {rvvi_synth.acev/rateset/CurrState[2]}  ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {rvvi_synth.acev/rateset/Match} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {rvvi_synth.acev/rateset/MessageEn} ]]

# the debug hub has issues with the clocks from the mmcm so lets give up an connect to the 100Mhz input clock.
#connect_debug_port dbg_hub/clk [get_nets default_100mhz_clk]
connect_debug_port dbg_hub/clk [get_nets CPUCLK]
