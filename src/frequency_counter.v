`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // If a module starts with #() then it is parametisable. It can be instantiated with different settings
    // for the localparams defined here. So the default is an UPDATE_PERIOD of 1200 and BITS = 12
    //
    // '-1' in the main, but not in the start
    localparam UPDATE_PERIOD = 1200 - 1,
    localparam BITS = 12
)(
    input wire              clk,
    input wire              reset,
    input wire              signal,

    input wire [BITS-1:0]   period,
    input wire              period_load,

    output wire [6:0]       segments,
    output wire             digit
    );

    // states
    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS  = 2;

    reg [2:0] state = STATE_COUNT;

    reg [3:0] tens;
    reg [3:0] units;
    reg load;
    wire leading_edge_detect;

    reg [BITS-1:0] sample;
    reg [6:0] counter; //limit do 7 bits because we can only display up to 99 (2 digits)

    seven_segment seven_segment0(.clk(clk), .reset(reset), .load, .ten_count(tens), .unit_count(units), .segments(segments), .digit(digit));
    edge_detect edge_detect0(.clk(clk), .signal(signal), .leading_edge_detect(leading_edge_detect));

    //always @(posedge clk) begin
    //    if(reset)
    //        update_period   <= UPDATE_PERIOD;
    //    else if(period_load)
    //        update_period   <= period;
    //end


    always @(posedge clk) begin
        if(reset) begin
            
            tens    <= 0;
            units   <= 0;
            load    <= 0; 
            counter <= 0;
            sample  <= 0;
            state   <= STATE_COUNT;
            // reset things here

        end else begin
            case(state)
                STATE_COUNT: begin
                    // stop loading of new values to 7segment
                    load <= 0;
                    // could also do this in the if block which switches state
                    tens    <= 0;
                    units   <= 0;

                    // count edges and clock cycles
                    sample <= sample + 1'b1;
 
                    // can I get away with adding the detect value? NO per
                    // simulation
                    //counter <= counter + leading_edge_detect;
                    if(leading_edge_detect)
                        counter <= counter + 1'b1;


                    // if clock cycles > UPDATE_PERIOD then go to next state
                    // if use a `begin` can clean up the counters here instead
                    // of in STATE_UNITS
                    if (sample >= UPDATE_PERIOD)
                        state <= STATE_TENS;
                end

                STATE_TENS: begin
                    // count number of tens by subtracting 10 while edge counter >= 10
                    if (counter < 7'd10)
                        state <= STATE_UNITS;
                    else
                        tens <= tens + 1;
                        counter <= counter - 7'd10;
                end

                STATE_UNITS: begin
                    // what is left in edge counter is units
                    units <= counter; // not necessary to limit to bits [3:0];
                    // update the display
                    load <= 1'b1;
                    // go back to counting
                    state <= STATE_COUNT;
                    // have to set these *before* we get to STATE_COUNT
                    counter <= 0;
                    sample  <= 0;
                end

                default:
                    state           <= STATE_COUNT;

            endcase
        end
    end

endmodule
