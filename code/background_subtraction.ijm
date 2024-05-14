input = getDirectory("Choose an input directory");
output = getDirectory("Choose an output directory");

function subtractbackground(dapi_channel, fitc_channel,basepath, outdir) { 
	open(input + fitc_channel);
	run("Split Channels");
	selectWindow(fitc_channel+" (red)");
	close();
	selectWindow(fitc_channel+" (blue)");
	close();

	selectWindow(fitc_channel+" (green)");
	run("Subtract Background...", "rolling=10 sliding");
	run("Green");

	open(input + dapi_channel);
	run("Split Channels");
	selectWindow(dapi_channel+" (red)");
	close();
	selectWindow(dapi_channel+" (green)");
	close();
	selectWindow(dapi_channel+" (blue)");
	run("Grays");
	
	run("Merge Channels...", "c2=["+fitc_channel+" (green)] c3=["+dapi_channel+" (blue)] create");

	//print(outdir+basepath);
	saveAs("Tiff", outdir+"/"+basepath+"_merge.tif");
	close();

}

setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++){
        if(endsWith(list[i], "_DAPI.tif")){
        	basepath = split(list[i],"(_DAPI.tif)");
        	dapi = list[i];
        	fitc = basepath[0]+"_FITC.tif";
 			//print(fitc);
 			//print(dapi);
 			subtractbackground(dapi,fitc,basepath[0], output);
        	//break
        	print(basepath[0]+" done!");

        	}
        
}
print("all done!")
setBatchMode(false);