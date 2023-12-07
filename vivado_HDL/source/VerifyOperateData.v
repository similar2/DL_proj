`include "Define.v"
module VerifyIfOperateDataCorrect(
    input clk,
    input [7:0] GameStateChangeData,    // data of game state
    input [7:0] OriginOperateData,      // data of origin operate
    input [7:0] TargetMachine,          // data of target machine
    input InFrontOfTargetMachine,       // feedback of player if in front of machine
    input HasItemInHand,                // feedback of if has item in player's hand
    input TargetMachineIsProcessing,    // feedback of if Machine processing
    input TargetMachineHasItem,         // feedback of if Machine has item
    output reg [7:0] VerifiedOperateData = 0,   // return operate data after verify
    output reg [2:0] CompleteCusineNum = 0      // return how many cussine finish
);



// variable to memory What cusine is in player's hand
reg [5:0] ItemInHand = NULL;

// variable to analyse number of machine
wire [4:0] MachineNumber;
assign MachineNumber = TargetMachine[6:2];

// 2D array to store every machine status
reg [4:0] StoreNums [19:0][3:0];

// inital 2D array when game stop
reg NeedInital = TRUE , i = ZERO, j = ZERO;

always @(GameStateChangeData) begin
    if(GameStateChangeData == GAME_STOP) begin
        NeedInital = TRUE;
        CompleteCusineNum = ZERO;
    end
end

always @(posedge clk) begin
    if(NeedInital == TRUE) begin
        StoreNums[i][j] <= 5'b00000;
        if( j == 20 && i == 4 ) begin
           NeedInital = FALSE;
        end else begin
            if( j == 4 ) begin
                i <= i + 1;
                j <= 0;
            end else begin
                j <= j + 1;
        end 
        end
    end 
end



// verify if operate is legal
always @(OriginOperateData) begin
    if(InFrontOfTargetMachine) begin


        
        // Nothing But Want to Put
        if(OriginOperateData == OPERATE_PUT && !HasItemInHand)
            VerifiedOperateData = OPERATE_IGNORE;
        // Has Thing But Want to Get
        else if(OriginOperateData == OPERATE_GET && HasItemInHand) 
            VerifiedOperateData = OPERATE_IGNORE;
        // Machine Does Not Have Item But Want To Get
        else if(OriginOperateData == OPERATE_GET && !TargetMachineHasItem)
            VerifiedOperateData = OPERATE_IGNORE;

        // Storage Crate
        else if(MachineNumber>=1 && MachineNumber <= 6) begin
            if(OriginOperateData == OPERATE_THROW || OriginOperateData == OPERATE_PUT)
            VerifiedOperateData = OPERATE_IGNORE;
            else begin
                ItemInHand = MachineNumber;
                VerifiedOperateData = OriginOperateData;
            end
        end

        // Table
        else if(MachineNumber == TABLE_9 || MachineNumber == TABLE_11 || MachineNumber == TABLE_14 || MachineNumber == TABLE_17 || MachineNumber == TABLE_19) begin
            if(OriginOperateData == OPERATE_GET) begin
                if(StoreNums[MachineNumber][ITEM_NUM] > MIN_ITEM_NUM) begin
                    ItemInHand = StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]];
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = NULL;
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] - 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            end else if(OriginOperateData == OPERATE_THROW || OriginOperateData == OPERATE_PUT) begin
                if(StoreNums[MachineNumber][ITEM_NUM] < MAX_ITEM_NUM) begin
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] + 1;
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = ItemInHand;
                    ItemInHand = NULL;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            end else begin
                VerifiedOperateData = OriginOperateData;
            end
        end

        // Stone Mill and Cutting Machine 
        else if(MachineNumber == STONE_MILL_7 || MachineNumber == CUTTING_MACHINE_8) begin
            // throw
            if(OriginOperateData == OPERATE_THROW)
                VerifiedOperateData = OPERATE_IGNORE;
            // get
            else if(OriginOperateData == OPERATE_GET) begin
                if(TargetMachineHasItem) begin
                    ItemInHand = StoreNums[MachineNumber][FIRST_ITEM];
                    StoreNums[MachineNumber][FIRST_ITEM] = NULL;
                    VerifiedOperateData = OriginOperateData;
                end else begin
                    VerifiedOperateData = OPERATE_IGNORE;
                end
            // put
            end else if(OriginOperateData == OPERATE_PUT) begin
                if(TargetMachineHasItem) begin
                    VerifiedOperateData = OPERATE_IGNORE;
                end else begin
                    StoreNums[MachineNumber][FIRST_ITEM] = ItemInHand;
                    ItemInHand = NULL;
                    VerifiedOperateData = OriginOperateData;
                end
            // interact
            end else if(OriginOperateData == OPERATE_INTERACT) begin
                if(StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT) begin
                    StoreNums[MachineNumber][FIRST_ITEM] = SLICED_MEAT;
                end else if(StoreNums[MachineNumber][FIRST_ITEM] == WHEAT) begin
                    StoreNums[MachineNumber][FIRST_ITEM] = FLOUR;
                end else if(StoreNums[MachineNumber][FIRST_ITEM] == SWEET_FLOWER) begin
                    StoreNums[MachineNumber][FIRST_ITEM] = SUGAR;
                end else if(StoreNums[MachineNumber][FIRST_ITEM] == JUEYUN_CHILI) begin
                    StoreNums[MachineNumber][FIRST_ITEM] = SPICE;
                end else if(StoreNums[MachineNumber][FIRST_ITEM] == SLICED_MEAT) begin
                    StoreNums[MachineNumber][FIRST_ITEM] = SAUSAGE;
                end else
                    StoreNums[MachineNumber][FIRST_ITEM] = StoreNums[MachineNumber][FIRST_ITEM];
                VerifiedOperateData = OriginOperateData;
            end    
        end

        // Workbench and Mixer
        else if(MachineNumber == WORKBENCH_15 || MachineNumber == MIXER_16) begin
            // throw
            if(OriginOperateData == OPERATE_THROW)
                VerifiedOperateData = OriginOperateData;
            // get
            else if(OriginOperateData == OPERATE_GET) begin
                 if(StoreNums[MachineNumber][ITEM_NUM] > MIN_ITEM_NUM) begin
                    ItemInHand = StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]];
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = NULL;
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] - 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            // put
            end else if(OriginOperateData == OPERATE_PUT) begin
                 if(StoreNums[MachineNumber][ITEM_NUM] < MAX_ITEM_NUM) begin
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] + 1;
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = ItemInHand;
                    ItemInHand = NULL;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            // interact
            end else if(OriginOperateData == OPERATE_INTERACT) begin
                if((StoreNums[MachineNumber][ITEM_NUM] == TWO )&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SALT)||(StoreNums[MachineNumber][SECOND_ITEM] == SALT))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SLICED_MEAT)||(StoreNums[MachineNumber][SECOND_ITEM] == SLICED_MEAT))) begin
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = HAM;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                end else if((StoreNums[MachineNumber][ITEM_NUM] == THREE )&&
                    ((StoreNums[MachineNumber][FIRST_ITEM] == FLOUR)||(StoreNums[MachineNumber][SECOND_ITEM] == FLOUR)||(StoreNums[MachineNumber][THIRD_ITEM] == FLOUR))&&
                    ((StoreNums[MachineNumber][FIRST_ITEM] == SALT)&&(StoreNums[MachineNumber][SECOND_ITEM] == SALT)&&(StoreNums[MachineNumber][THIRD_ITEM] == SALT))&&
                    ((StoreNums[MachineNumber][FIRST_ITEM] == SPICE)&&(StoreNums[MachineNumber][SECOND_ITEM] ==  SPICE)&&(StoreNums[MachineNumber][THIRD_ITEM] ==  SPICE))
                    ) begin
                    StoreNums[MachineNumber][THIRD_ITEM] = NULL;
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = CUMIN;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                end
            end
        end

        // Oven
        else if(MachineNumber == OVEN_12 || MachineNumber == OVEN_13) begin
            // throw
            if(OriginOperateData == OPERATE_THROW) begin
                VerifiedOperateData = OPERATE_IGNORE;
            // get
            end else if(OriginOperateData == OPERATE_GET) begin
                if(StoreNums[MachineNumber][ITEM_NUM] > MIN_ITEM_NUM) begin
                    ItemInHand = StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]];
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = NULL;
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] - 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            // put
            end else if(OriginOperateData == OPERATE_PUT) begin
                if(StoreNums[MachineNumber][ITEM_NUM] < MAX_ITEM_NUM) begin
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] + 1;
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = ItemInHand;
                    ItemInHand = NULL;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            // interact
            end else if(OriginOperateData == OPERATE_INTERACT) begin
                // Make Sweet Madame
                if((StoreNums[MachineNumber][ITEM_NUM] == TWO)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT) || StoreNums[MachineNumber][SECOND_ITEM] == RAW_MEAT)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SWEET_FLOWER || StoreNums[MachineNumber][SECOND_ITEM] == SWEET_FLOWER))
                ) begin
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = SWEET_MADAME;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                // Make Chili Chicken
                end else if((StoreNums[MachineNumber][ITEM_NUM] == THREE)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SPICE)||(StoreNums[MachineNumber][SECOND_ITEM] == SPICE)||(StoreNums[MachineNumber][THIRD_ITEM] == SPICE))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][SECOND_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][THIRD_ITEM] == RAW_MEAT))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == JUEYUN_CHILI)||(StoreNums[MachineNumber][SECOND_ITEM] == JUEYUN_CHILI)||(StoreNums[MachineNumber][THIRD_ITEM] == JUEYUN_CHILI))
                ) begin
                    StoreNums[MachineNumber][THIRD_ITEM] = NULL;
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = CHILI_CHICKEN;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                // Make Berry Miss Manjuu	
                end else if((StoreNums[MachineNumber][ITEM_NUM] == THREE)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SUGAR)||(StoreNums[MachineNumber][SECOND_ITEM] == SUGAR)||(StoreNums[MachineNumber][THIRD_ITEM] == SUGAR))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == BERRY)||(StoreNums[MachineNumber][SECOND_ITEM] == BERRY)||(StoreNums[MachineNumber][THIRD_ITEM] == BERRY))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == FLOUR)||(StoreNums[MachineNumber][SECOND_ITEM] == FLOUR)||(StoreNums[MachineNumber][THIRD_ITEM] == FLOUR))
                ) begin
                    StoreNums[MachineNumber][THIRD_ITEM] = NULL;
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = BERRY_MISS_MANJUU;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                // Make Cold Cut Platter
                end else if((StoreNums[MachineNumber][ITEM_NUM] == TWO)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SLICED_MEAT) || StoreNums[MachineNumber][SECOND_ITEM] == SLICED_MEAT)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == CUMIN || StoreNums[MachineNumber][SECOND_ITEM] == CUMIN))
                ) begin
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = COLD_CUT_PLATTER;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                // Make Sticky Honey Roast
                end else if((StoreNums[MachineNumber][ITEM_NUM] == THREE)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SUGAR)||(StoreNums[MachineNumber][SECOND_ITEM] == SUGAR)||(StoreNums[MachineNumber][THIRD_ITEM] == SUGAR))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][SECOND_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][THIRD_ITEM] == RAW_MEAT))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == HAM)||(StoreNums[MachineNumber][SECOND_ITEM] == HAM)||(StoreNums[MachineNumber][THIRD_ITEM] == HAM))
                ) begin
                    StoreNums[MachineNumber][THIRD_ITEM] = NULL;
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = STICKY_HONEY_ROAST;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                end else if((StoreNums[MachineNumber][ITEM_NUM] == ONE)&&
                (StoreNums[MachineNumber][FIRST_ITEM] >= CUSINE_START_INDEX && StoreNums[MachineNumber][FIRST_ITEM] <= CUSINE_END_INDEX)
                ) begin
                    StoreNums[MachineNumber][FIRST_ITEM] = BAD_CUSINE;
                end
            end 
        end


        // Stove
        else if(MachineNumber == STOVE_10) begin
            // throw
            if(OriginOperateData == OPERATE_THROW) begin
                VerifiedOperateData = OPERATE_IGNORE;
            // get
            end else if(OriginOperateData == OPERATE_GET) begin
                if(StoreNums[MachineNumber][ITEM_NUM] > MIN_ITEM_NUM) begin
                    ItemInHand = StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]];
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = NULL;
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] - 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            // put
            end else if(OriginOperateData == OPERATE_PUT) begin
                if(StoreNums[MachineNumber][ITEM_NUM] < MAX_ITEM_NUM) begin
                    StoreNums[MachineNumber][ITEM_NUM] = StoreNums[MachineNumber][ITEM_NUM] + 1;
                    StoreNums[MachineNumber][StoreNums[MachineNumber][ITEM_NUM]] = ItemInHand;
                    ItemInHand = NULL;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            // interact
            end else if(OriginOperateData == OPERATE_INTERACT) begin
                // Make Sweet Madame
                if(((StoreNums[MachineNumber][ITEM_NUM] == TWO)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT) || StoreNums[MachineNumber][SECOND_ITEM] == RAW_MEAT)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SWEET_FLOWER || StoreNums[MachineNumber][SECOND_ITEM] == SWEET_FLOWER))
                )||
                // Make Chili Chicken
                ((StoreNums[MachineNumber][ITEM_NUM] == THREE)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SPICE)||(StoreNums[MachineNumber][SECOND_ITEM] == SPICE)||(StoreNums[MachineNumber][THIRD_ITEM] == SPICE))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][SECOND_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][THIRD_ITEM] == RAW_MEAT))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == JUEYUN_CHILI)||(StoreNums[MachineNumber][SECOND_ITEM] == JUEYUN_CHILI)||(StoreNums[MachineNumber][THIRD_ITEM] == JUEYUN_CHILI))
                )||
                // Make Berry Miss Manjuu	
                ((StoreNums[MachineNumber][ITEM_NUM] == THREE)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SUGAR)||(StoreNums[MachineNumber][SECOND_ITEM] == SUGAR)||(StoreNums[MachineNumber][THIRD_ITEM] == SUGAR))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == BERRY)||(StoreNums[MachineNumber][SECOND_ITEM] == BERRY)||(StoreNums[MachineNumber][THIRD_ITEM] == BERRY))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == FLOUR)||(StoreNums[MachineNumber][SECOND_ITEM] == FLOUR)||(StoreNums[MachineNumber][THIRD_ITEM] == FLOUR))
                ) ||
                // Make Cold Cut Platter
                ((StoreNums[MachineNumber][ITEM_NUM] == TWO)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SLICED_MEAT) || StoreNums[MachineNumber][SECOND_ITEM] == SLICED_MEAT)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == CUMIN || StoreNums[MachineNumber][SECOND_ITEM] == CUMIN))
                ) ||
                // Make Sticky Honey Roast
                ((StoreNums[MachineNumber][ITEM_NUM] == THREE)&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == SUGAR)||(StoreNums[MachineNumber][SECOND_ITEM] == SUGAR)||(StoreNums[MachineNumber][THIRD_ITEM] == SUGAR))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][SECOND_ITEM] == RAW_MEAT)||(StoreNums[MachineNumber][THIRD_ITEM] == RAW_MEAT))&&
                ((StoreNums[MachineNumber][FIRST_ITEM] == HAM)||(StoreNums[MachineNumber][SECOND_ITEM] == HAM)||(StoreNums[MachineNumber][THIRD_ITEM] == HAM))
                ) ||
                ((StoreNums[MachineNumber][ITEM_NUM] == ONE)&&
                (StoreNums[MachineNumber][FIRST_ITEM] >= CUSINE_START_INDEX && StoreNums[MachineNumber][FIRST_ITEM] <= CUSINE_END_INDEX)
                )) begin
                    StoreNums[MachineNumber][THIRD_ITEM] = NULL;
                    StoreNums[MachineNumber][SECOND_ITEM] = NULL;
                    StoreNums[MachineNumber][FIRST_ITEM] = BAD_CUSINE;
                    StoreNums[MachineNumber][ITEM_NUM] = ONE;
                end
            end 
        end

        // TrashBin
        else if(MachineNumber == TRASH_BIN_20) begin
            if(OriginOperateData == OPERATE_GET || OriginOperateData == OPERATE_INTERACT) begin
                VerifiedOperateData = OPERATE_IGNORE;
            end else if(OriginOperateData == OPERATE_PUT || OriginOperateData == OPERATE_THROW) begin
                ItemInHand = NULL;
                VerifiedOperateData = OriginOperateData;
            end
        end

        // Customs
        else if(MachineNumber == CUSTOMER_18) begin
            if(OriginOperateData == OPERATE_GET || OriginOperateData == OPERATE_THROW || OriginOperateData == OPERATE_INTERACT) begin
                VerifiedOperateData = OPERATE_IGNORE;
            end else if(OriginOperateData == OPERATE_PUT) begin
                if(ItemInHand >= CUSINE_START_INDEX && ItemInHand <= CUSINE_END_INDEX) begin
                    CompleteCusineNum = CompleteCusineNum + 1;
                    ItemInHand = NULL;
                end
            end
        end

    end else begin
        VerifiedOperateData = OPERATE_IGNORE;
    end
end

endmodule