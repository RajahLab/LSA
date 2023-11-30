function [] = create_secondLevel_groupBatch()
%% Author: Charana Rajagopal (charana.rajagopal@gmail.com). This example script was downloaded from hippocampish( http://hippocampish.wordpress.com/2013/03/19/setting-up-a-subject-batch-script-with-spm8/ ) and contains spm
% Script to run second level GLM for LSA
curdir = pwd;
%% Define variables for the subject
%Second Level output dir
b.outputDir=fullfile('/path/to/SecondLevel');
% Create directory to store output files
if ~exist(b.outputDir, 'dir')
    mkdir(b.outputDir);
end
%First Level input dir
dataDir='/path/to/FirstLevel';

%% Across Groups
subjList = {'001','002'};
%% Get contrast images
% %Use for RT modulation GLM Second Level analysis
% contrastNames={'EncAll-RetOld','EncWithRTxPostRT_pos','EncWithRTxPostRT_neg','EncWithRTXPreRT_pos','EncWithRTXPreRT_neg','EncAllDeactivations','EncAllActivations','EncWithRT-RetOld','EncNoRT-RetOld','EncWithRTActivations','EncNoRTActivations','EncWithRTDeactivations','EncNoRTDeactivations', 'RetOld-EncWithRT'};
% contrastNumbers={'C1','C2','C3','C4', 'C5', 'C6', 'C7', 'C8','C9', 'C10', 'C11', 'C12', 'C13','C14'};
% Use for Memory GLM Second level analysis
contrastNames={'SourceFail-Hit', 'SourceHit-Fail'};
contrastNumbers={'C1', 'C2'};


for j=1:numel(contrastNumbers)
    cd(curdir);
    b.outDirName=contrastNames{j};
    conID=str2num(extractAfter(contrastNumbers{j}, 'C'));
    b.scans=load_scans(dataDir, subjList, conID);

    %% % specify matlabbatch variable with subject-specific inputs
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');

    matlabbatch = batch_job_onesample(b);
    %   save matlabbatch variable for posterity
    outName = strcat(b.outDirName, '_', contrastNumbers{j},'_Batch');
    save([b.outputDir, '/', outName], 'matlabbatch');
    
    %  run matlabbatch job
    try
        spm_jobman('serial', matlabbatch);
    catch ME1
        cd(curdir);

    end
end
cd(curdir);
end
%% One sample t-test
function [matlabbatch]=batch_job_onesample(b)
matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(b.outputDir,b.outDirName)};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(b.scans(:));
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model Estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = b.outDirName;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec(1).titlestr = '';
matlabbatch{4}.spm.stats.results.conspec(1).contrasts = Inf;
matlabbatch{4}.spm.stats.results.conspec(1).threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec(1).thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec(1).extent = 0;
matlabbatch{4}.spm.stats.results.conspec(1).conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec(1).mask.none = 1;
matlabbatch{4}.spm.stats.results.conspec(2).titlestr = '';
matlabbatch{4}.spm.stats.results.conspec(2).contrasts = Inf;
matlabbatch{4}.spm.stats.results.conspec(2).threshdesc = 'FWE';
matlabbatch{4}.spm.stats.results.conspec(2).thresh = 0.05;
matlabbatch{4}.spm.stats.results.conspec(2).extent = 0;
matlabbatch{4}.spm.stats.results.conspec(2).conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec(2).mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;

end


