# Project Document

## 0. Introduction

### (1)Project Topic
- Topic: _**Option B Genshin Kitchen**_


### (2)Team Roles
- **施米乐: 33%**
- **范升泰: 33%**
- **王玺华: 33% -- Manual mode**

### (3)Development plan

- Plan: 
	- [x] Finish Manual Mode	_12.20 (By  王玺华 )_
	- [x] Test Manual Mode		_12.20 (By  王玺华 )_
	- [x] Finish Script Mode    _12.25_
	- [x] Test Script Mode		_12.25_
	- [x] Finish Part Bonus		_12.29_
	
## 1. System Function List

- **Client protocol via UART**
- **Manually prepare dishes**
- **Preventing illegal operations**
- **Use scripts**
- **Handling exception**
- **Maximum efficiency**

## 2. System Instructions

- **Leftmost Button** : Change Game State
- **Five switches on the right side** : Select Target Machine
- **Up Button** : Operate Move
- **Down Button** : Operate Throw
- **Left Button** : Operate Get
- **Right Button** : Operate Put
- **Center Button** : Operate Interact
- **The right four of the left LED lights** : Show Feedback Data
- **The Left One of the left LED lights** : Show Manual Mode Or Script Mode

## 3. System Architecture Description

### Top Module : **DemoTop**
- #### Internal Wires And Regs:

	- **wire uart_clk_16** : uart clk
	- **wire \[7:0\] dataIn_bits** : data to client
	- **wire dataIn_ready** : if data to client is ready
	- **wire \[7:0\] dataOut_bits** : data from client
	- **wire dataOut_valid** : if data from client is valid
	- **wire script_mode** : script mode
	- **wire \[7:0\] pc** : 
	- **wire \[15:0\] script** : 
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
	- **wire \[7:0\] data_target_script** : 
	- **wire \[7:0\] data_game_state_script**
	- **wire \[7:0\] data_operate_script**
	- **wire \[7:0\] data_operate_verified_script**



- #### Input And Output:
	- **INPUT**
		- **\[4:0\] button** : buttons of manual mode to operate machine
		- **\[7:0\] switches** : switches to choose gamestate and target machine
		- **clk** : system clk
		- **rx**  : UART rx
	- **OUTPUT**
		- **\[7:0]\ led**: leds to show feedback data and game mode
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

	#### 4. SendData (1)
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
      -  data_game_state

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
- ### SendData
	- #### Function : 
  	**send data to Client**
	- #### Inputs :
		- **enable** : Enable signal for controlling the FSM
		- **\[7:0\] data_target** : Data of target machine
		- **\[7:0\] data_game_state** : Data of game state
		- **\[7:0\] data_operate_verified** : Data of verified operation
		- **uart_clk** : UART clock
		- **data_ready** : Mark of data send finish
	- #### Output Regs
		- **\[7:0\] data_send** : Data to send to client
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
        - **\[7:0\] data_operate_verified** : valid operation data after verifing 

		
