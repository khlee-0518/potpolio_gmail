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
	,input	[399:0]	i_coe_filter_x3	
	,input	[3:0]	i_size_filter
	,input	[1:0]	i_sel_vid_bit
	,output			o_vf_dval	
	,output			o_vf_vval	
	,output			o_vf_hval	
	,output	[15:0]	o_vf_data	
	,output	[15:0]	o_coe_filter_sum	
	,output	[15:0]	o_coe_filter_power	
	,output	[ 7:0]	o_coe_filter_cnt	

	,input			aresetn		
    );
	
	genvar i;
	genvar j;
	
	wire	[3:0]	s_sel_filter						;(* MARK_DEBUG="true" *)
	wire			s_vid_d_val							;(* MARK_DEBUG="true" *)
	wire			s_vid_v_val							;(* MARK_DEBUG="true" *)
	wire			s_vid_h_val							;(* MARK_DEBUG="true" *)
	wire	[15:0]	s_vid_data							;
	wire	[15:0]	s_cnt_vf_pixel						;
	wire	[15:0]	s_cnt_vf_line						;
	wire	[15:0]	s_cnt_vf_frame						;
	reg		[3:0]	b_sel_filter						;(* MARK_DEBUG="true" *)
	reg				b_vid_d_val							;(* MARK_DEBUG="true" *)
	wire			b_vid_d_val_pls_neg					;(* MARK_DEBUG="true" *)
	reg				b_vid_v_val							;(* MARK_DEBUG="true" *)
	reg				b_vid_h_val							;(* MARK_DEBUG="true" *)
	reg		[15:0]	b_vid_data							;(* MARK_DEBUG="true" *)
	wire	[15:0]	b_vid_data_7d						;
	reg		[15:0]	b_cnt_vf_pixel						;
	wire	[15:0]	s_cnt_vf_pixel_d15					;
	wire	[15:0]	cnt_pixel_2d						;(* MARK_DEBUG="true" *)
	wire	[15:0]	cnt_pixel_7d						;
	reg		[15:0]	b_cnt_vf_line						;
	reg		[15:0]	b_cnt_vf_frame						;(* MARK_DEBUG="true" *)
	reg		[ 5:0]	vf_wea								;(* MARK_DEBUG="true" *)
	reg		[ 5:0]	vf_ena								;(* MARK_DEBUG="true" *)
	reg		[ 5:0]	mod6_wt_line						;
	reg		[ 5:0]	mod6_line_wt_wide					;
	wire	[ 5:0]	mod6_line_wt_wide_32d				;(* MARK_DEBUG="true" *)
	reg		[ 5:0]	mod6_line_rd						;(* MARK_DEBUG="true" *)
	wire	[ 5:0]	mod6_line_rd_4d						;(* MARK_DEBUG="true" *)
	wire	[ 5:0]	mod6_line_rd_or						;
	reg		[ 4:0]	mod5_pixel							;
	wire	[15:0]	s_bram_pre_ft_data		[0:5]		;//(* MARK_DEBUG="true" *)
	reg		[15:0]	arrange_pre_ft_data		[0:4]		;
	wire	[15:0]	arrange_pre_ft_data_conv[0:4][0:4]	;
	wire	[15:0]	s_arrange_filter_data				;
	wire	[11:0]	cnt_filter_data						;(* MARK_DEBUG="true" *)
	reg		[ 7:0]	coe_filter_cnt						;
	reg				coe_filter_change					;
	reg		[15:0]	coe_filter_sum						;
	reg		[15:0]	coe_filter_sum_1d					;
	reg		[15:0]	coe_filter_power					;
	reg		[15:0]	coe_filter				[0:4][0:4]	;
	reg		[15:0]	coe_filter_inv			[0:4][0:4]	;
	reg		[15:0]	coe_filter_line			[0:4]		;
	wire	[15:0]	coe_filter_line_conv	[0:4][0:4]	;
