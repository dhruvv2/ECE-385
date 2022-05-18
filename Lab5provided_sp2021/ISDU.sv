//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  Halted, //already here
						PauseIR1,  //already here
						PauseIR2, //already here
						S_18,  //already here
						S_33_1,  //already here
						S_33_2,  //already here
						S_33_3, 
						S_35,  //already here
						S_32,  //already here
						S_and,
						S_add,
						S_not,
						S_br,
						
						S_jmp0,
						S_jmpbreak,
						S_jmp1,
						S_22,
						
						S_jsr1,
						S_jsr2,
						
						S_ldr0,
						S_ldr1,
						S_ldr2,
						S_ldr3,
						S_ldr4,
						
						S_str0,
						S_str1,
						S_str2,
						S_str3
						//S_pause;
						}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b0;
		Mem_WE = 1'b0;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : //we added this
				Next_state = S_33_3;
			S_33_3:
				Next_state = S_35;
				
			S_35 : 
				Next_state =  S_32;
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : 
				case (Opcode)
					// You need to finish the rest of opcodes.....
					4'b0001 : //add
						Next_state = S_add;
					4'b0101 : //and
						Next_state = S_and;
					4'b1001 : //not
						Next_state = S_not;
					4'b0000 : //br
						Next_state = S_br;
					4'b1100 : //jmp
						Next_state = S_jmp0;
					4'b0100 : //jsr
						Next_state = S_jsr1;
					4'b0111 : //str
						Next_state = S_str0;
					4'b0110 : //ldr
						Next_state = S_ldr0;
					4'b1101 : //pause
						Next_state = PauseIR1;
					default : 
						Next_state = S_18;
						
				endcase
			S_add : 
				Next_state = S_18;

			// You need to finish the rest of states.....
			S_and :
				Next_state = S_18;
				
			S_not : Next_state = S_18;
			
			S_br :
				if (BEN == 1'b1)
					Next_state = S_22;
				else 
					Next_state = S_18;
			S_jmp0 : Next_state = S_18;
			
			
			
			S_jsr1: Next_state = S_jsr2; //S_21 adder1mux = 1'b0, adder2mux = 2'b11, pcmux = 2'b10, ld_pc = 1'b1;
			S_jsr2: Next_state = S_18;
				
			S_ldr0 : Next_state = S_ldr1;
			S_ldr1 : Next_state = S_ldr2;
			S_ldr2 : Next_state = S_ldr3;
			S_ldr3 : Next_state = S_ldr4;
			S_ldr4 : Next_state = S_18;
			
			S_str0 : Next_state = S_str1;
			S_str1 : Next_state = S_str2;
			S_str2 : Next_state = S_str3;
			S_str3 : Next_state = S_18;
			S_jmpbreak:;
			S_22 : Next_state = S_18;
			//Pause_IR1;
			default :;
				//Next_state = S_18;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b01; //pc mux is diff
					LD_PC = 1'b1;
				end
			S_33_1 : 
				Mem_OE = 1'b1;
			S_33_2 : 
				begin 
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
			S_33_3 :
				begin
				Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1: 
				begin
					LD_LED = 1'b1;
				end
			PauseIR2: ;
			S_32 : 
				LD_BEN = 1'b1;
			S_add : //add
				begin 
					SR2MUX = IR_5;
					ALUK = 2'b00;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					// incomplete...
					SR1MUX = 1'b1;
					DRMUX = 1'b0;
					LD_CC = 1'b1;
				end
			S_and : 
				begin 
					ALUK = 2'b01;
					GateALU = 1'b1;
					SR1MUX = 1'b1;
					SR2MUX = IR_5;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
					DRMUX = 1'b0;
				end
			S_not :
				begin
					ALUK = 2'b10;
					GateALU = 1'b1;
					SR1MUX = 1'b1;
					SR2MUX = 1'b0; //changed 
					LD_REG = 1'b1;
					LD_CC = 1'b1;
					DRMUX = 1'b0;
				end
			// You need to finish the rest of states.....
			S_ldr0 :
				begin
					SR1MUX = 1'b1;
					LD_MAR = 1'b1;
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					GateMARMUX = 1'b1;
					
				end
			S_ldr1 :
				begin
					Mem_OE = 1'b1; //switched
					Mem_WE = 1'b0;
					//GateMARMUX = 1'b1;
					//ADDR1MUX = 1'b1;
					//ADDR2MUX = 2'b01;
				end
			S_ldr2 :
				begin
					
					Mem_OE = 1'b1;
					Mem_WE = 1'b0;
					LD_MDR = 1'b1;
					//GateMARMUX = 1'b1;
					//ADDR1MUX = 1'b1;
					//ADDR2MUX = 2'b01;
				end
			S_ldr3 :
				begin
					Mem_OE = 1'b1;
					Mem_WE = 1'b0;
					LD_MDR = 1'b1;
					//GateMARMUX = 1'b1;
					//ADDR1MUX = 1'b1;
					//ADDR2MUX = 2'b01;
				end
			S_ldr4 :
				begin
					LD_REG = 1'b1;
					LD_CC = 1'b1;
					DRMUX = 1'b0;
					GateMDR = 1'b1;
				end
			S_str0 :
				begin
					//SR1MUX = 1'b1;
					//LD_MAR = ;
					//GateMARMUX = 1'b1;
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					SR1MUX = 1'b1;
					LD_MAR = 1'b1;
					GateMARMUX = 1'b1;
				end
			S_str1 :
				begin
					//Mem_OE = 1'b0;
					//Mem_WE = 1'b1;
					ALUK = 2'b11;
					SR1MUX = 1'b0;
					LD_MDR = 1'b1;
					GateALU = 1'b1;
					//GateMARMUX = 1'b1;
					//ADDR1MUX = 1'b1;
					//ADDR2MUX = 2'b01;
				end
			S_str2 :
				begin
					Mem_WE = 1'b1;
					Mem_OE = 1'b0;//changed
					//LD_MDR = 1'b1;
					//GateMARMUX = 1'b1;
					//ADDR1MUX = 1'b1;
					//ADDR2MUX = 2'b01;
				end
			S_str3 :
				begin
					Mem_WE = 1'b1;
					Mem_OE = 1'b0; //changed
					//GateMARMUX = 1'b1;
					//ADDR1MUX = 1'b1;
					//ADDR2MUX = 2'b01;
				end
				
			S_jsr1 :
				begin
					LD_REG = 1'b1;
					DRMUX = IR_11;
					GatePC = 1'b1;
				end
				
			S_jsr2 :
				begin
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b11;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
				
			S_jmp0 :
				begin
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b00;
					SR1MUX = 1'b1;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
			S_jmpbreak:;
			S_22 :
				begin
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b10;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
			default :;
				//Next_state = Halted;
			
		endcase
	end 

	
endmodule
