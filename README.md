Averageimage_multifolder-Igor
=============================

Igor procedure to make average image selecting files from multiple data folders

INSTALLATION:

copy ave_image.ipf file in the Igor Procedure subfolder in your Wavemetrics folder. Restart Igor Pro


By Alex Tran-Van-Minh (alexandra.tran.van.minh@gmail.com)

This function is to make an average of images stored in different data folders
First a prompt input asks the user :
1. To select the destination folder
2. then to select the waves to average
The user needs to select the data folder, and the wave.
The program will store a copy of the waves to average in the destination folder (with a indexed prefix), make and display the average, 
and kill the temporary waves
From command line call by typing avgimage()