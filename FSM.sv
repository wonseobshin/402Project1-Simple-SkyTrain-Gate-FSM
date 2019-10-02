module fsm(
	input logic clk, nfc, card_active, fund_enough, maintenance, monthly,
	output logic open, reduce_bal,
	output logic [1:0] disp
);

localparam [8:0] 
//disp => 000:idle, 001:insufficient funds, 010:invalid pass, 011:open and show balance, 100:open and show monthly pass expiry date
//(disp[2:0])(open)(reduce_bal)(state[3:0)]
	IDLE = 		9'b00000_0000,
//	TAPPED = 4'b0001, //decided not to use
	CHECK_VALID = 	9'b00000_0010,
	INVALID = 	9'b00000_0011,
	CHECK_BAL = 	9'b00000_0100,
	REDUCE_BAL = 	9'b00001_0101,
	INSUF_BAL = 	9'b00000_0110,
	OPEN = 		9'b01110_0111,
	DELAY_O = 	9'b01110_1000,
	DELAY_OM = 	9'b10010_1000,
	DELAY_E = 	9'b01000_1000,
	DELAY_IF = 	9'b00100_1000,
	CLOSE = 	9'b00000_1001,
	SERV = 		9'b00000_1010;
    
logic [8:0] state, next_state; 
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
			if(maintenance == 1'b1)
				state <= SERV;
		end
		IDLE:
		begin
			//disp = 2'b00;		//this display shows that the gate is awaiting for an nfc card tap
			if(maintenance) 	//go into service mode if maintenance flag s on
				next_state = SERV;
			if(nfc) 		// if card is tapped transition a state
				next_state = CHECK_VALID;
			else
				next_state = IDLE;
		end
		CHECK_VALID:
		begin
			if(card_active) begin	//check if the card account exists within system
				if(monthly)	//checks if card is a monthly pass
				begin
					next_state = OPEN;
				end
				else next_state = CHECK_BAL;
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
			if(fund_enough)
				next_state = REDUCE_BAL;		//reduce balance if there are enough funds the fund_enough signal comes from a higher level module
			else
				next_state = INSUF_BAL;
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
			if(monthly)
				next_state = DELAY_O;	// a delay state is needed to allow users to see the error message and to pass the gate while open
			else
				next_state = DELAY_OM;
		end
		DELAY_O:
		begin
			start_delay = 1;
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
			start_delay = 1;
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
			start_delay = 1;
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
			start_delay = 1;
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
			start_delay = 0;
			//open = 1'b0;
			//disp = 2'b00;
			next_state = IDLE;
		end
		default:
			next_state = IDLE;
	endcase
end  

always_comb 
begin
	disp =	state[8:6];
	open =	state[5];
	reduce_bal = state[4];
end

always_ff @(posedge clk)
begin
	if(start_delay)
		count <= count+1'b1;
	else
		count <= 2'b0;
end

always_comb 
begin
	if( count > 2'b10 )
		delayed = 1'b1;
	else
		delayed = 1'b0;
end

endmodule 