"""
Created on Mon Apr 11 12:10:46 2022

@author: rajsri
"""

import pandas
import numpy
import math
import nilearn
import os
import sys
import matplotlib.pyplot as plt
import matplotlib
import glob
import re
from collections import OrderedDict
from datetime import date, datetime
from nilearn.input_data import NiftiMasker, MultiNiftiMasker
from nilearn.image import concat_imgs, index_img
from nilearn import plotting
import math
import nibabel as nib
import argparse
sys.path.append(os.path.join('/path/to/python_extra/scripts'))
import preprocextras as pe
import plsextras as plse
import jinja2
from bids import BIDSLayout
from bids import BIDSLayoutIndexer
from bids.tests import get_test_data_path


## Set Paths & Make Output Folders
project_path= os.path.join('')
script_path= os.path.dirname(os.path.abspath(__file__))
batchText_output_path=os.path.join('')
reports_path=os.path.join('')
if not(os.path.isdir(reports_path)):
    os.mkdir(reports_path)

#Get css for reports
if not(os.path.islink(os.path.join(reports_path, 'css'))):
    os.symlink(os.path.join(script_path, 'html_report_template', 'css'), os.path.join(reports_path, 'css'), target_is_directory=True)

plot_path=os.path.join(reports_path, 'QC_Realignment_Plots')
if not(os.path.isdir(plot_path)):
    os.mkdir(plot_path)

if not(os.path.isdir(batchText_output_path)):
    os.mkdir(batchText_output_path)

nifti_output_path=os.path.join('')

if not(os.path.isdir(nifti_output_path)):
    os.mkdir(nifti_output_path)

confound_vars=['csf','white_matter','trans_x','trans_y','trans_z','rot_x','rot_y','rot_z']

IDs=list(sys.argv[1:])
tasks={'EncRun1', 'EncRun2', 'EncRun3', 'EncRun4', 'RetRun1', 'RetRun2', 'RetRun3', 'RetRun4'}
space_label = 'MNI152NLin2009cAsym'
descriptor = 'preproc'
FD_thresh=1.0
DVars_thresh=2.0

bad_subj=[]

for ID in IDs:
    print(ID)
    folder = os.path.join(project_path, 'BIDS', 'derivatives', 'fmriprep','sub-%s' %(str(ID)), "func")
    output_folder=os.path.join(nifti_output_path, 'sub-%s' %(str(ID)))
    if not(os.path.isdir(output_folder)):
        os.mkdir(output_folder)

    file_list= glob.glob("%s/*%s*%s*.nii.gz"%(folder, space_label, descriptor))
    file_list=[x for x in file_list if any(elem in x for elem in tasks)]
    file_list.sort()
    # print(file_list)

    mask_file_list= glob.glob("%s/*%s*brain_mask*.nii.gz"%(folder, space_label))
    mask_file_list=[x for x in mask_file_list if any(elem in x for elem in tasks)]
    mask_file_list.sort()
    
    confound_file_list = glob.glob("%s/*confounds_timeseries.tsv"%(folder))
    confound_file_list=[x for x in confound_file_list if any(elem in x for elem in tasks)]
    confound_file_list.sort()

    totalVolumestillRun=0
    bad_vols_all_runs=[]
    censor_list_all_runs=[]
    trimmed_confounds_all_runs=pandas.DataFrame()
    img_all_runs_list=[]
    report_rows=[]
    report_row_index_names=[]
    # starting & ending index across all runs
    start_ind=0
    end_ind=0
    for i,myfile in enumerate(file_list):
        print(myfile)
        try:
            img = nilearn.image.load_img(myfile)
        except:
            print("File not found: %s"%(myfile))
            continue

        try:
            mask_img = nilearn.image.load_img(os.path.join(folder, mask_file_list[i]))
        except:
            print("File not found: %s"%(myfile))
            continue

        try:
            confound_df = pandas.read_csv(os.path.join(folder, confound_file_list[i]), sep="\t")
        except:
            print("File not found: %s"%(confound_file_list[i]))
            continue


        ## Save trimmed_img
        trimmed_img, trimmed_confounds = pe.get_trimmed_img(img,confound_df, scans_to_trim=17)

        ## Convert to Time series
        brain_time_series = pe.get_time_series(trimmed_img,mask_img)


        # print(totalVolumestillRun)
        ##Get bad_vols
        bad_vols = pe.get_bad_vols(brain_time_series, trimmed_confounds, FD_thresh=FD_thresh)

        drive, path=os.path.split(myfile)
        path,filename=os.path.split(path)
        filename,file_ext=os.path.splitext(filename)
        filename,file_ext=os.path.splitext(filename)
        task=filename.split('_')[1].split('-')[1]
        print(task)


        #Save plot
        fig=pe.get_plot(trimmed_confounds,ID,brain_time_series, timing=None,FD_thresh=FD_thresh, Dvars_thresh=DVars_thresh, title='sub-%s FD & DVars plot for task-%s' %(str(ID),task))
        fig.savefig(os.path.join(plot_path, "sub-%s_task-%s_FD_DVars_plot.png"%(str(ID),task)),facecolor=fig.get_facecolor())

        ##Scrub data
        if len(bad_vols)>0:
            percent_badVols_run=(len(bad_vols)/brain_time_series.shape[0])*100
            report_rows.append([len(bad_vols), percent_badVols_run])
            report_row_index_names.append(task)
            bad_vols=[x+totalVolumestillRun for x in bad_vols]
            bad_vols_all_runs.extend(bad_vols)
            # scrubbed_img = pe.scrub_data(trimmed_img, trimmed_confounds,bad_vols)
        else:
            scrubbed_img = trimmed_img


        #Keep track of total volumes so far
        totalVolumestillRun+=brain_time_series.shape[0]
        print(totalVolumestillRun)

        # Smooth img
        print('Smoothing img')
        smoothed_img=pe.smooth_data(scrubbed_img,fwhm=6)
        # #
        # # # Remove confound variables
        cleaned_img = pe.clean_data(smoothed_img, trimmed_confounds, confound_vars,mask_img)

        #Save 3d scans
        end_ind=end_ind+cleaned_img.shape[3]
        print('Saving 3D volumes By run')
        pe.save_3d_scans_run(cleaned_img, start_ind, end_ind, output_folder,myfile, scans_to_trim=17)
        start_ind=end_ind;
        # trimmed_confounds_all_runs=trimmed_confounds_all_runs.append(trimmed_confounds, ignore_index=True)
        # img_all_runs_list=pe.concat_img_all_runs(cleaned_img, img_all_runs_list)

        #end within run
    censor_list=[]
    
   
    ##Generate reports
    print("Generating Reports")
    #Report df
    if len(report_rows)>0:
        report_df = pandas.DataFrame(report_rows, columns=["Total Bad Volumes", "% Bad Volumes"])
        report_df.index=report_row_index_names
        # print(report_df.head())
    else:
        report_df=pandas.DataFrame()


    ##Get all figures
    fig_list=glob.glob(os.path.join(plot_path,"sub-*%s*.png"%(str(ID))))
    fig_list.sort()
    pe.generate_report(report_df,fig_list, ID, FD_thresh=FD_thresh, DVars_thresh=DVars_thresh, remove_dict={}, confound_vars=confound_vars,output_path=reports_path, styleCols=["% Bad Volumes"])
