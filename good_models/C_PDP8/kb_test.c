#include <stdio.h>
#include <unistd.h>
#include <termios.h>
#include <sys/select.h>
#include <pthread.h>
#include <stdlib.h>

// Compile with gcc -pthread -o kb_test kb_test.c
//
// References:
//
// http://www.cs.cmu.edu/afs/cs/academic/class/15492-f07/www/pthreads.html#CREATIONTERMINATION
// http://cc.byexamples.com/2007/04/08/non-blocking-user-input-in-loop-without-ncurses/
// http://stackoverflow.com/questions/717572/how-do-you-do-non-blocking-console-i-o-on-linux-in-c

int kbhit(void);
void nonblock(int);

pthread_mutex_t output_mux;

struct keyboard_layout {
   char character;
   int keyboard_flag;
   int quit;
};

#define NB_ENABLE 1
#define NB_DISABLE 0

void* read_keyboard(void* kb_layout) {
    struct keyboard_layout* local_kb = (struct keyboard_layout*)kb_layout;
    int local_loop = 0;
    int local_key_press = 0;
    char new_char = 'a';

    nonblock(NB_ENABLE);
    while(!local_loop)
    {
        usleep(2);
        local_loop = kbhit();

	//No new characters
	if(local_key_press) {
		local_key_press = 0;
		
		//Mux
		pthread_mutex_lock(&output_mux);
		local_kb->keyboard_flag = 0;
		pthread_mutex_unlock(&output_mux);
	}
	
        if (local_loop != 0)
        {
	    local_key_press = 1;
	    new_char = fgetc(stdin);

	    pthread_mutex_lock(&output_mux);
            local_kb->character = new_char;
	    local_kb->keyboard_flag = 1;
	    pthread_mutex_unlock(&output_mux);
	    printf("\b");

            if (new_char == 'q') {
		pthread_mutex_lock(&output_mux);
		local_kb->quit = 1;
		pthread_mutex_unlock(&output_mux);
                local_loop = 1;
	    }
            else
                local_loop = 0;
        }
    }
    printf("\n you hit %c. \n", new_char);
    nonblock(NB_DISABLE);

    pthread_exit(0);gcc -pthread -o test test2.c
}

void* print_stuff(void* kb_layout) {
	struct keyboard_layout* local_kb = (struct keyboard_layout*)kb_layout;

	//Mux
	for(;;) {
		usleep(1);
		pthread_mutex_lock(&output_mux);
		if(local_kb->quit == 1) break;
		if(local_kb->keyboard_flag == 1) fprintf(stdout, "%c\n", local_kb->character);
		pthread_mutex_unlock(&output_mux);
		//fflush(stdout);
	}
	
	pthread_exit(0);
}

int main()
{
    pthread_t keyboard_thread, printer_thread;
    int retval1, retval2;
    struct keyboard_layout kb_layout;
    kb_layout.keyboard_flag = 0;
    kb_layout.character = 'a';
    kb_layout.quit = 0;

    retval1 = pthread_create(&keyboard_thread, NULL, read_keyboard, (void*)&kb_layout);
    if(retval1) {
	fprintf(stderr, "Keyboard thread failed\n");
	exit(-1);
    }

    retval2 = pthread_create(&printer_thread, NULL, print_stuff, (void*)&kb_layout);
    if(retval2) {
	fprintf(stderr, "Printer thread failed\n");
	exit(-2);
    }

    pthread_join(keyboard_thread, NULL);
    pthread_join(printer_thread, NULL);
 
    return 0;
}



int kbhit()
{
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
    select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
    return FD_ISSET(STDIN_FILENO, &fds);
}

void nonblock(int state)
{
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

