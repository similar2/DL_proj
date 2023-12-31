module VerifyIfOperateDataCorrect(input uart_clk,
                                  input [7:0] data_game_state,                              // data of game state
                                  input [7:0] data_operate,                                 // data of origin operate
                                  input [7:0] data_target,                                  // data of target machine
                                  input sig_front,                                          // feedback of player if in front of machine
                                  input sig_hand,                                           // feedback of if has item in player's hand
                                  input sig_processing,                                     // feedback of if Machine processing
                                  input sig_machine,                                        // feedback of if Machine has item
                                  output reg [7:0] data_operate_verified = OPERATE_IGNORE); // return operate data after verify
    
    
    // variable to analyse number of machine
    wire [4:0] target;
    assign target = data_target[6:2];
    
    
    always @(data_operate) begin
        
        // Game Not Start
        if (data_game_state[3:2] == GAME_STATE_STOP) begin
            data_operate_verified = OPERATE_IGNORE;
            
            end else if (data_operate != OPERATE_MOVE && !sig_front) begin
            data_operate_verified = OPERATE_IGNORE;
            
            end else begin
            
            // Storages
            if (target >= STORAGE_BEGIN && target <= STORAGE_END) begin
                if (data_operate == OPERATE_PUT || data_operate == OPERATE_THROW || data_operate == OPERATE_INTERACT) begin
                    data_operate_verified = OPERATE_IGNORE;
                    end else if (data_operate == OPERATE_GET) begin
                    if (!sig_hand) begin
                        data_operate_verified = data_operate;
                        end else begin
                        data_operate_verified = OPERATE_IGNORE;
                    end
                    end else begin
                    data_operate_verified = data_operate;
                end
            end
            
            // Stone Mill -- 7
            else if (target == STONE_MILL_7 || target == CUTTING_MACHINE_8) begin
            // throw
            if (data_operate == OPERATE_THROW) begin
                data_operate_verified = OPERATE_IGNORE;
                // put
                end else if (data_operate == OPERATE_PUT) begin
                if (sig_hand && !sig_machine) begin
                    data_operate_verified = OPERATE_PUT;
                    end else begin
                    data_operate_verified = OPERATE_IGNORE;
                end
                // get
                end else if (data_operate == OPERATE_GET) begin
                if (!sig_hand && sig_machine) begin
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
        else if (target == TABLE_9 || target == TABLE_11 || target == TABLE_14 || target == TABLE_17 || target == TABLE_19 || target == TRASH_BIN_20) begin
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
    else if (target == WORKBENCH_15 || target == MIXER_16 || target == STOVE_10 || target == OVEN_12 || target == OVEN_13) begin
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
    else if (target == CUSTOMER_18) begin
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
