/******************************************************************************
*
* Copyright (C) 2010 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

#include "netif/xemacpsif.h"
#include "lwipopts.h"

#if XPAR_GIGE_PCS_PMA_1000BASEX_CORE_PRESENT == 1 || \
	XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT == 1
#define PCM_PMA_CORE_PRESENT
#else
#undef PCM_PMA_CORE_PRESENT
#endif

u32_t link_speed = 100;
extern XEmacPs_Config XEmacPs_ConfigTable[];
extern u32_t phymapemac0[32];
extern u32_t phymapemac1[32];

XEmacPs_Config *xemacps_lookup_config(unsigned mac_base)
{
	XEmacPs_Config *cfgptr = NULL;
	s32_t i;

	for (i = 0; i < XPAR_XEMACPS_NUM_INSTANCES; i++) {
		if (XEmacPs_ConfigTable[i].BaseAddress == mac_base) {
			cfgptr = &XEmacPs_ConfigTable[i];
			break;
		}
	}

	return (cfgptr);
}

void init_emacps(xemacpsif_s *xemacps, struct netif *netif)
{
	XEmacPs *xemacpsp;
	s32_t status = XST_SUCCESS;

	xemacpsp = &xemacps->emacps;

#ifdef ZYNQMP_USE_JUMBO
	XEmacPs_SetOptions(xemacpsp, XEMACPS_JUMBO_ENABLE_OPTION);
#endif

	/* set mac address */
	status = XEmacPs_SetMacAddress(xemacpsp, (void*)(netif->hwaddr), 1);
	if (status != XST_SUCCESS) {
		xil_printf("In %s:Emac Mac Address set failed...\r\n",__func__);
	}

	/* AX7350B ETH1 is PS GEM0.  Do not access MDIO here: an absent or
	 * recently-reset PHY makes XEmacPs_PhyRead/Write wait forever for
	 * MDIOIDLE.  JL2121 powers up with autonegotiation enabled, so only
	 * set the GEM0 125-MHz RGMII clock divisors and MAC speed. */
	{
		u32 clk;
		Xil_Out32(0xF8000008U, 0x0000DF0DU); /* SLCR unlock */
		clk = Xil_In32(0xF8000140U);
		clk &= 0xFC0FC0FFU;
		clk |= (1U << 20) | (8U << 8);       /* GEM0 1-Gbit div1/div0 */
		Xil_Out32(0xF8000140U, clk);
		Xil_Out32(0xF8000004U, 0x0000767BU); /* SLCR lock */
	}
	link_speed = 1000;

	XEmacPs_SetOperatingSpeed(xemacpsp, link_speed);
	/* Setting the operating speed of the MAC needs a delay. */
	{
		volatile s32_t wait;
		for (wait=0; wait < 20000; wait++);
	}
}

void init_emacps_on_error (xemacpsif_s *xemacps, struct netif *netif)
{
	XEmacPs *xemacpsp;
	s32_t status = XST_SUCCESS;

	xemacpsp = &xemacps->emacps;

	/* set mac address */
	status = XEmacPs_SetMacAddress(xemacpsp, (void*)(netif->hwaddr), 1);
	if (status != XST_SUCCESS) {
		xil_printf("In %s:Emac Mac Address set failed...\r\n",__func__);
	}

	XEmacPs_SetOperatingSpeed(xemacpsp, link_speed);

	/* Setting the operating speed of the MAC needs a delay. */
	{
		volatile s32_t wait;
		for (wait=0; wait < 20000; wait++);
	}
}

void setup_isr (struct xemac_s *xemac)
{
	xemacpsif_s   *xemacpsif;

	xemacpsif = (xemacpsif_s *)(xemac->state);
	/*
	 * Setup callbacks
	 */
	XEmacPs_SetHandler(&xemacpsif->emacps, XEMACPS_HANDLER_DMASEND,
				     (void *) emacps_send_handler,
				     (void *) xemac);

	XEmacPs_SetHandler(&xemacpsif->emacps, XEMACPS_HANDLER_DMARECV,
				    (void *) emacps_recv_handler,
				    (void *) xemac);

	XEmacPs_SetHandler(&xemacpsif->emacps, XEMACPS_HANDLER_ERROR,
				    (void *) emacps_error_handler,
				    (void *) xemac);
}

void start_emacps (xemacpsif_s *xemacps)
{
	/* start the temac */
	XEmacPs_Start(&xemacps->emacps);
}

void restart_emacps_transmitter (xemacpsif_s *xemacps) {
	u32_t Reg;
	Reg = XEmacPs_ReadReg(xemacps->emacps.Config.BaseAddress,
					XEMACPS_NWCTRL_OFFSET);
	Reg = Reg & (~XEMACPS_NWCTRL_TXEN_MASK);
	XEmacPs_WriteReg(xemacps->emacps.Config.BaseAddress,
										XEMACPS_NWCTRL_OFFSET, Reg);

	Reg = XEmacPs_ReadReg(xemacps->emacps.Config.BaseAddress,
						XEMACPS_NWCTRL_OFFSET);
	Reg = Reg | (XEMACPS_NWCTRL_TXEN_MASK);
	XEmacPs_WriteReg(xemacps->emacps.Config.BaseAddress,
										XEMACPS_NWCTRL_OFFSET, Reg);
}

void emacps_error_handler(void *arg,u8 Direction, u32 ErrorWord)
{
	struct xemac_s *xemac;
	xemacpsif_s   *xemacpsif;
	XEmacPs_BdRing *rxring;
	XEmacPs_BdRing *txring;

	xemac = (struct xemac_s *)(arg);
	xemacpsif = (xemacpsif_s *)(xemac->state);
	rxring = &XEmacPs_GetRxRing(&xemacpsif->emacps);
	txring = &XEmacPs_GetTxRing(&xemacpsif->emacps);

	if (ErrorWord != 0) {
		switch (Direction) {
			case XEMACPS_RECV:
			if (ErrorWord & XEMACPS_RXSR_HRESPNOK_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Receive DMA error\r\n"));
				HandleEmacPsError(xemac);
			}
			if (ErrorWord & XEMACPS_RXSR_RXOVR_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Receive over run\r\n"));
				emacps_recv_handler(arg);
				setup_rx_bds(xemacpsif, rxring);
			}
			if (ErrorWord & XEMACPS_RXSR_BUFFNA_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Receive buffer not available\r\n"));
				emacps_recv_handler(arg);
				setup_rx_bds(xemacpsif, rxring);
			}
			break;
			case XEMACPS_SEND:
			if (ErrorWord & XEMACPS_TXSR_HRESPNOK_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Transmit DMA error\r\n"));
				HandleEmacPsError(xemac);
			}
			if (ErrorWord & XEMACPS_TXSR_URUN_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Transmit under run\r\n"));
				HandleTxErrors(xemac);
			}
			if (ErrorWord & XEMACPS_TXSR_BUFEXH_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Transmit buffer exhausted\r\n"));
				HandleTxErrors(xemac);
			}
			if (ErrorWord & XEMACPS_TXSR_RXOVR_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Transmit retry excessed limits\r\n"));
				HandleTxErrors(xemac);
			}
			if (ErrorWord & XEMACPS_TXSR_FRAMERX_MASK) {
				LWIP_DEBUGF(NETIF_DEBUG, ("Transmit collision\r\n"));
				process_sent_bds(xemacpsif, txring);
			}
			break;
		}
	}
}
