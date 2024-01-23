input = "/Users/sbandya/Desktop/hemocyte_ImageSegmentation/input_images/current/";
output_images = "/Users/sbandya/Desktop/hemocyte_ImageSegmentation/fitc_green/output_images/";
output_results = "/Users/sbandya/Desktop/hemocyte_ImageSegmentation/fitc_green/quant/";

function count_hemocytes (input, outimage, outtables, filename) {
	//title = getTitle();
	open(input + filename);
	run("Split Channels");
	selectWindow(filename + " (blue)");
	close();
	selectWindow(filename + " (red)");
	close();

	selectWindow(filename + " (green)");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setThreshold(60, 255);  
	//setTool("oval");

	run("Set Measurements...", "area mean area_fraction redirect=None decimal=3");

	x1=2000;
	y1=1500;
	x2=1000;
	y2=500;


	makeOval(615,435,110,98);
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	run("Enlarge...", "enlarge=100");
	run("Measure");
	//run("Enlarge...", "enlarge=100");
	//run("Measure");

	saveAs("Jpeg", outimage + filename); 
	selectWindow("Results");
	saveAs("Results", outtables + filename +".csv");
	close();
	close("Results");
}

setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++){
        print(list[i]);
        count_hemocytes(input, output_images, output_results, list[i]);
}
setBatchMode(false);

