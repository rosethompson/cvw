create_debug_core u_ila_0 ila




set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
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
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptr[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptr[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptr[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptr[3]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptrnext[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptrnext[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptrnext[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptrnext[3]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptrnext[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptrnext[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptrnext[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/wptrnext[3]} ]]



create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/SDCCLK}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/SDCIn}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/SDCCS[0]}]]

create_debug_port u_ila_0 probe
set_property port_width 2 [get_debug_ports u_ila_0/probe11]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/InterruptPending[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/InterruptPending[1]}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitFIFOWriteIncrement}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitFIFOReadEmpty}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitFIFOReadIncrement}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitLoad}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/SDCCmd}]]


create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ShiftEdge}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/SampleEdge}]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe19]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[3]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[4]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[5]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[6]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftReg[7]} ]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe20]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[3]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[4]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[5]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[6]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitReg[7]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitLoad}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ShiftIn}]]


create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/SCLKenable} ]] 

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe24]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/CurrState[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/CurrState[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/CurrState[2]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/EndOfFrameDelay}]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe26]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/NextState[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/NextState[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/NextState[2]} ]]

create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe27]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/BitNum[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/BitNum[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/BitNum[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/BitNum[3]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/ContinueTransmit}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/ContinueTransmitD}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitRegLoaded}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/PhaseOneOffset}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/controller/SPICLK}]]

create_debug_port u_ila_0 probe
set_property port_width 9 [get_debug_ports u_ila_0/probe33]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[3]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[4]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[5]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[6]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[7]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/TransmitData[8]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveFIFOWriteInc}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveFIFOReadIncrement}]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe36]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[3]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[4]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[5]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[6]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveShiftRegEndian[7]} ]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe37]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveWatermark[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveWatermark[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveWatermark[2]} ]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe38]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveReadWatermarkLevel[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveReadWatermarkLevel[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveReadWatermarkLevel[2]} ]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe39]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[3]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[4]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[5]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[6]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveData[7]} ]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveFIFOWriteFull}]]

create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/ReceiveFIFOReadEmpty}]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe42]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/raddr[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/raddr[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/raddr[2]} ]]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe43]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/waddr[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/waddr[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/waddr[2]} ]]


create_debug_port u_ila_0 probe
set_property port_width 4 [get_debug_ports u_ila_0/probe44]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptr[0]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptr[1]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptr[2]} {wallypipelinedsoc/uncoregen.uncore/sdc.sdc/rxFIFO/rptr[3]} ]]



# the debug hub has issues with the clocks from the mmcm so lets give up an connect to the 100Mhz input clock.
#connect_debug_port dbg_hub/clk [get_nets default_100mhz_clk]
connect_debug_port dbg_hub/clk [get_nets CPUCLK]

