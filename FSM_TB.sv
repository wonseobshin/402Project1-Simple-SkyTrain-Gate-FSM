module fsm_tb;

logic clk, nfc, card_active, fund_enough;
logic open, reduce_bal;
logic [1:0] disp;

fsm DUT(.clk(clk), .nfc(nfc), .card_active(card_active), 
	.fund_enough(fund_enough), .open(open), .reduce_bal(reduce_bal), .disp(disp));

always
begin
	clk = 1'b1;
	#5;
	clk = 1'b0;
	#5;
end

always @(posedge clk)
begin
	#10
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b1;
	fund_enough <= 1'b1;
	
	#50
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b1;
	fund_enough <= 1'b1;

	#50
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b0;
	fund_enough <= 1'b1;

	#50
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b1;
	fund_enough <= 1'b0;

	#50
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b0;
	fund_enough <= 1'b0;



end

endmodule