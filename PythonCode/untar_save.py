#import necessary libraries
import sys, tarfile
import os, re
import glob
from os.path import isfile, join
#import class 'Downloader' from python file 'download_landsat.py'
from download_landsat import Downloader

#Ask user if the data needed exists or not; if not download it from google storage downloader!
reply = raw_input("Does user already have landsat .tar.gz files? y/n  ")
if reply == "y":
    print sys.argv
    datdir = raw_input("Please enter the whole path of landsat_data directory:  ")
    tar_folder = os.listdir(datdir)
    os.chdir(datdir)
    tar_files = glob.glob("*.tar.bz")
    
else:
    list_scene = [] 
    item = ""
    while item != "q":
        item = raw_input("Enter scene_id: (or press 'q', when done)  ")
        list_scene.append(item)
       
    print ("The scene list is %s",list_scene[:-1])
    d = Downloader()    
    tar_folder = d.download(list_scene[:-1])
    os.chdir(tar_folder)
    tar_files = glob.glob("*.tar.bz")

#In order to merge the code with R script the path and names have to synced for untar images
dest_file = raw_input("Enter project data folder (/BrazilDam/data):  ")
for compressed_files in tar_files:
    print tar_files
    folder_names = [["254","_sea_before"], ["334","_sea_after"], ["277","_river_before"],["341","_river_after"], ["284","_br_before"],["316","_br_after"]]
        
    for items in folder_names:
        m = items[0] in compressed_files
        if m == True:
            file_untar = tarfile.open(compressed_files)
            untar_path = os.path.join(dest_file,(compressed_files[:-7]+items[1]))
            print untar_path
            if not os.path.exists(untar_path):
                os.makedirs(untar_path)
            file_untar.extractall(path = untar_path)
            file_untar.close()
        else:
            pass

print("--Files are now ready to use in Main.R script---")
