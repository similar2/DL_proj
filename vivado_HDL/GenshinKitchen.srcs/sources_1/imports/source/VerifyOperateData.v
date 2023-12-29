module VerifyIfOperateDataCorrect(
    input uart_clk,
    input [7:0] data_game_state,    // data of game state
    input [7:0] data_operate,      // data of origin operate
    input [7:0] data_target,          // data of target machine
    input sig_front,       // feedback of player if in front of machine
    input sig_hand,                // feedback of if has item in player's hand
    input sig_processing,    // feedback of if Machine processing
    input sig_machine,         // feedback of if Machine has item
    output reg [7:0] data_operate_verified = OPERATE_IGNORE,   // return operate data after verify
    output reg [2:0] data_cusine_finish_num = 0,      // return how many cussine finish
    output reg [7:0] test_led = 0
);


// variable to memory What cusine is in player's hand
reg [5:0] hand_item = NULL;

// Stone Mill -- 7
reg [5:0] item_7 = NULL;


// variable to analyse number of machine
wire [4:0] target;
assign target = data_target[6:2];


// always @(data_operate) begin
//     led[5:0] = item_7;

//     if(data_operate == OPERATE_IGNORE) begin
//         data_operate_verified = OPERATE_IGNORE;

//     // Game Not Start
//     end else if(data_game_state[3:2] == GAME_STATE_STOP) begin
//         data_operate_verified = OPERATE_IGNORE;

//     end else if(data_operate != OPERATE_MOVE && !sig_front) begin
//         data_operate_verified = OPERATE_IGNORE;

//     end else if(data_operate == OPERATE_PUT && !sig_hand) begin
//             data_operate_verified = OPERATE_IGNORE;
    
//     end else if(data_operate == OPERATE_GET && (sig_hand || !sig_machine)) begin
//             data_operate_verified = OPERATE_IGNORE;

//     end else begin
                
//         // Storages
//         if(target >= STORAGE_BEGIN && target <= STORAGE_END) begin
//             if(data_operate == OPERATE_PUT || data_operate == OPERATE_THROW || data_operate == OPERATE_INTERACT) begin
//                 data_operate_verified = OPERATE_IGNORE;
//             end else if(data_operate == OPERATE_GET) begin
//                 if(!sig_hand) begin
//                     hand_item = target;
//                     data_operate_verified = data_operate;
//                 end else begin
//                     data_operate_verified = OPERATE_IGNORE;
//                 end
//             end else begin
//                 data_operate_verified = data_operate;
//             end
//         end

//         // Stone Mill -- 7
//         else if(target == STONE_MILL_7) begin
//             // throw
//             if(data_operate == OPERATE_THROW) begin
//                 data_operate_verified = OPERATE_IGNORE;
//             // put
//             end else if(data_operate == OPERATE_PUT) begin
//                 if(item_7 == NULL && hand_item != NULL) begin
//                     data_operate_verified = OPERATE_PUT;
//                     item_7 = hand_item;
//                     led[6] = 1;
//                     hand_item = NULL;
//                 end else begin
//                     led[7] = 1;
//                     data_operate_verified = OPERATE_IGNORE;
//                 end
//             // get
//             end else if(data_operate == OPERATE_GET) begin
//                 if(item_7 != NULL && hand_item == NULL) begin
//                     hand_item = item_7;
//                     item_7 = NULL;
//                     data_operate_verified = OPERATE_GET;
//                 end else begin
//                     data_operate_verified = OPERATE_IGNORE;
//                 end
//             // interact
//             end else if(data_operate == OPERATE_INTERACT) begin
//                 if(item_7 != NULL) begin
//                     if(item_7 == RAW_MEAT) begin
//                         item_7 = SLICED_MEAT;
//                     end else if(item_7 == JUEYUN_CHILI) begin
//                         item_7 = SPICE;
//                     end else if(item_7 == WHEAT) begin
//                         item_7 = FLOUR;
//                     end else if(item_7 == SWEET_FLOWER) begin
//                         item_7 = SUGAR;
//                     end else if(item_7 == SLICED_MEAT) begin
//                         item_7 = SAUSAGE;
//                     end
//                 end
//                     data_operate_verified = data_operate;
//             // move
//             end else if(data_operate == OPERATE_MOVE) begin
//                 data_operate_verified = data_operate;
//             end
//         end
        
