// `include "Define.v"
module VerifyIfOperateDataCorrect(
    input clk,
    input [7:0] GameStateChangeData,    // data of game state
    input [7:0] OriginOperateData,      // data of origin operate
    input [7:0] TargetMachine,          // data of target machine
    input InFrontOfTargetMachine,       // feedback of player if in front of machine
    input HasItemInHand,                // feedback of if has item in player's hand
    input TargetMachineIsProcessing,    // feedback of if Machine processing
    input TargetMachineHasItem,         // feedback of if Machine has item
    output reg [7:0] VerifiedOperateData = OPERATE_IGNORE,   // return operate data after verify
    output reg [2:0] CompleteCusineNum = 0,      // return how many cussine finish
    output reg [7:0] led = 0
);


// variable to memory What cusine is in player's hand
reg [5:0] ItemInHand = NULL;

// Stone Mill -- 7
reg [5:0] item_7 = NULL;


// variable to analyse number of machine
wire [4:0] MachineNumber;
assign MachineNumber = TargetMachine[6:2];

parameter FALSE = 0 , TRUE = 1;

// data of game state
parameter GAME_STATE_STOP = 2'b10;

// data of operate
parameter OPERATE_GET = 8'b1_00001_10 , OPERATE_PUT = 8'b1_00010_10 , OPERATE_INTERACT = 8'b1_00100_10 , OPERATE_MOVE = 8'b1_01000_10 , OPERATE_THROW = 8'b1_10000_10 , OPERATE_IGNORE = 8'b1_00000_10;

// index of machine
parameter STORAGE_BEGIN = 1 , STORAGE_END = 6;
parameter STONE_MILL_7 = 7;
parameter CUTTING_MACHINE_8 = 8;
parameter TABLE_9 = 9 , TABLE_11 = 11 , TABLE_14 = 14 , TABLE_17 = 17 , TABLE_19 = 19;
parameter STOVE_10 = 10;
parameter OVEN_12 = 12 , OVEN_13 = 13;
parameter WORKBENCH_15 = 15;
parameter MIXER_16 = 16;
parameter CUSTOMER_18 = 18;
parameter TRASH_BIN_20 = 20;


// things index
parameter NULL = 0, 
          SWEET_FLOWER = 1, WHEAT = 2, JUEYUN_CHILI = 3, RAW_MEAT = 4, BERRY = 5, SALT = 6,
          HAM = 7, SPICE = 8, FLOUR = 9, SLICED_MEAT = 10, SUGAR = 11, CUMIN = 12,
          SAUSAGE = 13, SWEET_MADAME = 14, CHILI_CHICKEN = 15, BERRY_MISS_MANJUU = 16, COLD_CUT_PLATTER = 17, STICKY_HONEY_ROAST = 18,
          BAD_CUSINE = 19;

reg [7:0] OperateData = 0;

// always @(OperateData) begin
//     led[5:0] = item_7;

//     if(OperateData == OPERATE_IGNORE) begin
//         VerifiedOperateData = OPERATE_IGNORE;

//     // Game Not Start
//     end else if(GameStateChangeData[3:2] == GAME_STATE_STOP) begin
//         VerifiedOperateData = OPERATE_IGNORE;

//     end else if(OperateData != OPERATE_MOVE && !InFrontOfTargetMachine) begin
//         VerifiedOperateData = OPERATE_IGNORE;

//     end else if(OperateData == OPERATE_PUT && !HasItemInHand) begin
//             VerifiedOperateData = OPERATE_IGNORE;
    
//     end else if(OperateData == OPERATE_GET && (HasItemInHand || !TargetMachineHasItem)) begin
//             VerifiedOperateData = OPERATE_IGNORE;

//     end else begin
                
//         // Storages
//         if(MachineNumber >= STORAGE_BEGIN && MachineNumber <= STORAGE_END) begin
//             if(OperateData == OPERATE_PUT || OperateData == OPERATE_THROW || OperateData == OPERATE_INTERACT) begin
//                 VerifiedOperateData = OPERATE_IGNORE;
//             end else if(OperateData == OPERATE_GET) begin
//                 if(!HasItemInHand) begin
//                     ItemInHand = MachineNumber;
//                     VerifiedOperateData = OperateData;
//                 end else begin
//                     VerifiedOperateData = OPERATE_IGNORE;
//                 end
//             end else begin
//                 VerifiedOperateData = OperateData;
//             end
//         end

