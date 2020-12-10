#!/bin/bash

#ls -1d simruns/20151124*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH
#ls -1d simruns/20151201*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH
#ls -1d simruns/20151210T13*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH
#ls -1d simruns/20151210T15*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH

#ls -1d simruns/20151209*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH
#ls -1d simruns/20151210*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH
#ls -1d simruns/20151221*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH


#ls -1d simruns/20160106*  | sed -e "s%^%compute_noise('./%" -e "s%$%/CZT');%" | octave -qH

#ls -1d /mnt/Cloud2/spc_testbenches/spie2016_presentation/simplified_noise_framework/simruns/20160108_one_stage_compinload_1Grfb/*  | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160108_one_stage_compinload_1Grfb_gtarget0.05-0.2.txt
#ls -1d /mnt/Cloud2/spc_testbenches/spie2016_presentation/simplified_noise_framework/simruns/20160108_one_stage_compinload_100MEGrfb/*  | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160108_one_stage_compinload_100MEGrfb_gtarget0.05-0.2.txt

#ls -1d /mnt/Cloud2/spc_testbenches/spie2016_presentation/simplified_noise_framework/simruns/20160111T152* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#ls -1d C2simruns/20160111T155* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#ls -1d C2simruns/20160111T19* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH

#ls -1d C1simruns/20160113* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#ls -1d C1simruns/20160114T* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt 20160114_supercombo3_500fcin_10MEGrfb_250umpix_gtarget0.05-0.2.txt

#ls -1d C1simruns/20160125T* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160125_supercombo4_500fcin_10MEGrfb_250umpix_gtarget0.05-0.2_fixedbode_Tmat.txt

#ls -1d C1simruns/20160202T* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160202_WLsweep_500fcin_10MEGrfb_250umpix_gtarget0.25-2_Tmatana.txt

#ls -1d C1simruns/20160210_fullthermaleq/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160210_WLsweep_fullthermaleq_500fcin_10MEGrfb_250umpix_gtarget0.25-2.txt
#ls -1d C1simruns/20160210_simplifiedthermaleq/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160210_WLsweep_simplifiedthermaleq_500fcin_10MEGrfb_250umpix_gtarget0.25-2.txt

#ls -1d C1simruns/20160212T* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160212_WLsweep_twostage_500fcin_10MEGrfb_250umpix_gtarget1-1.5.txt

#ls -1d C1simruns/20160330_1mmpitch/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160330_1mmpitch.txt

#ls -1d C1simruns/20160408_three_stage/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160408_three_stage.txt

#ls -1d C1simruns/20160419_cin_rdet_rfb_vars/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT',[50 10]);%" | octave -qH
#mv adat.txt adat_20160419_cin_rdet_rfb_vars.txt

#ls -1d C1simruns/20160425T* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT',[56 5]);%" | octave -qH
#mv adat.txt adat_20160425_cin_rdet_rfb_vars_r56c5.txt

#ls -1d C1simruns/20160426_three_stage_cin_rdet_sweep/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT',[56 5]);%" | octave -qH
#mv adat.txt adat_20160426_cin_rdet_rfb_vars_r56c5_threestage.txt

#ls -1d C1simruns/20160426_three_stage_cin_rdet_sweep/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160426_cin_rdet_rfb_vars_threestage.txt

#ls -1d C1simruns/20160426_three_stage_cin_rdet_sweep/* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH
#mv adat.txt adat_20160426_cin_rdet_rfb_vars_threestage_gtarget125.txt

ls -1d C1simruns/20160502T* | sed -e "s%^%compute_noise('%" -e "s%$%/CZT');%" | octave -qH





