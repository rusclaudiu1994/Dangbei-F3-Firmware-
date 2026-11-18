#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <poll.h>
#include <sys/stat.h>
#include "page.h"
#include "campage.h"
#include <arpa/inet.h>
#include <sys/wait.h>
#ifndef TOKEN_FILE
#define TOKEN_FILE "/data/touchpadd/token"
#endif
#ifndef HA_IP
#define HA_IP "192.168.1.155"
#endif
#ifndef HA_PORT
#define HA_PORT 8123
#endif
#ifndef CAM_ENTITY
#define CAM_ENTITY "camera.camera_levi"
#endif
#define FLAG "/data/local/tmp/touchpadd.off"
static int ufd=-1;
static void emit(int type,int code,int val){struct input_event ev;memset(&ev,0,sizeof ev);ev.type=type;ev.code=code;ev.value=val;if(write(ufd,&ev,sizeof ev)<0){}}
static void syn(void){emit(EV_SYN,SYN_REPORT,0);}
static void dev_off(void){ if(ufd>=0){ ioctl(ufd,UI_DEV_DESTROY); close(ufd); ufd=-1; } }
static int setup(void){
  if(ufd>=0) return 0;
  ufd=open("/dev/uinput",O_WRONLY|O_NONBLOCK); if(ufd<0) return -1;
  ioctl(ufd,UI_SET_EVBIT,EV_KEY); ioctl(ufd,UI_SET_KEYBIT,BTN_LEFT); ioctl(ufd,UI_SET_KEYBIT,BTN_RIGHT); ioctl(ufd,UI_SET_KEYBIT,BTN_MIDDLE);
  ioctl(ufd,UI_SET_EVBIT,EV_REL); ioctl(ufd,UI_SET_RELBIT,REL_X); ioctl(ufd,UI_SET_RELBIT,REL_Y); ioctl(ufd,UI_SET_RELBIT,REL_WHEEL);
  struct uinput_user_dev d; memset(&d,0,sizeof d); snprintf(d.name,UINPUT_MAX_NAME_SIZE,"Touchpad Proiector");
  d.id.bustype=BUS_VIRTUAL; d.id.vendor=0x1d6b; d.id.product=0x0101; d.id.version=1;
  if(write(ufd,&d,sizeof d)!=sizeof d){close(ufd);ufd=-1;return -2;}
  if(ioctl(ufd,UI_DEV_CREATE)<0){close(ufd);ufd=-1;return -3;}
  return 0;
}
static int btn(char c){return c=='r'?BTN_RIGHT:c=='m'?BTN_MIDDLE:BTN_LEFT;}
static void handle_events(char *q){
  char *save=NULL; for(char *t=strtok_r(q,";",&save);t;t=strtok_r(NULL,";",&save)){
    if(t[0]=='m'){int x=0,y=0; if(sscanf(t,"m,%d,%d",&x,&y)==2){ if(x>500)x=500; if(x<-500)x=-500; if(y>500)y=500; if(y<-500)y=-500; if(x)emit(EV_REL,REL_X,x); if(y)emit(EV_REL,REL_Y,y); syn(); }}
    else if(t[0]=='w'){int w=0; if(sscanf(t,"w,%d",&w)==1 && w){ if(w>20)w=20; if(w<-20)w=-20; emit(EV_REL,REL_WHEEL,w); syn(); }}
    else if(t[0]=='c' && t[1]==','){int b=btn(t[2]); emit(EV_KEY,b,1); syn(); usleep(30000); emit(EV_KEY,b,0); syn();}
    else if(t[0]=='b' && t[1]==','){int v=(t[4]=='1'); emit(EV_KEY,btn(t[2]),v); syn();}
  }
}
static void reply(int c,const char *type,const char *body,size_t len){
  char h[256]; int n=snprintf(h,sizeof h,"HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %zu\r\nAccess-Control-Allow-Origin: *\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n",type,len);
  if(write(c,h,n)<0){} size_t o=0; while(o<len){ssize_t w=write(c,body+o,len-o); if(w<=0)break; o+=w;}
}

