function [] = create_SuccessVsFailure_GLM(subject_id, dataDir, onsetFile, output_dir)
%% Author: Charana Rajagopal (charana.rajagopal@gmail.com). This example script was downloaded from hippocampish( http://hippocampish.wordpress.com/2013/03/19/setting-up-a-subject-batch-script-with-spm8/ ) and contains spm
%% Code to create & run first level Memory GLM for LSA
%Inputs: This function takes four inputs:
% subject_id - string specifying the subject_id.
% niftiDir  - string with full path to Nifti files. Eg: '/path/to/myDir'
% onsetFile - full path of subject's onset file. Eg:'/path/to/onsets/onset.xlsx'
% output_dir - path to store SPM.mat & batch file
% To call this function type create_SuccessVsFailure_GLM(subject_id, niftiDir, onsetFile, output_dir)

%clear all;
curdir = pwd;
% output_dir='/data/laborajah3/Attention_Memory/SPM_Analyses/Nov2023/SourceHitVsSourceFailure/';

%% Get Onset values
%Enc
T=readtable(onsetFile, 'Sheet', 'Summary_ONSETS', 'Format', 'auto');
b.onsets_Enc{1}.name='EncCorrectSource';
notNanIdx=~isnan(T.ENCCorrectSource(1:end-1,:));
b.onsets_Enc{1}.value=T.ENCCorrectSource(notNanIdx);

b.onsets_Enc{2}.name='EncSourceFailure'; %Recog SMiss


if any(~isnan(T.ENCMisses(1:end-1,:)))
    temp=[T.ENCRecog(1:end-1,:); T.ENCSMiss(1:end-1,:); T.ENCMisses(1:end-1,:)];
else
    temp=[T.ENCRecog(1:end-1,:); T.ENCSMiss(1:end-1,:);];
end
notNanIdx=~isnan(temp);
b.onsets_Enc{2}.value=sort(temp(notNanIdx));

%Ret
b.onsets_Ret{1}.name='RetCorrectSource';
notNanIdx=~isnan(T.RETCorrectSource(1:end-1,:));
b.onsets_Ret{1}.value=T.RETCorrectSource(notNanIdx);

b.onsets_Ret{2}.name='RetSourceFailure'; %Recog SMiss
temp=[T.RETRecog(1:end-1,:); T.RETSMiss(1:end-1,:); T.RETMisses(1:end-1,:)];
notNanIdx=~isnan(temp);
b.onsets_Ret{2}.value=sort(temp(notNanIdx));

b.onsets_Ret{3}.name = 'RetCorrectRejections';
notNanIdx=~isnan(T.RETCorrectRejections(1:end-1,:));
b.onsets_Ret{3}.value=T.RETCorrectRejections(notNanIdx);

b.onsets_Ret{4}.name = 'RetFalseAlarms';
notNanIdx=~isnan(T.RETFalseAlarms(1:end-1,:));
b.onsets_Ret{4}.value=T.RETFalseAlarms(notNanIdx);

% No response onsets
b.onsets_NoResp={};
notNanIdx=~isnan(T.ENC_RETNoResp(1:end-1,:));
idx=1; %keep track enc/ret no response conditions
if any(notNanIdx)
    b.onsets_NoResp{idx}.name = 'EncNoResponses';  
    b.onsets_NoResp{idx}.value=T.ENC_RETNoResp(notNanIdx);
    idx=idx+1;
end

temp=[T.RETNoRespOld(1:end-1,:); T.RETNoRespNew(1:end-1,:)];
if any(temp)
    b.onsets_NoResp{idx}.name = 'RetNoResponses';
    notNanIdx=~isnan(temp);
    b.onsets_NoResp{idx}.value=sort(temp(notNanIdx));
end



%% Define variables for the subject
b.curSubj = subject_id;
b.dataDir = strcat(dataDir,'/sub-',b.curSubj);
b.scans=spm_select('ExtFPList',b.dataDir, '^sub');
b.scans=strcat(b.scans);
b.scans=cellstr(b.scans);
b.outputDir=fullfile(output_dir,'FirstLevel', ['sub-', b.curSubj]);
b.SPMdir=fullfile(b.outputDir);

% Create directory to store output files
if ~exist(b.outputDir, 'dir')
        mkdir(b.outputDir);
end

%% Make contrast vector

Glm_contrast_file=fullfile(output_dir,'sourceHitvsFail_firstlevelcontrasts.xlsx');
T2 = readtable(Glm_contrast_file);%,opts, 'ReadVariablenames', true);
T2( any(ismissing(T2),2), :) = [];
b.contrastNames=strcat(T2.Var1);
b.contrastNames=b.contrastNames(~cellfun('isempty',b.contrastNames));

%% % specify matlabbatch variable with subject-specific inputs
spm('defaults', 'FMRI');
spm_jobman('initcfg');

matlabbatch = batch_job(b, T2(:, 3:end));

%   save matlabbatch variable for posterity
outName = strcat(b.curSubj, '_SuccessVsFailure');
save([b.outputDir, '/sub-', outName], 'matlabbatch');

%  run matlabbatch job

try
    spm_jobman('serial', matlabbatch);
catch ME1
    cd(curdir);
   
end


end

function [matlabbatch]=batch_job(b, T)
%-----------------------------------------------------------------------
% Job saved on 19-May-2022 10:07:22 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(b.SPMdir);
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.7;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 44;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 22;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = b.scans;
%% Encoding onsets
for i = 1:numel(b.onsets_Enc)
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).name = b.onsets_Enc{i}.name;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).onset=b.onsets_Enc{i}.value;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).orth = 1;
end
%% Ret onsets
for j = 1:numel(b.onsets_Ret)
    id=numel(b.onsets_Enc) + j;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).name = b.onsets_Ret{j}.name;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).onset = b.onsets_Ret{j}.value;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).orth = 1;
end

%% NoResponse onsets
if numel(b.onsets_NoResp)>0
    for k = 1:numel(b.onsets_NoResp)
        id=numel(b.onsets_Enc) + numel(b.onsets_Ret) + k;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).name = b.onsets_NoResp{k}.name;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).onset = b.onsets_NoResp{k}.value;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(id).orth = 1;
    end
end
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('Model Estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
for i=1:numel(b.contrastNames)
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.name = b.contrastNames{i};
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.weights = table2array(T(i,:));
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
end
matlabbatch{3}.spm.stats.con.delete = 0;  


end




