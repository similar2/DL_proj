module VerifyIfOperateDataCorrect(
    input [7:0] OriginOperateData,
    input [7:0] TargetMachine,
    input InFrontOfTargetMachine,
    input HasItemInHand,
    input TargetMachineIsProcessing,
    input TargetMachineHasItem,
    output reg [7:0] VerifiedOperateData
);

reg [3:0] StoreNums [19:0][2:0] = {{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000},{4'b0000,4'b0000,4'b0000}}; 

parameter OPERATE_GET = 8'bx_00001_10 , OPERATE_PUT = 8'bx_00010_10 , OPERATE_INTERACT = 8'bx_00100_10 , OPERATE_MOVE = 8'bx_01000_10 , OPERATE_THROW = 8'bx_10000_10 , OPERATE_IGNORE = 8'bx_00000_10;


parameter TABLE_9 = 9 , TABLE_11 = 11 , TABLE_14 = 14 , TABLE_17 = 17 , TABLE_19 = 19;
parameter STONE_MILL_7 = 7;
parameter CUTTING_MACHINE_8 = 8;
parameter WORKBENCH_15 = 15;


parameter MAX_ITEM_NUM = 3 , MIN_ITEM_NUM = 0;


wire [4:0] MachineNumber;
assign MachineNumber = TargetMachine[6:2];

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
            else 
            VerifiedOperateData = OriginOperateData;
        end

        // Table
        else if(MachineNumber == TABLE_9 || MachineNumber == TABLE_11 || MachineNumber == TABLE_14 || MachineNumber == TABLE_17 || MachineNumber == TABLE_19) begin
            if(OriginOperateData == OPERATE_GET) begin
                if(StoreNums[MachineNumber] > MIN_ITEM_NUM) begin
                    StoreNums[MachineNumber] = StoreNums[MachineNumber] - 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            end else if(OriginOperateData == OPERATE_THROW || OriginOperateData == OPERATE_PUT) begin
                if(StoreNums[MachineNumber] < MAX_ITEM_NUM) begin
                    StoreNums[MachineNumber] = StoreNums[MachineNumber] + 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            end else begin
                VerifiedOperateData = OriginOperateData;
            end
        end

        // Stone Mill and Cutting Machine 
        else if(MachineNumber == STONE_MILL_7 || MachineNumber == CUTTING_MACHINE_8) begin
            if(OriginOperateData == OPERATE_THROW)
                VerifiedOperateData = OPERATE_IGNORE;
            else if(OriginOperateData == OPERATE_GET) begin
                if(TargetMachineHasItem)
                    VerifiedOperateData = OriginOperateData;
                else
                    VerifiedOperateData = OPERATE_IGNORE;
            end else
                VerifiedOperateData = OriginOperateData;
        end

        // Workbench
        else if(MachineNumber == WORKBENCH_15) begin
            if(OriginOperateData == OPERATE_THROW)
                VerifiedOperateData = OriginOperateData;
            else if(OriginOperateData == OPERATE_GET) begin
                if(StoreNums[MachineNumber] > MIN_ITEM_NUM) begin
                    StoreNums[MachineNumber] = StoreNums[MachineNumber] - 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            end else if(OriginOperateData == OPERATE_PUT) begin
                if(StoreNums[MachineNumber] < MAX_ITEM_NUM) begin
                    StoreNums[MachineNumber] = StoreNums[MachineNumber] + 1;
                    VerifiedOperateData = OriginOperateData;
                end else
                    VerifiedOperateData = OPERATE_IGNORE;
            end
        end

    end else begin
        VerifiedOperateData = OPERATE_IGNORE;
    end
end

endmodule