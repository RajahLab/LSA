 ## To run dcm2bids - Charana Rajagopal
## make sure you activate conda environment before running this
## conda activate dcm2bids (OR)
## source activate dcm2bids
## To run - bash run_dcm2bids.sh 015 
##
subjID=$1
counter_balance_sheet=/path/to/Participant_counterbalance_sheet.xlsx
#Set up folders & config file
dicomDir=$(ls -d /path/to/dicom/*_${subjID}_*/)
bidsDir=/path/to/BIDS
scriptDir=${bidsDir}/code
config_file=bids_config.json
#DICOm to BIDS convert
dcm2bids -d ${dicomDir}  -p ${subjID} -c ${config_file} -o $bidsDir


#Edit Json file to add fieldmap info
echo "Adding fieldmap to phasediff json files..........."
#extract acq order
acq_ord=$(xlsx2csv $counter_balance_sheet | sed -e's/"//g' | while read l; do d=`echo "$l" |awk '{printf "%03d", $1}'`; if [[ "$d" == "$subjID" ]] ; then  ord=`echo "$l"|cut -d, -f5,6,7,8 | sed -e's/,/ /g'`; echo "$ord" ; fi ; done)
echo $acq_ord
#edit json file
python editJsonFile.py $subjID $acq_ord


echo "Removing Localizer & temporary files"
rm -r $bidsDir/tmp_dcm2bids

