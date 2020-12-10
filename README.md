# SPICE simulation framework for poly-Si amplifiers

A set of simulation scripts used to run SPICE simulations on amplifier circuit designs based on polysilicon transistors.  The frameworks ingest mcards (model cards based on measured poly-Si transistor data) and calculate the gain, noise, and speed of a given circuit configuration.

Most of this work was developed to support the design and development of the SPC1 photon counting ASIC prototypes for Dr. Larry Antonuk's imager group.

## Overview

Two simulation frameworks (run_sims.sh in this folder and amp.sh in the simplified_noise_framework folder)
* amp.sh figures out the correct bias voltages to use
* run.sh calculates the maximum count rate of a given circuit

## Batch processing

amp.sh has a special runtime to check several configurations in batch
* generate a WLtable (following one of the WLtable_* as template)
* run sweepWL.sh <WLtable> and it will launch several instances of amp.sh to cover every row in WLtable


