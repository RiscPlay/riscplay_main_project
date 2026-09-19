// ===========Oooo==========================================Oooo========

// =  Copyright (C) 2014-2016 Gowin Semiconductor Technology Co.,Ltd.

// =                     All rights reserved.

// =====================================================================

//

//  __      __      __

//  \ \    /  \    / /   [File name   ] sdrc_defines.v

//   \ \  / /\ \  / /    [Description ] SDRAM Controller

//    \ \/ /  \ \/ /     [Timestamp   ] Wednesday June 22 10:00:30 2016

//     \  /    \  /      [version     ] 1.0.0

//      \/      \/       

//

// ===========Oooo==========================================Oooo========

// Code Revision History :

// --------------------------------------------------------------------

// Ver: | Author |Mod. Date |Changes Made:

// V1.0 | XX     |06/22/16  |Initial version

// ===========Oooo==========================================Oooo========

    

    //DATA_WIDTH

	`define SDRAM_DATA_WIDTH    32

	//BANK_WIDTH

	`define SDRAM_BANK_WIDTH    2

	//ROW_WIDTH

	`define SDRAM_ADDR_ROW_WIDTH     11

	//COLUMN_WIDTH

	`define SDRAM_ADDR_COLUMN_WIDTH  8

	

	

///////////////////////////////////////////	

	

	`define USER_ADDR_WIDTH 21 

	

	 //ADDR_WIDTH

	`define SDRAM_ADDR_WIDTH    `SDRAM_ADDR_ROW_WIDTH

    //DQM_WIDTH

	`define SDRAM_DQM_WIDTH     `SDRAM_DATA_WIDTH/8





