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
    output reg [7:0] VerifiedOperateData = 0,   // return operate data after verify
    output reg [2:0] CompleteCusineNum = 0      // return how many cussine finish
);

parameter RAM_READ = 0 , RAM_WRITE = 1;

reg RamStatus = RAM_READ;
wire [8:0] RamOut;
reg [8:0] RamIn;
reg [6:0] RamAddr;

RAM ram(.clka(clk),.addra(RamAddr),.dina(RamOut),.douta(RamOut),.wea(RamStatus));

// variable to memory What cusine is in player's hand
reg [5:0] ItemInHand = NULL;



reg [7:0] PrevOriginOperateData = 0;

// variable to analyse number of machine
wire [4:0] MachineNumber;
assign MachineNumber = TargetMachine[6:2];

reg [2:0] CusineNum;
reg [5:0] Cusine1;
reg [5:0] Cusine2;
reg [5:0] Cusine3;

parameter RAM_STORE_SIZE = 4;

reg [3:0] CurrentState = WAIT_DATA;
parameter WAIT_DATA = 0;
parameter READ_ITEM_NUM = 1;
parameter READ_CUSINE_1 = 2;
parameter READ_CUSINE_2 = 3;
parameter READ_CUSINE_3 = 4;
parameter VERIFY = 5;
parameter PREPARE_WRITE = 6;
parameter WRITE_CUSINE_NUM = 7;
parameter WRITE_CUSINE_1 = 8;
parameter WRITE_CUSINE_2 = 9;
parameter WRITE_CUSINE_3 = 10;
parameter END_WRITE = 11;


always @(posedge clk) begin

    if(CurrentState == WAIT_DATA) begin
        if(PrevOriginOperateData != OriginOperateData) begin
            PrevOriginOperateData <= OriginOperateData;
            CurrentState <= READ_ITEM_NUM;
            RamStatus <= RAM_READ;
            RamAddr <= MachineNumber * RAM_STORE_SIZE;
        end
    end else if(CurrentState == READ_ITEM_NUM) begin
        CusineNum <= RamOut[2:0];
        RamAddr <= RamAddr + 1;
        CurrentState <= READ_CUSINE_1;
    end else if(CurrentState == READ_CUSINE_1) begin
        Cusine1 <= RamOut[5:0];
        RamAddr <= RamAddr + 1;
        CurrentState <= READ_CUSINE_2;
    end else if(CurrentState == READ_CUSINE_2) begin
        Cusine2 <= RamOut[5:0];
        RamAddr <= RamAddr + 1;
        CurrentState <= READ_CUSINE_3;
    end else if(CurrentState == READ_CUSINE_3) begin
        Cusine3 <= RamOut[5:0];
        CurrentState <= VERIFY;
    end else if(CurrentState == VERIFY) begin


        if(OriginOperateData == OPERATE_PUT && !HasItemInHand) begin
            VerifiedOperateData <= OPERATE_IGNORE;
            CurrentState <= WAIT_DATA;
        end
            
        // Has Thing But Want to Get
        else if(OriginOperateData == OPERATE_GET && HasItemInHand) begin
            VerifiedOperateData <= OPERATE_IGNORE;
            CurrentState <= WAIT_DATA;
        end
            
        // Machine Does Not Have Item But Want To Get
        else if(OriginOperateData == OPERATE_GET && !TargetMachineHasItem) begin
            VerifiedOperateData <= OPERATE_IGNORE;
            CurrentState <= WAIT_DATA;
        end
            

        // Storage Crate
        else if(MachineNumber>= 1 && MachineNumber <= 6) begin
            if(OriginOperateData == OPERATE_THROW || OriginOperateData == OPERATE_PUT) begin
                VerifiedOperateData <= OPERATE_IGNORE;
                CurrentState <= WAIT_DATA;
            end else begin
                ItemInHand <= MachineNumber;
                VerifiedOperateData <= OriginOperateData;
                CurrentState <= WAIT_DATA;
            end
        end

        // Table
        else if(MachineNumber == TABLE_9 || MachineNumber == TABLE_11 || MachineNumber == TABLE_14 || MachineNumber == TABLE_17 || MachineNumber == TABLE_19) begin
            if(OriginOperateData == OPERATE_GET) begin
                if(CusineNum > MIN_ITEM_NUM) begin
                    VerifiedOperateData <= OriginOperateData;
                    CusineNum <= CusineNum - 1;
                    CurrentState <= PREPARE_WRITE;
                    case (CusineNum)
                        1: begin
                            ItemInHand <= Cusine1;
                            Cusine1 <= NULL;
                        end
                        2:begin
                            ItemInHand <= Cusine2;
                            Cusine2 <= NULL;
                        end
                        3:begin
                            ItemInHand <= Cusine3;
                            Cusine3 <= NULL; 
                        end
                    endcase
                end else begin
                    VerifiedOperateData <= OPERATE_IGNORE;
                    CurrentState <= WAIT_DATA;
                end
            end else if(OriginOperateData == OPERATE_THROW || OriginOperateData == OPERATE_PUT) begin
                if(CusineNum < MAX_ITEM_NUM) begin
                    VerifiedOperateData <= OriginOperateData;
                    CusineNum <= CusineNum + 1;
                    ItemInHand<=NULL;
                    CurrentState <= PREPARE_WRITE;
                    case (CusineNum)
                        0:Cusine1 <= ItemInHand; 
                        1:Cusine2 <= ItemInHand; 
                        2:Cusine3 <= ItemInHand; 
                    endcase   
                end else begin
                    VerifiedOperateData <= OPERATE_IGNORE;
                    CurrentState <= WAIT_DATA;
                end    
            end else begin
                VerifiedOperateData <= OriginOperateData;
                CurrentState <= WAIT_DATA;
            end
        end

    end else if(CurrentState == PREPARE_WRITE) begin 
        CurrentState <= WRITE_CUSINE_NUM;
    end else if(CurrentState == WRITE_CUSINE_NUM) begin
        RamStatus <= RAM_WRITE;
        RamAddr <= MachineNumber * RAM_STORE_SIZE;
        RamIn <= CusineNum;
        CurrentState <= WRITE_CUSINE_1;
    end else if(CurrentState == WRITE_CUSINE_1) begin
        RamAddr <= RamAddr + 1;
        RamIn <= Cusine1;
        CurrentState <= WRITE_CUSINE_2;
    end else if(CurrentState == WRITE_CUSINE_2) begin
        RamAddr <= RamAddr + 1;
        RamIn <= Cusine2;
        CurrentState <= WRITE_CUSINE_3;
    end else if(CurrentState ==WRITE_CUSINE_3) begin
        RamAddr <= RamAddr + 1;
        RamIn <= Cusine3;
        CurrentState <= END_WRITE;
    end else if(CurrentState == END_WRITE) begin
        RamAddr <= 0;
        RamStatus <= RAM_READ;
        CurrentState <= WAIT_DATA;
    end
        
end


endmodule