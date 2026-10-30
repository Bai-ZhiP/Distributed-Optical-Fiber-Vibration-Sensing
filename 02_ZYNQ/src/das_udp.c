#include <string.h>
#include <arm_neon.h>
#include <stdio.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"
#include "lwip/udp.h"
#include "lwip/pbuf.h"
#include "das_udp.h"

#define N 80000U
#define DDC_SAMPLES 80000U
#define IQ_WORDS (DDC_SAMPLES/25U*2U)
static short iq_words[IQ_WORDS] __attribute__((aligned(64)));
#define BYTES (32U+2U*N)
#define DMA XPAR_AXI_ETHERNET_0_DMA_BASEADDR
#define CR (DMA+0x30U)
#define SR (DMA+0x34U)
#define DA (DMA+0x48U)
#define LEN (DMA+0x58U)
#define MAGIC 0x32534252U
static u32 dma_buffers[2][(BYTES+63U)/64U*16U] __attribute__((aligned(64)));
static u32 *dma_buffer = dma_buffers[0];
static struct udp_pcb *data_pcb,*status_pcb;
static u32 active, loops;
volatile u32 DAS_Frames, DAS_Errors, DAS_SendErrors, DAS_BadHeaders, DAS_LastTrigger, DAS_Skipped;
static const short ci[24] __attribute__((aligned(16)))={16384,-6976,-10444,15869,-3070,-13255,14357,1029,-15233,11943,5063,-16255,8779,8779,-16255,5063,11943,-15233,1029,14357,-13255,-3070,15869,-10444};
static const short cq[24] __attribute__((aligned(16)))={0,-14825,12624,4075,-16094,9630,7893,-16352,6031,11216,-15582,2053,13833,-13833,-2053,15582,-11216,-6031,16352,-7893,-9630,16094,-4075,-12624};
static void demodulate_iq(const short *raw) {
 int16x8_t c0=vld1q_s16(ci),c1=vld1q_s16(ci+8),c2=vld1q_s16(ci+16);
 int16x8_t q0=vld1q_s16(cq),q1=vld1q_s16(cq+8),q2=vld1q_s16(cq+16);
 for(unsigned b=0;b<DDC_SAMPLES/25U;b++) {
  const short *p=raw+b*25;
  int16x8_t a0=vld1q_s16(p),a1=vld1q_s16(p+8),a2=vld1q_s16(p+16);
  int32x4_t ai=vmull_s16(vget_low_s16(a0),vget_low_s16(c0));
  int32x4_t aq=vmull_s16(vget_low_s16(a0),vget_low_s16(q0));
  ai=vmlal_s16(ai,vget_high_s16(a0),vget_high_s16(c0));
  aq=vmlal_s16(aq,vget_high_s16(a0),vget_high_s16(q0));
  ai=vmlal_s16(ai,vget_low_s16(a1),vget_low_s16(c1));
  aq=vmlal_s16(aq,vget_low_s16(a1),vget_low_s16(q1));
  ai=vmlal_s16(ai,vget_high_s16(a1),vget_high_s16(c1));
  aq=vmlal_s16(aq,vget_high_s16(a1),vget_high_s16(q1));
  ai=vmlal_s16(ai,vget_low_s16(a2),vget_low_s16(c2));
  aq=vmlal_s16(aq,vget_low_s16(a2),vget_low_s16(q2));
  ai=vmlal_s16(ai,vget_high_s16(a2),vget_high_s16(c2));
  aq=vmlal_s16(aq,vget_high_s16(a2),vget_high_s16(q2));
  int32x2_t ri=vadd_s32(vget_low_s32(ai),vget_high_s32(ai));
  int32x2_t rq=vadd_s32(vget_low_s32(aq),vget_high_s32(aq));
  int si=vget_lane_s32(vpadd_s32(ri,ri),0)+p[24]*(-6976);
  int sq=vget_lane_s32(vpadd_s32(rq,rq),0)+p[24]*(14825);
  int a=si/25600, c=sq/25600;
  iq_words[2*b]=(short)(a>32767?32767:(a< -32768?-32768:a));
  iq_words[2*b+1]=(short)(c>32767?32767:(c< -32768?-32768:c));
 }
}
static void put32(u8 *p,u32 v) {p[0]=v;p[1]=v>>8;p[2]=v>>16;p[3]=v>>24;}
static void status(void) {
 char msg[160];
 int n=snprintf(msg,sizeof(msg),"RBS2 AD2_B ready frames=%lu errors=%lu tx_errors=%lu bad_header=%lu trigger=%lu skipped=%lu CR=%08lx SR=%08lx",(unsigned long)DAS_Frames,(unsigned long)DAS_Errors,(unsigned long)DAS_SendErrors,(unsigned long)DAS_BadHeaders,(unsigned long)DAS_LastTrigger,(unsigned long)DAS_Skipped,(unsigned long)Xil_In32(CR),(unsigned long)Xil_In32(SR));
 if(n>=(int)sizeof(msg))n=sizeof(msg)-1;
 struct pbuf *p=pbuf_alloc(PBUF_TRANSPORT,n,PBUF_RAM);
 if(p) {memcpy(p->payload,msg,n);udp_send(status_pcb,p);pbuf_free(p);}
}
static void arm(void) {
 Xil_DCacheFlushRange((UINTPTR)dma_buffer,sizeof(dma_buffers[0]));
 Xil_Out32(SR,0x7000U);
 Xil_Out32(DA,(u32)(UINTPTR)dma_buffer);
 Xil_Out32(CR,1U); // polled DMA, no PL completion interrupts
 Xil_Out32(LEN,BYTES);
 active=1;
}
int das_dma_init(void) {
 u32 sr=Xil_In32(SR),cr=Xil_In32(CR);
 if((sr&0x78U)||(cr&4U)) {
  xil_printf("DMA requires clean PL reset CR=%08x SR=%08x\r\n",cr,sr);return -1;
 }
 arm();return 0;
}
int das_udp_start(void) {
 ip_addr_t ip; IP4_ADDR(&ip,172,18,9,10);
 data_pcb=udp_new();status_pcb=udp_new();
 if(!data_pcb||!status_pcb)return -1;
 if(udp_connect(data_pcb,&ip,50005)!=ERR_OK||udp_connect(status_pcb,&ip,50006)!=ERR_OK)return -1;
 status();return 0;
}
void das_dma_poll(void) {
 if(++loops==100000U) {loops=0;status();}
 if(!active)return;
 u32 sr=Xil_In32(SR);
 if(sr&0x70U) {DAS_Errors++;active=0;status();return;}
 if(!(sr&0x1000U))return; // require a new completed TLAST, not just idle
 active=0;
 u32 *buffer = dma_buffer; /* CPU owns this completed buffer until return. */
 Xil_DCacheInvalidateRange((UINTPTR)buffer,sizeof(dma_buffers[0]));
 if(buffer[0]!=MAGIC||buffer[4]!=250000000U||buffer[5]!=N||buffer[6]!=4U) {
  DAS_BadHeaders++;status();return;
 }
 DAS_LastTrigger=buffer[1];DAS_Skipped=buffer[7];
 /* Arm only the other cache-line-isolated buffer before doing DDC/network work. */
 dma_buffer = buffer == dma_buffers[0] ? dma_buffers[1] : dma_buffers[0];
 arm();
 demodulate_iq((const short *)(buffer+8));
 const u8 *samples=(const u8 *)iq_words;
 for(u32 off=0;off<IQ_WORDS;) {
  u32 n=IQ_WORDS-off;if(n>600)n=600;
  struct pbuf *p=pbuf_alloc(PBUF_TRANSPORT,48+2*n,PBUF_RAM);
  if(!p){DAS_SendErrors++;break;}
  u8 *b=p->payload;
  put32(b,0x33425149U);put32(b+4,buffer[1]);put32(b+8,off);put32(b+12,n);
  put32(b+16,buffer[4]);put32(b+20,12U|(off==0?1U:0U)|(off+n==IQ_WORDS?2U:0U));
  put32(b+24,IQ_WORDS);put32(b+28,buffer[7]);put32(b+32,buffer[2]);put32(b+36,buffer[3]);
  put32(b+40,1000);put32(b+44,25); // nominal PRF; timestamp is measured
  memcpy(b+48,samples+2*off,2*n);
  if(udp_send(data_pcb,p)!=ERR_OK)DAS_SendErrors++;
  pbuf_free(p);off+=n;
  /* IQ payload is 12.5x smaller: no per-packet sleep. */ // bounded burst pacing; skipped triggers remain explicit
 }
 DAS_Frames++;
}
void das_print_app_header(void) {xil_printf("\r\nIQB3 AD2_B: 80 MHz DDC, 100 ns blocks, IQ scale 8, 3200 complex bins, external TRIG, UDP 50005\r\n");}
int start_application(void) {return das_udp_start();}
int transfer_data(void) {das_dma_poll();return 0;}
void print_app_header(void) {das_print_app_header();}