static void cam_proxy(int c){
  pid_t p=fork(); if(p!=0){ close(c); return; }
  if(fork()!=0) _exit(0);
  char tok[1024]={0}; int tf=open(TOKEN_FILE,O_RDONLY); if(tf<0){ reply(c,"text/plain","no token",8); _exit(0);} int tn=read(tf,tok,sizeof tok-1); close(tf); if(tn<=0){reply(c,"text/plain","no token",8);_exit(0);} tok[tn]=0; for(int k=tn-1;k>=0&&(tok[k]=='\n'||tok[k]=='\r'||tok[k]==' ');k--) tok[k]=0;
  int h=socket(AF_INET,SOCK_STREAM,0); struct sockaddr_in a; memset(&a,0,sizeof a); a.sin_family=AF_INET; a.sin_port=htons(HA_PORT); inet_pton(AF_INET,HA_IP,&a.sin_addr);
  struct timeval tv={10,0}; setsockopt(h,SOL_SOCKET,SO_RCVTIMEO,&tv,sizeof tv);
  if(connect(h,(struct sockaddr*)&a,sizeof a)<0){ reply(c,"text/plain","ha down",7); _exit(0);} 
  char req[1400]; int rn=snprintf(req,sizeof req,"GET /api/camera_proxy_stream/%s HTTP/1.1\r\nHost: %s:%d\r\nAuthorization: Bearer %s\r\nConnection: close\r\n\r\n",CAM_ENTITY,HA_IP,HA_PORT,tok);
  if(write(h,req,rn)<0) _exit(0);
  char buf[16384]; int got=0; char *end=NULL;
  while(got<(int)sizeof buf-1){ ssize_t n=read(h,buf+got,sizeof buf-1-got); if(n<=0) _exit(0); got+=n; buf[got]=0; end=strstr(buf,"\r\n\r\n"); if(end) break; }
  if(!end) _exit(0);
  char ct[256]="multipart/x-mixed-replace"; char *q=strcasestr(buf,"\r\nContent-Type:"); if(q){ q+=15; while(*q==' ')q++; int k=0; while(q[k]&&q[k]!='\r'&&k<255){ct[k]=q[k];k++;} ct[k]=0; }
  int status=atoi(buf+9);
  char hd[512]; int hn=snprintf(hd,sizeof hd,"HTTP/1.1 %d OK\r\nContent-Type: %s\r\nCache-Control: no-store\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n",status,ct);
  if(write(c,hd,hn)<0) _exit(0);
  int body=got-(int)(end+4-buf); if(body>0 && write(c,end+4,body)<0) _exit(0);
  struct timeval tv2={30,0}; setsockopt(h,SOL_SOCKET,SO_RCVTIMEO,&tv2,sizeof tv2);
  for(;;){ ssize_t n=read(h,buf,sizeof buf); if(n<=0) break; ssize_t o=0; while(o<n){ ssize_t w=write(c,buf+o,n-o); if(w<=0) _exit(0); o+=w; } }
  _exit(0);
}
int main(int argc,char**argv){
  signal(SIGPIPE,SIG_IGN); signal(SIGHUP,SIG_IGN); signal(SIGCHLD,SIG_IGN);
  if(!(argc>2 && strcmp(argv[2],"-f")==0)){ pid_t p=fork(); if(p<0) return 1; if(p>0) return 0; setsid(); p=fork(); if(p>0) _exit(0); int nfd=open("/dev/null",O_RDWR); if(nfd>=0){dup2(nfd,0);dup2(nfd,1);dup2(nfd,2);} chdir("/"); }
  int port=argc>1?atoi(argv[1]):8099;
  struct stat sb;
  int s=socket(AF_INET,SOCK_STREAM,0); int one=1; setsockopt(s,SOL_SOCKET,SO_REUSEADDR,&one,sizeof one);
  struct sockaddr_in a; memset(&a,0,sizeof a); a.sin_family=AF_INET; a.sin_port=htons(port); a.sin_addr.s_addr=htonl(INADDR_ANY);
  if(bind(s,(struct sockaddr*)&a,sizeof a)<0){perror("bind");return 1;} listen(s,32);
  for(;;){
    int off=(stat(FLAG,&sb)==0);
    if(off && ufd>=0) dev_off();
    if(!off && ufd<0) setup();
    struct pollfd pf={s,POLLIN,0}; if(poll(&pf,1,700)<=0) continue;
    int c=accept(s,NULL,NULL); if(c<0) continue;
    setsockopt(c,IPPROTO_TCP,TCP_NODELAY,&one,sizeof one);
    struct timeval tv={2,0}; setsockopt(c,SOL_SOCKET,SO_RCVTIMEO,&tv,sizeof tv);
    char buf[4096]; ssize_t n=read(c,buf,sizeof buf-1); if(n<=0){close(c);continue;} buf[n]=0;
    char *sp=strchr(buf,' '); char *path=sp?sp+1:buf; char *e=strchr(path,' '); if(e)*e=0;
    if(strncmp(path,"/cam.mjpg",9)==0){ cam_proxy(c); while(waitpid(-1,NULL,WNOHANG)>0){} continue; }
    if(strcmp(path,"/camera")==0){ reply(c,"text/html; charset=utf-8",CAMPAGE,strlen(CAMPAGE)); shutdown(c,SHUT_WR); close(c); continue; }
    if(strncmp(path,"/e?q=",5)==0){ if(ufd>=0) handle_events(path+5); reply(c,"text/plain","ok",2); }
    else if(strcmp(path,"/off")==0){ int f=open(FLAG,O_CREAT|O_WRONLY,0666); if(f>=0)close(f); chmod(FLAG,0666); dev_off(); reply(c,"text/plain","off",3); }
    else if(strcmp(path,"/on")==0){ unlink(FLAG); setup(); reply(c,"text/plain",ufd>=0?"on":"err",ufd>=0?2:3); }
    else if(strcmp(path,"/state")==0){ reply(c,"text/plain",ufd>=0?"on":"off",ufd>=0?2:3); }
    else if(strcmp(path,"/ping")==0){ reply(c,"text/plain",ufd>=0?"ok":"no-uinput",ufd>=0?2:9); }
    else { reply(c,"text/html; charset=utf-8",PAGE,strlen(PAGE)); }
    shutdown(c,SHUT_WR); close(c);
  }
}