//	wire			b_vid_d_val_d3						;
	wire	[31:0]	mult_ft_data			[0:4][0:4]	;
	reg		[31:0]	mult_ft_data_1d			[0:4][0:4]	;
	reg		[31:0]	mult_ft_data_shift		[0:4][0:4]	;
	reg		[31:0]	mult_ft_data_sum_pixel	[0:4]		;//(* MARK_DEBUG="true" *)
	reg		[31:0]	mult_ft_data_sum_line				;
	reg		[31:0]	mult_ft_data_div					;//(* MARK_DEBUG="true" *)
	reg		[15:0]	mult_ft_data_limit					;//(* MARK_DEBUG="true" *)
	wire			b_vid_d_val_d16						;//(* MARK_DEBUG="true" *)
	wire			b_vid_v_val_32d						;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_pixel							;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_line_or							;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_line							;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_line_dly3_p						;(* MARK_DEBUG="true" *)
	wire	[15:0]	cnt_line_dly3_p_4d					;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_line_exp						;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_line_dly3_n						;
	reg		[15:0]	cnt_line_pos						;
	reg		[15:0]	cnt_frame							;(* MARK_DEBUG="true" *)
	reg		[7:0]	status_filter						;
	reg		[3:0]	size_filter							;(* MARK_DEBUG="true" *)
	reg		[1:0]	sel_vid_bit							;
	wire	[3:0]	s_size_filter						;
	wire	[1:0]	s_sel_vid_bit						;
	reg		[31:0]	limit_neg							;
	reg		[31:0]	limit_sat							;
	wire	[15:0]	cnt_line_3d							;(* MARK_DEBUG="true" *)
	wire	[15:0]	cnt_line_4d							;
														 (* MARK_DEBUG="true" *)
	reg				rd_en_dval_dly						;(* MARK_DEBUG="true" *)
	reg				rd_en_dval_dly4						;(* MARK_DEBUG="true" *)
	reg				rd_en_dval_dly_wr					;(* MARK_DEBUG="true" *)
	wire	[15:0]	cnt_pixel_20d						;(* MARK_DEBUG="true" *)
	reg				exp_fval_3line						;(* MARK_DEBUG="true" *)
	reg		[3:0]	status_fval							;(* MARK_DEBUG="true" *)
	wire			dval_dly3_21d						;(* MARK_DEBUG="true" *)
	wire			exp_fval_3line_32d					;(* MARK_DEBUG="true" *)
	wire			b_vid_h_val_d25						;(* MARK_DEBUG="true" *)
	wire	[15:0]	mult_ft_data_limit_4d				;(* MARK_DEBUG="true" *)
	wire			srst								;(* MARK_DEBUG="true" *)
	wire			b_vid_d_val_2d						;(* MARK_DEBUG="true" *)
	wire			dval_dly3							;(* MARK_DEBUG="true" *)
	wire			dval_dly4							;(* MARK_DEBUG="true" *)
	reg				wr_en_dval							;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_pixel_rd						;(* MARK_DEBUG="true" *)
	wire	[15:0]	cnt_pixel_rd_3d						;

	reg		[15:0]	cnt_exp_fval						;
	reg		[15:0]	cnt_3line_period					;
	reg		[15:0]	lock_period_3line					;
	reg				period_3line						;
	reg				intv_f_d_val						;
	reg		[15:0]	cnt_line_blank						;
	reg		[15:0]	cnt_f_d_val							;
	reg		[15:0]	lock_cnt_f_d_val					;(* MARK_DEBUG="true" *)
	wire			dval_or_pls_neg						;(* MARK_DEBUG="true" *)
	wire			s_vid_v_val_pls						;(* MARK_DEBUG="true" *)
	wire			dval_or								;(* MARK_DEBUG="true" *)
	wire			b_vid_d_val_4d						;(* MARK_DEBUG="true" *)
	wire			b_vid_d_val_5d						;(* MARK_DEBUG="true" *)
	wire			dval_or_1d							;(* MARK_DEBUG="true" *)
	wire			dval_dly3_pls_neg_4d				;(* MARK_DEBUG="true" *)
	wire			dval_dly3_pls						;(* MARK_DEBUG="true" *)
	wire			dval_dly3_pls_neg					;(* MARK_DEBUG="true" *)
	wire			dval_dly4_pls						;(* MARK_DEBUG="true" *)
	wire			dval_dly4_pls_neg					;(* MARK_DEBUG="true" *)
	wire			full_dval_dly3						;(* MARK_DEBUG="true" *)
	wire			empty_dval_dly3						;(* MARK_DEBUG="true" *)
	wire			full_dval_dly4						;(* MARK_DEBUG="true" *)
	wire			empty_dval_dly4						;(* MARK_DEBUG="true" *)
	reg				togg_dval_dly3						;(* MARK_DEBUG="true" *)
	wire			togg_dval_dly3_pls					;(* MARK_DEBUG="true" *)
	wire			togg_dval_dly3_pls_n				;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_last_line_even					;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_last_line_odd					;(* MARK_DEBUG="true" *)
	reg		[15:0]	cnt_last_3line						;


/////////////////////////////////////////////////////////
	assign s_sel_filter		= i_sel_filter				;
	assign s_vid_d_val		= i_vid_d_val				;
	assign s_vid_v_val		= i_vid_v_val				;
	assign s_vid_h_val		= i_vid_h_val				;
	assign s_vid_data		= i_vid_data				;
	assign s_cnt_vf_pixel	= i_cnt_pixel				;
	assign s_cnt_vf_line	= i_cnt_line				;
	assign s_cnt_vf_frame	= i_cnt_frame				;
	assign s_size_filter	= i_size_filter				;
	assign s_sel_vid_bit	= i_sel_vid_bit				;
	
//	assign o_vf_dval	= b_vid_d_val_d16;
	assign o_vf_dval	= dval_dly3_21d;
//	assign o_vf_vval	= b_vid_v_val_32d;
//	assign o_vf_vval	= fval_dly3_15d | fval_dly3_16d;
//	assign o_vf_vval	= exp_fval_3line | exp_fval_3line_32d;
	assign o_vf_vval	= exp_fval_3line_32d;
//	assign o_vf_hval	= b_vid_d_val_d16;
//	assign o_vf_hval	= b_vid_h_val_d25;
	assign o_vf_hval	= dval_dly3_21d;

//	assign o_vf_data	= {6'h0, mult_ft_data_limit[ 9:0]};
//	assign o_vf_data	= mult_ft_data_limit[15:0];
	assign o_vf_data	= mult_ft_data_limit_4d[15:0];
	
	assign o_coe_filter_sum		[15:0] = coe_filter_sum;
	assign o_coe_filter_power	[15:0] = coe_filter_power;
	assign o_coe_filter_cnt		[ 7:0] = coe_filter_cnt;
	
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		b_vid_d_val					<= 0;
		b_vid_v_val					<= 0;
		b_vid_h_val					<= 0;
		b_cnt_vf_pixel		[15:0]	<= 0;
		b_cnt_vf_line		[15:0]	<= 0;
		b_cnt_vf_frame		[15:0]	<= 0;
//		mod6_line_rd_1d		[ 5:0]	<= 0;
//		mod6_line_rd_2d		[ 5:0]	<= 0;
		b_sel_filter		[3:0]	<= 0;
		size_filter			[3:0]	<= 5;
		sel_vid_bit			[1:0]	<= 0;
	end
	else begin
		b_vid_d_val					<= s_vid_d_val		;
		b_vid_v_val					<= s_vid_v_val		;
		b_vid_h_val					<= s_vid_h_val		;
		b_cnt_vf_pixel				<= s_cnt_vf_pixel	;
		b_cnt_vf_line				<= s_cnt_vf_line	;
		b_cnt_vf_frame				<= s_cnt_vf_frame	;
