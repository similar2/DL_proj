// bool constant
parameter TRUE = 1 , FALSE = 0;
parameter  STORAGE_END = 6;

// int constant
parameter ZERO = 0 , ONE = 1 , TWO = 2 , THREE = 3;

// data of operate
parameter OPERATE_GET = 8'b1_00001_10 , OPERATE_PUT = 8'b1_00010_10 , OPERATE_INTERACT = 8'b1_00100_10 , OPERATE_MOVE = 8'b1_01000_10 , OPERATE_THROW = 8'b1_10000_10 , OPERATE_IGNORE = 8'b1_00000_10;

// data of game state
parameter GAME_START = 8'bxxxx_01_01 , GAME_STOP = 8'bxxxx_10_01;  

parameter PRESS_UP = 5'b10000 , PRESS_DOWN = 5'b01000 , PRESS_CENTER = 5'b00100 , PRESS_LEFT = 5'b00010 , PRESS_RIGHT = 5'b00001;

// anti-shake constant
parameter ANTISHAKECNT = 15000;


// start and end index of cusine
parameter CUSINE_START_INDEX = 13 , CUSINE_END_INDEX = 18;

// index of array in verify model
parameter ITEM_NUM = 0 ,FIRST_ITEM = 1 ,SECOND_ITEM = 2,THIRD_ITEM = 3;

// max item nums that machine can store
parameter MAX_ITEM_NUM = 3 , MIN_ITEM_NUM = 0;

// index of machine
parameter STORAGE_BEGIN = 1 , SOTRAGE_END = 6;
parameter STONE_MILL_7 = 7;
parameter CUTTING_MACHINE_8 = 8;
parameter TABLE_9 = 9 , TABLE_11 = 11 , TABLE_14 = 14 , TABLE_17 = 17 , TABLE_19 = 19;
parameter STOVE_10 = 10;
parameter OVEN_12 = 12 , OVEN_13 = 13;
parameter WORKBENCH_15 = 15;
parameter MIXER_16 = 16;
parameter CUSTOMER_18 = 18;
parameter TRASH_BIN_20 = 20;


//parameter for script

//jump script
parameter  enabled = 1'b1,disabled = 1'b0,action_code = 3'b001,jump_code =  3'b010,wait_code = 3'b011,game_code = 3'b100;

parameter if_mode = 2'b00, ifn_mode = 2'b01,
          player_ready = 3'd0, player_hasitem = 3'd1,
          target_ready = 3'd2, target_hasitem = 3'd3;


parameter DEBOUNCE_TIME = 1000000;  // Set the debounce time threshold
    parameter GET = 2'b00, PUT = 2'b01, INTERACT = 2'b10, THROW = 2'b11;
parameter ENABLED = 1'b1, DISABLED = 1'b0;

    // Operation codes
    parameter game_start = 2'b01, game_end = 2'b10;
parameter MAX = 15;
    
    parameter FEEDBACK = 2'b01;
    parameter UARTCNT = 325;
    parameter SECONDCNT = 50000000;
    parameter MILLISECONDCNT = 50000;

    
    // data of game state
    parameter GAME_STATE_STOP = 2'b10;
    

    
    parameter SELECT_DATA_IGNORE = 8'b000000_11;
    parameter SELECT_VALUE_MAX = 20;
    parameter CHANNEL_TARGET = 2'b11;

    parameter SEND_NULL = 2'b00 , SEND_GAMESTATE = 2'b01 , SEND_TARGET = 2'b10 , SEND_OPERATE = 2'b11;

    parameter waituntil_mode = 2'b01, wait_mode = 2'b00;

    // things index
    parameter NULL = 0, 
              SWEET_FLOWER = 1, WHEAT = 2, JUEYUN_CHILI = 3, RAW_MEAT = 4, BERRY = 5, SALT = 6,
              HAM = 7, SPICE = 8, FLOUR = 9, SLICED_MEAT = 10, SUGAR = 11, CUMIN = 12,
              SAUSAGE = 13, SWEET_MADAME = 14, CHILI_CHICKEN = 15, BERRY_MISS_MANJUU = 16, COLD_CUT_PLATTER = 17, STICKY_HONEY_ROAST = 18,
              BAD_CUSINE = 19;

