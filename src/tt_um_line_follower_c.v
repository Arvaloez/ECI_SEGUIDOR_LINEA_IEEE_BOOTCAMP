module tt_um_line_follower_c ( 
    input  wire        clk,
    input  wire        ena,
    input  wire        rst_n,        
    input  wire [7:0]  ui_in,    
    input  wire [7:0]  uio_in,   
    output reg  [7:0]  uo_out,   
    output wire [7:0]  uio_out,  
    output wire [7:0]  uio_oe    
);
    reg signed [7:0] s0, s1, s2, s3, s4, s5, s6, s7 = 8'b00000000;
    reg signed [7:0] sum_error = 8'b00000000;
    reg signed [7:0] error = 8'b00000000;
    reg              aux = 1'b0;
    wire signal_Q_motor_der;
    wire signal_Q_motor_izq;
    // PWM
    pwm pwm_signal (
        .clk         (clk),
        .rst_n       (rst_n),        
        .Q_motor_der (signal_Q_motor_der),
        .Q_motor_izq (signal_Q_motor_izq),
        .error       (error)
    );
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;
    // Pesos 
    always @(*) begin
        s0 = ui_in[0] ? 8'b11101101 : 8'b00000000;
        s1 = ui_in[1] ? 8'b11110001 : 8'b00000000;
        s2 = ui_in[2] ? 8'b11110111 : 8'b00000000;
        s3 = ui_in[3] ? 8'b11111011 : 8'b00000000;
        s4 = ui_in[4] ? 8'b00000101 : 8'b00000000;
        s5 = ui_in[5] ? 8'b00001001 : 8'b00000000;
        s6 = ui_in[6] ? 8'b00001111 : 8'b00000000;
        s7 = ui_in[7] ? 8'b00010011 : 8'b00000000;
        if (ena)
            sum_error = s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7;
        else
            sum_error = 8'b00000000;
        if (ui_in == 8'b00000000 && aux == 1'b0 && ena == 1'b1)
            error = 8'b11000001;
        else if (ui_in == 8'b00000000 && aux == 1'b1 && ena == 1'b1)
            error = 8'b00111111;
        else if (uio_in[1:0] == 2'b01 && sum_error > 0 && ena == 1'b1)
            error = sum_error + 8'b00000110;
        else if (uio_in[1:0] == 2'b10 && sum_error > 0 && ena == 1'b1)
            error = sum_error + 8'b00001011;
        else if (uio_in[1:0] == 2'b11 && sum_error > 0 && ena == 1'b1)
            error = sum_error + 8'b00001111;
        else if (uio_in[3:2] == 2'b01 && sum_error < 0 && ena == 1'b1)
            error = sum_error - 8'b00000110;
        else if (uio_in[3:2] == 2'b10 && sum_error < 0 && ena == 1'b1)
            error = sum_error - 8'b00001011;
        else if (uio_in[3:2] == 2'b11 && sum_error < 0 && ena == 1'b1)
            error = sum_error - 8'b00001111;
        else if (ena == 1'b1)
            error = sum_error;
        else
            error = 8'b00000000;
            
        uo_out[1] = (ena == 1'b1) ? signal_Q_motor_der : 1'b0;
        uo_out[0] = (ena == 1'b1) ? signal_Q_motor_izq : 1'b0;
        uo_out[7:2] = (ena == 1'b1) ? 6'b000001 : 6'b000000;
    end
    // aux - agregado rst_n
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            aux <= 1'b0;             
        else if (error < 0)
            aux <= 1'b0;
        else
            aux <= 1'b1;
    end
endmodule
