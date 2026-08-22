module BIN2OHT #(
    parameter BIN_DW = 32
)(
    input  logic [BIN_DW-1:0] bin,
    output logic [2**BIN_DW-1:0] oht
);

    /*AUTOWIRE*/

    assign  oht = bin;
        
    end

endmodule