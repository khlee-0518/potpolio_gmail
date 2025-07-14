`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/17 16:52:44
// Design Name: 
// Module Name: video_filter_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module video_filter_rx(
	 input			aclk			
	,input			vclk		
	,input	[3:0]	i_sel_filter
	,input			i_vid_d_val	
	,input			i_vid_v_val	
	,input			i_vid_h_val	
	,input	[15:0]	i_vid_data	
	,input	[15:0]	i_cnt_pixel	
	,input	[15:0]	i_cnt_line	
	,input	[15:0]	i_cnt_frame	
	,input	[399:0]	i_coe_filter	
//	,input	[15:0]	i_coe_filter_0_0	
//	,input	[15:0]	i_coe_filter_0_1	
//	,input	[15:0]	i_coe_filter_0_2	
//	,input	[15:0]	i_coe_filter_0_3	
//	,input	[15:0]	i_coe_filter_0_4	
//	,input	[15:0]	i_coe_filter_1_0	
//	,input	[15:0]	i_coe_filter_1_1	
//	,input	[15:0]	i_coe_filter_1_2	
//	,input	[15:0]	i_coe_filter_1_3	
//	,input	[15:0]	i_coe_filter_1_4	
//	,input	[15:0]	i_coe_filter_2_0	
//	,input	[15:0]	i_coe_filter_2_1	
//	,input	[15:0]	i_coe_filter_2_2	
//	,input	[15:0]	i_coe_filter_2_3	
//	,input	[15:0]	i_coe_filter_2_4	
//	,input	[15:0]	i_coe_filter_3_0	
//	,input	[15:0]	i_coe_filter_3_1	
//	,input	[15:0]	i_coe_filter_3_2	
//	,input	[15:0]	i_coe_filter_3_3	
//	,input	[15:0]	i_coe_filter_3_4	
//	,input	[15:0]	i_coe_filter_4_0	
//	,input	[15:0]	i_coe_filter_4_1	
//	,input	[15:0]	i_coe_filter_4_2	
//	,input	[15:0]	i_coe_filter_4_3	
//	,input	[15:0]	i_coe_filter_4_4	
	,output			o_vf_dval	
	,output			o_vf_vval	
	,output			o_vf_hval	
	,output	[15:0]	o_vf_data	
	,input			aresetn		
    );
	
	genvar i;
	genvar j;
	
	wire	[3:0]	s_sel_filter						;
	wire			s_vid_d_val							;
	wire			s_vid_v_val							;
	wire			s_vid_h_val							;
	wire	[ 9:0]	s_vid_data							;
	wire	[15:0]	s_cnt_vf_pixel						;
	wire	[15:0]	s_cnt_vf_line						;
	wire	[15:0]	s_cnt_vf_frame						;
	reg		[3:0]	b_sel_filter						;(* MARK_DEBUG="true" *)
	reg				b_vid_d_val							;(* MARK_DEBUG="true" *)
	reg				b_vid_v_val							;(* MARK_DEBUG="true" *)
	reg				b_vid_h_val							;(* MARK_DEBUG="true" *)
	reg		[15:0]	b_vid_data							;
	wire	[15:0]	s_vid_data_dly						;
	reg		[15:0]	b_cnt_vf_pixel						;
	wire	[15:0]	s_cnt_vf_pixel_d15					;
	wire	[15:0]	s_cnt_vf_pixel_d2					;
	wire	[15:0]	s_cnt_vf_pixel_d3					;
	reg		[15:0]	b_cnt_vf_line						;
	reg		[15:0]	b_cnt_vf_frame						;
	reg		[ 5:0]	vf_wea								;
	reg		[ 5:0]	vf_ena								;
	reg		[ 5:0]	mod6_wt_line						;
	reg		[ 5:0]	mod6_line_wt_wide					;
	reg		[ 5:0]	mod6_line_rd						;
	wire	[ 5:0]	mod6_line_rd_3d						;
	reg		[ 5:0]	mod6_line_rd_1d						;
	reg		[ 4:0]	mod5_pixel							;
	wire	[15:0]	s_bram_pre_ft_data		[0:5]		;(* MARK_DEBUG="true" *)
	reg		[15:0]	arrange_pre_ft_data		[0:4]		;(* MARK_DEBUG="true" *)
	wire	[15:0]	arrange_pre_ft_data_conv[0:4][0:4]	;
	wire	[15:0]	s_arrange_filter_data				;
	wire	[11:0]	cnt_filter_data						;(* MARK_DEBUG="true" *)
	reg		[15:0]	coe_filter_cnt						;
	reg				coe_filter_change					;
	reg		[15:0]	coe_filter_sum						;
	reg		[15:0]	coe_filter_sum_1d					;
	reg		[15:0]	coe_filter_power					;
	reg		[15:0]	coe_filter				[0:4][0:4]	;(* MARK_DEBUG="true" *)
	reg		[15:0]	coe_filter_inv			[0:4][0:4]	;
	reg		[15:0]	coe_filter_line			[0:4]		;
	wire	[15:0]	coe_filter_line_conv	[0:4][0:4]	;
	wire			b_vid_d_val_d3						;
	wire	[31:0]	mult_ft_data			[0:4][0:4]	;(* MARK_DEBUG="true" *)
	reg		[31:0]	mult_ft_data_1d			[0:4][0:4]	;
	reg		[31:0]	mult_ft_data_shift		[0:4][0:4]	;(* MARK_DEBUG="true" *)
	reg		[31:0]	mult_ft_data_sum_pixel	[0:4]		;(* MARK_DEBUG="true" *)
	reg		[31:0]	mult_ft_data_sum_line				;
	reg		[31:0]	mult_ft_data_div					;(* MARK_DEBUG="true" *)
	reg		[15:0]	mult_ft_data_limit					;(* MARK_DEBUG="true" *)
	wire			b_vid_d_val_d16						;(* MARK_DEBUG="true" *)
	wire			b_vid_v_val_32d						;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_pixel							;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_line							;
	reg		[15:0]	cnt_frame							;(* MARK_DEBUG="true" *)
	reg		[7:0]	status_filter						;
	
	assign s_sel_filter		= i_sel_filter				;
	assign s_vid_d_val		= i_vid_d_val				;
	assign s_vid_v_val		= i_vid_v_val				;
	assign s_vid_h_val		= i_vid_h_val				;
	assign s_vid_data		= i_vid_data				;
	assign s_cnt_vf_pixel	= i_cnt_pixel				;
	assign s_cnt_vf_line	= i_cnt_line				;
	assign s_cnt_vf_frame	= i_cnt_frame				;
	
	assign o_vf_dval	= b_vid_d_val_d16;
	assign o_vf_vval	= b_vid_v_val_32d;
	assign o_vf_hval	= b_vid_d_val_d16;
	assign o_vf_data	= mult_ft_data_limit[15:0];
//	assign o_vf_data	= {6'h0, mult_ft_data_limit[ 9:0]};
	
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		b_vid_d_val					<= 0;
		b_vid_v_val					<= 0;
		b_vid_h_val					<= 0;
		b_vid_data			[15:0]	<= 0;
		b_cnt_vf_pixel		[15:0]	<= 0;
		b_cnt_vf_line		[15:0]	<= 0;
		b_cnt_vf_frame		[15:0]	<= 0;
		mod6_line_rd_1d		[ 5:0]	<= 0;
		b_sel_filter		[3:0]	<= 0;
	end
	else begin
		b_vid_d_val					<= s_vid_d_val		;
		b_vid_v_val					<= s_vid_v_val		;
		b_vid_h_val					<= s_vid_h_val		;
		b_vid_data					<= {6'h0, s_vid_data[9:0]}	;
		b_cnt_vf_pixel				<= s_cnt_vf_pixel	;
		b_cnt_vf_line				<= s_cnt_vf_line	;
		b_cnt_vf_frame				<= s_cnt_vf_frame	;
		mod6_line_rd_1d				<= mod6_line_rd;
		b_sel_filter				<= s_sel_filter;
	end
end
delay_data	#(
	.BIT_WIDTH		(6						),	//1~
	.NUM_DELAY		(3						)	//1~
	)
	dly_mod6_line_rd					(
	.aclk			(vclk					),
	.delay_array_i	(mod6_line_rd			),
	.delay_array_o	(mod6_line_rd_3d		),
	.aresetn		(aresetn				)
);

//count video
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_pixel			[15:0]	<= 0;
	end
	else if(b_vid_d_val==1)begin
		cnt_pixel					<= cnt_pixel +1;
	end
	else begin
		cnt_pixel					<= 0;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_line							<= 0;
	end
	else if(b_vid_v_val_pls==1)begin
		cnt_line							<= 0;
	end
	else if(s_vid_d_val_pls==1)begin
		cnt_line							<= cnt_line +1;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_frame							<= 0;
	end
	else if(b_vid_v_val_pls)begin
		cnt_frame							<= cnt_frame +1;
	end
end
gen_pulse		gen_pulse_fval				(
	.aclk			(vclk					),
	.step_i			(b_vid_v_val			),
	.pulse_o		(b_vid_v_val_pls		),
	.aresetn		(aresetn				)
);
gen_pulse_neg	gen_pulse_dval_neg			(
	.aclk			(vclk					),
	.step_i			(s_vid_d_val			),
	.pulse_o		(s_vid_d_val_pls		),
	.aresetn		(aresetn				)
);

//
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(15						)	//1~
	)
	vf_pixel16_delay_data					(
	.aclk			(vclk					),
//	.delay_array_i	(b_cnt_vf_pixel			),
	.delay_array_i	(cnt_pixel				),
	.delay_array_o	(s_cnt_vf_pixel_d15		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(2						)	//1~
	)
	vf_pixel2_delay_data					(
	.aclk			(vclk					),
//	.delay_array_i	(b_cnt_vf_pixel			),
	.delay_array_i	(cnt_pixel				),
	.delay_array_o	(s_cnt_vf_pixel_d2		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(3						)	//1~
	)
	vf_pixel3_delay_data					(
	.aclk			(vclk					),
//	.delay_array_i	(b_cnt_vf_pixel			),
	.delay_array_i	(cnt_pixel				),
	.delay_array_o	(s_cnt_vf_pixel_d3		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(2						)	//1~
	)
	vf_data_delay_data						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_data				),
	.delay_array_o	(s_vid_data_dly			),
	.aresetn		(aresetn				)
);

//generate
//for(i=0; i < 6; i=i+1) begin: gen_bram_mod_wt
//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		mod6_wt_line			[i]		<= 0;
//	end
//	else if( (b_cnt_vf_line%6)==i && b_vid_d_val==1)begin
//		mod6_wt_line			[i]		<= 1;
//	end
//	else begin
//		mod6_wt_line			[i]		<= 0;
//	end
//end
//end
//endgenerate
//
//generate
//for(i=0; i < 6; i=i+1) begin: gen_bram_mod_wt_wide
//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		mod6_line_wt_wide		[i]		<= 0;
//	end
//	else if( (b_cnt_vf_line%6)==i )begin
//		mod6_line_wt_wide		[i]		<= 1;
//	end
//	else begin
//		mod6_line_wt_wide		[i]		<= 0;
//	end
//end
//end
//endgenerate
//
//generate
//for(i=0; i < 6; i=i+1) begin: gen_bram_mod_rd
//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		mod6_line_rd			[i]		<= 0;
//	end
//	else if( (b_cnt_vf_line%6)!=i && b_vid_d_val==1)begin
//		mod6_line_rd			[i]		<= 1;
//	end
//	else begin
//		mod6_line_rd			[i]		<= 0;
//	end
//end
//end
//endgenerate

generate
for(i=0; i < 6; i=i+1) begin: gen_bram_mod_wt
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mod6_wt_line			[i]		<= 0;
	end
	else if( (cnt_line%6)==i && b_vid_d_val==1)begin
		mod6_wt_line			[i]		<= 1;
	end
	else begin
		mod6_wt_line			[i]		<= 0;
	end
end
end
endgenerate

generate
for(i=0; i < 6; i=i+1) begin: gen_bram_mod_wt_wide
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mod6_line_wt_wide		[i]		<= 0;
	end
	else if( (cnt_line%6)==i )begin
		mod6_line_wt_wide		[i]		<= 1;
	end
	else begin
		mod6_line_wt_wide		[i]		<= 0;
	end
end
end
endgenerate

generate
for(i=0; i < 6; i=i+1) begin: gen_bram_mod_rd
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mod6_line_rd			[i]		<= 0;
	end
	else if( (cnt_line%6)!=i && b_vid_d_val==1)begin
		mod6_line_rd			[i]		<= 1;
	end
	else begin
		mod6_line_rd			[i]		<= 0;
	end
end
end
endgenerate

generate
for(i=0; i < 6; i=i+1) begin: gen_bram_ena
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		vf_ena					[i]		<= 0;
	end
	else if( mod6_wt_line[i]==1 )begin
		vf_ena					[i]		<= 1;
	end
	else begin
		vf_ena					[i]		<= 0;
	end
end
end
endgenerate

generate
for(i=0; i < 6; i=i+1) begin: gen_bram_wea
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		vf_wea					[i]		<= 0;
	end
	else if( mod6_wt_line[i]==1 )begin
		vf_wea					[i]		<= 1;
	end
	else begin
		vf_wea					[i]		<= 0;
	end
end
end
endgenerate


generate
for(i=0; i < 6; i=i+1) begin: gen_mem_video_filter
blk_mem_video_filter vf0_blk_mem_video_filter
(
	.clka		(vclk						),// input	wire clka
	.ena		(vf_ena				[i]		),// input	wire ena
	.wea		(vf_wea				[i]		),// input	wire [0 : 0] wea
	.addra		(s_cnt_vf_pixel_d2	[11:0]	),// input	wire [11 : 0] addra
	.dina		(s_vid_data_dly		[15:0]	),// input	wire [15 : 0] dina
	.douta		(							),// output	wire [15 : 0] douta
	.clkb		(vclk						),// input	wire clkb
	.enb		(mod6_line_rd_1d	[i]		),// input	wire enb
	.web		(0							),// input	wire [0 : 0] web
	.addrb		(s_cnt_vf_pixel_d2	[11:0]	),// input	wire [11 : 0] addrb
	.dinb		(0							),// input	wire [15 : 0] dinb
	.doutb		(s_bram_pre_ft_data	[i]		) // output	wire [15 : 0] doutb
);
end
endgenerate

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		arrange_pre_ft_data			[0]		<= 0;
		arrange_pre_ft_data			[1]		<= 0;
		arrange_pre_ft_data			[2]		<= 0;
		arrange_pre_ft_data			[3]		<= 0;
		arrange_pre_ft_data			[4]		<= 0;
	end
	else if( b_vid_d_val_d3==0 )begin
		arrange_pre_ft_data			[0]		<= 0;
		arrange_pre_ft_data			[1]		<= 0;
		arrange_pre_ft_data			[2]		<= 0;
		arrange_pre_ft_data			[3]		<= 0;
		arrange_pre_ft_data			[4]		<= 0;
	end
	else if( mod6_line_wt_wide[0]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[5];
	end
	else if( mod6_line_wt_wide[1]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[0];
	end
	else if( mod6_line_wt_wide[2]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[1];
	end
	else if( mod6_line_wt_wide[3]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[2];
	end
	else if( mod6_line_wt_wide[4]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[3];
	end
	else if( mod6_line_wt_wide[5]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[4];
	end
	else begin
		arrange_pre_ft_data			[0]		<= 0;
		arrange_pre_ft_data			[1]		<= 0;
		arrange_pre_ft_data			[2]		<= 0;
		arrange_pre_ft_data			[3]		<= 0;
		arrange_pre_ft_data			[4]		<= 0;
	end
end

generate
for(j=0; j < 5; j=j+1) begin: gen_pre_ft_data_conv_j
	for(i=0; i < 5; i=i+1) begin: gen_i
	delay_data	#(
		.BIT_WIDTH		(16									),	//1~
		.NUM_DELAY		(i+1								)	//1~
		)
		vf_d3_val_delay_data								(
		.aclk			(vclk								),
		.delay_array_i	(arrange_pre_ft_data		[j]		),
		.delay_array_o	(arrange_pre_ft_data_conv	[j]	[i]	),
		.aresetn		(aresetn							)
	);
	end
end
endgenerate

assign s_arrange_filter_data[15:0] = arrange_pre_ft_data	[0]		;
assign cnt_filter_data		[11:0] = s_arrange_filter_data	[11:0]	;

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter					[0][0]	<= 0;
		coe_filter					[0][1]	<= 0;
		coe_filter					[0][2]	<= 0;
		coe_filter					[0][3]	<= 0;
		coe_filter					[0][4]	<= 0;
		coe_filter					[1][0]	<= 0;
		coe_filter					[1][1]	<= 0;
		coe_filter					[1][2]	<= 0;
		coe_filter					[1][3]	<= 0;
		coe_filter					[1][4]	<= 0;
		coe_filter					[2][0]	<= 0;
		coe_filter					[2][1]	<= 0;
		coe_filter					[2][2]	<= 0;
		coe_filter					[2][3]	<= 0;
		coe_filter					[2][4]	<= 0;
		coe_filter					[3][0]	<= 0;
		coe_filter					[3][1]	<= 0;
		coe_filter					[3][2]	<= 0;
		coe_filter					[3][3]	<= 0;
		coe_filter					[3][4]	<= 0;
		coe_filter					[4][0]	<= 0;
		coe_filter					[4][1]	<= 0;
		coe_filter					[4][2]	<= 0;
		coe_filter					[4][3]	<= 0;
		coe_filter					[4][4]	<= 0;
	end
	else begin
		coe_filter					[0][0]	<= i_coe_filter[ 0*16+15 : 0*16 ];	//i_coe_filter_0_0;	
		coe_filter					[0][1]	<= i_coe_filter[ 1*16+15 : 1*16 ];	//i_coe_filter_0_1;	
		coe_filter					[0][2]	<= i_coe_filter[ 2*16+15 : 2*16 ];	//i_coe_filter_0_2;	
		coe_filter					[0][3]	<= i_coe_filter[ 3*16+15 : 3*16 ];	//i_coe_filter_0_3;	
		coe_filter					[0][4]	<= i_coe_filter[ 4*16+15 : 4*16 ];	//i_coe_filter_0_4;	
		coe_filter					[1][0]	<= i_coe_filter[ 5*16+15 : 5*16 ];	//i_coe_filter_1_0;	
		coe_filter					[1][1]	<= i_coe_filter[ 6*16+15 : 6*16 ];	//i_coe_filter_1_1;	
		coe_filter					[1][2]	<= i_coe_filter[ 7*16+15 : 7*16 ];	//i_coe_filter_1_2;	
		coe_filter					[1][3]	<= i_coe_filter[ 8*16+15 : 8*16 ];	//i_coe_filter_1_3;	
		coe_filter					[1][4]	<= i_coe_filter[ 9*16+15 : 9*16 ];	//i_coe_filter_1_4;	
		coe_filter					[2][0]	<= i_coe_filter[10*16+15 :10*16 ];	//i_coe_filter_2_0;	
		coe_filter					[2][1]	<= i_coe_filter[11*16+15 :11*16 ];	//i_coe_filter_2_1;	
		coe_filter					[2][2]	<= i_coe_filter[12*16+15 :12*16 ];	//i_coe_filter_2_2;	
		coe_filter					[2][3]	<= i_coe_filter[13*16+15 :13*16 ];	//i_coe_filter_2_3;	
		coe_filter					[2][4]	<= i_coe_filter[14*16+15 :14*16 ];	//i_coe_filter_2_4;	
		coe_filter					[3][0]	<= i_coe_filter[15*16+15 :15*16 ];	//i_coe_filter_3_0;	
		coe_filter					[3][1]	<= i_coe_filter[16*16+15 :16*16 ];	//i_coe_filter_3_1;	
		coe_filter					[3][2]	<= i_coe_filter[17*16+15 :17*16 ];	//i_coe_filter_3_2;	
		coe_filter					[3][3]	<= i_coe_filter[18*16+15 :18*16 ];	//i_coe_filter_3_3;	
		coe_filter					[3][4]	<= i_coe_filter[19*16+15 :19*16 ];	//i_coe_filter_3_4;	
		coe_filter					[4][0]	<= i_coe_filter[20*16+15 :20*16 ];	//i_coe_filter_4_0;	
		coe_filter					[4][1]	<= i_coe_filter[21*16+15 :21*16 ];	//i_coe_filter_4_1;	
		coe_filter					[4][2]	<= i_coe_filter[22*16+15 :22*16 ];	//i_coe_filter_4_2;	
		coe_filter					[4][3]	<= i_coe_filter[23*16+15 :23*16 ];	//i_coe_filter_4_3;	
		coe_filter					[4][4]	<= i_coe_filter[24*16+15 :24*16 ];	//i_coe_filter_4_4;	
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter_sum				[15:0]	<= 0;
	end
	else begin
		coe_filter_sum				[15:0]	<= 
		coe_filter[0][0] + coe_filter[0][1] + coe_filter[0][2] + coe_filter[0][3] + coe_filter[0][4] +
		coe_filter[1][0] + coe_filter[1][1] + coe_filter[1][2] + coe_filter[1][3] + coe_filter[1][4] +
		coe_filter[2][0] + coe_filter[2][1] + coe_filter[2][2] + coe_filter[2][3] + coe_filter[2][4] +
		coe_filter[3][0] + coe_filter[3][1] + coe_filter[3][2] + coe_filter[3][3] + coe_filter[3][4] +
		coe_filter[4][0] + coe_filter[4][1] + coe_filter[4][2] + coe_filter[4][3] + coe_filter[4][4] ;
	end
end
//filter count
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter_sum_1d			[15:0]	<= 0;
	end
	else begin
		coe_filter_sum_1d					<= coe_filter_sum;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter_change				<= 0;
	end
	else if(coe_filter_sum != coe_filter_sum_1d	)begin
		coe_filter_change				<= 1;
	end
	else begin
		coe_filter_change				<= 0;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter_power			[15:0]	<= 0;
	end
	else if(coe_filter_change==1)begin
		coe_filter_power					<= coe_filter_sum	>>1;
	end
	else begin
		coe_filter_power					<= coe_filter_power	>>1;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter_cnt					<= 0;
	end
	else if(coe_filter_change ==1 )begin
		coe_filter_cnt					<= 0;
	end
	else if(coe_filter_power > 0)begin
		coe_filter_cnt					<= coe_filter_cnt +1;
	end
end

generate
for(j=0; j < 5; j=j+1) begin: gen_coe_filter_inv
	for(i=0; i < 5; i=i+1) begin: gen_i
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			coe_filter_inv					[j][i]	<= 0;
		end
		else begin
			coe_filter_inv					[j][i]	<= coe_filter	[j][4-i]	;
		end
	end
	end
end
endgenerate

delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(1						)	//1~
	)
	dly_b_vid_v_val_1d						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_v_val			),
	.delay_array_o	(b_vid_v_val_1d			),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(18						)	//1~
	)
	dly_b_vid_v_val_32d						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_v_val			),
	.delay_array_o	(b_vid_v_val_32d		),
	.aresetn		(aresetn				)
);

delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(16						)	//1~
	)
	dly_b_vid_d_val_d13						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_d_val			),
	.delay_array_o	(b_vid_d_val_d16		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(3						)	//1~
	)
	dly_b_vid_d_val_d3						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_d_val			),
	.delay_array_o	(b_vid_d_val_d3			),
	.aresetn		(aresetn				)
);

generate
for(i=0; i < 5; i=i+1) begin: gen_mod5_pixel
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mod5_pixel				[i]		<= 0;
	end
//	else if( (b_cnt_vf_pixel%5)==i && b_vid_d_val==1)begin
	else if( (cnt_pixel%5)==i && b_vid_d_val==1)begin
		mod5_pixel				[i]		<= 1;
	end
	else begin
		mod5_pixel				[i]		<= 0;
	end
end
end
endgenerate

generate
for(i=0; i < 5; i=i+1) begin: gen_coe_filter
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		coe_filter_line				[i]		<= 0;
	end
	else if( mod5_pixel[0]==1)begin
		coe_filter_line				[i]		<= coe_filter[i][0];
	end
	else if( mod5_pixel[1]==1)begin
		coe_filter_line				[i]		<= coe_filter[i][1];
	end
	else if( mod5_pixel[2]==1)begin
		coe_filter_line				[i]		<= coe_filter[i][2];
	end
	else if( mod5_pixel[3]==1)begin
		coe_filter_line				[i]		<= coe_filter[i][3];
	end
	else if( mod5_pixel[4]==1)begin
		coe_filter_line				[i]		<= coe_filter[i][4];
	end
	else begin
		coe_filter_line				[i]		<= 0;
	end
end
end
endgenerate


//generate
//for(i=0; i < 5; i=i+1) begin: gen_coe_filter_conv
//	assign coe_filter_line_conv[0][i] = coe_filter_line[i];
//end
//endgenerate
//
//generate
//for(j=1; j < 5; j=j+1) begin: gen_coe_filter_conv_1d_j
//	for(i=0; i < 5; i=i+1) begin: gen_i
//	delay_data	#(
//		.BIT_WIDTH		(16								),	//1~
//		.NUM_DELAY		(j								)	//1~
//		)
//		vf_d3_val_delay_data							(
//		.vclk			(vclk							),
//		.delay_array_i	(coe_filter_line			[i]	),
//		.delay_array_o	(coe_filter_line_conv	[j]	[i]	),
//		.aresetn		(aresetn						)
//	);
//	end
//end
//endgenerate

generate
for(j=0; j < 5; j=j+1) begin: gen_coe_filter_conv_1d_j
	for(i=0; i < 5; i=i+1) begin: gen_i
	delay_data	#(
		.BIT_WIDTH		(16								),	//1~
		.NUM_DELAY		(i+1							)	//1~
		)
		vf_d3_val_delay_data							(
		.aclk			(vclk							),
		.delay_array_i	(coe_filter_line		[j]		),
		.delay_array_o	(coe_filter_line_conv	[j]	[i]	),
		.aresetn		(aresetn						)
	);
	end
end
endgenerate




generate
for(j=0; j < 5; j=j+1) begin: gen_mult_filter_j
	for(i=0; i < 5; i=i+1) begin: gen_i
	mult_filter mult_filter (
		.CLK	(vclk								), // input		wire CLK
		.A		(arrange_pre_ft_data_conv	[j]	[i]	), // input		wire [15 : 0] A
		.B		(coe_filter_inv				[j]	[i]	), // input		wire [15 : 0] B
		.P		(mult_ft_data				[j]	[i]	)  // output	wire [31 : 0] P
	);
	end
end
endgenerate

generate
for(j=0; j < 5; j=j+1) begin: gen_mult_ft_data_1d_j
	for(i=0; i < 5; i=i+1) begin: gen_i
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			mult_ft_data_1d			[j]	[i]	<= 0;
		end
		else begin
			mult_ft_data_1d			[j]	[i]	<= mult_ft_data	[j]	[i];
		end
	end
	end
end
endgenerate

generate
for(j=0; j < 5; j=j+1) begin: gen_mult_ft_data_shift_j
	for(i=0; i < 5; i=i+1) begin: gen_i
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			mult_ft_data_shift		[j]	[i]	<= 0;
		end
		else begin
			mult_ft_data_shift		[j]	[i]	<= mult_ft_data_1d	[j]	[i] >> 0;
		end
	end
	end
end
endgenerate

//generate
//for(j=0; j < 5; j=j+1) begin: gen_mult_ft_data_sum_pixel
//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		mult_ft_data_sum_pixel		[j]		<= 0;
//	end
//	else begin
//		mult_ft_data_sum_pixel		[j]			
//		<= mult_ft_data_shift[j][0] + mult_ft_data_shift[j][1] + mult_ft_data_shift[j][2] + mult_ft_data_shift[j][3] + mult_ft_data_shift[j][4];
//	end
//end
//end
//endgenerate

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mult_ft_data_sum_pixel		[0]		<= 0;
		mult_ft_data_sum_pixel		[1]		<= 0;
		mult_ft_data_sum_pixel		[2]		<= 0;
		mult_ft_data_sum_pixel		[3]		<= 0;
		mult_ft_data_sum_pixel		[4]		<= 0;
	end
	else if(b_sel_filter==0)begin	//gaussian
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] + mult_ft_data_shift[0][1] + mult_ft_data_shift[0][2] + mult_ft_data_shift[0][3] + mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] + mult_ft_data_shift[1][1] + mult_ft_data_shift[1][2] + mult_ft_data_shift[1][3] + mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] + mult_ft_data_shift[2][1] + mult_ft_data_shift[2][2] + mult_ft_data_shift[2][3] + mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<=  mult_ft_data_shift[3][0] + mult_ft_data_shift[3][1] + mult_ft_data_shift[3][2] + mult_ft_data_shift[3][3] + mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<=  mult_ft_data_shift[4][0] + mult_ft_data_shift[4][1] + mult_ft_data_shift[4][2] + mult_ft_data_shift[4][3] + mult_ft_data_shift[4][4];
	end
	else if(b_sel_filter==1)begin	//laplacian
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] + mult_ft_data_shift[0][1] + mult_ft_data_shift[0][2] + mult_ft_data_shift[0][3] + mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] + mult_ft_data_shift[1][1] + mult_ft_data_shift[1][2] + mult_ft_data_shift[1][3] + mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] + mult_ft_data_shift[2][1] - mult_ft_data_shift[2][2] + mult_ft_data_shift[2][3] + mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<=  mult_ft_data_shift[3][0] + mult_ft_data_shift[3][1] + mult_ft_data_shift[3][2] + mult_ft_data_shift[3][3] + mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<=  mult_ft_data_shift[4][0] + mult_ft_data_shift[4][1] + mult_ft_data_shift[4][2] + mult_ft_data_shift[4][3] + mult_ft_data_shift[4][4];
	end
	else if(b_sel_filter==2)begin	//sobel y? x?
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] + mult_ft_data_shift[0][1] + mult_ft_data_shift[0][2] - mult_ft_data_shift[0][3] - mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] + mult_ft_data_shift[1][1] + mult_ft_data_shift[1][2] - mult_ft_data_shift[1][3] - mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] + mult_ft_data_shift[2][1] + mult_ft_data_shift[2][2] - mult_ft_data_shift[2][3] - mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<=  mult_ft_data_shift[3][0] + mult_ft_data_shift[3][1] + mult_ft_data_shift[3][2] - mult_ft_data_shift[3][3] - mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<=  mult_ft_data_shift[4][0] + mult_ft_data_shift[4][1] + mult_ft_data_shift[4][2] - mult_ft_data_shift[4][3] - mult_ft_data_shift[4][4];
	end
	else if(b_sel_filter==3)begin	//sobel y? x?
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] + mult_ft_data_shift[0][1] + mult_ft_data_shift[0][2] + mult_ft_data_shift[0][3] + mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] + mult_ft_data_shift[1][1] + mult_ft_data_shift[1][2] + mult_ft_data_shift[1][3] + mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] + mult_ft_data_shift[2][1] + mult_ft_data_shift[2][2] + mult_ft_data_shift[2][3] + mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<= -mult_ft_data_shift[3][0] - mult_ft_data_shift[3][1] - mult_ft_data_shift[3][2] - mult_ft_data_shift[3][3] - mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<= -mult_ft_data_shift[4][0] - mult_ft_data_shift[4][1] - mult_ft_data_shift[4][2] - mult_ft_data_shift[4][3] - mult_ft_data_shift[4][4];
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mult_ft_data_sum_line		[31:0]	<= 0;
	end
	else begin
		mult_ft_data_sum_line					
		<= mult_ft_data_sum_pixel[0] + mult_ft_data_sum_pixel[1] + mult_ft_data_sum_pixel[2] + mult_ft_data_sum_pixel[3] + mult_ft_data_sum_pixel[4];
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mult_ft_data_div			[31:0]	<= 0;
	end
	else if(b_sel_filter==0)begin
		mult_ft_data_div					<= mult_ft_data_sum_line >> coe_filter_cnt;
	end
	else begin
		mult_ft_data_div			[31:0]	<= mult_ft_data_sum_line;
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mult_ft_data_limit			[15:0]	<= 0;
		status_filter				[7:0]	<= 0;
	end
//	gaussian
	else if(b_sel_filter==0 && mult_ft_data_div >=32'hFFFFC000)begin
		mult_ft_data_limit					<= 0;
		status_filter				[7:0]	<= 1;
	end
	else if(b_sel_filter==0 && mult_ft_data_div >=32'h000003FF)begin
		mult_ft_data_limit					<= 32'h03ff;
		status_filter				[7:0]	<= 2;
	end
	else if(b_sel_filter==0 )begin
		mult_ft_data_limit					<= mult_ft_data_div[15:0];
		status_filter				[7:0]	<= 2;
	end
//	laplacian
	else if(b_sel_filter==1 && mult_ft_data_div >=32'hFFFFC000)begin
		mult_ft_data_limit					<= 0;
		status_filter				[7:0]	<= 3;
	end
	else if(b_sel_filter==1 && mult_ft_data_div >=32'h000003FF)begin
		mult_ft_data_limit					<= 32'h03ff;
		status_filter				[7:0]	<= 4;
	end
	else if(b_sel_filter==1 )begin
		mult_ft_data_limit					<= mult_ft_data_div[15:0];
		status_filter				[7:0]	<= 5;
	end
//	sobel
	else if(mult_ft_data_div >=32'hFFFFC000)begin
		mult_ft_data_limit					<= 32'hffffffff - mult_ft_data_div[31:0] +1;
		status_filter				[7:0]	<= 6;
	end
	else if(mult_ft_data_div >=32'h000003FF)begin
		mult_ft_data_limit					<= 32'h03ff;
		status_filter				[7:0]	<= 7;
	end
	else begin
		mult_ft_data_limit					<= mult_ft_data_div[15:0];
		status_filter				[7:0]	<= 8;
	end
end














endmodule

