# Hemocyte Recruitment Quantification
Workflow to quantify hemocyte recruitment in _Drosophila melanogaster_ abdomens in confocal microscopy images


# Aims

Are hemocytes recruited to clear starvation-induced ovarian follicle cell death? 
	- Are there more hemocytes in the center of the abdomen than in the perimeter in starved abdomens when compared to well-fed controls?

# Tools

- QuPath
- Python v3.9.0
- R version 4.2.1 (2022-06-23)

# Workflow Description

## QuPath

- Define ROI manually
- Find centroid of defined polygon
- Identify fluorescence as discrete objects
- Find centroid of each object
- Obtain Delauney triangulation metrics

## Custom Python Script

- Measure distance of object centroid from polygon centroid
- Plot distribution of centroid distances for conditioned and starved hemocytes, normalized by area of abdomen
- Reject the null hypothesis that there is no difference in the means and variances of distributions of starved and conditioned abdomens

# Methods

## QuPath - ROI definition, Segmentation, centroid measurements, delauney triangulation

1. Download and install QuPath  
    1. Download link https://qupath.github.io/ 
    2. Documentation https://qupath.readthedocs.io/en/stable/index.html
2. Set up input and output directories
    1. create input directory with DAPI and FITC .tif images to be quantified 
    2. create output directory named `analysis` with 3 following sub-directories -
        1. `annotation_measurements` for `.txt` files containing ROI area measurements
        2. `detection_measurements`- for `.txt` files containing hemocyte object detection measurements
        3.  `annotated_images`- for storing QuPath processed images containing polygon annotation, positive cell detections, and delauney triangulation measurements. 
3. Open FITC image to be quantified in QuPath
4. Set image type as `Fluoresence` in the auto-prompt dialogue box
5. Use the `brush tool` to draw ROI boundaries around the abdomen, excluding debris and thorax
6. Open the script editor - `automate > show script editor`
7. Paste the following code into the script editor -
    
    ```groovy
    
    annotation_measurements = "/Users/sbandya/Desktop/dev/hemocyte_ImageSegmentation/analysis/annotation_measurements"
    detection_measurements = "/Users/sbandya/Desktop/dev/hemocyte_ImageSegmentation/analysis/detection_measurements"
    annotated_images = "/Users/sbandya/Desktop/dev/hemocyte_ImageSegmentation/analysis/annotated_images"
    
    def imageData = QPEx.getCurrentImageData()
    def server = imageData.getServer()
    def viewer = getCurrentViewer()
    
    String path = server.getPath()
    String path_without_extension =  path.lastIndexOf('.').with {it != -1 ? path[0..<it] : path}
    String filename = path_without_extension[path_without_extension.lastIndexOf('/')+1..-1]
    
    setImageType('FLUORESCENCE');
    runPlugin('qupath.lib.plugins.objects.FillAnnotationHolesPlugin', '{}');
    runPlugin('qupath.imagej.detect.cells.PositiveCellDetection', '{"detectionImage": "Green",  "requestedPixelSizeMicrons": 0.5,  "backgroundRadiusMicrons": 7.0,  "medianRadiusMicrons": 0.0,  "sigmaMicrons": 0.5,  "minAreaMicrons": 1.0,  "maxAreaMicrons": 400.0,  "threshold": 25.0,  "watershedPostProcess": true,  "cellExpansionMicrons": 5.0,  "includeNuclei": true,  "smoothBoundaries": true,  "makeMeasurements": true,  "thresholdCompartment": "Nucleus: Green max",  "thresholdPositive1": 10.0,  "thresholdPositive2": 20.0,  "thresholdPositive3": 30.0,  "singleThreshold": true}');
    runPlugin('qupath.opencv.features.DelaunayClusteringPlugin', '{"distanceThresholdMicrons": 0.0,  "limitByClass": false,  "addClusterMeasurements": false}');
    saveAnnotationMeasurements("${annotation_measurements}/${filename}.txt")
    saveDetectionMeasurements("${detection_measurements}/${filename}.txt")
    writeRenderedImage(viewer, "${annotated_images}/${filename}.png")
    ```
    
8. Modify the paths to the variables `annotation_measurements`, `detection_measurements`, `annotated_images` to show the full paths to the directories you created in step 2.b.
9. Run the script using keys `Cmd+R` on Mac OSX or `Ctrl+R` on Windows

## Python - Stastiscal analysis  and visualization of hemocyte distribution

```bash
# Create new virtual environment and install necessary libraries
python3 -m venv hemocyte_quant
source hemocyte_quant/bin/activate

pip3 install ipykernel 
pip3 install numpy 
pip3 install pandas 
pip3 install matplotlib 
pip3 install seaborn

# Create new kernel with libraries installed
python -m ipykernel install --user --name=hemocyte_quant
jupyter notebook 

# Perform statistical analysis and visualization of hemocyte distribution 
analyze_intensity_distributions.ipynb

```

Intensity distribution visualizations were performed in the Jupyter notebook `analyze_intensity_distributions.ipynb` 

# Results


# References

1. Bankhead, P., Loughrey, M.B., Fernández, J.A. *et al.* QuPath: Open source software for digital pathology image analysis. *Sci Rep* **7,** 16878 (2017). https://doi.org/10.1038/s41598-017-17204-5
2. Spatstat R library
    1. Spatial Point Patterns: Methodology and Applications with R

# Tutorials