//		mod6_line_rd_1d				<= mod6_line_rd;
//		mod6_line_rd_2d				<= mod6_line_rd_1d;
		b_sel_filter				<= s_sel_filter;
		size_filter					<= s_size_filter;
		sel_vid_bit					<= s_sel_vid_bit;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		b_vid_data			[15:0]	<= 0;
		limit_neg			[31:0]	<= 32'hFFFFC000;
		limit_sat			[31:0]	<= 32'h000003FF;
	end
	else if(sel_vid_bit[1:0]==0)begin
		b_vid_data					<= {6'h0, s_vid_data[9:0]}	;
		limit_neg					<= 32'hFFFFC000;
		limit_sat					<= 32'h000003FF;
	end
	else if(sel_vid_bit[1:0]==1)begin
		b_vid_data					<= {4'h0, s_vid_data[11:0]}	;
		limit_neg					<= 32'hFFFFC000;
		limit_sat					<= 32'h00000FFF;
	end
	else if(sel_vid_bit[1:0]==2)begin
		b_vid_data					<= {2'h0, s_vid_data[13:0]}	;
		limit_neg					<= 32'hFFFFC000;
		limit_sat					<= 32'h00003FFF;
	end
	else if(sel_vid_bit[1:0]==3)begin
		b_vid_data					<= {      s_vid_data[15:0]}	;
		limit_neg					<= 32'hFFFF0000;
		limit_sat					<= 32'h0000FFFF;
	end
	else begin
		b_vid_data					<= {6'h0, s_vid_data[9:0]}	;
		limit_neg					<= 32'hFFFFC000;
		limit_sat					<= 32'h000003FF;
	end
end





delay_data	#(
	.BIT_WIDTH		(6						),	//1~
	.NUM_DELAY		(4						)	//1~
	)
	dly_mod6_line_rd					(
	.aclk			(vclk					),
	.delay_array_i	(mod6_line_rd			),
	.delay_array_o	(mod6_line_rd_4d		),
	.aresetn		(aresetn				)
);

//count video
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_pixel			[15:0]	<= 0;
	end
	else if(b_vid_d_val==1)begin
//	else if(dval_or_1d==1)begin
		cnt_pixel					<= cnt_pixel +1;
	end
	else if(b_vid_d_val_pls_neg==1)begin
		cnt_pixel					<= 0;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_pixel_rd		[15:0]	<= 0;
	end
	else if(dval_or&&dval_or_1d==1)begin
		cnt_pixel_rd					<= cnt_pixel_rd +1;
	end
	else if(dval_or_pls_neg==1)begin
		cnt_pixel_rd					<= 0;
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_line							<= 0;
	end
	else if(s_vid_v_val_pls==1)begin
		cnt_line							<= 0;
	end
	else if(s_vid_d_val_pls_neg==1)begin
		cnt_line							<= cnt_line +1;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_line_pos						<= 0;
	end
	else if(s_vid_v_val_pls==1)begin
		cnt_line_pos						<= 0;
	end
	else if(s_vid_d_val_pls==1)begin
		cnt_line_pos						<= cnt_line_pos +1;
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_line_or							<= 0;
	end
	else if(s_vid_v_val_pls==1)begin
		cnt_line_or							<= 0;
	end
//	else if(s_vid_d_val_pls_neg==1)begin
	else if(dval_or_pls_neg==1)begin
		cnt_line_or							<= cnt_line_or +1;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_frame							<= 0;
	end
	else if(s_vid_v_val_pls)begin
		cnt_frame							<= cnt_frame +1;
	end
end
gen_pulse		gen_pulse_fval				(
	.aclk			(vclk					),
	.step_i			(s_vid_v_val			),
	.pulse_o		(s_vid_v_val_pls		),
	.aresetn		(aresetn				)
);
gen_pulse_neg	gen_pulse_neg_fval			(
	.aclk			(vclk					),
	.step_i			(s_vid_v_val			),
	.pulse_o		(s_vid_v_val_pls_neg	),
	.aresetn		(aresetn				)
);
gen_pulse		gen_pulse_dval				(
	.aclk			(vclk					),
	.step_i			(s_vid_d_val			),
	.pulse_o		(s_vid_d_val_pls		),
	.aresetn		(aresetn				)
);
gen_pulse_neg	gen_pulse_neg_dval			(
	.aclk			(vclk					),
	.step_i			(s_vid_d_val			),
	.pulse_o		(s_vid_d_val_pls_neg	),
	.aresetn		(aresetn				)
);


//delay_data	#(
//	.BIT_WIDTH		(16						),	//1~
//	.NUM_DELAY		(15						)	//1~
//	)
//	vf_pixel16_delay_data					(
//	.aclk			(vclk					),
////	.delay_array_i	(b_cnt_vf_pixel			),
//	.delay_array_i	(cnt_pixel				),
//	.delay_array_o	(s_cnt_vf_pixel_d15		),
//	.aresetn		(aresetn				)
//);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(2						)	//1~
	)
	vf_pixel2_delay_data					(
	.aclk			(vclk					),
//	.delay_array_i	(b_cnt_vf_pixel			),
	.delay_array_i	(cnt_pixel				),
	.delay_array_o	(cnt_pixel_2d			),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(7						)	//1~
	)
	vf_pixel7_delay_data					(
	.aclk			(vclk					),
//	.delay_array_i	(b_cnt_vf_pixel			),
	.delay_array_i	(cnt_pixel				),
	.delay_array_o	(cnt_pixel_7d			),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(3						)	//1~
	)
	vf_pixel3_rd_delay_data					(
	.aclk			(vclk					),
//	.delay_array_i	(b_cnt_vf_pixel			),
	.delay_array_i	(cnt_pixel_rd			),
	.delay_array_o	(cnt_pixel_rd_3d		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(7						)	//1~
	)
	vf_data_delay_data						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_data				),
	.delay_array_o	(b_vid_data_7d			),
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
//	else if( (cnt_line_or%6)==i && b_vid_d_val==1)begin
//	else if( (cnt_line_or%6)==i && dval_or_1d==1)begin
	else if( (cnt_line_3d%6)==i && b_vid_d_val_5d==1)begin
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
	else if( (cnt_line_or%6)==i )begin
		mod6_line_wt_wide		[i]		<= 1;
	end
	else begin
		mod6_line_wt_wide		[i]		<= 0;
	end
end
end
endgenerate

delay_data	#(
	.BIT_WIDTH		(6						),	//1~
	.NUM_DELAY		(32						)	//1~
	)
	delay_data_mod6_line_wt_wide			(
	.aclk			(vclk					),
	.delay_array_i	(mod6_line_wt_wide		),
	.delay_array_o	(mod6_line_wt_wide_32d	),
	.aresetn		(aresetn				)
);


generate
for(i=0; i < 6; i=i+1) begin: gen_bram_mod_rd
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mod6_line_rd			[i]		<= 0;
	end
//	else if( (cnt_line_or%6)!=i && b_vid_d_val==1)begin
	else if( (cnt_line_or%6)!=i && dval_or_1d==1)begin
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
//	else if( cnt_line_exp >= 3)begin
//		vf_ena					[i]		<= 0;
//	end
//	else if( cnt_last_3line >= 3)begin
//		vf_ena					[i]		<= 0;
//	end
	else if( empty_dval_dly4 == 1)begin
		vf_ena					[i]		<= 0;
	end
	else if( mod6_wt_line[0]==1 && cnt_line_4d==0)begin
		vf_ena					[i]		<= 1;
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
//	else if( cnt_line_exp >= 3)begin
//		vf_wea					[i]		<= 0;
//	end
//	else if( cnt_last_3line >= 3)begin
//		vf_wea					[i]		<= 0;
//	end
	else if( empty_dval_dly4 == 1)begin
		vf_wea					[i]		<= 0;
	end
	else if( mod6_wt_line[0]==1 && cnt_line_4d==0)begin
		vf_wea					[i]		<= 1;
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

assign mod6_line_rd_or = mod6_line_rd | mod6_line_rd_4d;


always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_line_blank					<= 0;
	end
	else if( |vf_wea[5:0]==1)begin
		cnt_line_blank					<= 0;
	end
	else begin
		cnt_line_blank					<= cnt_line_blank +1;
	end
end

generate
for(i=0; i < 6; i=i+1) begin: gen_mem_video_filter
blk_mem_video_filter vf0_blk_mem_video_filter
(
	.clka		(vclk						),// input	wire clka
	.ena		(vf_ena				[i]		),// input	wire ena
	.wea		(vf_wea				[i]		),// input	wire [0 : 0] wea
//	.addra		(cnt_pixel_2d		[11:0]	),// input	wire [11 : 0] addra
	.addra		(cnt_pixel_7d		[13:0]	),// input	wire [11 : 0] addra
	.dina		(b_vid_data_7d		[15:0]	),// input	wire [15 : 0] dina
	.douta		(							),// output	wire [15 : 0] douta
	.clkb		(vclk						),// input	wire clkb
	.enb		(mod6_line_rd_or	[i]		),// input	wire enb
	.web		(0							),// input	wire [0 : 0] web
//	.addrb		(cnt_pixel_rd_3d	[11:0]	),// input	wire [11 : 0] addrb
	.addrb		(cnt_pixel_rd_3d	[13:0]	),// input	wire [11 : 0] addrb
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
//	else if( b_vid_d_val_d3==0 )begin
//	else if( dval_or_2d==0 )begin
//	else if( dval_or_pls_neg==1 )begin
//		arrange_pre_ft_data			[0]		<= 0;
//		arrange_pre_ft_data			[1]		<= 0;
//		arrange_pre_ft_data			[2]		<= 0;
//		arrange_pre_ft_data			[3]		<= 0;
//		arrange_pre_ft_data			[4]		<= 0;
//	end
	else if( mod6_line_wt_wide_32d[0]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[5];
	end
	else if( mod6_line_wt_wide_32d[1]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[0];
	end
	else if( mod6_line_wt_wide_32d[2]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[3];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[1];
	end
	else if( mod6_line_wt_wide_32d[3]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[4];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[2];
	end
	else if( mod6_line_wt_wide_32d[4]==1 )begin
		arrange_pre_ft_data			[0]		<= s_bram_pre_ft_data[5];
		arrange_pre_ft_data			[1]		<= s_bram_pre_ft_data[0];
		arrange_pre_ft_data			[2]		<= s_bram_pre_ft_data[1];
		arrange_pre_ft_data			[3]		<= s_bram_pre_ft_data[2];
		arrange_pre_ft_data			[4]		<= s_bram_pre_ft_data[3];
	end
	else if( mod6_line_wt_wide_32d[5]==1 )begin
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
	else if(size_filter==3)begin
		coe_filter					[0][0]	<= 0;
		coe_filter					[0][1]	<= 0;
		coe_filter					[0][2]	<= 0;
		coe_filter					[0][3]	<= 0;
		coe_filter					[0][4]	<= 0;
		coe_filter					[1][0]	<= 0;
		coe_filter					[1][1]	<= i_coe_filter_x3[ 6*16+15 : 6*16 ];	//i_coe_filter_1_1;	
		coe_filter					[1][2]	<= i_coe_filter_x3[ 7*16+15 : 7*16 ];	//i_coe_filter_1_2;	
		coe_filter					[1][3]	<= i_coe_filter_x3[ 8*16+15 : 8*16 ];	//i_coe_filter_1_3;	
		coe_filter					[1][4]	<= 0;
		coe_filter					[2][0]	<= 0;
		coe_filter					[2][1]	<= i_coe_filter_x3[11*16+15 :11*16 ];	//i_coe_filter_2_1;	
		coe_filter					[2][2]	<= i_coe_filter_x3[12*16+15 :12*16 ];	//i_coe_filter_2_2;	
		coe_filter					[2][3]	<= i_coe_filter_x3[13*16+15 :13*16 ];	//i_coe_filter_2_3;	
		coe_filter					[2][4]	<= 0;
		coe_filter					[3][0]	<= 0;
		coe_filter					[3][1]	<= i_coe_filter_x3[16*16+15 :16*16 ];	//i_coe_filter_3_1;	
		coe_filter					[3][2]	<= i_coe_filter_x3[17*16+15 :17*16 ];	//i_coe_filter_3_2;	
		coe_filter					[3][3]	<= i_coe_filter_x3[18*16+15 :18*16 ];	//i_coe_filter_3_3;	
		coe_filter					[3][4]	<= 0;
		coe_filter					[4][0]	<= 0;
		coe_filter					[4][1]	<= 0;
		coe_filter					[4][2]	<= 0;
		coe_filter					[4][3]	<= 0;
		coe_filter					[4][4]	<= 0;
	end
	else if(size_filter==5)begin
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
	else if(size_filter==3) begin
		coe_filter_sum				[15:0]	<= 
						   coe_filter[1][1] + coe_filter[1][2] + coe_filter[1][3] +
						   coe_filter[2][1] + coe_filter[2][2] + coe_filter[2][3] +
						   coe_filter[3][1] + coe_filter[3][2] + coe_filter[3][3] ;
	end
	else if(size_filter==5) begin
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
	.NUM_DELAY		(4						)	//1~
	)
	dly_b_vid_d_val_d4						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_d_val			),
	.delay_array_o	(b_vid_d_val_4d			),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(5						)	//1~
	)
	dly_b_vid_d_val_d5						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_d_val			),
	.delay_array_o	(b_vid_d_val_5d			),
	.aresetn		(aresetn				)
);

delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(2						)	//1~
	)
	dly_b_vid_d_val_d3						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_d_val			),
	.delay_array_o	(b_vid_d_val_2d			),
	.aresetn		(aresetn				)
);
//delay_data	#(
//	.BIT_WIDTH		(1						),	//1~
//	.NUM_DELAY		(1						)	//1~
//	)
//	dly_b_vid_d_val_d1						(
//	.aclk			(vclk					),
//	.delay_array_i	(b_vid_d_val			),
//	.delay_array_o	(b_vid_d_val_d1			),
//	.aresetn		(aresetn				)
//);

