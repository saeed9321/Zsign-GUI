#!/bin/sh

#  Script.sh
#  ZsignGUI
#
#  Created by Said Al Mujaini on 4/15/22.
#

# Command

cert=$1
prov=$2
ipa=$3
out_ipa=$4

echo "------------ Codesigning with ----------"
echo "certificate   :"$cert
echo "provision     :"$prov
echo "ipa           :"$ipa
echo "output ipa    :"$out_ipa

zsign -k $cert -m $prov -z 9 -o $out_ipa $ipa
