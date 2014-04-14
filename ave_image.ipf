#pragma rtGlobals=1		// Use modern global access method.
#include <All IP Procedures>

// This function is to make an average of images stored in different data folder
//First a prompt input asks the user :
//1. To select the destination folder
//2. then to select the waves to average
//The user needs to select the data folder, and the wave.
//The program will store a copy of the waves to average in the destination folder (with a indexed prefix), make and display the average, and kill the temporary waves


Function avgimage()

	
	// Creates the "tempfolder" temporary folder to store names of data folders
	newdatafolder/O/S root:tempfolder
	DFREF dftemp=getdatafolderdfr()
	
	variable numDFR=countobjectsdfr(root:,4)//returns the number of data folders
	variable i
	for (i=0;i<numDFR;i+=1)// creates for each data folder in root: a matching string in tempfolder
		string nametouse=getindexedobjnamedfr(root:,4,i)
		string/g $nametouse
		
		SVAR tempstring=$nametouse
	endfor
	killstrings tempfolder // tempfolder should not show in the list the user will select from
	string/g stop //add a stop option when the user has finished selecting waves
	
	//The first prompt is to select the folder where the average image will be created

	string destfolder
	Prompt destfolder, "choose destination folder", popup, stringlist("!destfolder*",";")
	DoPrompt "Create average image in:", destfolder
	string/g $destfolder
	DFREF destDFR=root:$destfolder
	
	If (stringmatch(destfolder,"stop")==1) // aborts if user selected "stop"
		return 0
	endif

	Setdatafolder destDFR
	
	string nameavgwave
	Prompt nameavgwave,"enter name of output wave"
	Doprompt "name", nameavgwave
	
	variable numimtoavg=0
	Make/o/n=(100,2) wavestoadddims
	
	Do
		Setdatafolder dftemp
		string dfrtouse
		Prompt dfrtouse, "choose data folder", popup,stringlist("!dfrtouse*",";")
		Doprompt "data folder", dfrtouse
		string/g $dfrtouse
		
		If (stringmatch(dfrtouse,"stop")==1)// get out of the loop when user selects "stop"
			break
		Endif
		
		setdatafolder root:$dfrtouse
		string imagetoadd
		Prompt imagetoadd, "choose image", popup, wavelist("*",";","DIMS:2")
		Doprompt "image", imagetoadd
		wave w=$imagetoadd
		
		//copies selected wave in destination folder with prefix "toadd_"+indexofchosenwave
		Duplicate/o w, destDFR:$("toadd_"+num2str(numimtoavg)+"_"+nameofwave($imagetoadd))
		Setdatafolder destDFR

		numimtoavg+=1
	While(1)
	
	Setdatafolder destDFR
	
	string/g toaddlist=wavelist("toadd_*",";","")

	//loops to check that waves selected have the same size
	variable j
	for (j=0;j<numimtoavg;j+=1)
		wavestoadddims[j][0]=dimsize($(stringfromlist(j,toaddlist) ),0)
		wavestoadddims[j][1]=dimsize($(stringfromlist(j,toaddlist) ),1)
	endfor
	deletepoints/M=0 numimtoavg,100-numimtoavg, wavestoadddims
	deletepoints/M=1 numimtoavg,100-numimtoavg, wavestoadddims
		
	for (j=numimtoavg-1;j>=0;j-=1)
		If ((wavestoadddims[j][0]!=wavestoadddims[j-1][0])||(wavestoadddims[j][1]!=wavestoadddims[j-1][1]))
			doAlert 0, "some waves have different dimensions"
			return 0
		endif
	endfor
	
	//Make the average
	make/o/n=(wavestoadddims[0][0],wavestoadddims[0][1]) tempave

	for (j=0;j<numimtoavg;j+=1)
		Duplicate/o $(stringfromlist(j,toaddlist)) tempwave
		tempave=tempave+tempwave
		killwaves tempwave
	endfor
	
	tempave=tempave/numimtoavg
	rename tempave $nameavgwave
	Setscale/p x,0,dimdelta($(stringfromlist(0,toaddlist)),0),"" $nameavgwave
	Setscale/p y,0,dimdelta($(stringfromlist(0,toaddlist)),1),"" $nameavgwave
	
	Display;appendimage $nameavgwave
	setaxis/a/r left
	
	for (j=0;j<numimtoavg;j+=1)
		killwaves $(stringfromlist(j,toaddlist))
	endfor
	killwaves  wavestoadddims
	killstrings toaddlist
	killdatafolder dftemp
End