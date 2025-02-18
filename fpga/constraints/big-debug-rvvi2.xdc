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
connect_debug_port u_ila_0/probe9 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiRdata[0]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[1]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[2]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[3]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[4]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[5]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[6]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[7]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[8]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[9]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[10]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[11]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[12]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[13]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[14]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[15]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[16]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[17]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[18]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[19]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[20]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[21]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[22]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[23]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[24]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[25]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[26]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[27]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[28]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[29]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[30]} {rvvi_synth.hwrvvitracer/RvviAxiRdata[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe10]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiRstrb[0]} {rvvi_synth.hwrvvitracer/RvviAxiRstrb[1]} {rvvi_synth.hwrvvitracer/RvviAxiRstrb[2]} {rvvi_synth.hwrvvitracer/RvviAxiRstrb[3]}  ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiRlast}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiRvalid}]]

create_debug_port u_ila_0 probe
set_property port_width 56 [get_debug_ports u_ila_0/probe13]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {wallypipelinedsoc/core/lsu/PAdrM[0]} {wallypipelinedsoc/core/lsu/PAdrM[1]} {wallypipelinedsoc/core/lsu/PAdrM[2]} {wallypipelinedsoc/core/lsu/PAdrM[3]} {wallypipelinedsoc/core/lsu/PAdrM[4]} {wallypipelinedsoc/core/lsu/PAdrM[5]} {wallypipelinedsoc/core/lsu/PAdrM[6]} {wallypipelinedsoc/core/lsu/PAdrM[7]} {wallypipelinedsoc/core/lsu/PAdrM[8]} {wallypipelinedsoc/core/lsu/PAdrM[9]} {wallypipelinedsoc/core/lsu/PAdrM[10]} {wallypipelinedsoc/core/lsu/PAdrM[11]} {wallypipelinedsoc/core/lsu/PAdrM[12]} {wallypipelinedsoc/core/lsu/PAdrM[13]} {wallypipelinedsoc/core/lsu/PAdrM[14]} {wallypipelinedsoc/core/lsu/PAdrM[15]} {wallypipelinedsoc/core/lsu/PAdrM[16]} {wallypipelinedsoc/core/lsu/PAdrM[17]} {wallypipelinedsoc/core/lsu/PAdrM[18]} {wallypipelinedsoc/core/lsu/PAdrM[19]} {wallypipelinedsoc/core/lsu/PAdrM[20]} {wallypipelinedsoc/core/lsu/PAdrM[21]} {wallypipelinedsoc/core/lsu/PAdrM[22]} {wallypipelinedsoc/core/lsu/PAdrM[23]} {wallypipelinedsoc/core/lsu/PAdrM[24]} {wallypipelinedsoc/core/lsu/PAdrM[25]} {wallypipelinedsoc/core/lsu/PAdrM[26]} {wallypipelinedsoc/core/lsu/PAdrM[27]} {wallypipelinedsoc/core/lsu/PAdrM[28]} {wallypipelinedsoc/core/lsu/PAdrM[29]} {wallypipelinedsoc/core/lsu/PAdrM[30]} {wallypipelinedsoc/core/lsu/PAdrM[31]} {wallypipelinedsoc/core/lsu/PAdrM[32]} {wallypipelinedsoc/core/lsu/PAdrM[33]} {wallypipelinedsoc/core/lsu/PAdrM[34]} {wallypipelinedsoc/core/lsu/PAdrM[35]} {wallypipelinedsoc/core/lsu/PAdrM[36]} {wallypipelinedsoc/core/lsu/PAdrM[37]} {wallypipelinedsoc/core/lsu/PAdrM[38]} {wallypipelinedsoc/core/lsu/PAdrM[39]} {wallypipelinedsoc/core/lsu/PAdrM[40]} {wallypipelinedsoc/core/lsu/PAdrM[41]} {wallypipelinedsoc/core/lsu/PAdrM[42]} {wallypipelinedsoc/core/lsu/PAdrM[43]} {wallypipelinedsoc/core/lsu/PAdrM[44]} {wallypipelinedsoc/core/lsu/PAdrM[45]} {wallypipelinedsoc/core/lsu/PAdrM[46]} {wallypipelinedsoc/core/lsu/PAdrM[47]} {wallypipelinedsoc/core/lsu/PAdrM[48]} {wallypipelinedsoc/core/lsu/PAdrM[49]} {wallypipelinedsoc/core/lsu/PAdrM[50]} {wallypipelinedsoc/core/lsu/PAdrM[51]} {wallypipelinedsoc/core/lsu/PAdrM[52]} {wallypipelinedsoc/core/lsu/PAdrM[53]} {wallypipelinedsoc/core/lsu/PAdrM[54]} {wallypipelinedsoc/core/lsu/PAdrM[55]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {ExternalStall}]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe15]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {rvvi_synth.hwrvvitracer/phy_txd[0]} {rvvi_synth.hwrvvitracer/phy_txd[1]} {rvvi_synth.hwrvvitracer/phy_txd[2]} {rvvi_synth.hwrvvitracer/phy_txd[3]} {rvvi_synth.hwrvvitracer/phy_txd[4]} {rvvi_synth.hwrvvitracer/phy_txd[5]} {rvvi_synth.hwrvvitracer/phy_txd[6]} {rvvi_synth.hwrvvitracer/phy_txd[7]}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {rvvi_synth.hwrvvitracer/phy_tx_en}]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe17]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiWdata[0]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[1]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[2]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[3]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[4]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[5]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[6]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[7]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[8]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[9]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[10]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[11]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[12]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[13]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[14]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[15]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[16]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[17]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[18]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[19]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[20]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[21]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[22]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[23]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[24]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[25]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[26]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[27]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[28]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[29]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[30]} {rvvi_synth.hwrvvitracer/RvviAxiWdata[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiWlast}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiWvalid}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {rvvi_synth.hwrvvitracer/RvviAxiWready}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {rvvi_synth.hwrvvitracer/phy_tx_er}]]


