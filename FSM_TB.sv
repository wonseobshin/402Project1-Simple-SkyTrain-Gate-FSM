`timescale 1ns/10ps
module fsm_tb;

logic clk, nfc, card_active, fund_enough, maintenance, monthly;
logic open, reduce_bal;
logic [2:0] disp;
logic [1:0] sound;

fsm DUT(.clk(clk), .nfc(nfc), .card_active(card_active), .maintenance(maintenance), .monthly(monthly),
	.fund_enough(fund_enough), .open(open), .reduce_bal(reduce_bal), .disp(disp), .sound(sound));

always		// forever loop a clk signal
begin
	clk = 1'b1;
	#5;
	clk = 1'b0;
	#5;
end

always @(posedge clk)
begin
	#20

	//happy case where user taps valid card and passes
	//door should open and display the open display 
	nfc <= 1'b1;
	card_active <= 1'b1;
	fund_enough <= 1'b1;
	monthly <= 1'b0;
	#20
	nfc <= 1'b0;

	#100

	//another happy case where user taps valid MONTHLY card and passes
	//door should open and display the open display 
	nfc <= 1'b1;
	card_active <= 1'b1;
	fund_enough <= 1'b1;
	monthly <= 1'b1;
	#20
	nfc <= 1'b0;

	#50
	monthly <= 1'b0;
	#50

	//invalid card case
	//door should not open and should display invalid card error
	nfc <= 1'b1;
	card_active <= 1'b0;
	fund_enough <= 1'b1;
	#20
	nfc <= 1'b0;

	#100
	//insufficient fund case
	//door should not open and display insufficient funds error
	nfc <= 1'b1;
	card_active <= 1'b1;
	fund_enough <= 1'b0;
	#20
	nfc <= 1'b0;

	#100
	//maintenance case
	//should not react to nfc card
	maintenance <= 1'b1;
	#20
	nfc <= 1'b1;
	card_active <= 1'b0;
	fund_enough <= 1'b0;
	#20
	nfc <= 1'b0;

	#100
	maintenance <= 1'b0;


end

endmodule