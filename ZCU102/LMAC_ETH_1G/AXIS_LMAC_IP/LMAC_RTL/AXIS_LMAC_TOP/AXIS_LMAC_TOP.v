//
// Copyright (C) 2018 LeWiz Communications, Inc. 
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with this library release; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
// 
// LeWiz can be contacted at:  support@lewiz.com
// or address:  
// PO Box 9276
// San Jose, CA 95157-9276
// www.lewiz.com
// 
//    Author: LeWiz Communications, Inc.
//    Language: Verilog
//



`timescale 1fs/1fs

module AXIS_LMAC_TOP (
  //// CLK/RESET
  input                 dclk,   //DMA PL CLK 100MHZ
  input                 lclk,   //LMAC CLK 156.25MHz
  input                 rst_,
  
  //// INPUT_LMAC_SPEED_MODE
  input     [ 1: 0]     fmac_speed,         //by default = 2'b01 for 1G mode
  
  //// GMII_SIGNALS
  output 	[ 7: 0]    	gmii_txd,			//o-8
  output 				gmii_tx_en, 		//o-1	
  output 				gmii_tx_er, 		//o-1	
  input  	[ 7: 0]     gmii_rxd,			//i-8
  //input  	            gmii_rxc,			//i-1
  input      			gmii_rx_er,			//i-1
  input 				gmii_rx_dv,         //i-1
  
  //// TX User Interface Signals
  input                 s_axis_tvalid,      //i-1
  output                s_axis_tready,      //o-1
  input     [63: 0]     s_axis_tdata,       //i-32
  input     [ 7: 0]     s_axis_tkeep,       //i-4
  input                 s_axis_tlast,       //i-1

  //// RX User Interface Signals
  output                m_axis_tvalid,      //o-1
  input                 m_axis_tready,      //i-1
  output    [63: 0]     m_axis_tdata,       //o-32
  output    [ 7: 0]     m_axis_tkeep,       //o-4
  output                m_axis_tlast        //o-1
);
    
  //Interface to TX PATH
  wire         		tx_mac_wr;       	//1
  wire	[63: 0]	    tx_mac_data;		//64
  wire	           	tx_mac_full;		//1
  wire  [12: 0]     tx_mac_usedw;    	//13
  
  //Interface to RX PATH
  wire 	[63: 0]   	rx_mac_data;		//64
  wire			   	rx_mac_empty;   	//1
  wire 		   		rx_mac_rd;      	//1
  
  //for pattern search (I/F to RX Path/EXTR)
  wire	       		cs_fifo_rd_en;		//1
  wire		       	cs_fifo_empty;		//1
  wire 	[63: 0]   	ipcs_fifo_dout;		//64
  
  wire	[31: 0]		FMAC_REGDOUT_in;   
  wire 				reg_rd_done_in;
  wire	[15 : 0]	host_addr_reg_out; 
  wire 				reg_rd_start_out;  

  	//AXIS LMAC BRIDGE
	AXIS_BRIDGE_TOP AXIS_BRIDGE_TOP(

	.clk 						(dclk),							//i-1, 100MHz
	.xA_clk 					(lclk),							//i-1, 156.25MHz
	.reset_ 					(rst_),        					//i-1
             
	//Main Signals	               	
	.tx_mac_aclk 				(dclk), 						//i-1, TX clock 100MHz.                                     
	.tx_axis_mac_tdata 			(s_axis_tdata),					//i-DATA_WIDTH, Write data.                          
	.tx_axis_mac_tvalid 		(s_axis_tvalid),				//i-1, Signal to show if the data is valid.          
	.tx_axis_mac_tlast 			(s_axis_tlast),					//i-1, Signal to show the last data byte or quadword.
	.tx_axis_mac_tuser 			(1'b0),							//i-1, Error signal.                                 
	.tx_axis_mac_tstrb 			(s_axis_tkeep),					//i-8, To show how many bytes of the data is valid.  
	.tx_axis_mac_tready 		(s_axis_tready),				//o-1, Indicates if the slave is ready.              
	      
	//Sideband Signals                  	
	.tx_ifg_delay 				(1'b0),							//i-1, Control signal for configurable interframe gap                                                           
	.tx_collision 				(),								//o-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	.tx_retransmit 				(),								//o-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	.tx_statistics_vector 		(),   							//o-32,A statistics vector that gives information on the last frame transmitted.                                
	.tx_statistics_valid 		(),								//o-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.  
	
	//Signals to AXIS Master
	.rx_mac_aclk				(dclk),							//i-1, RX clock 100MHz.	
	.rx_axis_mac_tdata 			(m_axis_tdata),					//o-64, data signal of bridge module
    .rx_axis_mac_tvalid 		(m_axis_tvalid),  				//o-1, signal to AXIS master indicating the data is valid
    .rx_axis_mac_tlast 			(m_axis_tlast),					//o-1, signal to AXIS Master saying end of data
    .rx_axis_mac_tuser 			(),								//o-1, error signal from FMAC
    .rx_axis_filter_tuser 		(),								//o-1, error signal from filter of FMAC
    .rx_axis_mac_tstrb 			(m_axis_tkeep),					//o-8, Signal indicating valid bytes inside the qword transmitting
    .rx_statistics_vector 		(),								//o-27, information about current frame 
    .rx_statistics_valid 		(),								//o-1, Signal indication the statistics vector is valid
    
    //Signals from AXIS Master
	.rx_axis_mac_tready 		(m_axis_tready),				//i-1, signal indicating that AXIS master accepted data
	.rx_axis_compatible_mode 	(1'b1),							//i-1, signal to keep tready always one     
	
	//Signals from FMAC	                    	                    			
	.fib_tx_mac_usedw 			(tx_mac_usedw),					//i-13, Bit-wise OR the signal to use it as empty signal 
           
	//Signals to FMAC                 	                			
	.fib_tx_mac_data 			(tx_mac_data),					//o-64, Data in of FMAC for tx path 
	.fib_tx_mac_wr 				(tx_mac_wr),					//o-1,  Write enable signal of FMAC FIFO 
	.fib_tx_mac_ipcs_data 		(),								//o-64, IPCS Data in of FMAC IPCS for tx path 
    .fib_tx_mac_ipcs_wr 		(),  							//o-1 , Write enable signal of FMAC IPCS FIFO    
    
	//Signals from FMAC
	.fib_rx_mac_data_empty 		(rx_mac_empty),					//i-1 , signal from FMAC saying its FIFO is empty
	.fib_rx_mac_pkt_data 		(rx_mac_data),					//i-64, data signal of FMAC module
    .fib_rx_mac_ipcs_empty 		(cs_fifo_empty),  				//i-1 , signal from IPCS FIFO in FMAC its empty
    .fib_rx_mac_ipcs_data 		(ipcs_fifo_dout),				//i-64, data signal of IPCS FIFO from FMAC module
    
    //Signals to FMAC
	.fib_rx_mac_rd 				(rx_mac_rd), 					//o-1, read signal 
	.fib_rx_mac_ipcs_rd 		(cs_fifo_rd_en), 				//o-1, read signal        
	
	.host_addr_in				(16'h0),		  				//i-16   
	.mac_regdout_in				(FMAC_REGDOUT_in),		        //i-32
	.reg_rd_start_in			(1'b0),	    		            //i-1 
	.reg_rd_done_in				(reg_rd_done_in),	            //i-1 
	                                                                  
	.host_addr_out				(host_addr_reg_out),		    //o-16
	.mac_regdout_out			(),				                //o-32
	.reg_rd_start_out			(reg_rd_start_out),	            //o-1 
	.reg_rd_done_out			(),			    				//o-1 
                                                            	
	.test 						()								//o-1 debug		

	);


//LEWIZ_ETH_MAC CORE2
	LMAC_SYNTH LMAC_SYNTH (

	    .clk	  			(lclk),     		//i-1, clk156
	    .reset_				(rst_),      //i-1, reset_
	
	    // Interface to TX PATH
		.tx_mac_wr			(tx_mac_wr),    	// i-1
		.tx_mac_data		(tx_mac_data),		// i-64
		.tx_mac_full		(tx_mac_full),		// o-1
	    .tx_mac_usedw		(tx_mac_usedw),     // o-13
			
	    // Interface to RX PATH
	    .rx_mac_data		(rx_mac_data),
	    .rx_mac_ctrl		(),
	    .rx_mac_empty		(rx_mac_empty),
	    .rx_mac_rd			(rx_mac_rd),
	
	    //for pattern search (I/F to RX Path/EXTR)
	    .cs_fifo_rd_en		(cs_fifo_rd_en),	//i-1
	    .cs_fifo_empty		(cs_fifo_empty),	//o-1
	
	    .ipcs_fifo_dout		(ipcs_fifo_dout),		
	
        //input				xgmii_reset_,		//i-1   
    	.gmii_txd			(gmii_txd),			//o-8
    	.gmii_txc			(),			        //o-8
    	.gmii_tx_en			(gmii_tx_en), 		//o-1		
    	.gmii_tx_er			(gmii_tx_er), 		//o-1		
    	.gmii_rxd			(gmii_rxd),			//i-8
    	//.gmii_rxc			(gmii_rxc),			//i-1
    	.gmii_rx_er			(gmii_rx_er),		//i-1
    	.gmii_rx_dv			(gmii_rx_dv),		//i-1
        //input[ 1 : 0]		xgmii_led_,		    //i-2
	
	    .xauiA_linkup		(),					// to LED on board 
	        
	    // From central decoder
	    .host_addr_reg		(host_addr_reg_out),
	    .SYS_ADDR			(4'h1),
	            
	    // From mac_register
	    .fail_over			(1'b0),
	    .fmac_ctrl			(32'h00000808),
	    .fmac_ctrl1			(32'h000005ee),
	
	    .fmac_rxd_en		(1'b1),
	
	    .mac_pause_value	(32'hffff0000),			// [31:16] = tx_pause_value to send a pause frame, [15:0] = rx_pause_value (not implement)
	    //.mac_addr0		(48'h001232004eaf),		// mac_addr to check in non-promiscuous mode
	    .mac_addr0		    (48'h001232ffffff),		// mac_addr to check in non-promiscuous mode - lewiz mac
	
	    .reg_rd_start		(reg_rd_start_out),
	
	    .reg_rd_done_out	(reg_rd_done_in),		
	
	    .FMAC_REGDOUT		(FMAC_REGDOUT_in),
	    .FIFO_OV_IPEND  	(),
	    .fmac_speed			(fmac_speed)

	);


endmodule