//         // Stone Mill -- 7
//         else if(MachineNumber == STONE_MILL_7) begin
//             // throw
//             if(OperateData == OPERATE_THROW) begin
//                 VerifiedOperateData = OPERATE_IGNORE;
//             // put
//             end else if(OperateData == OPERATE_PUT) begin
//                 if(item_7 == NULL && ItemInHand != NULL) begin
//                     VerifiedOperateData = OPERATE_PUT;
//                     item_7 = ItemInHand;
//                     led[6] = 1;
//                     ItemInHand = NULL;
//                 end else begin
//                     led[7] = 1;
//                     VerifiedOperateData = OPERATE_IGNORE;
//                 end
//             // get
//             end else if(OperateData == OPERATE_GET) begin
//                 if(item_7 != NULL && ItemInHand == NULL) begin
//                     ItemInHand = item_7;
//                     item_7 = NULL;
//                     VerifiedOperateData = OPERATE_GET;
//                 end else begin
//                     VerifiedOperateData = OPERATE_IGNORE;
//                 end
//             // interact
//             end else if(OperateData == OPERATE_INTERACT) begin
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
//                     VerifiedOperateData = OperateData;
//             // move
//             end else if(OperateData == OPERATE_MOVE) begin
//                 VerifiedOperateData = OperateData;
//             end
//         end
        
//         // Normal Situation
//         else
//         VerifiedOperateData = OPERATE_IGNORE;
//     end
 
// end

always @(OperateData) begin

    // Game Not Start
    if(GameStateChangeData[3:2] == GAME_STATE_STOP) begin
        VerifiedOperateData = OPERATE_IGNORE;

    end else if(OperateData != OPERATE_MOVE && !InFrontOfTargetMachine) begin
        VerifiedOperateData = OPERATE_IGNORE;

    end else begin
                
        // Storages
        if(MachineNumber >= STORAGE_BEGIN && MachineNumber <= STORAGE_END) begin
            if(OperateData == OPERATE_PUT || OperateData == OPERATE_THROW || OperateData == OPERATE_INTERACT) begin
                VerifiedOperateData = OPERATE_IGNORE;
            end else if(OperateData == OPERATE_GET) begin
                if(!HasItemInHand) begin
                    VerifiedOperateData = OperateData;
                end else begin
                    VerifiedOperateData = OPERATE_IGNORE;
                end
            end else begin
                VerifiedOperateData = OperateData;
            end
        end

        // Stone Mill -- 7
        else if(MachineNumber == STONE_MILL_7 || MachineNumber == CUTTING_MACHINE_8) begin
            // throw
            if(OperateData == OPERATE_THROW) begin
                VerifiedOperateData = OPERATE_IGNORE;
            // put
            end else if(OperateData == OPERATE_PUT) begin
                if(HasItemInHand && !TargetMachineHasItem) begin
                    VerifiedOperateData = OPERATE_PUT;
                end else begin
                    VerifiedOperateData = OPERATE_IGNORE;
                end
            // get
            end else if(OperateData == OPERATE_GET) begin
                if(!HasItemInHand && TargetMachineHasItem) begin
                    VerifiedOperateData = OPERATE_GET;
                end else begin
                    VerifiedOperateData = OPERATE_IGNORE;
                end
            // interact
            end else begin
                VerifiedOperateData = OriginOperateData;
            end
        end

        else if(MachineNumber == TABLE_9 || MachineNumber == TABLE_11 || MachineNumber == TABLE_14 || MachineNumber == TABLE_17 || MachineNumber == TABLE_19 || MachineNumber == TRASH_BIN_20) begin
            case(OriginOperateData)
            OPERATE_THROW , OPERATE_PUT: begin
                case(HasItemInHand)
                TRUE:VerifiedOperateData = OriginOperateData;
                default:VerifiedOperateData = OPERATE_IGNORE;
                endcase
            end
            OPERATE_GET: begin
                case({HasItemInHand,TargetMachineHasItem})
                {FALSE,TRUE}:VerifiedOperateData = OriginOperateData;
                default:VerifiedOperateData = OPERATE_IGNORE;
                endcase
            end
            default:VerifiedOperateData = OriginOperateData;
            endcase
        end

        else if(MachineNumber == WORKBENCH_15 || MachineNumber == MIXER_16 || MachineNumber == STOVE_10 || MachineNumber == OVEN_12 || MachineNumber == OVEN_13) begin
            case(OriginOperateData)
            OPERATE_THROW:VerifiedOperateData = OPERATE_IGNORE;
            OPERATE_PUT: begin
                case(HasItemInHand)
                TRUE:VerifiedOperateData = OriginOperateData;
                default:VerifiedOperateData = OPERATE_IGNORE;
                endcase
            end
            OPERATE_GET: begin
                case({HasItemInHand,TargetMachineHasItem})
                {FALSE,TRUE}:VerifiedOperateData = OriginOperateData;
                default:VerifiedOperateData = OPERATE_IGNORE;
                endcase
            end
            default:VerifiedOperateData = OriginOperateData;
            endcase
        end

        else if(MachineNumber == CUSTOMER_18) begin
            OPERATE_GET , OPERATE_THROW , OPERATE_INTERACT: OriginOperateData = OPERATE_IGNORE;
            OPERATE_PUT: begin
                case(HasItemInHand)
                TRUE:VerifiedOperateData = OriginOperateData;
                default:VerifiedOperateData = OPERATE_IGNORE;
                endcase
            end
            default : VerifiedOperateData = OriginOperateData;
        end


        
        // Normal Situation
        else
        VerifiedOperateData = OPERATE_IGNORE;
    end
 
end


endmodule