# 	Project Document

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
	
	#### 10. AnalyseScript
	- ##### In
		- script
		- clk
		- res
		- stop
		- sig_front
		- sig_hand
		- sig_processing
		- sig_machine
		- btn_step
		- milisecont_clk
		- debug_mode
	- ##### Out
		- pc
		- data_operate_script
		- data_game_state_script  
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

    

    *following 4 modules is designed to interpret specific kind of scripts for debug*

	- #### **actionDebug**

		- ##### **Function:**

			interpret action scripts

		- ##### **Inputs:**

			- **rst**: reset sig
			- **en**: enable sig
			- **[7:0] i_num**: index of target machine
			- **[1:0]func**: which action to take
			- **clk**: clock sig

		- ##### **Outputs:**

			- **move_ready**: is player in front of target machine or not
			- **[7:0] target_machine**: sig to change target machine
			- **[7:0] control_data**: sig to control operation 

	- #### **WaitDebug**

		- ##### **Function**: 

			wait until sig turns 1 or wait a certain amount of time

		- ##### **Inputs:**

			- **en**: enable sig
			- **[7:0] i_num**:  number of ms to wait
			- **[1:0] func**: func
			- **[2:0] i_sign**: to determine which sig to wait
			- **millisecond_clk**: because the unit of waiting time is ms, we introduce this clock to help
			- **clk**: uart_clk
			- **[7:0] feedback_sig**: feedback sig from client

		- ##### **Output**:

			- **is_ready**: finish waiting and ready for next script

	- #### **jumpDebug**

		- ##### **Function**

			if satisfy certain condition, jump some lines of script by incrementing pc

		- ##### **Inputs**

			- **en**: enable sig
			- **[7:0]i_num**: amount of lines to skip
			- **[1:0] func**: define "if" or "ifnot" mode
			- **rst**: reset sig
			- **clk**: clock sig 
			- **[7:0]Current_pc**: pc of this jump script
			- **[7:0] feedback_sig**: feedback sig from client

		- ##### **Outputs**

			- **next_pc**: where pc should go to
			- **is_ready**: set 1 when finish one script

	- #### **game_stateDebug**

		- ##### **Function**

			change game state

		- ##### **Input**

			- **en**: enable sig
			- **[1:0]func**: determine to start or end a game
			- **clk**: clock sig

		- ##### **Output**

			- **[7:0]game_state**: data to control game state

	
	*following 4 modules is designed to interpret specific kind of scripts*
	
	- #### **auto_action**
		
		- ##### **Function**

			interpret action scripts
			
		- ##### **Input**
			
			- **clk**: clock sig
			-  **enable**:  enable sig
			-  **[7:0]i_num**: index of target machine
			-  **[1:0]func**: which action to take
			-  **[7:0]pc**: when it changes, the script state is reset
			-   **sig_front**: to check if the move is complete
			-   **sig_hand**: to check if the get, put, or throw action is complete
			-   **sig_processing**: to check if the interact has started
			-   **sig_machine** : It is non-functional but included in the input list to enhance the aesthetic appeal XD
		
		- ##### **Output**
			
			- **[7:0] target_machine**: sig to change target machine
			- **[7:0] op_data**: sig to control operation 
			- **scriptDonePulse**: pulse sig indicating script has finished

	- #### **auto_game_state**
		
		- ##### **Function**

			change game state
			
		- ##### **Input**
			
			- **clk**: clock sig
			-  **enable**:  enable sig
			-  **[1:0]func**:  determine to start or end a game
			-  **[7:0]pc**: when it changes, the script state is reset
		
		- ##### **Output**
			
			- **[7:0]game_state**: data to control game state
			- **scriptDonePulse**: pulse sig indicating script has finished
	

	- #### **auto_wait**
		
		- ##### **Function**

			wait until sig turns 1 or wait a certain amount of time
			
		- ##### **Input**
			
			- **clk**: uart_clk
			-  **enable**:  enable sig
			- **[7:0] i_num**:  number of ms to wait
			- **[1:0] func**: func
			- **[2:0] i_sign**: to determine which sig to wait
			- **millisecond_clk**: because the unit of waiting time is ms, we introduce this clock to help
			-   **sig_front**: sig to wait
			-   **sig_hand**: sig to wait
			-   **sig_processing**: sig to wait
			-   **sig_machine**: sig to wait
		
		- ##### **Output**
			- **scriptDonePulse**: pulse sig indicating script has finished

	- #### **auto_jump**
		
		- ##### **Function**

			if satisfy certain condition, jump some lines of script by incrementing pc
			
		- ##### **Input**
			
			- **clk**: clock sig
			-  **enable**:  enable sig
			-  **[7:0]pc**: when it changes, the script state is reset
			- **[7:0]i_num**: amount of lines to skip
			- **[1:0] func**: define "if" or "ifnot" mode
			-   **sig_front**: sig to check if jump or not
			-   **sig_hand**: sig to check if jump or not
			-   **sig_processing**: sig to check if jump or not
			-   **sig_machine** : sig to check if jump or not
		
		- ##### **Output**
			
			- **[7:0]jump_num**: number of lines that need to jump
			- **scriptDonePulse**: pulse sig indicating script has finished

	*following 1 modules is designed to prevent the script from executing too quickly.*
	
	- #### **delay_by_twenty_mili_second**
		- ##### **Function**
			
			delay the command by 20 miliseconds to prevent the script from executing too quickly
			
		- ##### **Input**
			
			- **clk**: clock sig
			- **reset**: reset sig
			-  **pulse_in**: input pulse sig
		- ##### **Output**

			- **pulse_out**: the pulse signal delayed by 20 milliseconds

