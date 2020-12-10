# SPICE simulation framework for poly-Si amplifiers

## Overview

Two simulation frameworks (run_sims.sh in this folder and amp.sh in the simplified_noise_framework folder)
* amp.sh figures out the correct bias voltages to use
* run.sh calculates the maximum count rate of a given circuit

## Batch processing

amp.sh has a special runtime to check several configurations in batch
* generate a WLtable (following one of the WLtable_* as template)
* run sweepWL.sh <WLtable> and it will launch several instances of amp.sh to cover every row in WLtable


