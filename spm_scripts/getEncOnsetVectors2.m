function [onsets] = getEncOnsetVectors2(onsetFile, sheetName, onsetName)
%% Author: Charana Rajagopal (charana.rajagopal@gmail.com).
%% Code to create & run first level Memory GLM for LSA
%Inputs: This function takes three inputs:
% onsetFile - full path of subject's onset file. Eg:'/path/to/onsets/onset.xlsx'
% sheetName - string containing name of excel sheet
% onsetName - string containing name for onset vector
% Outputs:
% onsets - struct containing onset name, value and duration for SPM
% To call this function type onsets=getRetOnsetVectors2(onsetFile, sheetName, onsetName)
% NOTE: only to use for matlab versions>2020
%%
T = readtable(onsetFile, 'Sheet', sheetName, 'Format', 'auto');
notNanIdx=~isnan(T.PreStimRT);
%EncWithRT (has both Pre/PostRT)
onsets.name=onsetName;
onsets.value=T.ENCStimOnset(notNanIdx);
onsets.PreStimRT=T.MeanCorrectedPre(notNanIdx);
onsets.PostStimRT=T.MeanCorrectedPost(notNanIdx);

%EncNoRT - does not have either pre or post RT.
onsets.EncNoRT.name='EncNoRT';
onsets.EncNoRT.value=T.ENCStimOnset(isnan(T.PreStimRT));
onsets.EncNoRT.value=onsets.EncNoRT.value(~isnan(onsets.EncNoRT.value));

end

