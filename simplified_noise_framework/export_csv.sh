#!/bin/bash




gawk 'BEGIN { OFS="," } { print $1,$4,$5,$6,$7,$9,$14,$15,$17,$18,$19,$20,$21,$22,$23 }' "$1" | \
  sed -r -e "s/.*([0-9]{8}T[0-9]{6}_)/\1/" \
         -e "s/_three_stage//" \
         -e "s/_compinload//" \
         -e "s/_dp_/_/" \
         -e "s/_m2.*_m4_[0-9]*u[0-9]*u//" \
         -e "s/_rfb_[0-9]*[A-Za-z]*_/_/" \
         -e "s/_rdet_[0-9]*[A-Za-z]*_/_/" \
         -e "s/_cpar_[0-9]*[A-Za-z]*_/_/" \
         -e "s%/CZT%%" \
         -e "s/PITCH1000e-6/P1mm/" \
         -e "s/PITCH250e-6/P250um/"

