//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 5 Given Code - SLC-3 top-level (Physical RAM)
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//------------------------------------------------------------------------------





module bus(
	input logic GateMARMUX, GatePC, GateMDR, GateALU, //gate values, determine if its open or closed
	input logic [15:0] MARMUX, PC, MDR, ALU,//actual value in the MARMUX and all, probably has to be changed, add ALU later
	output logic [15:0] out //out can go to IR, MAR or the register, or to LOGIC
);

always_comb
	begin
		if(GateMARMUX) 
			out = MARMUX; //where does it match up?
		 else if(GatePC) 
			out = PC; 
		 else if(GateMDR)
			out = MDR;
		else if(GateALU) 
			out = ALU;
		else
			out = 16'hxxxx; //should be dont cares
	end

endmodule 
//output feeds into MDR
module MIO_En(input logic [15:0] Data_to_CPU, Bus_out,
				  input logic MIO_Select,
				  output logic [15:0] MDR);

		always_comb
			begin
				if(MIO_Select == 1) begin
					MDR = Data_to_CPU;
				end else begin
					MDR = Bus_out;
				end
			end
	
endmodule

//this module feeds into the PC 
module PC_MUX(input logic [15:0] Bus_out_, PC_Next, MARMUX,
				 input logic [1:0] PCMUX,
				 output logic [15:0] PC);
				 
		always_comb
			begin
				if(PCMUX == 2'b00) begin
					PC = Bus_out_;
				end else if(PCMUX == 2'b01) begin
					PC = PC_Next;
				end else if(PCMUX == 2'b10) begin
					PC = MARMUX;
				end else begin
					PC = 16'hxxxx;//should be dont cares
				end
			end
endmodule


module SR2MUX(input logic [15:0] SR2_out, IR_sext,
					input logic select,
					output logic [15:0] SR2MUX_out);
		
		always_comb
			begin
				if(select == 0) begin
					SR2MUX_out = SR2_out; // might have to change these assignments if there is a data sheet somewhere
				end else begin
					SR2MUX_out = IR_sext;
				end
			end		
			
					
endmodule


module ADDR1MUX(input logic [15:0] SR1_out, PC_out,
					input logic ADDR1MUX,
					output logic [15:0] ADDR1MUX_out);
		
		always_comb
			begin
				if(ADDR1MUX == 1'b1) begin
					ADDR1MUX_out = SR1_out; // might have to change these assignments if there is a data sheet somewhere
				end else begin
					ADDR1MUX_out = PC_out;
				end
			end		
			
					
endmodule

module ADDR2MUX(input logic [15:0] IR11BITS, IR9BITS, IR6BITS, ZERO16bit,
				 input logic [1:0] ADDR2MUX,
				 output logic [15:0] ADDR2MUX_out);
				 
		always_comb
			begin
				if(ADDR2MUX == 2'b00) begin
					ADDR2MUX_out = ZERO16bit;
				end else if(ADDR2MUX == 2'b01) begin
					ADDR2MUX_out = IR6BITS;
				end else if(ADDR2MUX == 2'b11) begin
					ADDR2MUX_out = IR11BITS;
				end else if(ADDR2MUX == 2'b10) begin
					ADDR2MUX_out = IR9BITS;
				end else begin
					ADDR2MUX_out = 16'hxxxx;//should be dont cares
				end
			end
endmodule

module SR1MUX(input logic [2:0] IR11TO9, IR8TO6,
					input logic SR1,
					output logic [2:0] SR1MUX_out);
		
		always_comb
			begin
				if(SR1 == 0) begin
					SR1MUX_out = IR11TO9; // might have to change these assignments if there is a data sheet somewhere
				end else begin
					SR1MUX_out = IR8TO6;
				end
			end		
			
					
endmodule

module DRMUX(input logic [2:0] IR11TO9, TRIP1,
					input logic DR,
					output logic [2:0] DRMUX_out);
		
		always_comb
			begin
				if(DR == 1'b0) begin
					DRMUX_out = IR11TO9; // might have to change these assignments if there is a data sheet somewhere
				end else begin
					DRMUX_out = TRIP1;
				end
			end		
			
					
endmodule

module REG(input logic [15:0] Bus_out,
			  input logic [2:0] SR2, DRMUX, SR1MUX,
			  input logic LD_REG, Clk, Reset,
			  output logic [15:0] SR1_out, SR2_out);
			  
			  logic [15:0] Regs [8] ;
			  
			always_ff @ (posedge Clk) begin
			   if(Reset == 1'b1) 
				begin
					Regs[7] <= 16'h0000;
					Regs[6] <= 16'h0000;
					Regs[5] <= 16'h0000;
					Regs[4] <= 16'h0000;
					Regs[3] <= 16'h0000;
					Regs[2] <= 16'h0000;
					Regs[1] <= 16'h0000;
					Regs[0] <= 16'h0001;
				end 
				else if(LD_REG) begin
					Regs[DRMUX] <= Bus_out;
				end //else begin
				//	Regs[DRMUX] <= Regs[DRMUX];
				//end
			end
			always_comb begin
				SR1_out = Regs[SR1MUX];
				SR2_out = Regs[SR2];
			  end
			  
endmodule

module BEN(input logic LD_CC, LD_BEN, Clk, Reset,
			  input logic [2:0] IR11TO9,
			  input logic [15:0] Bus_out,
			  output logic BEN_out);
			  
		logic n,z,p;
		logic n_out, z_out, p_out;

		always_comb begin
				if(Bus_out == 16'h0000) begin 
					n = 1'b0;
					z = 1'b1;
					p = 1'b0;
				end else if(Bus_out[15] == 1'b1) begin
					n = 1'b1;
					z = 1'b0;
					p = 1'b0;
				end else begin
					n = 1'b0;
					z = 1'b0;
					p = 1'b1;
				end 
		end
		
				
			always_ff @ (posedge Clk) begin
				if(LD_CC == 1) begin
					n_out = n;
					z_out = z;
					p_out = p;
				end
				if(LD_BEN == 1'b1) begin
					BEN_out <= IR11TO9[2] & n_out | IR11TO9[1] & z_out | IR11TO9[0] & p_out;
				end 
				if(Reset) begin
					BEN_out <= 1'b0;
				end
			end
endmodule

module ALU(input logic [15:0] Aval, Bval,
			  input logic [1:0] ALUK,
			  output logic [15:0] ALU_out);
			  
		always_comb
			  begin
					if (ALUK == 2'b00) 
						//add function
						ALU_out = Aval+Bval;
					 else if (ALUK == 2'b01)  
						//and function
						ALU_out = Aval & Bval;
					 else if (ALUK == 2'b10) 
						//NOT function
						ALU_out = ~Aval;
					 else if (ALUK == 2'b11) 
						//pass input as output
						ALU_out = Aval;
					 else
						ALU_out = 16'hxxxx;
					
			  end

endmodule

module slc3(
	input logic [9:0] SW,
	input logic	Clk, Reset, Run, Continue,
	output logic [9:0] LED,
	input logic [15:0] Data_from_SRAM,
	output logic OE, WE,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3,
	output logic [15:0] ADDR,
	output logic [15:0] Data_to_SRAM
);


// An array of 4-bit wires to connect the hex_drivers efficiently to wherever we want
// For Lab 1, they will direclty be connected to the IR register through an always_comb circuit
// For Lab 2, they will be patched into the MEM2IO module so that Memory-mapped IO can take place
logic [3:0] hex_4 [3:0]; 





HexDriver hex_drivers[3:0] (hex_4, {HEX3, HEX2, HEX1, HEX0});

// This works thanks to http://stackoverflow.com/questions/1378159/verilog-can-we-have-an-array-of-custom-modules



// Internal connections
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED;
logic GatePC, GateMDR, GateALU, GateMARMUX;
logic SR2MUX, ADDR1MUX;
logic BEN, MIO_EN, DRMUX, SR1MUX;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic [15:0] MDR_In;
logic [15:0] MAR, MDR, IR, ALU;

logic [15:0] PC, Bus_out, MARMUX_out, PC_input, MIO_En, SR2_out, SR1_out, ADDR2MUX_out, ADDR1MUX_out;

logic [15:0] FIVEBIR, SIXBIR, NINEBIR, ELEVBIR;

logic [15:0] A,B;

logic [2:0] SR1MUX_out, DRMUX_out;

logic [15:0] AddedAddress;

assign AddedAddress = ADDR1MUX_out + ADDR2MUX_out;


assign FIVEBIR = {{11{IR[4]}}, IR[4:0]};
assign SIXBIR = {{10{IR[5]}}, IR[5:0]};
assign NINEBIR = {{7{IR[8]}}, IR[8:0]};
assign ELEVBIR = {{5{IR[10]}}, IR[10:0]};

assign LED = IR[9:0];
//{{10{IR[5]}}, IR[5:0]} sign extending 




// Connect MAR to ADDR, which is also connected as an input into MEM2IO
//	MEM2IO will determine what gets put onto Data_CPU (which serves as a potential
//	input into MDR)
assign ADDR = MAR; 
assign MIO_EN = OE;
// Connect everything to the data path (you have to figure out this part)
//datapath d0 (.*);

//our code below:

bus datapath(.GateMARMUX(GateMARMUX), .GatePC(GatePC), .GateMDR(GateMDR), .GateALU(GateALU),
				 .MARMUX(AddedAddress), .PC(PC), .MDR(MDR), .ALU(ALU), .out(Bus_out));



//SR2MUX, SR1MUX, ADDR2MUX, ADDR1MUX, REG, BEN, DRMUX

//instantiate BEN
BEN BEN1(.LD_CC(LD_CC), .LD_BEN(LD_BEN), .IR11TO9(IR[11:9]), .Bus_out(Bus_out), .BEN_out(BEN), .Clk(Clk), .Reset(Reset));

//instantiate ADDR1MUX
ADDR1MUX ADDR1MUX1(.SR1_out(A), .PC_out(PC), .ADDR1MUX(ADDR1MUX), .ADDR1MUX_out(ADDR1MUX_out));

//instantiate ADDR2MUX
ADDR2MUX ADDR2MUX1(.IR11BITS(ELEVBIR), .IR9BITS(NINEBIR), .IR6BITS(SIXBIR), .ZERO16bit(16'h0000), .ADDR2MUX(ADDR2MUX), .ADDR2MUX_out(ADDR2MUX_out));

//instantiate REG FILE
REG REGFILE(.Bus_out(Bus_out), .SR2(IR[2:0]), .DRMUX(DRMUX_out), .SR1MUX(SR1MUX_out), .LD_REG(LD_REG), .SR1_out(A), .SR2_out(SR2_out), .Clk(Clk), .Reset(Reset));

//instantiate DRMUX
DRMUX DRMUX1(.IR11TO9(IR[11:9]), .TRIP1(3'b111), .DR(DRMUX), .DRMUX_out(DRMUX_out));

//instantiate SR1MUX
SR1MUX SR1MUX1(.IR11TO9(IR[11:9]), .IR8TO6(IR[8:6]), .SR1(SR1MUX), .SR1MUX_out(SR1MUX_out));				 

//instantiate SR2MUX
SR2MUX SR2MUX1(.SR2_out(SR2_out), .IR_sext(FIVEBIR), .select(SR2MUX), .SR2MUX_out(B));				 
//instantiate ALU
ALU ALU1(.Aval(A), .Bval(B), .ALUK(ALUK), .ALU_out(ALU));

//instantiate PC MUX
PC_MUX PCMUX1(.Bus_out_(Bus_out), .PC_Next(PC+1), .MARMUX(ADDR1MUX_out+ADDR2MUX_out), .PCMUX(PCMUX), .PC(PC_input));

// instantiate MIO MUX 
MIO_En MIO_En1(.Data_to_CPU(MDR_In), .Bus_out(Bus_out), .MIO_Select(MIO_EN), .MDR(MIO_En));

//4 registers - MAR, MDR, PC and IR 
reg_16 MAR1(.Clk(Clk), .Reset(Reset), .Load(LD_MAR), .D(Bus_out), .Data_Out(MAR));

reg_16 MDR1(.Clk(Clk), .Reset(Reset), .Load(LD_MDR), .D(MIO_En), .Data_Out(MDR));

reg_16 PC1(.Clk(Clk), .Reset(Reset), .Load(LD_PC), .D(PC_input), .Data_Out(PC));

reg_16 IR1(.Clk(Clk), .Reset(Reset), .Load(LD_IR), .D(Bus_out), .Data_Out(IR));

//code below is given

// Our SRAM and I/O controller (note, this plugs into MDR/MAR)
//
Mem2IO memory_subsystem(
    .*, .Reset(Reset), .ADDR(ADDR), .Switches(SW),
    .HEX0(hex_4[0][3:0]), .HEX1(hex_4[1][3:0]), .HEX2(hex_4[2][3:0]), .HEX3(hex_4[3][3:0]),
    .Data_from_CPU(MDR), .Data_to_CPU(MDR_In),
    .Data_from_SRAM(Data_from_SRAM), .Data_to_SRAM(Data_to_SRAM)
);


// State machine, you need to fill in the code here as well
ISDU state_controller(
	.*, .PCMUX(PCMUX), .Reset(Reset), .Run(Run), .Continue(Continue),
	.Opcode(IR[15:12]), .IR_5(IR[5]), .IR_11(IR[11]),
   .Mem_OE(OE), .Mem_WE(WE)
);

// SRAM WE register
//logic SRAM_WE_In, SRAM_WE;
//// SRAM WE synchronizer
//always_ff @(posedge Clk or posedge Reset_ah)
//begin
//	if (Reset_ah) SRAM_WE <= 1'b1; //resets to 1
//	else 
//		SRAM_WE <= SRAM_WE_In;
//end

	
endmodule
