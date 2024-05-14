# Hemocyte Recruitment Analysis
Workflow to analyze hemocyte localization in confocal microscopy images of cryosectioned _Drosophila melanogaster_ abdomens, as described in publication (upcoming- under review at Frontiers in Immunology) 

## Aims
Are hemocytes recruited to clear the dying ovarian follicle epithelium during starvation?  
Does hemocyte localization patterns change in starved abdomens compared to well-fed controls? 

## Software 
- FIJI ImageJ v2.1.0/1.53c
- QuPath v0.3.2
- Python v3.11.5

## Workflow overview

## QuPath 

- Define ROI manually
- Find centroid of defined polygon
- Identify fluorescence as discrete objects
- Find centroid of each object
- Obtain Delauney triangulation metrics

## Custom Python notebooks and FIJI macro

- Preprocess DAPI and FITC images to remove background noise and merge channels
- Summarize and consolidate abdomen ROI measurements and hemocyte coordinates into dataframes for downstream analysis
- visualize distributions of abdomen area, hemocyte detections 
- Determine hemocyte sparsity in well fed and starved abdomens

# Methods

### 1. Preprocess images 

raw images are thresholded based on Yen's method implemented in scikit-image https://scikit-image.org/docs/stable/api/skimage.filters.html#skimage.filters.threshold_yen and then merged into green and blue channels in FIJI

```bash
# Create new python virtual environment and install necessary libraries
python3 -m venv hemocyte_quant
source hemocyte_quant/bin/activate

pip3 install ipykernel 
pip3 install numpy 
pip3 install pandas 
pip3 install matplotlib 
pip3 install seaborn
pip3 install scipy 
pip3 install statsmodels
pip3 install sklearn 
pip3 install scikit-image

# Create new kernel with libraries installed
python -m ipykernel install --user --name=hemocyte_quant --user
jupyter notebook 

# Run the following notebook to perform preprocessing 
preprocess_FITC.ipynb 

```

Once images are preprocessed, run FIJI macro `merge_scikit.ijm` to apply LUT and merge DAPI and FITC channels


### 2. ROI definition, Segmentation, centroid measurements, delauney triangulation

- Set up input and output directories
    1. create input directory with merged DAPI and FITC .tif images to be quantified 
    2. create output directory named `results` with 3 following sub-directories -
        1. `annotation_measurements` for `.txt` files containing ROI area measurements
        2. `detection_measurements`- for `.txt` files containing hemocyte object detection measurements
        3. `annotated_images`- for storing QuPath processed images containing polygon annotation, positive cell detections, and delauney triangulation measurements. 
- Open merged input image to be quantified in QuPath
- Set image type as `Fluoresence` in the auto-prompt dialogue box
- Use the `brush tool` to draw ROI boundaries around the abdomen, excluding debris and thorax
- Open the script editor - `automate > show script editor` and open the file `quantify_hemocyteFITC_intensity.groovy`
- Modify the paths to the variables `annotation_measurements`, `detection_measurements`, `annotated_images` to include the full paths to the directories created in step 2.b.
- Run the script using keys `Cmd+R` on Mac OSX or `Ctrl+R` on Windows

### 3. Stastiscal analysis and visualization of hemocyte distribution

To perform downstream analysis on hemocyte detections, run the following notebooks in the order mentioned-  

`scale_coordinates_midsections.ipynb` For consolidating feature vectors into dataframes

`exploratory_analysis_midsections.ipynb` For visualization of distributions of area, hemocyte detections, delaunay triangulation 

`nearest_neighbors_midsections.ipynb` For Nearest-neighbors G-function analysis


## Results
Figures and consolidated csv files are in the `results/v2_allbatches` folder

# References

1. Bankhead, P., Loughrey, M.B., Fernández, J.A. *et al.* QuPath: Open source software for digital pathology image analysis. *Sci Rep* **7,** 16878 (2017). https://doi.org/10.1038/s41598-017-17204-5
2. Spatstat R library
    1. Spatial Point Patterns: Methodology and Applications with R