generate
for(i=0; i < 5; i=i+1) begin: gen_mod5_pixel
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		mod5_pixel				[i]		<= 0;
	end
//	else if( (b_cnt_vf_pixel%5)==i && b_vid_d_val==1)begin
//	else if( (cnt_pixel%5)==i && b_vid_d_val==1)begin
	else if( (cnt_pixel%5)==i && dval_or_1d==1)begin
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
	else if(b_sel_filter==1)begin	//laplacian Off center
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] + mult_ft_data_shift[0][1] + mult_ft_data_shift[0][2] + mult_ft_data_shift[0][3] + mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] + mult_ft_data_shift[1][1] + mult_ft_data_shift[1][2] + mult_ft_data_shift[1][3] + mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] + mult_ft_data_shift[2][1] - mult_ft_data_shift[2][2] + mult_ft_data_shift[2][3] + mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<=  mult_ft_data_shift[3][0] + mult_ft_data_shift[3][1] + mult_ft_data_shift[3][2] + mult_ft_data_shift[3][3] + mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<=  mult_ft_data_shift[4][0] + mult_ft_data_shift[4][1] + mult_ft_data_shift[4][2] + mult_ft_data_shift[4][3] + mult_ft_data_shift[4][4];

//		mult_ft_data_sum_pixel		[0]		<=  -mult_ft_data_shift[0][0] - mult_ft_data_shift[0][1] - mult_ft_data_shift[0][2] - mult_ft_data_shift[0][3] - mult_ft_data_shift[0][4];
//		mult_ft_data_sum_pixel		[1]		<=  -mult_ft_data_shift[1][0] - mult_ft_data_shift[1][1] - mult_ft_data_shift[1][2] - mult_ft_data_shift[1][3] - mult_ft_data_shift[1][4];
//		mult_ft_data_sum_pixel		[2]		<=  -mult_ft_data_shift[2][0] - mult_ft_data_shift[2][1] + mult_ft_data_shift[2][2] - mult_ft_data_shift[2][3] - mult_ft_data_shift[2][4];
//		mult_ft_data_sum_pixel		[3]		<=  -mult_ft_data_shift[3][0] - mult_ft_data_shift[3][1] - mult_ft_data_shift[3][2] - mult_ft_data_shift[3][3] - mult_ft_data_shift[3][4];
//		mult_ft_data_sum_pixel		[4]		<=  -mult_ft_data_shift[4][0] - mult_ft_data_shift[4][1] - mult_ft_data_shift[4][2] - mult_ft_data_shift[4][3] - mult_ft_data_shift[4][4];
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
	else if(b_sel_filter==4)begin	//laplacian On Center
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] + mult_ft_data_shift[0][1] + mult_ft_data_shift[0][2] + mult_ft_data_shift[0][3] + mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] + mult_ft_data_shift[1][1] + mult_ft_data_shift[1][2] + mult_ft_data_shift[1][3] + mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] + mult_ft_data_shift[2][1] - mult_ft_data_shift[2][2] + mult_ft_data_shift[2][3] + mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<=  mult_ft_data_shift[3][0] + mult_ft_data_shift[3][1] + mult_ft_data_shift[3][2] + mult_ft_data_shift[3][3] + mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<=  mult_ft_data_shift[4][0] + mult_ft_data_shift[4][1] + mult_ft_data_shift[4][2] + mult_ft_data_shift[4][3] + mult_ft_data_shift[4][4];
	end
	else begin
		mult_ft_data_sum_pixel		[0]		<=  mult_ft_data_shift[0][0] - mult_ft_data_shift[0][1] - mult_ft_data_shift[0][2] - mult_ft_data_shift[0][3] - mult_ft_data_shift[0][4];
		mult_ft_data_sum_pixel		[1]		<=  mult_ft_data_shift[1][0] - mult_ft_data_shift[1][1] - mult_ft_data_shift[1][2] - mult_ft_data_shift[1][3] - mult_ft_data_shift[1][4];
		mult_ft_data_sum_pixel		[2]		<=  mult_ft_data_shift[2][0] - mult_ft_data_shift[2][1] + mult_ft_data_shift[2][2] - mult_ft_data_shift[2][3] - mult_ft_data_shift[2][4];
		mult_ft_data_sum_pixel		[3]		<=  mult_ft_data_shift[3][0] - mult_ft_data_shift[3][1] - mult_ft_data_shift[3][2] - mult_ft_data_shift[3][3] - mult_ft_data_shift[3][4];
		mult_ft_data_sum_pixel		[4]		<=  mult_ft_data_shift[4][0] - mult_ft_data_shift[4][1] - mult_ft_data_shift[4][2] - mult_ft_data_shift[4][3] - mult_ft_data_shift[4][4];
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
	else if(b_sel_filter==0 && mult_ft_data_div >= limit_neg[31:0])begin
		mult_ft_data_limit					<= 0;
		status_filter				[7:0]	<= 1;
	end
	else if(b_sel_filter==0 && mult_ft_data_div >= limit_sat[31:0])begin
		mult_ft_data_limit					<= limit_sat[31:0];
		status_filter				[7:0]	<= 2;
	end
	else if(b_sel_filter==0 )begin
		mult_ft_data_limit					<= mult_ft_data_div[15:0];
		status_filter				[7:0]	<= 2;
	end
