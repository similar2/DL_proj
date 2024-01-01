# Project Document

## 0. Introduction

### (1)Project Topic
- Topic: _**Option B Genshin Kitchen**_


### (2)Team Roles
- **施米乐: 33%** -- **Script Debug Mode**
- **范升泰: 33%** -- **Script Auto Mode and bonus 1, 2**
- **王玺华: 33% -- Manual mode**

### (3)Development plan

- Plan: 
	- [x] Finish Manual Mode	_12.20 (By  王玺华 )_
	- [x] Test Manual Mode		_12.20 (By  王玺华 )_
	- [x] Finish Script Mode    _12.25(By 施米乐&范升泰)_
	- [x] Test Script Mode		_12.25 (By 施米乐&范升泰)_
	- [x] Finish Part Bonus		_12.29 (By 范升泰)_
	
## 1. System Function List

- **Client protocol via UART**
- **Manually prepare dishes**
- **Preventing illegal operations**
- **Use scripts**
- **Handling exception**
- **Maximum efficiency**

## 2. System Instructions

### **Manual Mode**

- **Leftmost Button** : Change Game State
- **Five switches on the right side** : Select Target Machine
- **Up Button** : Operate Move
- **Down Button** : Operate Throw
- **Left Button** : Operate Get
- **Right Button** : Operate Put
- **Center Button** : Operate Interact
- **The right four of the left LED lights** : Show Feedback Data
- **The Left One of the left LED lights** : Show Manual Mode Or Script Mode

### **Script Debug Mode**

- **Leftmost Button**: set 1 to activate debug mode
- **Down Button**: increment pc to access next script
- **Right Button**: reset pc to 8'b0000_0000 and start first script

- **Left 8 Led**: show the feedback data as manual mode
- **Right 8 Led**: show the value of pc 

## 3. System Architecture Description

### Top Module : **DemoTop**
- #### Internal Wires And Regs:

	##### **Wires for Manual Mode and Feedback Data **
	
	- **wire uart_clk_16** : uart clk
	- **wire \[7:0\] dataIn_bits** : data to client
	- **wire dataIn_ready** : if data to client is ready
	- **wire \[7:0\] dataOut_bits** : data from client
	- **wire dataOut_valid** : if data from client is valid
	- **wire uart_reset** : reset signal to UART
	- **wire second_clk** : clock of per second
	- **wire millisecond_clk** : clock of per millisecond
	- **wire \[7:0\] data_game_state** : game state data from FPGA switch
	- **wire \[7:0\] data_operate** : origin game operation data from FPGA buttons
	- **wire \[7:0\] data_operate_verified** : valid game operation data
	- **wire \[7:0\] data_target** : target machine data from FPGA switches
	- **wire sig_front** : feedback data of if player in front of target machine
	- **wire sig_hand** : feedback data of if player has item in hand
	- **wire sig_processing** : feedback data of target machine is processing
	- **wire sig_machine** : feedback data of if target machine has item
	
	##### **Wires for Script Mode**
	
	- **wire script_mode** : script mode set 1 when client is sending scripts
	
	- **wire \[7:0\] pc** : program counter, indicating which script should be read
	
	- **wire \[15:0\] script** : current script that is being executed
	
	- **wire [7:0] script_num**: the size of all scripts ought to be interpreted 
	
	- **reg en_script, reg en_manual**: these two sigs show that the data_out_bits should use control data from manual module or script module.
	
	- **wire \[7:0\] data_target_script** :  target machine data from script 
	
	- **wire \[7:0\] data_game_state_script**: game state data from script 
	
	- **wire \[7:0\] data_operate_script**: raw operation date from script
	
	- **wire \[7:0\] data_operate_verified_script**: verified data from script
	
	  ​	*the four sig above only take effect when en_script set high*
	
	- **reg mode_interpret_script**: set high when script module is working and didn't finish interpreting all scripts

​		

