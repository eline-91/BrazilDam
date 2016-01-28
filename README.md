# BrazilDam
Hereby we describe step by step procedure to understand the spread of toxic waster sludge that broke following the Samarco Dam,
breach incident that took place on the November 5, 2015 near a small village called Bento Rodrigues.

The main script for the analysis is performed in R however, initial data procuring and management is done in python

Step 1

In order to set correct data directories, to be used during analysis, run part of 'Main.R' script between the dashed lines ( #---#)

Step 2

Run python file 'untar_save.py' to download the data. The script would need user to answer to a few prompts. 

However, before user must make sure that landsat utils package is installed (est time: 20- 30 min). To read more on it visit:
https://pythonhosted.org/landsat-util/installation.html (also see below)

The user will go through for the following sequence

- Prompt inquiring if the data is availbale, answer y or n
    If the data is not avaialble the program is designed to downlaod it from Google Storage downloader
    However, if the data is available the user will be prompted for the data source directory

- User will be prompted for Scene Ids.
    It is assumed the researcher should find these ScenesID from prior knowledge of the disaster and some preliminary research 
on the subject.
    - SceneIDs (further below find "Easy to Copy Scenes Ids")
For this case the SceneIDs are the following

  a) Before the disaster Scenes

  ##The scenes are taken from the month of September and October in order to avoid seasonal change contributing to our change index
  
    1. Bentro Rodrigues (place of incident, Novmber 5) : LC82170742015284LGN00
    2. River Doce (the exact dates of the union of toxic sludge with River Doce are unknown): LC82150732015254LGN00
    3. River Doce dealta (River Doce meets the Atlandtic Ocean, November 25): LC82160742015277LGN00
  
  b) After the disaster Scenes
  
    1. Bento Rodrigues (November 12): LC82170742015316LGN00
    2. River Doce (December 7): LC82150732015341LGN00
    3. River Doce delta (November 30): LC82160742015334LGN00
- Landsat download directory: the default set directory is "/home/user/landsat"

- After the download is complete or in case the user already have downlaoded data, the function untars the files
  Enter the data folder to save the untar files. Here please enter the dataDir from the 'Main.R' script.

Step 3
Once the data is procured we will begin the analysis for which user has to move back to 'Main.R' and run rest of the script.

#Easy to Copy Scene IDs
LC82170742015284LGN00
LC82170742015316LGN00
LC82160732015277LGN00
LC82160732015341LGN00
LC82150742015254LGN00
LC82150742015334LGN00

#Landsat-utils installation

$: sudo apt-get update
$: sudo apt-get install python-pip python-numpy python-scipy libgdal-dev libatlas-base-dev gfortran libfreetype6-dev
$: sudo pip install python.h
$: sudo apt-get  update; sudo apt-get install  python-dev -y
$: pip install landsat-util
$: pip install homura
$: pip install requirements

installing homura needs python.h 
http://stackoverflow.com/questions/8282231/ubuntu-i-have-python-but-gcc-cant-find-python-h

