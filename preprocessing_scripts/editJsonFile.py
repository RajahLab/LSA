"""
Created on Mon Apr 11 15:25:37 2022

@author: rajsri
"""

import pandas
import numpy
import math
import os
import sys
import glob
import re
import json

def get_intendedfor_list(ID, order, func_path):
    intendedfor_list=[]
    ##Add Enc Runs to intended for list
    for ord in order:
        func_file=glob.glob(os.path.join(func_path, "sub-%s_task-EncRun%s_bold.nii.gz"%(str(ID), ord)))[0]
        func_file= func_file.split("/")[len(func_file.split("/"))-1]
        sbref_file=glob.glob(os.path.join(func_path, "sub-%s_task-EncRun%s_sbref.nii.gz"%(str(ID), ord)))[0]
        sbref_file= sbref_file.split("/")[len(sbref_file.split("/"))-1]
        intendedfor_list.append(os.path.join("func",func_file))
        intendedfor_list.append(os.path.join("func",sbref_file))


    ##Add Ret Runs to intended for list
    for ord in order:
        func_file=glob.glob(os.path.join(func_path, "sub-%s_task-RetRun%s_bold.nii.gz"%(str(ID), ord)))[0]
        func_file= func_file.split("/")[len(func_file.split("/"))-1]
        sbref_file=glob.glob(os.path.join(func_path, "sub-%s_task-RetRun%s_sbref.nii.gz"%(str(ID), ord)))[0]
        sbref_file= sbref_file.split("/")[len(sbref_file.split("/"))-1]
        intendedfor_list.append(os.path.join("func",func_file))
        intendedfor_list.append(os.path.join("func",sbref_file))

    # intendedfor_list.sort()
    return intendedfor_list
def write_json(new_data, filename='data.json'):
    with open(filename,'r+') as file:
          # First we load existing data into a dict.
        file_data = json.load(file)
        # file_data["descriptions"].append(new_data)
        # file_data.update(new_data)
        file_data["IntendedFor"] = new_data
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json.
        json.dump(file_data, file, indent = 4)

project_path= os.path.join('/data', 'laborajah3', 'Attention_Memory', 'Data', 'Session_2_data')

ID=sys.argv[1]
acq_order=list(sys.argv[2:])
if len(acq_order) < 4:
    sys.exit("Error! Too few run numbers in acquisition order")

fmap_path=os.path.join(project_path, 'BIDS', 'sub-%s' %str(ID), 'fmap')
func_path=os.path.join(project_path, 'BIDS', 'sub-%s' %str(ID), 'func')

phasediff_files=[]
for file in os.listdir(fmap_path):
    if file.endswith("_phasediff.json"):
        phasediff_files.append(file)

phasediff_files.sort(key=lambda x: int(x.split('_')[2].split('-')[1]))
print(phasediff_files)

for file in phasediff_files:
    if "run-01" in file:
        intendedfor_list = get_intendedfor_list(ID, acq_order[:len(acq_order)//2], func_path)
    elif "run-02" in file:
        intendedfor_list = get_intendedfor_list(ID, acq_order[len(acq_order)//2:], func_path)
    else:
        sys.exit("Incorrect number of fieldmaps")

    print(intendedfor_list)

    write_json(intendedfor_list, filename=os.path.join(fmap_path, file))
