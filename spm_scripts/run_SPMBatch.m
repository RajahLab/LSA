%% Author: Charana Rajagopal.
% Script to run first level analysis over all subjects 
%% Set paths
nifti_path='/path/to/nifti/';
onsets_path='/path/to/onsetFiles/';

hitVsfail_output_dir='';
RT_modulation_output_dir='';

subjList = {'001','002'};

for i=1:numel(subjList)
    try
%         create_RTmodulation_GLM(subjList{i},nifti_path , strcat(onsets_path, 'Attention_Onset_',subjList{i},'.xlsx'), RT_modulation_output_dir);
        create_SuccessVsFailure_GLM(subjList{i}, nifti_path, strcat(onsets_path, 'Attention_Onset_',subjList{i},'.xlsx'), hitVsfail_output_dir);
  catch ME
        disp(ME.message);
    end
end
    