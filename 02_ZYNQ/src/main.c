#include <stdio.h>

#include "xparameters.h"
#include "xil_printf.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "lwip/tcp.h"
#include "netif/etharp.h"
#include "xil_cache.h"
#include "xil_exception.h"
#include "das_udp.h"

void lwip_init(void);
void tcp_fasttmr(void);
void tcp_slowtmr(void);
extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;

static struct netif server_netif;

static void print_ip(char *msg, struct ip_addr *ip)
{
    xil_printf("%s%d.%d.%d.%d\r\n", msg, ip4_addr1(ip), ip4_addr2(ip),
               ip4_addr3(ip), ip4_addr4(ip));
}

int main(void)
{
    struct ip_addr ipaddr, netmask, gw;
    ip_addr_t pc_ip;
    struct eth_addr pc_mac = {{0x2c, 0x41, 0x38, 0x8b, 0x32, 0xb9}};
    unsigned char mac[] = {0x00, 0x0a, 0x35, 0x00, 0x01, 0x02};

    init_platform();
    /* Match the PC's currently active wired adapter (172.18.9.10/21). */
    IP4_ADDR(&ipaddr, 172, 18, 9, 11);
    IP4_ADDR(&netmask, 255, 255, 248, 0);
    IP4_ADDR(&gw, 0, 0, 0, 0);

    print_app_header();
    lwip_init();
    if (!xemac_add(&server_netif, &ipaddr, &netmask, &gw, mac,
                   PLATFORM_EMAC_BASEADDR)) {
        xil_printf("Error adding PS GEM0 (ETH1)\r\n");
        cleanup_platform();
        return -1;
    }
    netif_set_default(&server_netif);
    platform_enable_interrupts();
    netif_set_up(&server_netif);
    netif_set_link_up(&server_netif);

    /* PS GEM0 has its own DMA, independent of the PL ADC AXI DMA. */
    IP4_ADDR(&pc_ip, 172, 18, 9, 10);
    (void)etharp_add_static_entry(&pc_ip, &pc_mac);

    /* Start lwIP first so the PC receives a bring-up marker even if the
     * capture DMA setup reports an error; this keeps network and ADC faults
     * distinguishable during board bring-up. */
    if (start_application() != 0) {
        xil_printf("DAS capture/UDP init failed\r\n");
        cleanup_platform();
        return -2;
    }
    /* AXI DMA IRQ enables stay clear; GEM and timer IRQs remain enabled. */
    if (das_dma_init() != 0) {
        xil_printf("DAS capture DMA init failed\r\n");
        cleanup_platform();
        return -2;
    }
    print_ip("Board IP: ", &ipaddr);

    while (1) {
        if (TcpFastTmrFlag) {
            tcp_fasttmr();
            TcpFastTmrFlag = 0;
        }
        if (TcpSlowTmrFlag) {
            tcp_slowtmr();
            TcpSlowTmrFlag = 0;
        }
        xemacif_input(&server_netif);
        transfer_data();
    }
}