//	laplacian
	else if( (b_sel_filter==1 || b_sel_filter==4) && mult_ft_data_div >= limit_neg[31:0])begin
		mult_ft_data_limit					<= 0;
		status_filter				[7:0]	<= 3;
	end
	else if( (b_sel_filter==1 || b_sel_filter==4) && mult_ft_data_div >= limit_sat[31:0])begin
		mult_ft_data_limit					<= limit_sat[31:0];
		status_filter				[7:0]	<= 4;
	end
	else if( (b_sel_filter==1 || b_sel_filter==4) )begin
		mult_ft_data_limit					<= mult_ft_data_div[15:0];
		status_filter				[7:0]	<= 5;
	end
//	sobel
	else if( (b_sel_filter==2 || b_sel_filter==3) && mult_ft_data_div >= limit_neg[31:0])begin
		mult_ft_data_limit					<= 32'hffffffff - mult_ft_data_div[31:0] +1;
		status_filter				[7:0]	<= 6;
	end
	else if( (b_sel_filter==2 || b_sel_filter==3) && mult_ft_data_div >= limit_sat[31:0])begin
		mult_ft_data_limit					<= limit_sat[31:0];
		status_filter				[7:0]	<= 7;
	end
	else begin
		mult_ft_data_limit					<= mult_ft_data_div[15:0];
		status_filter				[7:0]	<= 8;
	end
