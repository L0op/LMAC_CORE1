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


// synopsys translate_off
`timescale 1ns / 1ns                                                                                                                                               
// synopsys translate_on

module gige_s2p (
		clk,					 //i-1, FMAC clk, 125Mhz
		reset_,					 //i-1, Reset signal
		fmac_speed, 			 //i-2, FMAC Speed 2-bit wide
		
		
		
		data_in,				 //i-8, Data in signal from PHY
//		ctrl_in,				 //i-1, Ctrl in signal from PHY
		pdet_in,				 //i-1, pattern detect
		gmii_rx_dv,				 //i-1, Valid data signal
		
		data_out,				 //o-64, Output in parallel 64-bit form
		ctrl_out,				 //o-8, Output ctrl sign in parallel 8-bit
		
		loopback_en,			 //i-1, loopback signal
		sfp_los,				 //i-1, 
		linkup,					 //o-1
		x_we,					 //o-1, Write Signal for Gige FIFO
		x_bcnt_we,				 //o-1, Write Signal for Byte Count FIFO
		x_byte_cnt				 //o-32, Byte Count of every Packet
	);

input 			clk;			 //i-1, FMAC clk, 125Mhz
input 			reset_;			 //i-1, Reset signal
input	[1:0]	fmac_speed;		 //i-2, FMAC Speed 2-bit wide
input 	[7:0]	data_in;		 //i-8, Data in signal from PHY
//input 			ctrl_in;		 //i-1, Ctrl in signal from PHY
input			pdet_in;		 //i-1, pattern detect
(* KEEP = "TRUE" *) input			gmii_rx_dv;		 //i-1, Valid data signal

(* KEEP = "TRUE" *) output	[63:0]	data_out;		 //o-64, Output in parallel 64-bit form
output	[07:0]	ctrl_out;		 //o-8, Output ctrl sign in parallel 8-bit

input			loopback_en;	 //i-1, loopback signal
input			sfp_los;		 //i-1, 
output			linkup;			 //o-1
output          x_we;			 //o-1, Write Signal for Gige FIFO
output          x_bcnt_we;		 //o-1, Write Signal for Byte Count FIFO
output	[15:0]	x_byte_cnt;		 //o-32, Byte Count of every Packet

reg			linkup;
reg         x_we;
reg         x_bcnt_we;
reg [15:0]	x_byte_cnt;


reg 	[7:0]	data_in_dly;	 //Delayed data
reg 	[7:0]	data_in_dly_1;	 //Delayed data
reg 			ctrl_in_dly;

(* KEEP = "TRUE" *) reg			frame;				 //Shows how much data coming in to the module is valid or how long the packet lasts
reg			insert;

reg			sof;				 //Start of Frame
reg			eof;				 //End of Frame

reg			eof0;				 //Packet End on byte 0
reg			eof1;				 //Packet End on byte 1
reg			eof2;				 //Packet End on byte 2
reg			eof3;				 //Packet End on byte 3
reg			eof4;				 //Packet End on byte 4
reg			eof5;				 //Packet End on byte 5
reg			eof6;				 //Packet End on byte 6
reg	[15:0]	count;				 //Counter to give out parallel valid data

reg			pvld;				 //Shows if the data in parallel is valid or not

reg [63:0]	data_out;
reg [7:0]	ctrl_out;

reg [7:0]	dff0, dff1, dff2, dff3, dff4, dff5, dff6, dff7;
reg 		cff0, cff1, cff2, cff3, cff4, cff5, cff6, cff7;

(* KEEP = "TRUE" *) wire [63:0] pdata = {dff0, dff1, dff2, dff3, dff4, dff5, dff6, dff7};
(* KEEP = "TRUE" *) wire [7:0]	pctrl = {cff0, cff1, cff2, cff3, cff4, cff5, cff6, cff7};

reg 		eof_dly1;
reg 		eof_dly2;
reg	[7:0]	counter2;
reg [15:0]	count100;

reg		pulse10 ;
reg		pulse100;
reg		eof_seen ;
reg		pulse10_dly1;
reg		pulse100_dly1;

reg frame_dly1;
(* KEEP = "TRUE" *) reg ctrl_high,ctrl_low, ctrl_low_dly;

(* KEEP = "TRUE" *) reg gmii_rx_dv_dly;

reg [3:0] count_data;
(* KEEP = "TRUE" *) reg data_flag;


 
always @ (posedge clk)
begin
	if (!reset_)
	begin
		data_in_dly <= 8'h07;
		data_in_dly_1 <= 8'h07;		
		ctrl_in_dly <= 1'b1; 
	
		frame <= 1'b0;
		insert <= 1'b0;
		
		sof <= 1'b0;
		eof <= 1'b0;
		eof_dly1 <= 1'b0;
		eof_dly2 <= 1'b0;
		eof_seen <= 1'b0 ;
		
		eof0 <= 1'b0;
		eof1 <= 1'b0;
		eof2 <= 1'b0;
		eof3 <= 1'b0;
		eof4 <= 1'b0;
		eof5 <= 1'b0;
		eof6 <= 1'b0;
		
		count <= 16'h0;
		pvld <= 1'b0;
		
		data_out <= 64'h0707070707070707;
		ctrl_out <= 8'hff;
		x_bcnt_we <= 1'b0;
		x_we <= 1'b0;
		
//		pulse10 <= 1'b0;
		x_byte_cnt <= 16'h0;
//		pulse10_dly1 <= 1'b0;
		gmii_rx_dv_dly <= 0;
		ctrl_high <= 1'b0;
		ctrl_low <= 1'b0;
		ctrl_low_dly <= 1'b0;
	end
	
	else
	begin

		data_in_dly <= data_in;
		data_in_dly_1 <= data_in_dly;
		gmii_rx_dv_dly <= gmii_rx_dv;
		
		ctrl_high <= ((~gmii_rx_dv_dly) & gmii_rx_dv)? 1'b1 : 1'b0;
		ctrl_low  <= (gmii_rx_dv_dly & (~gmii_rx_dv))? 1'b1 : 1'b0; 
		ctrl_low_dly  <= ctrl_low;
  
	
		frame <= ctrl_high ? 1'b1 : ( ctrl_low ? 1'b0 : frame);

		
	
		sof <= ctrl_high;

		eof <= ctrl_low;
		
		
		eof_dly1	<= eof ;
		eof_dly2 <= eof_dly1;
		eof_seen	<=
			frame & !frame_dly1 ? 1'b0 :
			eof & !eof_dly1 ? 1'b1 :
			eof_seen ;
		
		if (fmac_speed == 2'd1)
			begin                  
				eof0 <= data_flag ? ctrl_low & (count == 16'd0)	:	ctrl_low & (count == 16'd7);
				eof1 <= data_flag ? ctrl_low & (count == 16'd7)	:	ctrl_low & (count == 16'd6);
				eof2 <= data_flag ? ctrl_low & (count == 16'd6)	:	ctrl_low & (count == 16'd5);
				eof3 <= data_flag ? ctrl_low & (count == 16'd5)	:	ctrl_low & (count == 16'd4);
				eof4 <= data_flag ? ctrl_low & (count == 16'd4)	:	ctrl_low & (count == 16'd3);
				eof5 <= data_flag ? ctrl_low & (count == 16'd3)	:	ctrl_low & (count == 16'd2);
				eof6 <= data_flag ? ctrl_low & (count == 16'd2)	:	ctrl_low & (count == 16'd1);
				
				count <= (frame & count != 16'h0)? (count - 16'h1) : 16'h7 ;   //Down Counter for 8 counts
				

				x_byte_cnt <= ctrl_high ? 16'd1 :		   //Calculate byte count
						(frame & ctrl_low & data_flag) ? x_byte_cnt + 16'd1:
						(frame & ctrl_low) ? x_byte_cnt:
						(frame) ? x_byte_cnt + 16'd1 :     
						x_byte_cnt;                                      
						
						
						
				
		        x_bcnt_we <= eof_dly2;										   //Wite to byte count fifo once byte count calculated
				
			end
			
		else if (fmac_speed == 2'd2)
			begin
				eof0 <= data_flag ? ctrl_low & (count == 16'd70)	:	ctrl_low & (count == 16'd69);
				eof1 <= data_flag ? ctrl_low & (count == 16'd60)	:	ctrl_low & (count == 16'd59);
				eof2 <= data_flag ? ctrl_low & (count == 16'd50)	:	ctrl_low & (count == 16'd49);
				eof3 <= data_flag ? ctrl_low & (count == 16'd40)	:	ctrl_low & (count == 16'd39);
				eof4 <= data_flag ? ctrl_low & (count == 16'd30)	:	ctrl_low & (count == 16'd29);
				eof5 <= data_flag ? ctrl_low & (count == 16'd20)	:	ctrl_low & (count == 16'd19);
				eof6 <= data_flag ? ctrl_low & (count == 16'd10)	:	ctrl_low & (count == 16'd09);
			    
			    count <= 
					(frame & !frame_dly1) ? 16'd77 :
					( (frame | frame_dly1 )& count != 16'h0)? (count - 16'h1) : 16'd79 ;
					
				x_byte_cnt <= ctrl_high ? 16'd1 :		   //Calculate byte count
						(pulse10_dly1 & frame & ctrl_low & data_flag) ? x_byte_cnt + 16'd1:
						(pulse10_dly1 & frame & ctrl_low) ? x_byte_cnt:
						(pulse10_dly1 & frame) ? x_byte_cnt + 16'd1 :     
						x_byte_cnt;              
				
												
				x_bcnt_we <= (eof & counter2 == 8'd1) ? 1'b1 :
    						1'b0;
    						
			end
			
		else if (fmac_speed == 2'd3)
			begin
				eof0 <= data_flag ? ctrl_low & (count == 16'd700)	:	ctrl_low & (count == 16'd699);
				eof1 <= data_flag ? ctrl_low & (count == 16'd600)	:	ctrl_low & (count == 16'd599);
				eof2 <= data_flag ? ctrl_low & (count == 16'd500)	:	ctrl_low & (count == 16'd499);
				eof3 <= data_flag ? ctrl_low & (count == 16'd400)	:	ctrl_low & (count == 16'd399);
				eof4 <= data_flag ? ctrl_low & (count == 16'd300)	:	ctrl_low & (count == 16'd299);
				eof5 <= data_flag ? ctrl_low & (count == 16'd200)	:	ctrl_low & (count == 16'd199);
				eof6 <= data_flag ? ctrl_low & (count == 16'd100)	:	ctrl_low & (count == 16'd099);
			
				count <= 
					(frame & !frame_dly1) ? 16'd797 :
					((frame | frame_dly1 ) & count != 16'h0)? (count - 16'h1) : 16'd799 ;
					
				x_byte_cnt <= ctrl_high ? 16'd1 :		   //Calculate byte count
						(pulse100_dly1 & frame & ctrl_low & data_flag) ? x_byte_cnt + 16'd1:
						(pulse100_dly1 & frame & ctrl_low) ? x_byte_cnt:
						(pulse100_dly1 & frame) ? x_byte_cnt + 16'd1 :     
						x_byte_cnt;              
					
				x_bcnt_we <= (eof & count100 == 16'd01) ? 1'b1 :
							1'b0;
											
		    end
		    			
		pvld <= data_flag ? ((count == 16'h1) | ctrl_low) : (ctrl_low_dly ? 1'b0 : (count == 16'h1));	
				
		
		casez ({linkup, pvld, eof0, eof1, eof2, eof3, eof4, eof5, eof6})
		
		
		9'b1?1??????:// eof on lane 0
				begin
				data_out <= 64'h0707_0707_0707_07fd;
		        ctrl_out <= 8'hff;
		        x_we <= 1'b1; 
		        count <= 16'h0;                 
				end
				
		9'b1?01?????:// eof on lane 1
				begin
				data_out <= {56'h070707070707fd, dff2};
		        ctrl_out <= {7'b1111111, cff2};
		        x_we <= 1'b1;     
		         count <= 16'h0;             
				end
				
		9'b1?001????:// eof on lane 2
				begin
				data_out <= {48'h0707070707fd, dff2, dff3};
		        ctrl_out <= {6'b111111, cff2, cff3};
		        x_we <= 1'b1;   
		         count <= 16'h0;               
				end
				
		9'b1?0001???:// eof on lane 3
				begin
				data_out <= {40'h07070707fd, dff2, dff3, dff4};
		        ctrl_out <= {5'b11111, cff2, cff3, cff4};
		        x_we <= 1'b1;   
		         count <= 16'h0;   
				end
		
		9'b1?00001??:// eof on lane 4
				begin
				data_out <= {32'h070707fd, dff2, dff3, dff4, dff5};
		        ctrl_out <= {4'b1111, cff2, cff3, cff4, cff5};
		        x_we <= 1'b1;   
		         count <= 16'h0;
				end
				
		9'b1?000001?:// eof on lane 5
				begin
				data_out <= {24'h0707fd, dff2, dff3, dff4, dff5, dff6};
		        ctrl_out <= {3'b111, cff2, cff3, cff4, cff5, cff6};
		        x_we <= 1'b1;  
		         count <= 16'h0;
				end
				
		9'b1?0000001:// eof on lane 6
				begin
				data_out <= {16'h07fd, dff2, dff3, dff4, dff5, dff6, dff7};
		        ctrl_out <= {2'b11, cff2, cff3, cff4, cff5, cff6, cff7};
		        x_we <= 1'b1;   
		         count <= 16'h0;
				end
		// If eof on lane 7, it is multiple of 8, pvld will take care of it		
		9'b11???????:// data within the frame
				begin
				data_out <= pdata;
		        ctrl_out <= (fmac_speed == 2'd1) ? (((pdata[63:56] == 8'hFD) & ctrl_low) ? 8'h80 : pctrl) :
		        			(fmac_speed == 2'd2) ? (((pdata[63:56] == 8'hFD) & (gmii_rx_dv_dly & (~gmii_rx_dv))) ? 8'h80 : pctrl) :
		        			(fmac_speed == 2'd3) ? (((pdata[63:56] == 8'hFD) & (gmii_rx_dv_dly & (~gmii_rx_dv))) ? 8'h80 : pctrl) : 
		        			pctrl;
		        
		        x_we <=  (fmac_speed == 2'b01)?	1'b1 :
		        			((frame & frame_dly1) | (pvld & eof))? 1'b1:
		        				1'b0; 			
	        						
				end
		default:
				begin
				data_out <= 64'h0707070707070707;
		        ctrl_out <= 8'hff;
		        x_we <= 1'b0;                  
				end
		endcase
		
	end
end


always @ (posedge clk)
begin
	if (!reset_)
		begin
	pulse10 <= 1'b0;
	pulse10_dly1 <= 1'b0;	
	end
	frame_dly1 <= frame;
		//count relative to data_in
	counter2 <= 
		(!reset_) ? 8'h0 :
		(frame & !frame_dly1) ? 8'd2 :	//initialize (count 0 already passed due to delay)
		(counter2 != 8'h9)? (counter2 + 8'h1) : 8'h0 ;
		
	count100 <=                                                                 
		(!reset_) ? 16'h0 :                                                         	
		(frame & !frame_dly1) ? 16'd2 :	//initialize (count 0 already passed due to delay)	
		(count100 != 16'h63)? (count100 + 16'h1) : 16'h0 ;                             		
	
	pulse100 <=
		(!reset_) ? 1'h0 :
		(count100 == 16'd98) ;
	
	pulse10	<= 
		(!reset_) ? 1'h0 :
		(counter2 == 8'd8) ;
	
	pulse10_dly1 <= pulse10;
	pulse100_dly1 <= pulse100;
	
	
	if (!reset_)
		begin
		dff0 <= 8'b0;
		dff1 <= 8'b0;
		dff2 <= 8'b0;
		dff3 <= 8'b0;
		dff4 <= 8'b0;
		dff5 <= 8'b0;
		dff6 <= 8'b0;
		dff7 <= 8'b0;
		
		cff0 <= 1'b0;
		cff1 <= 1'b0;
		cff2 <= 1'b0;
		cff3 <= 1'b0;
		cff4 <= 1'b0;
		cff5 <= 1'b0;
		cff6 <= 1'b0;
		cff7 <= 1'b0;
		
		count_data <= 4'b0000;
		data_flag  <= 1'b0;
		
		
		end
	else if (fmac_speed == 2'd1)		//1G
		begin
//		dff0 <= data_in;
//		dff1 <= dff0;
//		dff2 <= dff1;
//		dff3 <= dff2;
//		dff4 <= dff3;
//		dff5 <= dff4;
//		dff6 <= dff5;
//		dff7 <= dff6;
		
		if (count_data == 4'd8)
			count_data <= 0;
		else if (gmii_rx_dv)
			count_data <= count_data + 1;
		else
			count_data <= 0;
			
			
		data_flag <= (((pdata[63:16] == 48'h555555555555) | (pdata[63:16] == 48'h5555555555FB)) & (data_in_dly == 8'hd5) & (count == 16'd2)) ? 1'b1 : ((~gmii_rx_dv_dly) ? 1'b0 : data_flag);
		
		dff0 <= data_flag ? data_in_dly_1 : data_in_dly;
		dff1 <= ((data_in_dly_1 == 8'hd5) & ((pdata[63:8] == 56'hd5555555555555) | (pdata[63:8] == 56'hd55555555555FB)))? 8'h55 : dff0;
		dff2 <= dff1;
		dff3 <= dff2;
		dff4 <= dff3;
		dff5 <= dff4;
		dff6 <= dff5;
		dff7 <= dff6;

		
//		cff0 <= ctrl_in;
//		cff1 <= cff0;
//		cff2 <= cff1;
//		cff3 <= cff2;
//		cff4 <= cff3;
//		cff5 <= cff4;
//		cff6 <= cff5;
//		cff7 <= cff6;

//		cff0 <= ((gmii_rx_dv_dly) & (~frame)) ? 1'b1 :(((gmii_rx_dv_dly) & (~gmii_rx_dv)) ? 1'b1 : 1'b0) ;
		cff0 <= (ctrl_high | ctrl_low);
		cff1 <= cff0;
		cff2 <= cff1;
		cff3 <= cff2;
		cff4 <= cff3;
		cff5 <= cff4;
		cff6 <= cff5;
		cff7 <= cff6;

		end
	else if (fmac_speed ==2'd2)		//100M
		begin
		if ((counter2 == 8'h0) | (frame & !frame_dly1))
			begin
//				dff0 <= data_in;
//				dff1 <= dff0;
//				dff2 <= dff1;
//				dff3 <= dff2;
//				dff4 <= dff3;
//				dff5 <= dff4;
//				dff6 <= dff5;
//				dff7 <= dff6;
				
				dff0 <= data_in_dly;
				dff1 <= dff0;
				dff2 <= dff1;
				dff3 <= dff2;
				dff4 <= dff3;
				dff5 <= dff4;
				dff6 <= dff5;
				dff7 <= dff6;
				
				
//				cff0 <= ctrl_in;
//				cff1 <= cff0;
//				cff2 <= cff1;
//				cff3 <= cff2;
//				cff4 <= cff3;
//				cff5 <= cff4;
//				cff6 <= cff5;
//				cff7 <= cff6;
			
//				cff0 <= gmii_rx_dv_dly;
				cff0 <= (ctrl_high | ctrl_low) ;
				cff1 <= cff0;
				cff2 <= cff1;
				cff3 <= cff2;
				cff4 <= cff3;
				cff5 <= cff4;
				cff6 <= cff5;
				cff7 <= cff6;

			end
		end
	else if (fmac_speed == 2'd3)	//10M
		begin
		if ((count100 == 16'h0) | (frame & !frame_dly1))
			begin
//				dff0 <= data_in;	
//			    dff1 <= dff0;   
//			    dff2 <= dff1;   
//			    dff3 <= dff2;   
//			    dff4 <= dff3;   
//			    dff5 <= dff4;   
//			    dff6 <= dff5;   
//			    dff7 <= dff6; 
			    
				dff0 <= data_in_dly;
				dff1 <= dff0;
				dff2 <= dff1;
				dff3 <= dff2;
				dff4 <= dff3;
				dff5 <= dff4;
				dff6 <= dff5;
				dff7 <= dff6;
			      
			                    
//			    cff0 <= ctrl_in;
//			    cff1 <= cff0;   
//			    cff2 <= cff1;   
//			    cff3 <= cff2;   
//			    cff4 <= cff3;   
//			    cff5 <= cff4;   
//			    cff6 <= cff5;   
//			    cff7 <= cff6;
			    
//				cff0 <= gmii_rx_dv_dly;
				cff0 <= (ctrl_high | ctrl_low) ;
				cff1 <= cff0;
				cff2 <= cff1;
				cff3 <= cff2;
				cff4 <= cff3;
				cff5 <= cff4;
				cff6 <= cff5;
				cff7 <= cff6;
			    
			end   		
		end		
end


reg pdet_in_dly;
reg pdet_in_dly_1;
reg idle_detect;
reg [7:0] consec_idle;	// use to detect 4 consecutive idle pattern
reg link_ok;
reg	link_break;
reg real_los;

always @ (posedge clk)
begin
	if (!reset_)
	begin
		pdet_in_dly <= 1'b0;
		pdet_in_dly_1 <= 1'b0;
		idle_detect <= 1'b0;
		consec_idle <= 8'h0;
		link_ok 	<= 1'b0;
		link_break	<= 1'b0;
		real_los	<= 1'b0;
		linkup		<= 1'b0;
	end
	
	else
	begin
		pdet_in_dly <= pdet_in;
		pdet_in_dly_1 <= pdet_in_dly;
//		idle_detect <= pdet_in | pdet_in_dly;
		idle_detect <= ctrl_high ? 1'b1 : (!(gmii_rx_dv | gmii_rx_dv_dly));		
		consec_idle <= linkup? 8'h00 : {consec_idle[6:0], idle_detect};
		link_ok		<= (consec_idle == 8'hff) & !real_los;
		link_break	<= (pdata == 64'h0000_42BC_0000_B5BC) | real_los;
		real_los	<= (sfp_los & !loopback_en);
		linkup		<= link_ok? 1'b1 : (link_break? 1'b0 : linkup);
	end
end

endmodule