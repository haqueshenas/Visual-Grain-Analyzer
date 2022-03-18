 /* 
     Visual Grain Analyzer (VGA version 1.0)
  	
   -------------------------------------------
 
   A user-friendly code for phenomics
   
   ImageJ Macro Language
   Author: Abbas Haghshenas
   abbas.haghshenas@shirazu.ac.ir; haqueshenas@yahoo.com
   Department of Plant Production and Genetics, Shiraz University, Iran
   March 2022
   License: MIT License
    
 
   Applications:
    
   -The present macro simulates the processing and calculations reported in the
    preprint:
    Haghshenas, A., Emam, Y., & Jafarizadeh, S. (2021). Wheat grain width: A clue for
    re-exploring visual indicators of grain weight. bioRxiv, 2021.2010.2013.464205. 
    https://doi.org/10.1101/2021.10.13.464205
    Also, the manuscript has been submitted to Plant Methods.
    
   -This macro also could be used for other phenotyping purposes such as size & shape analyses of
    grains of other species, leaf area measurement, etc.
   
   
   Acknowledgements:
    
   This macro has benefited from the valuable comments of experts on ImageJ Forum.
   The authors appreciate the help of below accounts:
   Biovoxxel (Jan Brocher), Brian Northan (bnorthan), Gabriel, Herbie, Jomaydc (Johanna), MicroscopyRA, NicoDF (Nicolás De Francesco),
   Thomas Peterbauer, and Wayne Rasband.
   We would also thank Anna Klemm (anna.klemm@it.uu.se) and NEUBIAS Academy for sharing a beneficial course on writing ImageJ/Fiji macro
   on YouTube.
   
   
   Copyright <2022> <Abbas Haghshenas et al., Department of Plant Production and Genetics, Shiraz University, Shiraz, Iran>
   
   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
   (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
   publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:
   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
   FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   
   ---------------------------------------------------------------------------------------------------------------------------------------
  */
  
 // Setting measurements & options

	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape "+
	"feret's integrated median skewness kurtosis area_fraction stack limit display redirect=None decimal=9");
	
	setOption("BlackBackground", true);
	
 	// Choosing the input & output folders, and the size calibration sample:

	input_dir = getDirectory("Choose input folder");
	output_dir = getDirectory("Choose output folder");
	fileList = getFileList(input_dir); 

 	// "Setting" dialog window

	CalibrationMethod = newArray("Using calibration sample (camera)", "Using known resolution (scanner)");
	REFactor = 10;
	ThresholdingMethod = getList("threshold.methods");
	ThresholdingMethod = Array.concat(ThresholdingMethod, "Manual");
	SizeSieve = "0-Infinity";
	CircSieve = "0-1.0";
	OutputDrawings = newArray("Outlines & labels", "Fitted ellipses", "Outlines, labels, & ellipses",
	"Overlay, outlines, & labels", "Overlay, outlines, labels, & ellipses", "Don't save drawings");
	LineWidth = 1;
	FontSize = 20;
	FontColor = newArray("Black", "Blue", "Cyan", "DarkGray", "Gray", "Green", "LightGray", "Magenta", "Orange",
						 "Pink", "Red", "White", "Yellow");
	WatershedType = newArray("Red (RGB)", "Green (RGB)", "Blue (RGB)", "Brightness (HSB)");
	Dialog.create("VGA settings");
	Dialog.addChoice("Imaging and calibration method:", CalibrationMethod);
	Dialog.addNumber("Resolution enhancement factor:", REFactor);
	Dialog.addChoice("Thresholding method:", ThresholdingMethod);
	Dialog.addString("Size sieve (permissible area range; pixel^2):", SizeSieve);
	Dialog.addString("Shape sieve (permissible circularity range):", CircSieve);
	Dialog.addChoice("Output drawings:", OutputDrawings);
	Dialog.addNumber("Drawings line width (pixel):", LineWidth);
	Dialog.addNumber("Font size of labels:", FontSize);
	Dialog.addChoice("Font color (only for vectors):", FontColor, "Magenta");
	Dialog.addCheckbox("Dark background", false);
	Dialog.addCheckbox("Exclude the grains at the image edge", false);
	Dialog.addCheckbox("Include the grain holes", true);
	Dialog.addCheckbox("Try to separate touching grains", false);
	Dialog.addChoice("Type of separation (channel):", WatershedType, "Green (RGB)");
	Dialog.addCheckbox("Wheat grain weight estimations", true);
	Dialog.show();
	CalibrationMethod = Dialog.getChoice();
	REFactor = Dialog.getNumber();
	ThresholdingMethod = Dialog.getChoice();
	SizeSieve = Dialog.getString();
	CircSieve = Dialog.getString();
	OutputDrawings = Dialog.getChoice();
	LineWidth = Dialog.getNumber();
	FontSize = Dialog.getNumber();
	FontColor = Dialog.getChoice();
	DarkBackground = Dialog.getCheckbox();
	ExcludeEdge = Dialog.getCheckbox();
	IncludeHoles = Dialog.getCheckbox();
	Watershed = Dialog.getCheckbox();
	WatershedType = Dialog.getChoice();
	WGWE = Dialog.getCheckbox();
	
	if (ExcludeEdge) {
		ExEdg = "exclude ";
	} else {
		ExEdg = "";
	}
	
	if (IncludeHoles) {
		Include = " include";
	} else {
		Include = "";
	}
	
	WatershedTypeOption = WatershedType;
	
	if (WatershedType == "Red (RGB)") {
		WatershedType = "red";
	} else if (WatershedType == "Green (RGB)") {
		WatershedType = "green";
	} else if (WatershedType == "Blue (RGB)") {
		WatershedType = "blue";
	}

	if (DarkBackground == 1) {
		DarkBackgroundOption = "Yes";
	} else DarkBackgroundOption = "No";
	
	if (ExcludeEdge == 1) {
		ExcludeEdgeOption = "Yes";
	} else ExcludeEdgeOption = "No";
	
	if (IncludeHoles == 1) {
		IncludeOption = "Yes";
	} else IncludeOption = "No";
				
	if (Watershed == 1) {
		WatershedOption = "Yes";
	} else WatershedOption = "No";

	// Manual thresholding
	
	if (ThresholdingMethod == "Manual") {
	MinThresh = 0;
	MaxThresh = 0;
	Dialog.create("Manual thresholding");
	Dialog.addNumber("Lower threshold level:", MinThresh);
	Dialog.addNumber("Upper threshold level:", MaxThresh);
	Dialog.show();
	MinThresh = Math.round(Dialog.getNumber());
	MaxThresh = Math.round(Dialog.getNumber());
			
		if (MinThresh > MaxThresh) {
		showMessage("The lower level cannot be higher than the upper level!");
		Dialog.create("Manual thresholding");
		Dialog.addNumber("Lower threshold level:", MinThresh);
		Dialog.addNumber("Upper threshold level:", MaxThresh);
		Dialog.show();
		MinThresh = Math.round(Dialog.getNumber());
		MaxThresh = Math.round(Dialog.getNumber());
		}
			
		if (MinThresh > MaxThresh) {
			showMessage("The lower level cannot be higher than the upper level!");
			exit("VGA error: Incorrect thresholding!");
		}
			
		if (MinThresh < 0) {
		MinThresh = 0;
		}
		if (255 < MinThresh) {
		MinThresh = 255;
		}
		if (MaxThresh < 0) {
		MaxThresh = 0;
		}
		if (255 < MaxThresh) {
		MaxThresh = 255;
		}
	}
	
 // Imaging mode & size calibration
	
	// Camera mode

		if (CalibrationMethod == "Using calibration sample (camera)") {
	
		CalibDmm = getNumber("Please enter the diameter of circular calibration" + " sample (mm):", 20);
				
		open(File.openDialog("Choose image of calibration sample"));
		CalibTitle = getTitle();
		print("\nVisual Grain Analyzer (version 1.0)\n\n------------- Settings --------------" +
		"\n\nInput path: " + input_dir + "\nOutput path: " + output_dir + "\nCalibration method: " + CalibrationMethod + 
		"\nResolution enhancement factor: " + REFactor + "\nThresholding method: " + ThresholdingMethod);
			if (ThresholdingMethod == "Manual") {
		 		print("Manual thresholding levels: " + MinThresh + "-" + MaxThresh);
		 	}
		print("Size sieve (permissible area range; pixel^2): " + SizeSieve + "\nShape sieve (permissible circularity range): " + CircSieve + 
		"\nOutput drawings: " + OutputDrawings + "\nDark background: " + DarkBackgroundOption + "\nGrains at the image edge were excluded: " +
		ExcludeEdgeOption + "\nGrain holes were included: " + IncludeOption + "\nSeparation of touching grains: " + WatershedOption);
			if (Watershed) {
			print("Type of separation (color channel): " + WatershedTypeOption);
			}
		print("Diameter of calibration sample (mm): " + CalibDmm + "\n\n------------- Calibration --------------\n\n"+
		"Processing the calibration sample...\n   please wait...");
	 	 
		run("Scale...", "x=&REFactor y=&REFactor interpolation=Bicubic create");
		rename(CalibTitle);
		run("Set Scale...", "known=1 unit=pixel");
		
		if (Watershed == 1 && WatershedType != "Brightness (HSB)"){
						
			run("Split Channels");
			selectWindow(CalibTitle + " (" + WatershedType + ")");
			rename(CalibTitle);
		} else {

		run("HSB Stack");
		run("Convert Stack to Images");
		selectWindow("Brightness");
		rename(CalibTitle);
		}
		
		// Thresholding for calibration sample
		
		if (ThresholdingMethod == "Manual") {
			setThreshold(MinThresh, MaxThresh, "raw");
		} else {
																		
			if (DarkBackground) {
				setAutoThreshold("" + ThresholdingMethod + " dark");
			} else {
			 setAutoThreshold(ThresholdingMethod);
			}
		}
		
		// Analyzing the calibration sample
		
		run("Analyze Particles...", " size=0-Infinity clear include");
		close();
		if (nResults > 1) {
		exit("VGA error: More than one object was detected in the calibration image! Try other imaging or thresholding methods.");
		}
		if (nResults == 0) {
		exit("VGA error: No calibration sample was detected! Try other thresholding methods.");	
		}
		if (getResult("Circ.")<0.85) {
		exit("VGA error: The calibration sample seems not circular!");	
		}
	
		CalibDPix = getResult("Feret", nResults-1);
		CalibRatio = CalibDmm / CalibDPix;
		CalibRatio2 = Math.pow(CalibRatio,2);
	 
		print("\nSize calibration completed successfully!\n\n----------------------------------------");
		}

	// Scanner mode

		// Getting image resolution (for scanning mode):
		
	 	if (CalibrationMethod == "Using known resolution (scanner)") {
		GetResolution = newArray("Use image metadata", "I will enter it manually");
		Dialog.create("Resolution setting");
		Dialog.addChoice("Determining image resolution:", GetResolution);
		
		Dialog.show();
		GetResolution = Dialog.getChoice();
		GetRsolutionOption = "Using image Metadata";
	 	if (GetResolution == "I will enter it manually") {
			Resolution = getNumber("Please enter the scanning resolution (dpi):", 300)*REFactor;
			GetRsolutionOption = "Entered manually (" + Resolution/REFactor + " dpi)";
	  		}

		print("\nVisual Grain Analyzer (version 1.0)\n\n------------- Settings --------------" + 
		"\n\nInput path: "+ input_dir + "\nOutput path: " + output_dir + "\nCalibration method: " + CalibrationMethod + 
		"\nResolution enhancement factor: " + REFactor + "\nThresholding method: " + ThresholdingMethod);
			if (ThresholdingMethod == "Manual") {
		 		print("Manual thresholding levels: " + MinThresh + "-" + MaxThresh);
		 	}
		print("Size sieve (permissible area range; pixel^2): " + SizeSieve + "\nShape sieve (permissible circularity range): " + CircSieve + 
		"\nOutput drawings: " + OutputDrawings + "\nDark background: " + DarkBackgroundOption + "\nGrains at the image edge were excluded: " +
		ExcludeEdgeOption + "\nGrain holes were included: " + IncludeOption + "\nSeparation of touching grains: " + WatershedOption);
			if (Watershed) {
			print("Type of separation (color channel): " + WatershedTypeOption);
			}
		print("Resolution: " + GetRsolutionOption + "\n\n----------------------------------------");
	 	}

 // Recording the starting time of processing

     	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
     	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
     	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     	TimeString =DayNames[dayOfWeek]+" ";
     	if (dayOfMonth<10) {TimeString = TimeString+"0";}
     	TimeString = "\nProcessing of the input images started\n\non "+TimeString+dayOfMonth+
     	"-"+MonthNames[month]+"-"+year+" at ";
     	if (hour<10) {TimeString = TimeString+"0";}
     	TimeString = TimeString+hour+":";
     	if (minute<10) {TimeString = TimeString+"0";}
     	TimeString = TimeString+minute+":";
     	if (second<10) {TimeString = TimeString+"0";}
     	TimeString = TimeString+second;
     	print(TimeString+".\n\n-------------- Processing --------------\n");

 // Batch processing
 
	setBatchMode(true);
	for (f=0; f<fileList.length; f++){
	process( input_dir, fileList[ f ], output_dir );		
	} 
	setBatchMode(false);
	function process( input_dir, file, output_dir )
	{
	
	// Clean-up to prepare for analysis
	
	roiManager("reset");	
	run("Close All");
	run("Clear Results");

	//Open file
	
	open(input_dir + file);
	print("Processing image: " + file + " ...\n   please wait...");
	
	title = getTitle();

    // Resolution enhancement of the input images
    
	run("Scale...", "x=&REFactor y=&REFactor interpolation=Bicubic create");
	rename(title);
	
	// Scanner mode
		// Setting resolution in "Use image metadata" mode
		
			if (CalibrationMethod == "Using known resolution (scanner)") {
				if (GetResolution == "Use image metadata") {
					getPixelSize(unit, pixelWidth, pixelHeight);
					if (pixelWidth != pixelHeight) {
					exit("VGA error: Pixel is not square! Use other calibration methods!");
					}
					if (unit != "inches") {
					exit("VGA error: No standard metadata was found! Enter the resolution "+
					"manually, or try other calibration methods.");
					}
					else {
					Resolution = 1/pixelWidth;
						 }
			    }
		   }

 	// Calibration for "scanner" mode
 
	if (CalibrationMethod == "Using known resolution (scanner)") {
	 run("Set Scale...", "distance=&Resolution known=1 unit=pixel");
     CalibRatio = 25.4/Resolution;
	 CalibRatio2 = Math.pow(CalibRatio,2);
	 }
	
	// Binarizing the input image
	
	if (Watershed == 1 && WatershedType != "Brightness (HSB)"){
			
			run("Split Channels");
			selectWindow(title + " (" + WatershedType + ")");
			rename(title);
		} 
		else {
			
	 		run("HSB Stack");
	   		run("Convert Stack to Images");
	   		selectWindow("Brightness");
	   		rename(title);
		}
	
	// Thresholding
		
			if (ThresholdingMethod == "Manual") {
				setThreshold(MinThresh, MaxThresh, "raw");
			} else {
		
				if (DarkBackground) {
			 		setAutoThreshold("" +ThresholdingMethod+ " dark");
				} else {
			  			setAutoThreshold(ThresholdingMethod);
						}
					}
	
	// Watershed (for separation of touching grains)
	
		if (Watershed) {
			if (OutputDrawings != "Overlay, Outlines, labels, & ellipses" && 
				OutputDrawings != "Overlay, outlines, & labels") {
				run("Convert to Mask");
				run("Watershed");	
			}
		}	
	
	//Analyzing particles
	
		// Setting font size and line width of drawings
		
		   call("ij.plugin.filter.ParticleAnalyzer.setFontSize", FontSize);
		   call("ij.plugin.filter.ParticleAnalyzer.setLineWidth", LineWidth);
			
		// This part (i.e. the next 18 lines) is written and shared on ImageJ Forum by Biovoxxel (Jan Brocher).
			// see: https://forum.image.sc/t/how-to-produce-custom-drawing-outputs-using-analyze-particle/63550
	 if (OutputDrawings == "Outlines, labels, & ellipses") {
		run("Set Scale...", "known=1 unit=pixel");
		run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve display " +ExEdg+ "clear" +Include+ "");
		binaryImage = getImageID();	
		run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve show=Ellipses  " +ExEdg + Include+ "");
		ellipses = getTitle();
		rename("temp_" + ellipses);
		ellipses = getTitle();
		run("Invert");
		run("Red");
		selectImage(binaryImage);
		call("ij.plugin.filter.ParticleAnalyzer.setFontSize", FontSize);
		call("ij.plugin.filter.ParticleAnalyzer.setLineWidth", LineWidth);
		run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve show=Outlines " +ExEdg + Include+ "");
		outlines = getTitle();
		run("Add Image...", "image=["+ellipses+"] x=0 y=0 opacity=100 zero");
		close(ellipses);
		
	 } else
			
		// With a minor change, this part (i.e. the next 70 lines) is written and shared on ImageJ Forum by Wayne Rasband.
			// see: https://forum.image.sc/t/how-to-produce-custom-drawing-outputs-using-analyze-particle/63550		
	 if (OutputDrawings == "Overlay, outlines, & labels"){
		if(Watershed){
		   	run("Duplicate...", " ");
		   	rename(title);
		   	run("Convert to Mask");
		   	run("Watershed");
		   	run("Set Scale...", "known=1 unit=pixel");
			run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve display show=Overlay " +ExEdg+ "clear" +Include+ "");
			Overlay.copy;
			close;
			rename(title);
			Overlay.paste;
		} else {
			run("Set Scale...", "known=1 unit=pixel");
			run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve display show=Overlay " +ExEdg+ "clear" +Include+ "");
			resetThreshold;
		 		}
		Overlay.drawLabels(false);
		n = Overlay.size;
		DFontSize = 2*REFactor;
		setFont("SansSerif", DFontSize, "antialiased");
		setColor(FontColor);
		for (i=0; i<n; i++) {
   		Overlay.activateSelection(i);
 	  		//Roi.setUnscalableStrokeWidth(2); // requires daily build
   		Overlay.addSelection("red");
   		Roi.getBounds(x, y, width, height);
   		x = x+width/2-round(DFontSize/2);
   		y = y+height/2+round(DFontSize/2);
   		Overlay.drawString(i+1, x, y)
   		run("Select None");
   		saveAs("Tiff", output_dir + title + "_processed.tif");
		}
	 } else
	
	 if (OutputDrawings == "Overlay, outlines, labels, & ellipses"){
		if(Watershed){
		   	run("Duplicate...", " ");
		   	rename(title);
		   	run("Convert to Mask");
		   	run("Watershed");
		   	run("Set Scale...", "known=1 unit=pixel");
			run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve display show=Overlay " +ExEdg+ "clear" +Include+ "");
			Overlay.copy;
			close;
			rename(title);
			Overlay.paste;
		} else {
			run("Set Scale...", "known=1 unit=pixel");
			run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve display show=Overlay " +ExEdg+ "clear" +Include+ "");
			resetThreshold;
		 		}
		Overlay.drawLabels(false);
		n = Overlay.size;
		DFontSize = 2*REFactor;
		setFont("SansSerif", DFontSize, "antialiased");
		setColor(FontColor);
		for (i=0; i<n; i++) {
   		Overlay.activateSelection(i);
   		run("Fit Ellipse");
   			//Roi.setUnscalableStrokeWidth(2); // requires daily build
   		Overlay.addSelection("red");
   		Roi.getBounds(x, y, width, height);
   		x = x+width/2-round(DFontSize/2);
   		y = y+height/2+round(DFontSize/2);
   		Overlay.drawString(i+1, x, y)
   		run("Select None");
   		saveAs("Tiff", output_dir + title + "_processed.tif");
		}
	 } else {
	
		ODindex = "Outlines";
	
	 if (OutputDrawings == "Outlines & labels"){ 
	     ODindex = "Outlines";} else 
	 if (OutputDrawings == "Fitted ellipses"){
		 ODindex = "Ellipses";} else 
								
	run("Set Scale...", "known=1 unit=pixel");
	run("Analyze Particles...", " size=&SizeSieve circularity=&CircSieve show=&ODindex display " +ExEdg+ "clear" +Include+ "");
	}
	
	// Calculating the selected (superior) image-derived indices for wheat MGW prediction and saving...
	// their values in new columns (see the paper)
	
	if (nResults != 0){
	
	IJ.renameResults("Results");
	for (row=0; row<nResults; row++) {

		Circularity = getResult("Circ.", row);
		Solidity = getResult("Solidity", row);
		
		AreaByPerim = getResult("Area", row) / getResult("Perim.", row);
    	setResult("Area/Perim", row, AreaByPerim);
  
    	AreaCirc = getResult("Area",row) * Circularity;
    	setResult("Area*Circ.", row, AreaCirc);
	
		MinorBySolid = getResult("Minor", row) / Solidity;
		setResult("Minor/Solidity", row, MinorBySolid);

		MinFBySolid = getResult("MinFeret", row) / Solidity;
		setResult("MinF/Solidity", row, MinFBySolid);

		AreaSolid = getResult("Area", row) * Solidity;
		setResult("Area*Solidity", row, AreaSolid);

		PerimCirc = getResult("Perim.", row) * Circularity;
		setResult("Perim.*Circ.", row, PerimCirc);

		A1 = getResult("Area", row) * getResult("Perim.", row) * Circularity *
			 Solidity * getResult("MinFeret", row);
		setResult("A1 (Area*Perim.*Circ.*Solid.*MinFeret)", row, A1);

		A2 = getResult("Area", row) * getResult("Perim.", row) * Circularity *
			 Solidity * getResult("Minor", row);
		setResult("A2 (Area*Perim.*Circ.*Solid.*Minor)", row, A2);

		// Kim index has been taken from the study of Kim et al. (2021):
		// Kim, J., Savin, R., & Slafer, G. A. (2021). Weight of individual wheat grains estimated from 
		// high-throughput digital images of grain area. European Journal of Agronomy, 124, 126237.
		// https://doi.org/https://doi.org/10.1016/j.eja.2021.126237

		Area = getResult("Area", row);
		KimIndex = Math.pow(Area, 1.32);
		setResult("Kim index", row, KimIndex);
	
	// Calculating the basic image-derived indices based on millimeter
	
		Perimmm = getResult("Perim.", row) * CalibRatio;
		setResult("Perim. (mm)", row, Perimmm);
		
		Majormm = getResult("Major", row) * CalibRatio;
		setResult("Major (mm)", row, Majormm);
		
		Feretmm = getResult("Feret", row) * CalibRatio;
		setResult("Feret (mm)", row, Feretmm);
		
		Areamm = Area * CalibRatio2;
		setResult("Area (mm2)", row, Areamm);
		
		Minormm = getResult("Minor", row) * CalibRatio;
		setResult("Minor (mm)", row, Minormm);

		MinFmm = getResult("MinFeret", row) * CalibRatio;
		setResult("MinF (mm)", row, MinFmm);


	// Wheat grain weight estimations
	
		if (WGWE) {

			AreaByPerimmm = Areamm / Perimmm;
			setResult("Area/Perim. (based on mm)", row, AreaByPerimmm);

			AreaCircmm = Areamm * Circularity;
			setResult("Area*Circ. (based on mm)", row, AreaCircmm);

			MinorBySolidmm = Minormm / Solidity;
			setResult("Minor/Solid. (based on mm)", row, MinorBySolidmm);
		
			MinFBySolidmm = MinFmm / Solidity;
			setResult("MinF/Solid. (based on mm)", row, MinFBySolidmm);

			AreaSolidmm = Areamm * Solidity;
			setResult("Area*Solid (based on mm)", row, AreaSolidmm);

			PerimCircmm = Perimmm * Circularity;
			setResult("Perim.*Circ. (based on mm)", row, PerimCircmm);

			A1mm = (Areamm * Perimmm * Circularity * Solidity * MinFmm);
			setResult("A1 (based on mm)", row, A1mm);

			A2mm = (Areamm * Perimmm * Circularity * Solidity * Minormm);
			setResult("A2 (based on mm)", row, A2mm);

			KimIndexmm = Math.pow(Areamm, 1.32);
			setResult("Kim index (based on mm)", row, KimIndexmm);
	
		// Estimating wheat mean grain weight (MGW; mg) using linear models (see the paper).
			// "Pred.": predicted; mg: milligram 

			MGWAreamm = (Areamm * 3.45465289657542) - 10.5056151985942;
			setResult("Pred. MGW via Area (mg)", row, MGWAreamm);

			MGWMinormm = (Minormm * 26.2235320984931) - 37.4354782781915;
			setResult("Pred. MGW via Minor (mg)", row, MGWMinormm);

			MGWMinFmm =	(MinFmm * 25.7510143298851) - 38.2152962073392;
			setResult("Pred. MGW via MinF (mg)", row, MGWMinFmm);

			MGWAreaByPerimmm = (AreaByPerimmm * 98.9300565902831) - 51.2263389827057;
			setResult("Pred. MGW via Area/Perim. (mg)", row, MGWAreaByPerimmm);

			MGWAreaCircmm = (AreaCircmm * 4.38659456698031) - 6.50285378259882;
			setResult("Pred. MGW via Area*Circ. (mg)", row, MGWAreaCircmm);

			MGWMinorBySolidmm = (MinorBySolidmm * 25.8451725062272) - 38.6637693739865;
			setResult("Pred. MGW via Minor/Solidity (mg)", row, MGWMinorBySolidmm);

			MGWMinFBySolidmm = (MinFBySolidmm * 25.3266618161423) - 39.2958628289422;
			setResult("Pred. MGW via MinF/Solidity (mg)", row, MGWMinFBySolidmm);

			MGWAreaSolidmm = (AreaSolidmm * 3.53908703999503) - 10.1889702973988;
			setResult("Pred. MGW via Area*Solidity (mg)", row, MGWAreaSolidmm);

			MGWPerimCircmm = (PerimCircmm * 7.78045278393753) - 49.4410731094016;
			setResult("Pred. MGW via Perim.*Circ.", row, MGWPerimCircmm);

			MGWA1mm = (A1mm * 0.05055714899765) + 15.0110326693759;
			setResult("Pred. MGW via A1 (mg)", row, MGWA1mm);

			MGWA2mm = (A2mm * 0.0520301119954138) + 15.0057134742274;
			setResult("Pred. MGW via A2 (mg)", row, MGWA2mm);

			MGWKimIndexmm = (KimIndexmm * 1.12642072845763) + 1.14379065605157;
			setResult("Pred. MGW via Kim index (mg)", row, MGWKimIndexmm);

		}
	}


 //	Saving the results and outputs

	if (OutputDrawings != "Overlay, Outlines, labels, & ellipses" && OutputDrawings != "Don't save drawings" &&
		OutputDrawings != "Overlay, outlines, & labels") {
		saveAs("PNG", output_dir + title + "_processed.PNG");
	}
	
	saveAs("results", output_dir + title + ".csv");

	// Creating individual .csv files and "Total mean values.csv" table
	
		if (nResults > 1){
			run("Summarize");
		}
		
		tableTitle = Table.title;
		Table.rename(tableTitle, "Results");
		headings = Table.headings;
		headingsArray = split(headings, "\t");

		if (isOpen("Total mean values")==false) {
			Table.create("Total mean values");
		}
	
		selectWindow("Total mean values");
		size = Table.size;
		for (i=2; i<headingsArray.length; i++){
		
			if (nResults > 1) {
			data = getResultString(headingsArray[i], nResults-4);
			}
			else if (nResults < 2) {
			data = getResultString(headingsArray[i], nResults-1);
				 }

			selectWindow("Total mean values");
			Table.set("Label",size,title);
			if (nResults > 1) {
			Table.set("Num",size,nResults-4);
			}
			if (nResults < 2) {
			Table.set("Num",size,nResults);
			}
			Table.set(headingsArray[i], size, data);
			Table.update;
		}

	run("Close All");
	}
	}
	saveAs("Results", output_dir + "Total mean values.csv");

 // Finalizing...
	
	// Recording the ending time
	
    	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
     	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
     	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     	TimeString =DayNames[dayOfWeek]+" ";
     	if (dayOfMonth<10) {TimeString = TimeString+"0";}
     	TimeString = "\n----------------------------------------\n\n"+
     	    		 "Processing completed successfully\n\non "+TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" at ";
     	if (hour<10) {TimeString = TimeString+"0";}
     	TimeString = TimeString+hour+":";
     	if (minute<10) {TimeString = TimeString+"0";}
     	TimeString = TimeString+minute+":";
     	if (second<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+second;
    	print(TimeString+".");

	selectWindow("Log");
	saveAs("Text", output_dir + "Log.txt");

	// Closing all open windows

		cleanUp();
		function cleanUp() {
    		requires("1.30e");
    		if (isOpen("Results")) {
        		selectWindow("Results"); 
        		run("Close" );
    		}
    
    		if (isOpen("Total mean values.csv")) {
        		selectWindow("Total mean values.csv");
        		run("Close" );
    		}     
    
    		wait(4000);   
        
    		if (isOpen("Log")) {
        		selectWindow("Log");
         		run("Close" );
    		}
    
    		while (nImages()>0) {
        		  selectImage(nImages());  
          	  	run("Close");
    		}
		}
    
 //	End.