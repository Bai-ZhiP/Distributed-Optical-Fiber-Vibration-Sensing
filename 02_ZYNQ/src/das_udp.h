#ifndef DAS_UDP_H
#define DAS_UDP_H

int das_dma_init(void);
void das_dma_poll(void);
int das_udp_start(void);
void das_print_app_header(void);

/* The tutorial main loop calls these names. */
int start_application(void);
int transfer_data(void);
void print_app_header(void);

#endif