end


delay_data	#(
	.BIT_WIDTH		(16							),	//1~
	.NUM_DELAY		(4							)	//1~
	)
	delay_data_mult_ft_data_limit				(
	.aclk			(vclk						),
	.delay_array_i	(mult_ft_data_limit[15:0]	),
	.delay_array_o	(mult_ft_data_limit_4d[15:0]),
	.aresetn		(aresetn					)
);

//////////////////////////////
// video filter delay process
//////////////////////////////

//fifo_fval_dly3 fifo_fval_dly3 (
//  .clk	(vclk),      // input wire clk
//  .srst	(s_vid_v_val_pls),                // input wire srst
//  .din	(b_vid_v_val),      // input wire [0 : 0] din
//  .wr_en(b_vid_v_val | b_vid_v_val_1d),  // input wire wr_en
//  .rd_en(rd_en_fval_dly),  // input wire rd_en
//  .dout	(fval_dly3),    // output wire [0 : 0] dout
//  .full	(fval_dly3_full),    // output wire full
//  .empty(empty_fval_dly),  // output wire empty
//  .wr_rst_busy(),  // output wire wr_rst_busy
//  .rd_rst_busy()  // output wire rd_rst_busy
//);

// Fval delay

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		period_3line				<= 0;
	end
	else if(s_vid_v_val_pls==1)begin
		period_3line				<= 0;
	end
	else if(s_vid_d_val_pls==1 && cnt_line <3 )begin
		period_3line				<= 1;
	end
	else if(s_vid_d_val_pls==1 && cnt_line>=3 )begin
		period_3line				<= 0;
	end
end
gen_pulse_neg	gen_pulse_neg_period_3line		(
	.aclk			(vclk					),
	.step_i			(period_3line			),
	.pulse_o		(period_3line_pls		),
	.aresetn		(aresetn				)
);
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_3line_period				<= 0;
	end
	else if(s_vid_v_val_pls==1)begin
		cnt_3line_period				<= 0;
	end
	else if(period_3line==1)begin
		cnt_3line_period				<= cnt_3line_period +1;
	end
end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		lock_period_3line			<= 0;
	end
	else if(period_3line_pls==1)begin
		lock_period_3line			<= cnt_3line_period;
	end
end
//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		exp_fval_3line				<= 0;
//		cnt_exp_fval				<= 0;
//		status_fval					<= 0;
//	end
//	else if(s_vid_d_val_pls_neg==1 && cnt_line==2)begin
//		exp_fval_3line				<= 1;
//		cnt_exp_fval				<= 0;
//		status_fval					<= 1;
//	end
//	else if(cnt_exp_fval>=cnt_3line_period)begin
////	else if(cnt_exp_fval>=lock_period_3line)begin
//		exp_fval_3line				<= 0;
//		status_fval					<= 2;
//	end
//	else if(s_vid_v_val==0)begin
//		exp_fval_3line				<= 1;
//		cnt_exp_fval				<= cnt_exp_fval +1;
//		status_fval					<= 3;
//	end
//end
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		exp_fval_3line				<= 0;
		status_fval					<= 0;
	end
	else if(s_vid_d_val_pls_neg==1 && cnt_line==2)begin
		exp_fval_3line				<= 1;
		status_fval					<= 1;
	end
	else if(rd_en_dval_dly_21d_neg==1)begin
		exp_fval_3line				<= 0;
		status_fval					<= 2;
	end
end
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(21						)	//1~
	)
	delay_data_rd_en_dval_dly				(
	.aclk			(vclk					),
	.delay_array_i	(rd_en_dval_dly			),
	.delay_array_o	(rd_en_dval_dly_21d		),
	.aresetn		(aresetn				)
);
gen_pulse_neg	gen_pulse_neg_rd_en_dval_dly_21d	(
	.aclk			(vclk					),
	.step_i			(rd_en_dval_dly_21d		),
	.pulse_o		(rd_en_dval_dly_21d_neg	),
	.aresetn		(aresetn				)
);

delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(32						)	//1~
	)
	delay_data_exp_fval_3line				(
	.aclk			(vclk					),
	.delay_array_i	(exp_fval_3line			),
	.delay_array_o	(exp_fval_3line_32d		),
	.aresetn		(aresetn				)
);

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		intv_f_d_val					<= 0;
	end
	else if(s_vid_v_val_pls==1)begin
		intv_f_d_val					<= 1;
	end
	else if(s_vid_d_val_pls==1 || s_vid_d_val_pls==1 || s_vid_d_val==1)begin
		intv_f_d_val					<= 0;
	end
end
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(3						)	//1~
	)
	delay_data_intv_f_d_val					(
	.aclk			(vclk					),
	.delay_array_i	(intv_f_d_val			),
	.delay_array_o	(intv_f_d_val_3d		),
	.aresetn		(aresetn				)
);

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		cnt_f_d_val						<= 0;
	end
	else if(intv_f_d_val_3d==1)begin
		cnt_f_d_val						<= cnt_f_d_val +1;
	end
	else begin
		cnt_f_d_val						<= 0;
	end
end
gen_pulse_neg	gen_pulse_neg_intv_f_d_val	(
	.aclk			(vclk					),
	.step_i			(intv_f_d_val			),
	.pulse_o		(intv_f_d_val_pls_neg	),
	.aresetn		(aresetn				)
);
always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		lock_cnt_f_d_val				<= 0;
	end
	else if(intv_f_d_val_pls_neg==1)begin
		lock_cnt_f_d_val				<= cnt_f_d_val;
	end
end

//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		cnt_fval_length				<= 0;
//	end
//	else if(s_vid_v_val_pls_neg==1)begin
//		cnt_fval_length				<= 0;
//	end
//	else if(b_vid_v_val==1)begin
//		cnt_fval_length				<= cnt_fval_length +1;
//	end
//end
//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		lock_fval_length				<= 0;
//	end
//	else if(s_vid_v_val_pls_neg==1)begin
//		lock_fval_length				<= cnt_fval_length;
//	end
//end

