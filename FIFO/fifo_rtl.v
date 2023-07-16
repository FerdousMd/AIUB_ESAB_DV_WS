
// Code your design here

module fifo #(
	parameter FIFO_DEPTH = 16,
	parameter DATA_WIDTH = 32
) (
	input 						clk,
	input 						rstn,
	input 						push,
	input 						pop,
	input 	[DATA_WIDTH-1:0] 	in_data,

	output 						push_err_on_full,
	output 						pop_err_on_empty,
	output 						full,
	output 						empty,
	output 	[DATA_WIDTH-1:0] 	out_data
);

	reg [$clog2(FIFO_DEPTH)-1:0] data_count;
	reg [$clog2(FIFO_DEPTH):0] write_count;
	reg [$clog2(FIFO_DEPTH):0] read_count;
	reg [DATA_WIDTH-1:0] 	read_out_data;

	reg [DATA_WIDTH-1:0] fifo_memory [FIFO_DEPTH];

	wire write_en;
	wire read_en;


	always @(posedge clk, negedge rstn)
	begin
		if(!rstn)
		begin
			data_count  = 'b0;
		end
		else
		begin
			if (write_count > read_count)
				data_count = write_count - read_count;
			else
				data_count = 'b0;
		end
	end

	always @(posedge clk, negedge rstn)
	begin
		if(!rstn)
			read_count <= 0;
		else
		begin
			if (data_count == 0)
				read_count <= 0;
			if (read_en && (data_count != {($clog2(FIFO_DEPTH)){1'b0}}))
				read_count <= read_count + 1;
			else
				read_count <= read_count;
		end
	end


	always @(posedge clk, negedge rstn)
	begin
		if(!rstn)
			write_count <= 0;
		else
		begin
			if (data_count == 0)
				write_count <= 0;
			if (write_en && (data_count != {($clog2(FIFO_DEPTH)){1'b1}}))
				write_count <= write_count + 1;
			else
				write_count <= write_count;
		end
	end
	
	assign write_en = push && (!full);
	assign read_en  = pop & (!empty);
	assign full  = (&data_count);
	assign empty = (data_count == 0);
	assign push_err_on_full = (push && full);
	assign pop_err_on_empty = (pop && empty);



	always @(posedge clk or negedge rstn) 
	begin 
		if(~rstn) 
		begin
			for (int i = 0; i < FIFO_DEPTH; i++) 
			begin
				fifo_memory [i] <= 0;
			end
		end else begin
			 if (write_en) 
			 begin
			 	fifo_memory[write_count] <= in_data;
			 end

			 if (read_en) begin
			 	read_out_data <= fifo_memory[read_count];
			 end
		end
	end

	assign out_data = read_out_data;

		
endmodule








