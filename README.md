# Hemocyte Recruitment Analysis
Workflow to analyze hemocyte localization in confocal microscopy images of cryosectioned _Drosophila melanogaster_ abdomens, as described in publication ### 

## Aims
Are hemocytes recruited to clear the dying ovarian follicle epithelium during starvation?  
Does hemocyte localization patterns change in starved abdomens compared to well-fed controls? 

## Software 

- QuPath v0.3.2
- Python v3.11.5

## Workflow overview

## QuPath 

- Define ROI manually
- Find centroid of defined polygon
- Identify fluorescence as discrete objects
- Find centroid of each object
- Obtain Delauney triangulation metrics

## Custom Python notebooks

- Summarize and consolidate abdomen ROI measurements and hemocyte coordinates into dataframes for downstream analysis
- visualize distributions of abdomen area, hemocyte detections 
- Determine hemocyte sparsity in well fed and starved abdomens

# Methods

### QuPath - ROI definition, Segmentation, centroid measurements, delauney triangulation

1. Download and install QuPath  
    1. Download link https://qupath.github.io/ 
    2. Documentation https://qupath.readthedocs.io/en/stable/index.html
2. Set up input and output directories
    1. create input directory with DAPI and FITC .tif images to be quantified 
    2. create output directory named `analysis` with 3 following sub-directories -
        1. `annotation_measurements` for `.txt` files containing ROI area measurements
        2. `detection_measurements`- for `.txt` files containing hemocyte object detection measurements
        3. `annotated_images`- for storing QuPath processed images containing polygon annotation, positive cell detections, and delauney triangulation measurements. 
3. Open FITC image to be quantified in QuPath
4. Set image type as `Fluoresence` in the auto-prompt dialogue box
5. Use the `brush tool` to draw ROI boundaries around the abdomen, excluding debris and thorax
6. Open the script editor - `automate > show script editor` and open the file `quantify_hemocyteFITC_intensity.groovy`
7. Modify the paths to the variables `annotation_measurements`, `detection_measurements`, `annotated_images` to include the full paths to the directories created in step 2.b.
8. Run the script using keys `Cmd+R` on Mac OSX or `Ctrl+R` on Windows

### Python - Stastiscal analysis  and visualization of hemocyte distribution

```bash
# Create new virtual environment and install necessary libraries
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

# Create new kernel with libraries installed
python -m ipykernel install --user --name=hemocyte_quant --user
jupyter notebook 

# Perform statistical analysis and visualization of hemocyte distribution 
scale_coordinates_midsections.ipynb ## For consolidating feature vectors
exploratory_analysis_midsections.ipynb ## For visualization of distributions of area, hemocyte detections, delaunay triangulation 
nearest_neighbors_midsections.ipynb ## For G-function 

```

## Results
Figures and consolidated csv files are in the `results/midsections` folder

# References

1. Bankhead, P., Loughrey, M.B., Fernández, J.A. *et al.* QuPath: Open source software for digital pathology image analysis. *Sci Rep* **7,** 16878 (2017). https://doi.org/10.1038/s41598-017-17204-5
2. Spatstat R library
    1. Spatial Point Patterns: Methodology and Applications with R