//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		cnt_fval_3line				<= 0;
//	end
//	else if(s_vid_v_val_pls_neg==1)begin
//		cnt_fval_3line				<= 0;
//	end
//	else if(b_vid_v_val==1)begin
//		cnt_fval_3line				<= cnt_fval_3line +1;
//	end
//end

//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		rd_en_fval_dly					<= 0;
//	end
////	else if(s_vid_d_val_pls_neg==1 && cnt_line_or==2)begin
//	else if(s_vid_d_val_pls_neg==1 && cnt_line>=2 || fval_dly3_full==1)begin
//		rd_en_fval_dly					<= 1;
//	end
////	else if(empty_fval_dly==1 || s_vid_v_val_pls==1)begin
//	else if(empty_fval_dly==1)begin
//		rd_en_fval_dly					<= 0;
//	end
//end

//always @(posedge vclk or negedge aresetn) begin
//	if (aresetn==1'b0) begin
//		rd_en_fval_dly					<= 0;
//	end
//	else if( (cnt_fval_3line[31:0]=={16'h0,lock_period_3line[15:0]}) && (cnt_fval_3line>0) && (lock_period_3line>0) )begin
//		rd_en_fval_dly					<= 1;
//	end
//	else if(empty_fval_dly==1)begin
//		rd_en_fval_dly					<= 0;
//	end
//end

//assign fval_dly3_or = fval_dly3 | rd_en_fval_dly;
//
//delay_data	#(
//	.BIT_WIDTH		(1						),	//1~
//	.NUM_DELAY		(17						)	//1~
//	)
//	fval_delay_data_15d						(
//	.aclk			(vclk					),
////	.delay_array_i	(fval_dly3				),
//	.delay_array_i	(fval_dly3_or			),
//	.delay_array_o	(fval_dly3_15d			),
//	.aresetn		(aresetn				)
//);
//delay_data	#(
//	.BIT_WIDTH		(1						),	//1~
//	.NUM_DELAY		(18						)	//1~
//	)
//	fval_delay_data_16d						(
//	.aclk			(vclk					),
////	.delay_array_i	(fval_dly3				),
//	.delay_array_i	(fval_dly3_or			),
//	.delay_array_o	(fval_dly3_16d			),
//	.aresetn		(aresetn				)
//);


// Dval delay

assign srst = s_vid_v_val_pls | ~aresetn;

fifo_dval_dly3 fifo_dval_dly3 (
  .clk			(vclk				),  // input wire clk
  .srst			(srst				),  // input wire srst
  .din			(b_vid_d_val_2d		),  // input wire [0 : 0] din
  .wr_en		(wr_en_dval			),  // input wire wr_en
  .rd_en		(rd_en_dval_dly		),  // input wire rd_en
  .dout			(dval_dly3			),  // output wire [0 : 0] dout
  .full			(full_dval_dly3		),  // output wire full
  .empty		(empty_dval_dly3	),  // output wire empty
  .prog_empty	(					),  // output wire empty
  .wr_rst_busy	(					),  // output wire wr_rst_busy
  .rd_rst_busy	(					)   // output wire rd_rst_busy
);

////////	debug code s	/////////
fifo_dval_dly3 fifo_dval_dly4 (
  .clk			(vclk				),  // input wire clk
  .srst			(srst				),  // input wire srst
  .din			(b_vid_d_val_2d		),  // input wire [0 : 0] din
  .wr_en		(wr_en_dval			),  // input wire wr_en
  .rd_en		(rd_en_dval_dly4	),  // input wire rd_en
  .dout			(dval_dly4			),  // output wire [0 : 0] dout
  .full			(full_dval_dly4		),  // output wire full
  .empty		(empty_dval_dly4	),  // output wire empty
  .prog_empty	(					),  // output wire empty
  .wr_rst_busy	(					),  // output wire wr_rst_busy
  .rd_rst_busy	(					)   // output wire rd_rst_busy
);
gen_pulse		gen_pulse_dval_dly4		(
	.aclk			(vclk					),
	.step_i			(dval_dly4				),
	.pulse_o		(dval_dly4_pls			),
	.aresetn		(aresetn				)
);
gen_pulse_neg	gen_pulse_neg_dval_dly4		(
	.aclk			(vclk					),
	.step_i			(dval_dly4				),
	.pulse_o		(dval_dly4_pls_neg		),
	.aresetn		(aresetn				)
);
////////	debug code e	/////////

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		wr_en_dval						<= 0;
	end
	else if(s_vid_v_val_pls_neg_4d==1)begin
		wr_en_dval						<= 0;
	end
	else if(b_vid_v_val==1 && s_vid_d_val_pls==1 )begin
		wr_en_dval						<= 1;
	end
end

delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(4						)	//1~
	)
	delay_data_s_vid_v_val_pls_neg			(
	.aclk			(vclk					),
	.delay_array_i	(s_vid_v_val_pls_neg	),
	.delay_array_o	(s_vid_v_val_pls_neg_4d	),
	.aresetn		(aresetn				)
);


always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		rd_en_dval_dly					<= 0;
	end
//	else if(s_vid_d_val_pls_neg==1 && cnt_line_or==2)begin
	else if(s_vid_d_val_pls==1 && cnt_line>=3 || full_dval_dly3==1)begin
		rd_en_dval_dly					<= 1;
	end
//	else if(empty_dval_dly3==1 || s_vid_v_val_pls==1)begin
	else if(empty_dval_dly3==1)begin
		rd_en_dval_dly					<= 0;
	end
end

