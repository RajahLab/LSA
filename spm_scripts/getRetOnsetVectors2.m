function [onsets] = getRetOnsetVectors2(onsetFile, sheetName)
%% Author: Charana Rajagopal (charana.rajagopal@gmail.com).
%% Code to create & run first level Memory GLM for LSA
%Inputs: This function takes three inputs:
% onsetFile - full path of subject's onset file. Eg:'/path/to/onsets/onset.xlsx'
% sheetName - string containing name of excel sheet
% onsetName - string containing name for onset vector
% Outputs:
% onsets - struct containing onset name, value and duration for SPM
% To call this function type onsets=getEncOnsetVectors2(onsetFile, sheetName, onsetName)
% NOTE: only to use for matlab versions>2020
%%
T = readtable(onsetFile, 'Sheet', sheetName, 'Format', 'auto');
onsets.RetOld.name='RetOld';
oldRespIdx=~isnan(T.RETRESP) & strcmp(T.RETTrialType, 'Old');
onsets.RetOld.value=T.StimOnset(oldRespIdx);
onsets.RetOld.value=onsets.RetOld.value(~isnan(onsets.RetOld.value));

onsets.RetNew.name='RetNew';
newRespIdx=~isnan(T.RETRESP) & strcmp(T.RETTrialType, 'New');
onsets.RetNew.value=T.StimOnset(newRespIdx);
onsets.RetNew.value=onsets.RetNew.value(~isnan(onsets.RetNew.value));

onsets.RetNoResp.name='RetNoResp';
noRespIdx=isnan(T.RETRESP);
onsets.RetNoResp.value=T.StimOnset(noRespIdx);
onsets.RetNoResp.value=onsets.RetNoResp.value(~isnan(onsets.RetNoResp.value));



end

