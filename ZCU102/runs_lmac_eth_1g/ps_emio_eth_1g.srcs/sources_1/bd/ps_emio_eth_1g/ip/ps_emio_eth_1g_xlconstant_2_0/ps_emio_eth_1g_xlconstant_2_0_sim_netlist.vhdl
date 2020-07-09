-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
-- Date        : Sun Apr  7 11:13:51 2019
-- Host        : ubeluga running 64-bit Ubuntu 18.04.4 LTS
-- Command     : write_vhdl -force -mode funcsim -rename_top ps_emio_eth_1g_xlconstant_2_0 -prefix
--               ps_emio_eth_1g_xlconstant_2_0_ ps_emio_eth_1g_xlconstant_2_0_sim_netlist.vhdl
-- Design      : ps_emio_eth_1g_xlconstant_2_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps_emio_eth_1g_xlconstant_2_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 4 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of ps_emio_eth_1g_xlconstant_2_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of ps_emio_eth_1g_xlconstant_2_0 : entity is "ps_emio_eth_1g_xlconstant_2_0,xlconstant_v1_1_5_xlconstant,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of ps_emio_eth_1g_xlconstant_2_0 : entity is "yes";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of ps_emio_eth_1g_xlconstant_2_0 : entity is "xlconstant_v1_1_5_xlconstant,Vivado 2018.2";
end ps_emio_eth_1g_xlconstant_2_0;

architecture STRUCTURE of ps_emio_eth_1g_xlconstant_2_0 is
  signal \<const0>\ : STD_LOGIC;
begin
  dout(4) <= \<const0>\;
  dout(3) <= \<const0>\;
  dout(2) <= \<const0>\;
  dout(1) <= \<const0>\;
  dout(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
end STRUCTURE;