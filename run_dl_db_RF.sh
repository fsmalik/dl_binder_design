#!/bin/zsh

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "Runs dl_binder_design for RF diffusion results step by step. All files will end up in the directory with RFdiffusion results"
   echo
   echo "Syntax: run_dl_db_RF.sh /path/to/dir/with/rfdiffusion/results /path/to/dl_binder_design/base-dir [-h]"
   echo "options:"
   echo "  -h     Print this Help."
   echo
}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################
# Get the options
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

RFRESULTSDIR=$1
DLDESIGNDIR=$2

mkdir $RFRESULTSDIR/pdbs $RFRESULTSDIR/trbs
mv $RFRESULTSDIR/*.pdb $RFRESULTSDIR/pdbs
mv $RFRESULTSDIR/*.trb $RFRESULTSDIR/trbs

python $DLDESIGNDIR/helper_scripts/addFIXEDlabels.py --pdbdir $RFRESULTSDIR/pdbs --trbdir $RFRESULTSDIR/trbs

cd $DLDESIGNDIR/include/silent_tools/

./silentfrompdbs $RFRESULTSDIR/pdbs/*.pdb > $RFRESULTSDIR/my_design.silent

cd $RFRESULTSDIR

python $DLDESIGNDIR/mpnn_fr/dl_interface_design.py -silent my_design.silent

python $DLDESIGNDIR/af2_initial_guess/predict.py -silent out.silent

cd $DLDESIGNDIR/include/silent_tools/

./silentextract $RFRESULTSDIR/out.silent

mv *.pdb $RFRESULTSDIR/

cd $RFRESULTSDIR

mkdir pdb_results_af

mv *.pdb pdb_results_af
