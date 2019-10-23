module VX_generic_priority_encoder
  #(
  	parameter N = 1
  )
  (
    input  wire[N-1:0] valids,
    output reg[$clog2(N)-1:0] index,
    output reg           found
  );

	integer i;
	always @(*) begin
		index = 0;
		found = 0;
		for (i = `NW-1; i >= 0; i = i - 1) begin
			if (valids[i]) begin
				index = i[$clog2(N)-1:0];
				found = 1;
			end
		end
	end
endmodule