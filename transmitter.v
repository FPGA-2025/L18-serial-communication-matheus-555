module transmitter (
    input clk,
    input rstn,
    input start,
    input [6:0] data_in,
    output reg serial_out
);

    //insira seu código aqui
    localparam RESET                = 3'd0;
    localparam AGUARDA_START_BIT    = 3'd1;
    localparam START_BIT            = 3'd2;
    localparam ENVIA_DADOS          = 3'd3;
    localparam FINALIZA_ENVIO_DADOS = 3'd4;

    reg [2:0] estado;
    reg [2:0] proximo_estado;
    reg [3:0] contador_bit;
    reg [7:0] buffer_dados;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            estado = RESET;
        end else begin
            estado = proximo_estado;
        end
    end

    always @(estado) begin
        case (estado)
            RESET: begin
                proximo_estado = AGUARDA_START_BIT;
            end

            AGUARDA_START_BIT: begin
                proximo_estado = !start ? START_BIT : AGUARDA_START_BIT;
            end

            START_BIT: begin
                proximo_estado = ENVIA_DADOS;
            end

            ENVIA_DADOS: begin
                proximo_estado = contador_bit >= 8 ? FINALIZA_ENVIO_DADOS : ENVIA_DADOS;
            end

            FINALIZA_ENVIO_DADOS: begin
                proximo_estado = AGUARDA_START_BIT;
            end
        endcase
    end

    always @(posedge clk) begin
        case (estado)
            RESET: begin
                buffer_dados = 8'b00000000;
                serial_out   = 8'b11111111;
            end

            AGUARDA_START_BIT: begin
                
            end

            START_BIT: begin
                contador_bit = 4'b0000;
                buffer_dados = {(^data_in), data_in};
                serial_out   = 1'b0;
            end

            ENVIA_DADOS: begin
                contador_bit <= contador_bit+1; // Se atribuir com o sinal de '='(igual) não fuciona...

                if (contador_bit < 8) begin
                    serial_out = buffer_dados[contador_bit];
                end else begin
                    serial_out = 1'b1;
                end
            end

            FINALIZA_ENVIO_DADOS: begin
                serial_out = 1'b0;
            end
        endcase
    end
endmodule