- #### Input And Output:
	- **INPUT**
		- **\[4:0\] button** : buttons of manual mode to operate machine
		- **\[7:0\] switches** : switches to choose game state and target machine
		- **clk** : system clk
		- **rx**  : UART rx
	- **OUTPUT**
		- **\[7:0] led**: leds to show feedback data and game mode
		- **\[7:0\] led2** : leds to show other info
		- **tx** : URAT tx

 

- #### Submodule wire connection:
	##### 1. ScriptMem
	- ##### In
      - uart_clk_16
      - uart_reset
      - dataOut_bits
      - dataOut_valid
      - pc
	- ##### Out
      - script
      - script_mode
      - script_num

	#### 2. UART
	- ##### In
      - uart_clk_16
      - uart_reset
      - rx
      - tx
      - dataOut_bits
      - dataOut_valid
	- ##### Out
      - dataIn_bits
      - dataIn_ready

	#### 3. DivideClock
	- ##### In
      - clk
    - ##### Out 
      - uart_clk_16
      - second_clk
      - millisecond_clk

	#### 4. SendData
	- ##### In
      - en_manual
      - data_operate_verified
      - data_target
      - data_game_state
      - uart_clk_16
      - dataIn_ready
	- ##### Out
      - dataIn_bits

	#### 5. GameStateChange
	- ##### In
	  - switches
	  - uart_clk_16
	-  ##### Out
   		- data_game_state

	#### 6. TravelerTargetMachine
	- ##### In
  	  - switches
	  - uart_clk_16
	- ##### Out
	  - data_target

	#### 7. TravelerOperateMachine
	- ##### In
	  - button
	  - uart_clk_16
	- ##### Out
	  - data_operate

	#### 8. VerifyIfOperateDataCorrect
	- ##### In
  	  - uart_clk_16
  	  - data_game_state
  	  - data_target
  	  - sig_front
  	  - sig_hand
  	  - sig_processing
  	  - sig_machine
	- ##### Out
	  - data_operate_verified

	#### 9. ReceiveUnScriptData
	- ##### In
	  - dataOut_valid
	  - dataOut_bits
	  - uart_clk_16
	- ##### Out
	  - sig_front
	  - sig_hand
	  - sig_processing
	  - sig_machine
	  - led
	  ​	
	  ​		
## 4. Sub module Function Description

- ### ScriptMem (Provided By Demo)

    - however, we cannot to find a proper way to set ram module, so we rewrite this module to use a reg array to store all scripts 

- ### UART (Provided By Demo)

- ### DivideClock
  - #### Function : 
  **change system clock to clocks that FPGA need**
  - #### Inputs : 
  	- **clk** : system clock
  - #### Output Regs :
  	- **uart_clk** : uart clk
  	- **second_clk** : clk per second
  	- **millisecond_clk** : clk per millisecond		

- ### GameStateChange
  - #### Function: 
  	**get game state from switch**
  - #### Inputs:
  	- **switch** : switch control game start or end
  	- **uart_clk** : uart_clk
  - #### Output Reg:
  	- **data_game_state\[7:0\]** : data of game state

- ### ReceiveUnScriptData
  - #### Function : 
  	**receive feedback data from Client**
  - #### Inputs:
  	- **script_mode** : judge current state
  	- **data_valid** : from UART 
  	- **data_received** : data received from UART
  	- **uart_clk** : uart clk
  - #### Output Regs:
  	- **sig_front** : feedback data of if player is in front
  	- **sig_hand** : feedback data of if player has cusine
  	- **sig_processing** : feedback data of machine is processing
  	- **sig_machine** : feedback data of if machine has item
  	- **\[3:0\] feedback_leds** : show feedback data on leds
  	- **led_mode** : show current mode
- ### TravelerOperateMachine
  - #### Function : 
  	**get origin operate data from buttons**
  - #### Inputs :
  	- **button_up** : move operation
  	- **button_down** : throw operation
  	- **button_left** : get operation
  	- **button_center** : interact operation
  	- **button_right** : put operation
  	- **uart_clk** : uart_clk
  - #### Output Regs :
  	- **\[7:0\] data_operate** : origin data of operation from buttons

