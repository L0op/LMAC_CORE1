-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
-- Date        : Sun Apr  7 11:16:52 2019
-- Host        : ubeluga running 64-bit Ubuntu 18.04.4 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top ps_emio_eth_1g_xlconstant_0_2 -prefix
--               ps_emio_eth_1g_xlconstant_0_2_ ps_emio_eth_1g_xlconstant_0_2_stub.vhdl
-- Design      : ps_emio_eth_1g_xlconstant_0_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps_emio_eth_1g_xlconstant_0_2 is
  Port ( 
    dout : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );

end ps_emio_eth_1g_xlconstant_0_2;

architecture stub of ps_emio_eth_1g_xlconstant_0_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "dout[1:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "xlconstant_v1_1_5_xlconstant,Vivado 2018.2";
begin
end;