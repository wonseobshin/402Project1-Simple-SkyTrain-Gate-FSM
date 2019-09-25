module fsm_tb;

logic clk, nfc, card_active, fund_enough, maintenance;
logic open, reduce_bal;
logic [1:0] disp;

fsm DUT(.clk(clk), .nfc(nfc), .card_active(card_active), .maintenance(maintenance),
	.fund_enough(fund_enough), .open(open), .reduce_bal(reduce_bal), .disp(disp));

always		// forever loop a clk signal
begin
	clk = 1'b1;
	#5;
	clk = 1'b0;
	#5;
end

always @(posedge clk)
begin
	#10

	//happy case where user taps valid card and passes
	//door should open and display the open display (2'b11)
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b1;
	fund_enough <= 1'b1;

	#50
	//invalid card case
	//door should not open and should display invalid card error
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b0;
	fund_enough <= 1'b1;

	#50
	//insufficient fund case
	//door should not open and display insufficient funds error
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b1;
	fund_enough <= 1'b0;

	#50
	//maintenance case
	//should not react to nfc card
	maintenance <= 1'b1;
	#10
	nfc <= 1'b1;
	#10
	nfc <= 1'b0;
	card_active <= 1'b0;
	fund_enough <= 1'b0;



end

endmodule