## 5. Added two bonuses

- ### 5.1 Error Handling

	- **Pick Command Fix**: It checks if you're holding something before picking up a new item. If so, it drops the current item first. 

		- **Implementation method**:
			Before picking up a new item, the script checks if the player is already holding something by evaluating the "player_hasitem" flag. If this is set to 1, indicating an item is being held, it sends a command to throw the current item into the trash can. It then waits for the "player_hasitem" flag to return to 0 before transitioning into the move state and picking up the new item.
		
	- **Smart Throw Command**: If an item can't be thrown, the system moves and places it instead of throwing. 
	
	- **Implementation method**:
			Before entering the "SCRIPT_DOING" state, the script evaluates if the current "target_machine" is one of the following: "STONE_MILL", "CUTTING_MACHINE", "STOVE", "OVEN", "WORKBENCH", "MIXER" , or "CUSTOMER". If the "target_machine" matches any of these, the script sets the "PUTChangeFlag" to 1 and transitions to the "SCRIPT_STARTMOVING" state. 
			
		
			Furthermore, within the "SCRIPT_DOING" state, the script checks the status of "PUTChangeFlag". If it is set to 1, it will execute the same actions as the "PUT" command would.
	
- ### 5.2 Efficient Scripting

	-  **Automation Utilization**: Wherever possible, the script leverages automated machines such as cutting machines, mixers, stoves, and ovens to free up the player's time. 

	-  **Throw Optimization**: To reduce the time spent by the player in movement, the script capitalizes on the 'throw' functionality whenever feasible. 

	-   **Pathway Planning**: The script plans the shortest and most direct routes to ensure time expenditure are kept to a minimum. 

	My script's best time to make three dishes (香嫩椒椒鸡、树莓水馒头、冷肉拼盘) is 12.54 seconds . (avg 13 seconds)
	
## 6. Summary

### 1. Introduction
We chose Genshin Kitchen as our final project , since We think this project is both interesting and challenging. We may learn more about verilog and FPGA due to the process of completing this project. Deepen our understanding of the discipline of digital logic
### 2. Project Objective
Our project objective is to finish all basic task in rating requirements and complete bonus part as much as possible. And we succeeded in achieving that.
### 3. Design method
Our team members worked together to complete this project. We separated Genshin Kitchen's manual mode and script mode to complete this project. During the process of writing code, we adopted a top-down design approach. We have completed many different functional modules. Each module completes its independent functions which forming a low coupling and high cohesion pattern. This has improved the scalability and manageability of our project and make it more convenient to add new features.
### 4. Important features and implementation
For mannual mode ,  we processed game state change , operate machine and change selected machine separately. Using three modules , we successfully. We have achieved the switching from the machine's level signal to the data signal. Also , by adjusting clock division, through UART module , we sent it to the client in binary data format. Successfully achieved interaction between client and FPGA in manual mode. Also, we also validated the FPGA operate data in an independent module to prevent sending illegal data to clients.

Moreover, for script mode, we implemented two mode, debug mode and auto mode, which corresponding to executing scripts step by step and automatically. In this section, we properly use `enable` and `reset` signal to prevent errors. Besides, *finite-state-machine* also helps to construct our design.

In our design, we use *blocking assignment* and *non-blocking assignment* appropriately  and reuse our code to avoid duplication and improve maintainability. Also, necessary comments and document are added to help understanding and promote collaboration. All parameters are defined in a head file named `Define.v` , following the instruction pretty well.

### 5. Result analysis
We successfully finish all basic and bonus part of the project. And the project also passed out test , which means that it can interact with client normally and finish the game of Genshin Kitchen
### 6. Summary
Under the cooperation of group members , we successfully finish our project. Some issues that arose during the completion of the project were also resolved through our joint efforts. Each member of the group has improved their abilities in Verilog and FPGA during this task.

### 7. Proposal for Next Project

**Combination Lock** could be an option. Students should use BlueTooth to connect to client on pc or mobile platform and  input pre-configured password on it, whose output will be presented on board.

possible tasks:

- **Verify Password**: after 3 times of wrong input, the board will be locked for 1 min.
- **Reset Password**: after logging in by right password, you could reset password.
- **Display Output**: output what you input by digital tubes and count down when the board is locked.

Reference: *FPGA-Based Bluetooth Password Lock with EGO1 Development Board: Wireless Control, Unlocking, Password Modification, and Theft Protection. (FPGA-Jīyú EGO1 kāifā bǎn de lán yá mìmǎ suǒ wúxiàn kòngzhì kāisuǒ xiūgǎi mìmǎ fángdào bǎohù)(2023, December 28). CSDN Blog. https://blog.csdn.net/sirlhh/article/details/125598103*

