/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly, J.S. Peirce
** 
** 21 JANUARY 2015
** MEMORY.C 	IMPLEMENTATION FILE FOR MEMORY OP FUNCTIONS
******************************************************************************/

#include "kb_input.h"

/******************************************************************************
** THIS FUNCTION RUNS IN A THREAD. IT READS KEYBOARD INPUT AND STORES
** THE CHARS INPUTTED.
******************************************************************************/
void* read_keyboard(void* kb_layout) {
   struct keyboard* local_kb = (struct keyboard*)kb_layout;
   int kb_return = 0;
   int local_key_press = 0;
   char inputted_char;

	//Enable reading chars without hitting enter
	nonblocking(NB_ENABLE);

	//Begin the main reading loop
   while(!kb_return) {
   	//usleep(2);
      kb_return = kbhit();	//Check if key pressed

		//Clear the keyboard flag to simulate missing input
		if(local_key_press) {
			local_key_press = 0;
		
			pthread_mutex_lock(&keyboard_mux);
			local_kb->input_flag = 0;
			pthread_mutex_unlock(&keyboard_mux);
		}
	
		//Check to see if key was pressed
      if (kb_return != 0) {
	   	local_key_press = 1;
	   	inputted_char = fgetc(stdin);

	   	pthread_mutex_lock(&keyboard_mux);
         local_kb->input_char = inputted_char;
	    	local_kb->input_flag = 1;
	    	pthread_mutex_unlock(&keyboard_mux);
	    	//printf("\b");
			//fflush(stdout);

         kb_return = 0;
      }

		pthread_mutex_lock(&keyboard_mux);
		if(local_kb->quit) kb_return = 1;
		pthread_mutex_unlock(&keyboard_mux);
	}
   nonblocking(NB_DISABLE);

   pthread_exit(0);
}

/******************************************************************************
** THIS FUNCTION EMULATES THE WINDOWS FUNCTION KBHIT()
******************************************************************************/
int kbhit() {
	struct timeval tv;
	fd_set fds;
	tv.tv_sec = 0;
	tv.tv_usec = 0;
	FD_ZERO(&fds);
	FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
	select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
	return FD_ISSET(STDIN_FILENO, &fds);
}

/******************************************************************************
** THIS FUNCTION SETS THE TERMINAL TO NONBLOCKING MODE SO ENTER DOES NOT
** NEED TO BE PRESSED TO CAPTURE THE CHARACTER
******************************************************************************/
void nonblocking(int state) {
	struct termios ttystate;

	//get the terminal state
	tcgetattr(STDIN_FILENO, &ttystate);

	if (state==NB_ENABLE)
	{
		 //turn off canonical mode
		 ttystate.c_lflag &= ~ICANON;
		 //minimum of number input read.
		 ttystate.c_cc[VMIN] = 1;
	}
	else if (state==NB_DISABLE)
	{
		 //turn on canonical mode
		 ttystate.c_lflag |= ICANON;
	}
	//set the terminal attributes.
	tcsetattr(STDIN_FILENO, TCSANOW, &ttystate); 
}

