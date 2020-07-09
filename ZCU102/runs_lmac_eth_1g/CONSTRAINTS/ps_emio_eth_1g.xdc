#125MHz CLK
set_property IOSTANDARD LVDS_25 [get_ports {clk_125_clk_p clk_125_clk_n}]
set_property PACKAGE_PIN G21 [get_ports clk_125_clk_p]
set_property PACKAGE_PIN F21 [get_ports clk_125_clk_n]
create_clock -period 8.000 -name clk_125 [get_ports clk_125_clk_p]

set_property PACKAGE_PIN A12 [get_ports sfp_tx_dis]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_tx_dis]
set_property PACKAGE_PIN E4 [get_ports sfp_txp]
set_property PACKAGE_PIN D2 [get_ports sfp_rxp]

#USER_MGT_SI570_CLOCK2_C_P 
set_property PACKAGE_PIN C8      [get_ports gtrefclk_in_clk_p]

create_clock -name gt_ref_clk -period 8.0 [get_ports gtrefclk_in_clk_p]


set_property IOSTANDARD LVCMOS25 [get_ports *led]

#GPIO_LED[0]
set_property PACKAGE_PIN    ag14  [get_ports xcvr_rst_done_led]

#GPIO_LED[1]
set_property PACKAGE_PIN    af13  [get_ports link_status_led]
#GPIO_LED[2]
set_property PACKAGE_PIN    ae13  [get_ports link_sync_led]
#GPIO_LED[3]
set_property PACKAGE_PIN    aj14  [get_ports pcs_clk_led]

#GPIO_LED[4]
#set_property PACKAGE_PIN    aj15  [get_ports rx_clk_led]

#GPIO_LED[5]
set_property PACKAGE_PIN    ah13  [get_ports pl_reset_led]

#s_axis_tready
#set_property IOSTANDARD LVCMOS25 [get_ports s_axis_tready]
set_property PACKAGE_PIN    al12  [get_ports s_axis_tready_led]

#GPIO_LED[6]
#set_property PACKAGE_PIN    ah14  [get_ports mdc_clk_led]

#GPIO_LED[7]
set_property PACKAGE_PIN    ah14  [get_ports dir_125_clk_led]