create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe22]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/CurrState[0]} {rvvi_synth.hwrvvitracer/rvviactivelist/CurrState[1]} {rvvi_synth.hwrvvitracer/rvviactivelist/CurrState[2]}  ]]

create_debug_port u_ila_0 probe
set_property port_width 16 [get_debug_ports u_ila_0/probe23]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[0]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[1]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[2]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[3]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[4]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[5]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[6]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[7]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[8]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[9]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[10]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[11]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[12]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[13]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[14]} {rvvi_synth.hwrvvitracer/inversepacketizer/FrameCount[15]} ]]

create_debug_port u_ila_0 probe
set_property port_width 16 [get_debug_ports u_ila_0/probe24]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[0]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[1]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[2]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[3]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[4]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[5]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[6]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[7]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[8]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[9]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[10]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[11]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[12]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[13]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[14]} {rvvi_synth.hwrvvitracer/inversepacketizer/Minstr[15]} ]]

create_debug_port u_ila_0 probe
set_property port_width 16 [get_debug_ports u_ila_0/probe25]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[0]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[1]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[2]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[3]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[4]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[5]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[6]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[7]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[8]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[9]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[10]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[11]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[12]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[13]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[14]} {rvvi_synth.hwrvvitracer/rvviactivelist/HostMatchingActiveBits[15]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveListStall} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {rvvi_synth.hwrvvitracer/RVVIStall}]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe28]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {rvvi_synth.hwrvvitracer/inversepacketizer/Counter[0]} {rvvi_synth.hwrvvitracer/inversepacketizer/Counter[1]} {rvvi_synth.hwrvvitracer/inversepacketizer/Counter[2]}  ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {rvvi_synth.hwrvvitracer/packetizer/DelayFlag}]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe30]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {rvvi_synth.hwrvvitracer/packetizer/RstCount[0]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[1]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[2]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[3]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[4]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[5]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[6]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[7]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[8]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[9]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[10]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[11]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[12]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[13]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[14]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[15]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[16]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[17]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[18]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[19]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[20]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[21]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[22]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[23]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[24]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[25]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[26]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[27]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[28]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[29]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[30]} {rvvi_synth.hwrvvitracer/packetizer/RstCount[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe31]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[0]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[1]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[2]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[3]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[4]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[5]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[6]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[7]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[8]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[9]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[10]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[11]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[12]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[13]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[14]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[15]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[16]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[17]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[18]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[19]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[20]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[21]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[22]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[23]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[24]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[25]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[26]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[27]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[28]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[29]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[30]} {rvvi_synth.hwrvvitracer/packetizer/InnerPktDelay[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 16 [get_debug_ports u_ila_0/probe32]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[0]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[1]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[2]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[3]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[4]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[5]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[6]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[7]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[8]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[9]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[10]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[11]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[12]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[13]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[14]} {rvvi_synth.hwrvvitracer/rvviactivelist/ActiveBits[15]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe33]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/TailPtr[0]} {rvvi_synth.hwrvvitracer/rvviactivelist/TailPtr[1]} {rvvi_synth.hwrvvitracer/rvviactivelist/TailPtr[2]} {rvvi_synth.hwrvvitracer/rvviactivelist/TailPtr[3]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe34]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/ReplayPtrNext[0]} {rvvi_synth.hwrvvitracer/rvviactivelist/ReplayPtrNext[1]} {rvvi_synth.hwrvvitracer/rvviactivelist/ReplayPtrNext[2]} {rvvi_synth.hwrvvitracer/rvviactivelist/ReplayPtrNext[3]} ]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe35]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {rvvi_synth.hwrvvitracer/inversepacketizer/CurrState[0]} {rvvi_synth.hwrvvitracer/inversepacketizer/CurrState[1]} {rvvi_synth.hwrvvitracer/inversepacketizer/CurrState[2]}  ]]

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe36]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list {rvvi_synth.hwrvvitracer/PacketizerRvvi[0]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[1]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[2]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[3]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[4]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[5]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[6]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[7]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[8]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[9]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[10]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[11]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[12]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[13]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[14]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[15]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[16]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[17]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[18]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[19]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[20]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[21]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[22]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[23]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[24]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[25]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[26]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[27]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[28]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[29]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[30]} {rvvi_synth.hwrvvitracer/PacketizerRvvi[31]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list {rvvi_synth.hwrvvitracer/PacketizerRvviValid} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/DutValid} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/SelActiveList} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/HostInstrValid} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe41]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/HeadPtr[0]} {rvvi_synth.hwrvvitracer/rvviactivelist/HeadPtr[1]} {rvvi_synth.hwrvvitracer/rvviactivelist/HeadPtr[2]} {rvvi_synth.hwrvvitracer/rvviactivelist/HeadPtr[3]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/Full} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list {rvvi_synth.hwrvvitracer/rvviactivelist/Empty} ]]



# the debug hub has issues with the clocks from the mmcm so lets give up an connect to the 100Mhz input clock.
#connect_debug_port dbg_hub/clk [get_nets default_100mhz_clk]
connect_debug_port dbg_hub/clk [get_nets CPUCLK]

