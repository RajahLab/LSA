function [] = create_RTmodulation_GLM(subject_id, niftiDir, onsetFile, output_dir)
%% Author: Charana Rajagopal (charana.rajagopal@gmail.com). This example script was downloaded from hippocampish( http://hippocampish.wordpress.com/2013/03/19/setting-up-a-subject-batch-script-with-spm8/ ) and contains spm
%% Code to create & run first level RT modulation GLM for LSA
% Inputs: This function takes four inputs:
% subject_id - string specifying the subject_id.
% niftiDir  - string with full path to Nifti files. Eg: '/path/to/myDir'
% onsetFile - full path of subject's onset file. Eg:'/path/to/onsets/onset.xlsx'
% output_dir - path to store SPM.mat & batch file
% To call this function type create_RTmodulation_GLM(subject_id, niftiDir, onsetFile, output_dir)

curdir = pwd;

%% Get Onset values
%Enc
b.onsets_Enc=getEncOnsetVectors2(onsetFile, 'ENC', 'EncWithRT');
%Ret
b.onsets_Ret=getRetOnsetVectors2(onsetFile, 'RET');


%% Define variables for the subject
b.curSubj = subject_id;
b.niftiDir = strcat(niftiDir,'/sub-',b.curSubj);
b.scans=spm_select('ExtFPList',b.niftiDir, '^sub');
b.scans=strcat(b.scans);
b.scans=cellstr(b.scans);
b.outputDir=fullfile(output_dir, 'FirstLevel', ['sub-', b.curSubj]);

% Create directory to store output files
if ~exist(b.outputDir, 'dir')
        mkdir(b.outputDir);
end


%% Make contrast vector

Glm_contrast_file=fullfile(output_dir, 'first_level_contrasts.xlsx');
T2 = readtable(Glm_contrast_file);%,opts, 'ReadVariablenames', true);
T2( any(ismissing(T2),2), :) = [];
b.contrastNames=strcat(T2.Var1);
b.contrastNames=b.contrastNames(~cellfun('isempty',b.contrastNames));

%% % specify matlabbatch variable with subject-specific inputs
spm('defaults', 'FMRI');
spm_jobman('initcfg');
%% PostPre
matlabbatch = batch_job_PostPre(b, T2(:, 3:end));

%   save matlabbatch variable for posterity
outName = strcat(b.curSubj, '_PostPre');
save([b.outputDir, '/sub-', outName], 'matlabbatch');

% %  run matlabbatch job
try
    spm_jobman('serial', matlabbatch);
catch ME1
    cd(curdir);
    
end
end

function [matlabbatch]=batch_job_PostPre(b,T)
%-----------------------------------------------------------------------
% Job saved on 19-May-2022 10:07:22 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(b.outputDir);
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.7;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 44;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 22;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = b.scans;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = b.onsets_Enc.name;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset=b.onsets_Enc.value;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1).name = 'Post_stim_RT';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1).param = b.onsets_Enc.PostStimRT;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(2).name = 'Pre_stim_RT';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(2).param = b.onsets_Enc.PreStimRT;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(2).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = b.onsets_Ret.RetOld.name;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = b.onsets_Ret.RetOld.value;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = b.onsets_Ret.RetNew.name;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = b.onsets_Ret.RetNew.value;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).orth = 0;
if numel(b.onsets_Enc.EncNoRT.value) > 0
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = b.onsets_Enc.EncNoRT.name;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = b.onsets_Enc.EncNoRT.value;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).orth = 0;
end
if numel(b.onsets_Ret.RetNoResp.value) > 0
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = b.onsets_Ret.RetNoResp.name;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = b.onsets_Ret.RetNoResp.value;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).orth = 0;
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