//         // Normal Situation
//         else
//         data_operate_verified = OPERATE_IGNORE;
//     end
 
// end

always @(data_operate) begin

    // Game Not Start
    if(data_game_state[3:2] == GAME_STATE_STOP) begin
        data_operate_verified = OPERATE_IGNORE;

    end else if(data_operate != OPERATE_MOVE && !sig_front) begin
        data_operate_verified = OPERATE_IGNORE;

    end else begin
                
        // Storages
        if(target >= STORAGE_BEGIN && target <= STORAGE_END) begin
            if(data_operate == OPERATE_PUT || data_operate == OPERATE_THROW || data_operate == OPERATE_INTERACT) begin
                data_operate_verified = OPERATE_IGNORE;
            end else if(data_operate == OPERATE_GET) begin
                if(!sig_hand) begin
                    data_operate_verified = data_operate;
                end else begin
                    data_operate_verified = OPERATE_IGNORE;
                end
            end else begin
                data_operate_verified = data_operate;
            end
        end

        // Stone Mill -- 7
        else if(target == STONE_MILL_7 || target == CUTTING_MACHINE_8) begin
            // throw
            if(data_operate == OPERATE_THROW) begin
                data_operate_verified = OPERATE_IGNORE;
            // put
            end else if(data_operate == OPERATE_PUT) begin
                if(sig_hand && !sig_machine) begin
                    data_operate_verified = OPERATE_PUT;
                end else begin
                    data_operate_verified = OPERATE_IGNORE;
                end
            // get
            end else if(data_operate == OPERATE_GET) begin
                if(!sig_hand && sig_machine) begin
                    data_operate_verified = OPERATE_GET;
                end else begin
                    data_operate_verified = OPERATE_IGNORE;
                end
            // interact
            end else begin
                data_operate_verified = data_operate;
            end
        end

        // Table And TrashBin
        else if(target == TABLE_9 || target == TABLE_11 || target == TABLE_14 || target == TABLE_17 || target == TABLE_19 || target == TRASH_BIN_20) begin
            case(data_operate)
            OPERATE_THROW , OPERATE_PUT: begin
                case(sig_hand)
                TRUE:data_operate_verified = data_operate;
                default:data_operate_verified = OPERATE_IGNORE;
                endcase
            end
            OPERATE_GET: begin
                case({sig_hand,sig_machine})
                {FALSE,TRUE}:data_operate_verified = data_operate;
                default:data_operate_verified = OPERATE_IGNORE;
                endcase
            end
            default:data_operate_verified = data_operate;
            endcase
        end

        // WorkBench , Stove , Mixer , Oven
        else if(target == WORKBENCH_15 || target == MIXER_16 || target == STOVE_10 || target == OVEN_12 || target == OVEN_13) begin
            case(data_operate)
            OPERATE_THROW:data_operate_verified = OPERATE_IGNORE;
            OPERATE_PUT: begin
                case(sig_hand)
                TRUE:data_operate_verified = data_operate;
                default:data_operate_verified = OPERATE_IGNORE;
                endcase
            end
            OPERATE_GET: begin
                case({sig_hand,sig_machine})
                {FALSE,TRUE}:data_operate_verified = data_operate;
                default:data_operate_verified = OPERATE_IGNORE;
                endcase
            end
            default:data_operate_verified = data_operate;
            endcase
        end

        // Custom
        else if(target == CUSTOMER_18) begin
            case(data_operate)
            OPERATE_GET , OPERATE_THROW , OPERATE_INTERACT: data_operate_verified = OPERATE_IGNORE;
            OPERATE_PUT: begin
                case(sig_hand)
                TRUE:data_operate_verified = data_operate;
                default:data_operate_verified = OPERATE_IGNORE;
                endcase
            end
            default : data_operate_verified = data_operate;
            endcase
        end


        
        // Normal Situation
        else
        data_operate_verified = OPERATE_IGNORE;
    end
 
end


endmodule