- ### TravelerTargetMachine
  - #### Function : 
  	**get target machine from switches**
  - #### Inputs:
  	- **\[4:0\] select_switches** : switches to choose target machine
  	- **uart_clk : uart clk**
  - #### Output Regs:
    - **\[7:0\] data_target** : data of index of machine that player chosen

- ### VerifyIfOperateDataCorrect
    - #### Function : 
    **verify if origin operation data is valid , if not ignore it**
    - #### Inputs:
        - **uart_clk** : uart clk
        - **\[7:0\] data_game_state** : data of game state
        - **\[7:0\] data_operate** : data of origin operation
        - **\[7:0\] data_target** : data of target machine
        - **sig_front** : feedback data of if player in front of target machine
        - **sig_hand** : feedback data of if player has item
        - **sig_processing** : feedback data of if machine is processing
        - **sig_machine** : feedback data of if machine has item
    - #### Output Regs:
        - **\[7:0\] data_operate_verified** : valid operation data after verified

- ### **AnalyseScript**

    - #### **Function:**

        work as a sorter to process one sentence of script, based on the op_code, to use different module

    - #### **Inputs:**

      - **[15:0] script**: script need to be processed
      - **clk**: uart_clk
      - **res**: reset sig before debounced
      - **stop**: pause the game
      - **sig _front, sig_hand, sig_processing, sig_machine**: feedback sigs
      - **btn_step**: only work during debug mode, increment pc by 2 bytes
      - **millisecond_clk**: another clock sig whose period is 1ms
      - **debug_mode**: if this is 1 then we use btn_step to force pc move forward

    - #### **Outputs**

      - **pc**: program counter
      - **data_operate_script**: sig to control operate
      - **data_target_script**: sig to control target machine change
      - **data_game_state_script**: sig to control game state change

    

    *following 4 modules is designed to interpret specific kind of scripts*

- ### **action**

    - #### **Function:**

        interpret action scripts

    - #### **Inputs:**

        - **rst**: reset sig
        - **en**: enable sig
        - **[7:0] i_num**: index of target machine
        - **[1:0]func**: which action to take
        - **clk**: clock sig

    - #### **Outputs:**

        - **move_ready**: is player in front of target machine or not
        - **[7:0] target_machine**: sig to change target machine
        - **[7:0] control_data**: sig to control operation 

- ### **Wait**

    - #### **Function**: 

        wait until sig turns 1 or wait a certain amount of time

    - #### **Inputs:**

        - **en**: enable sig
        - **[7:0] i_num**:  number of ms to wait
        - **[1:0] func**: func
        - **[2:0] i_sign**: to determine which sig to wait
        - **millisecond_clk**: because the unit of waiting time is ms, we introduce this clock to help
        - **clk**: uart_clk
        - **[7:0] feedback_sig**: feedback sig from client

    - #### **Output**:

        - **is_ready**: finish waiting and ready for next script

- ### **Jump**

    - #### **Function**

        if satisfy certain condition, jump some lines of script by incrementing pc

    - #### **Inputs**

        - **en**: enable sig
        - **[7:0]i_num**: amount of lines to skip
        - **[1:0] func**: define "if" or "ifnot" mode
        - **rst**: reset sig
        - **clk**: clock sig 
        - **[7:0]Current_pc**: pc of this jump script
        - **[7:0] feedback_sig**: feedback sig from client

    - #### **Outputs**

        - **next_pc**: where pc should go to
        - **is_ready**: set 1 when finish one script

- ### **Game state**

    - #### **Function**

        change game state

    - #### **Input**

        - **en**: enable sig
        - **[1:0]func**: determine to start or end a game
        - **clk**: clock sig

    - #### **Output**

        - **game_state**: data to control game state
