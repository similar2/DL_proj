`timescale 1ns/1ps

module AnalyseReceiveData(
    input [7:0] data_receive,
    input data_valid,
    output reg traveler_in_front_of_target_machine,
    output reg traveler_has_item_in_hand,
    output reg target_machine_is_processing,
    output reg target_machine_has_item
);


always@(*)
begin
    if(data_valid==0)
    begin
        case({data_receive[1],data_receive[0]})
        2'b01:
        begin
            traveler_in_front_of_target_machine <= data_receive[2];
            traveler_has_item_in_hand <= data_receive[3];
            target_machine_is_processing <= data_receive[4];
            target_machine_has_item <= data_receive[5];
        end
        endcase
    end
end
endmodule