always @(posedge vclk or negedge aresetn) begin
	if (aresetn==1'b0) begin
		rd_en_dval_dly4					<= 0;
	end
	else if(s_vid_d_val_pls==1 && cnt_line>=0 || full_dval_dly4==1)begin
		rd_en_dval_dly4					<= 1;
	end
	else if(empty_dval_dly4==1)begin
		rd_en_dval_dly4					<= 0;
	end
end

////////	debug code s	/////////
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			cnt_line_dly3_p			[15:0]	<= 0;
		end
		else if(s_vid_v_val_pls==1)begin
			cnt_line_dly3_p					<= 0;
		end
		else if(dval_dly3_pls==1)begin
			cnt_line_dly3_p					<= cnt_line;
		end
	end
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			cnt_line_dly3_n			[15:0]	<= 0;
		end
		else if(s_vid_v_val_pls==1)begin
			cnt_line_dly3_n					<= 0;
		end
		else if(dval_dly3_pls_neg==1)begin
			cnt_line_dly3_n					<= cnt_line;
		end
	end
	delay_data	#(
		.BIT_WIDTH		(16						),	//1~
		.NUM_DELAY		(4						)	//1~
		)
		delay_data_cnt_line_dly3_p_4d			(
		.aclk			(vclk					),
		.delay_array_i	(cnt_line_dly3_p		),
		.delay_array_o	(cnt_line_dly3_p_4d		),
		.aresetn		(aresetn				)
	);
	delay_data	#(
		.BIT_WIDTH		(1						),	//1~
		.NUM_DELAY		(4						)	//1~
		)
		delay_data_dval_dly3_pls_neg_4d			(
		.aclk			(vclk					),
		.delay_array_i	(dval_dly3_pls_neg		),
		.delay_array_o	(dval_dly3_pls_neg_4d	),
		.aresetn		(aresetn				)
	);
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			cnt_line_exp			[15:0]	<= 0;
		end
		else if( s_vid_v_val_pls==1 )begin
			cnt_line_exp					<= 0;
		end
		else if( (cnt_line_dly3_p_4d==cnt_line_dly3_n) && (cnt_line_dly3_n != 0) && (dval_dly3_pls_neg_4d==1) )begin
			cnt_line_exp					<= cnt_line_exp +1;
		end
	end

	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			togg_dval_dly3				<= 0;
		end
		else if( s_vid_v_val_pls==1 )begin
			togg_dval_dly3				<= 0;
		end
		else if( dval_dly3_pls_neg==1 )begin
			togg_dval_dly3				<= ~togg_dval_dly3;
		end
	end
	gen_pulse		gen_pulse_togg_dval_dly3	(
		.aclk			(vclk					),
		.step_i			(togg_dval_dly3			),
		.pulse_o		(togg_dval_dly3_pls		),
		.aresetn		(aresetn				)
	);
	gen_pulse_neg	gen_pulse_togg_dval_dly3_neg	(
		.aclk			(vclk					),
		.step_i			(togg_dval_dly3			),
		.pulse_o		(togg_dval_dly3_pls_n	),
		.aresetn		(aresetn				)
	);
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			cnt_last_line_even		[15:0]	<= 0;
		end
		else if( s_vid_v_val_pls==1 )begin
			cnt_last_line_even				<= 0;
		end
		else if( togg_dval_dly3_pls==1 )begin
			cnt_last_line_even				<= cnt_line;
		end
	end
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			cnt_last_line_odd		[15:0]	<= 0;
		end
		else if( s_vid_v_val_pls==1 )begin
			cnt_last_line_odd				<= 0;
		end
		else if( togg_dval_dly3_pls_n==1 )begin
			cnt_last_line_odd				<= cnt_line;
		end
	end
	always @(posedge vclk or negedge aresetn) begin
		if (aresetn==1'b0) begin
			cnt_last_3line		[15:0]		<= 0;
		end
		else if( s_vid_v_val_pls==1 )begin
			cnt_last_3line					<= 0;
		end
		else if( (dval_dly3_pls_neg==1) && (cnt_last_line_even==cnt_last_line_odd) && (cnt_last_line_even>=20 && cnt_last_line_odd>=20) )begin
			cnt_last_3line					<= cnt_last_3line +1;
		end
	end

////////	debug code e	/////////


delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(21						)	//1~
	)
	dval_delay_data							(
	.aclk			(vclk					),
	.delay_array_i	(dval_dly3				),
	.delay_array_o	(dval_dly3_21d			),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(25						)	//1~
	)
	dly_b_vid_h_val_d13						(
	.aclk			(vclk					),
	.delay_array_i	(b_vid_h_val			),
	.delay_array_o	(b_vid_h_val_d25		),
	.aresetn		(aresetn				)
);

gen_pulse		gen_pulse_dval_dly3		(
	.aclk			(vclk					),
	.step_i			(dval_dly3				),
	.pulse_o		(dval_dly3_pls			),
	.aresetn		(aresetn				)
);
gen_pulse_neg	gen_pulse_neg_dval_dly3		(
	.aclk			(vclk					),
	.step_i			(dval_dly3				),
	.pulse_o		(dval_dly3_pls_neg		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(3						)	//1~
	)
	delay_data_cnt_line_3d					(
	.aclk			(vclk					),
	.delay_array_i	(cnt_line				),
	.delay_array_o	(cnt_line_3d			),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(4						)	//1~
	)
	delay_data_cnt_line_4d					(
	.aclk			(vclk					),
	.delay_array_i	(cnt_line				),
	.delay_array_o	(cnt_line_4d			),
	.aresetn		(aresetn				)
);

//assign dval_or = b_vid_d_val_4d | dval_dly3;
assign dval_or = (exp_fval_3line_32d==0) ? b_vid_d_val_4d : dval_dly3;

gen_pulse_neg	gen_pulse_neg_dval_or		(
	.aclk			(vclk					),
	.step_i			(dval_or				),
	.pulse_o		(dval_or_pls_neg		),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(2						)	//1~
	)
	dval_or_2d_delay_data						(
	.aclk			(vclk					),
	.delay_array_i	(dval_or				),
	.delay_array_o	(dval_or_2d				),
	.aresetn		(aresetn				)
);
delay_data	#(
	.BIT_WIDTH		(1						),	//1~
	.NUM_DELAY		(1						)	//1~
	)
	dval_or_1d_delay_data						(
	.aclk			(vclk					),
	.delay_array_i	(dval_or				),
	.delay_array_o	(dval_or_1d				),
	.aresetn		(aresetn				)
);

delay_data	#(
	.BIT_WIDTH		(16						),	//1~
	.NUM_DELAY		(20						)	//1~
	)
	cnt_pixel_16d_delay_data				(
	.aclk			(vclk					),
	.delay_array_i	(cnt_pixel				),
	.delay_array_o	(cnt_pixel_20d			),
	.aresetn		(aresetn				)
);

gen_pulse_neg	gen_pulse_b_vid_d_val		(
	.aclk			(vclk					),
	.step_i			(b_vid_d_val			),
	.pulse_o		(b_vid_d_val_pls_neg	),
	.aresetn		(aresetn				)
);



endmodule

