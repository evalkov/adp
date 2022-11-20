#!/bin/sh
aimless \
         hklin      XDS_ASCII.mtz \
         scales     aimless.scales \
         plot       aimless.plt \
         rogues     aimless.rogues \
         correlplot aimless_correl.xmgr \
         rogueplot  aimless_rogue.xmgr \
         normplot   aimless_norm.xmgr \
         anomplot   aimless_anom.xmgr \
         hklout     aimless.mtz \
         scalepack  aimless.sca \
         <<end_inp
ANOMALOUS ON
RUN      1 BATCH 1 TO 1000
CYCLES 20
BINS 10
RESOLUTION RUN   1   18.8 1.25 ! recommended resolution cut based on...

REJECT SCALE   6 ALL -8
REJECT MERGE   6 ALL -8
!
REFINE PARALLEL 2 ! Number of CPUs for parallelisation
LINK SURFACE ALL

!
SCALES ROTATION SPACING 5.0 ABSORPTION 6 BFACTOR ON
OUTPUT MERGED
!RESTORE aimless.scales ! Read scales and SDcorrection parameters from a SCALES file from a previous run of Aimless
end_inp

