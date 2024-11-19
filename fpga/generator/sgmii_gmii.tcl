set partNumber $::env(XILINX_PART)
set boardName $::env(XILINX_BOARD)

set ipName sgmii_gmii

create_project $ipName . -force -part $partNumber
if {$boardName!="ArtyA7"} {
    set_property board_part $boardName [current_project]
}

create_ip -name gig_ethernet_pcs_pma -vendor xilinx.com -library ip -module_name sgmii_gmii

set_property -dict [list \
    CONFIG.Standard {SGMII} \
    CONFIG.Physical_Interface {LVDS} \
    CONFIG.Management_Interface {false} \
    CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
    CONFIG.LvdsRefClk {625} \
] [get_ips sgmii_gmii]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
