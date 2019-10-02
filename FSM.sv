module fsm(
	input logic clk, nfc, card_active, fund_enough, maintenance, monthly,
	output logic open, reduce_bal,
	output logic [2:0] disp,
	output logic [1:0] sound
);

localparam [10:0] 
//disp => 000:idle, 001:insufficient funds, 010:invalid pass, 100:open and show balance, 101:open and show monthly pass expiry date, 111: Unavailable due to maintenance
//sound => 00:no sound, 01:error beeps(beep beep beep), 10:pass beep (beeeep), 
//(sound[1:0])_(disp[2:0])_(open)(reduce_bal)(state[3:0)]
	IDLE = 		11'b00_000_00_0000,
//	TAPPED = 4'b0001, //decided not to use
	CHECK_VALID = 	11'b00_000_00_0010,
	INVALID = 	11'b01_000_00_0011,
	CHECK_BAL = 	11'b00_000_00_0100,
	REDUCE_BAL = 	11'b00_000_01_0101,
	INSUF_BAL = 	11'b01_000_00_0110,
	OPEN = 		11'b10_000_10_0111,
	DELAY_O = 	11'b00_100_10_1000,
	DELAY_OM = 	11'b00_101_10_1000,
	DELAY_E = 	11'b00_010_00_1000,
	DELAY_IF = 	11'b00_001_00_1000,
	CLOSE = 	11'b00_000_00_1001,
	SERV = 		11'b00_111_00_1010,
	SERV_E = 	11'b01_111_00_1010;
    
logic [10:0] state, next_state; 
logic delayed, start_delay;
logic [1:0] count;

always_ff @(posedge clk)
begin
	state <= next_state;
end

//assign delayed = 1'b1;	//for this exmple the delay is just one clk cycle for testing. longer delays can easily be added with a counter

always_comb 
begin 
	case (state)
		SERV:
		begin
			if(nfc)
				next_state = SERV_E;
			else
				if(maintenance == 1'b1)
					next_state = SERV;
				else
					next_state = IDLE;
		end
		SERV_E:				//error when user tries to tap on a machine in service. only one cycle to make sound
		begin
			next_state = SERV;
		end
		IDLE:
		begin
			//disp = 2'b00;		//this display shows that the gate is awaiting for an nfc card tap
			if(maintenance) begin	//go into service mode if maintenance flag s on
				next_state = SERV;
			end
			if(nfc) begin		// if card is tapped transition a state
				next_state = CHECK_VALID ;
			end
		end
		CHECK_VALID:
		begin
			if(card_active) begin	//check if the card account exists within system
				next_state = CHECK_BAL;
			end
			else begin
				next_state = INVALID;
			end
		end
		INVALID:
		begin
			//disp = 2'b10; 		//display invalid card err on screen
			next_state = DELAY_E;	//delay multiple clks to allow user to read error on screen
		end
		CHECK_BAL:
		begin
			if(monthly)	//checks if card is a monthly pass
			begin
				next_state = OPEN;
			end
			else 
				if(fund_enough == 1'b1) begin
					next_state = REDUCE_BAL;		//reduce balance if there are enough funds the fund_enough signal comes from a higher level module
				end
				else begin
				next_state = INSUF_BAL;
				end
		end
		REDUCE_BAL:
		begin
			//reduce_bal = 1'b1;	// will send a blip of single bit signal to software to reduce card balance.
			next_state = OPEN;
		end
		INSUF_BAL:
		begin
			//disp = 2'b01;		// insufficient balance display
			next_state = DELAY_IF;
		end
		OPEN:
		begin
			//open = 1'b1;
			//disp = 2'b11;		//this is the open display
			//reduce_bal = 1'b0;
			if(monthly == 1'b1)
				next_state = DELAY_O;	// a delay state is needed to allow users to see the error message and to pass the gate while open
			else
				next_state = DELAY_OM;
		end
		DELAY_O:
		begin
			//start_delay = 1;
			if(delayed) begin
				if(open)
					next_state = CLOSE;
				else
					next_state = IDLE;
			end
			else 
				next_state = DELAY_O;
		end
		DELAY_OM:
		begin
			//start_delay = 1;
			if(delayed) begin
				if(open)
					next_state = CLOSE;
				else
					next_state = IDLE;
			end
			else 
				next_state = DELAY_OM;
		end
		DELAY_IF:
		begin
			//start_delay = 1;
			if(delayed) begin
				if(open)
					next_state = CLOSE;
				else
					next_state = IDLE;
			end
			else 
				next_state = DELAY_IF;
		end
		DELAY_E:
		begin
			//start_delay = 1;
			if(delayed) begin
				if(open)
					next_state = CLOSE;
				else
					next_state = IDLE;
			end
			else 
				next_state = DELAY_E;
		end
		CLOSE:
		begin

			//start_delay = 0;
			//open = 1'b0;
			//disp = 2'b00;
			next_state = IDLE;
		end
		default:
		begin
			next_state = IDLE;
		end
	endcase
end  

always_comb 
begin
	disp =	state[8:6];
	open =	state[5];
	reduce_bal = state[4];
	sound = state[10:9];
end

always_ff @(posedge clk)
begin
	if(start_delay)
	begin
		count <= count+1'b1;
	end
	else
	begin
		count <= 2'b0;
	end
end

always_comb 
begin
	if(state[3:0] == 4'b1000)
		start_delay = 1'b1;
	else
		start_delay = 1'b0;

	if( count > 2'b10 )
	begin
		delayed = 1'b1;
	end
	else
	begin
		delayed = 1'b0;
	end
end

endmodule 