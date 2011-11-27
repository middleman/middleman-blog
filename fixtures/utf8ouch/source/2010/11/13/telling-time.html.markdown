---
title: Telling Time.
date: 2010/11/13
---

Norse legend tells of the end of this cycle of Middle Earth,
before the death of gods and the total submergence of its peoples. A
great battle will take place before this time, called Ragnarok, in
which even Odin will meet his fate in the jaws of Fenrir. Yet, the
future might be bent; the All Father watches anxiously for signs of
Ragnarok's quickening.

READMORE

It was said that after hanging from Yggdrasil, Odin learned of eighteen runes; nine of which he would tell no one. From these had Odin learned Posix programming perhaps he might have constructed himself a warning device.

    #include <stdio.h>
    #include <stdlib.h>
    #include <signal.h>
    #include <stdbool.h>
    #include <sys/time.h>

    bool near = false ;

    void handler(int cause, siginfo_t *HowCome, void *ucontext) {
      near = !near;
    }

    int main() {
      struct itimerval itimer;
      struct sigaction sa;
      int i = 0;

      sigemptyset( &sa.sa_mask ); /* Block no signals. */
      sa.sa_flags = SA_SIGINFO;   /* Route signal handler to sa_sigaction */
      sa.sa_sigaction = handler;  /* Define fancy handler. */
      if (sigaction (SIGALRM, &sa, 0)) {
        perror("sigaction");
        exit(EXIT_FAILURE);
      }

      itimer.it_value.tv_sec=0;
      itimer.it_value.tv_usec=7000;    /* 0.007 seconds to the next timer. */
      itimer.it_interval.tv_sec=0;
      itimer.it_interval.tv_usec=7000; /* 0.007 seconds for each timer after. */
      setitimer(ITIMER_REAL, &itimer, NULL);

      while (i != 1000000) {
        switch (near) {
        case false: {
          ++i;
        } break;
        case true: {
          --i; // BUG FIX: Damned small monitor. + is - with only one eye!
        } break;
        }
      }

      /*
        Sneru þær af afli
        örlögþáttu,
        þá er borgir braut
        í Bráluni;
        þær of greiddu
        gullin símu
        ok und mánasal
        miðjan festu.
      */

      printf("Ragnarök is nigh.\n");
      exit(EXIT_SUCCESS);
    }

