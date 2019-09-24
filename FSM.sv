module fsm(
	input logic clk, nfc, card_active, fund_enough,
	output logic open, reduce_bal,
	output logic [1:0] disp
);

localparam [3:0] // for 4 states : size_state = 1:0
	IDLE = 4'b0000,
//	TAPPED = 4'b0001, //decided not to use
	CHECK_VALID = 4'b0010,
	INVALID = 4'b0011,
	CHECK_BAL = 4'b0100,
	REDUCE_BAL = 4'b0101,
	INSUF_BAL = 4'b0110,
	OPEN = 4'b0111,
	DELAY = 4'b1000,
	CLOSE = 4'b1001,
	SERV = 4'b1010;
    
logic [3:0] state, next_state; 
logic delayed, maintenance;

always_ff @(posedge clk)
begin
	state <= next_state;
end



always_comb 
begin 
	case (state)
		IDLE:
		begin
			disp = 2'b00;
			if(nfc) begin
				next_state = CHECK_VALID ;
			end
		end
//		TAPPED:
//		begin
//			next_state = 
//		end
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
			disp = 2'b10; 		//display invalid card err on screen
			next_state = DELAY;	//delay multiple clks to allow user to read error on screen
		end
		CHECK_BAL:
		begin
			if(fund_enough) begin
				next_state = REDUCE_BAL;
			end
			else begin
				next_state = INSUF_BAL;
			end
		end
		REDUCE_BAL:
		begin
			reduce_bal = 1'b1;
			next_state = OPEN;
		end
		INSUF_BAL:
		begin
			disp = 2'b01;
			next_state = DELAY;
		end
		OPEN:
		begin
			open = 1'b1;
			reduce_bal = 1'b0;
			next_state = DELAY;
		end
		DELAY:
		begin
			delayed = 1'b1;	//for this exmple the delay is just one clk cycle for testing. longer delays can easily be added with a counter
			if(delayed) begin
				if(open)
					next_state = CLOSE;
				else
					next_state = IDLE;
			end
			else 
				next_state = DELAY;
		end
		CLOSE:
		begin
			open = 1'b0;
			next_state = IDLE;
		end
		SERV:
		begin
			if(maintenance)
				next_state = SERV;
			else
				next_state = IDLE;
		end
		default:
		begin
			next_state = IDLE;
		end
	endcase
end  
    
// optional D-FF to remove glitches
always_ff @(posedge clk) begin 
end 
endmodule 