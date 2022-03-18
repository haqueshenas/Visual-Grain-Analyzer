# Visual-Grain-Analyzer
Visual Grain Analyzer (version 1.0)

(For more detailed information, please see the PDF version of README)

Visual Grain Analyzer (VGA) is a user-friendly ImageJ macro, which has utilized ImageJ/or Fiji facilities to provide a simple tool for grain analysis, seed technology, and phenomics studies. 
This macro:

A)	Simulates the processing and calculations reported in the manuscript:
    Haghshenas, A., Emam, Y., & Jafarizadeh, S. (2021). Wheat grain width: A clue for re-exploring visual indicators of grain weight. bioRxiv, 2021.2010.2013.464205.
      https://doi.org/10.1101/2021.10.13.464205
    
   In particular, as reported in the paper, VGA provides various estimations of wheat grain weight, based on the image-derived indices.


B)	Also, VGA might be used for other phenotyping purposes such as size & shape analyses of grains of other species, leaf area measurement, etc.



How to run?

For running this user-friendly macro, no scriptwriting or image processing skills are required. Just follow the below steps to process your own images, and extract the quantitative information:

1)	Download the free and open-source Fiji (or ImageJ) software from: https://imagej.net/software/fiji/downloads
2)	Create two input and output folders, and put your images in the input folder.
3)	Open the VGA.ijm macro in the Fiji. For this, you can either drag & drop the file into the Fiji head, or follow: File> Open.
4)	In the macro editor, click “Run” (if the Run button is hidden, you can follow Run> Run from the top bar). 
5)	Follow the successive pop-up dialog windows of the macro, to initiate the processing. After clicking Ok in the last window, status of processing will be displayed on the Log window. Please wait for the message: “Processing completed successfully”.
6)	Find the results in the output folder (you have determined the output path previously in the respective pop-up window).


Inputs

•	RGB images


Outputs

•	Single .csv files: include the quantitative results extracted from the individual images

•	“Total mean values .csv” file: provides the mean values of all individual .csv files.

•	Drawings: various types of drawings represent the visual output of image processing, including segmentation, ellipse fitting, etc.

•	Log: general information about processing and settings are saved in this file.







Copyright

MIT license

Copyright <2022> <Abbas Haghshenas et al., Department of Plant Production and Genetics, Shiraz University, Shiraz, Iran>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
