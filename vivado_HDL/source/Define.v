bool constant
parameter TRUE = 1 , FALSE = 0;

int constant
parameter ZERO = 0 , ONE = 1 , TWO = 2 , THREE = 3;

// anti-shake constant
parameter ANTISHAKECNT = 5000000;   

// data of game state
parameter GAME_START = 8'bxxxx_01_01 , GAME_STOP = 8'bxxxx_10_01;  

// data of operate
parameter OPERATE_GET = 8'bx_00001_10 , OPERATE_PUT = 8'bx_00010_10 , OPERATE_INTERACT = 8'bx_00100_10 , OPERATE_MOVE = 8'bx_01000_10 , OPERATE_THROW = 8'bx_10000_10 , OPERATE_IGNORE = 8'bx_00000_10;


// things index
parameter NULL = 0, 
          SWEET_FLOWER = 1, WHEAT = 2, JUEYUN_CHILI = 3, RAW_MEAT = 4, BERRY = 5, SALT = 6,
          HAM = 7, SPICE = 8, FLOUR = 9, SLICED_MEAT = 10, SUGAR = 11, CUMIN = 12,
          SAUSAGE = 13, SWEET_MADAME = 14, CHILI_CHICKEN = 15, BERRY_MISS_MANJUU = 16, COLD_CUT_PLATTER = 17, STICKY_HONEY_ROAST = 18,
          BAD_CUSINE = 19;

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




