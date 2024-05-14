// This script takes in a .tiff image and identifies hemocytes as objects based on FITC (green) fluorescence intensities
// This script has 3 outputs - measurements of user-defined polygon ROI, measurements of objects detected, annotated image 
// with ROI and object detections overlayed.

// Author : Shruthi Bandyadka (sbandya@bu.ed), McCall Lab, Boston University 
import qupath.lib.gui.scripting.QPEx

annotation_measurements = "/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/v2_allbatches/annotation_measurements/"
detection_measurements = "/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/v2_allbatches/detection_measurements/"
annotated_images = "/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/v2_allbatches/annotated_images/"

def imageData = QPEx.getCurrentImageData()
def server = imageData.getServer()
def viewer = getCurrentViewer()

String path = server.getPath()
String path_without_extension =  path.lastIndexOf('.').with {it != -1 ? path[0..<it] : path}
String filename = path_without_extension[path_without_extension.lastIndexOf('/')+1..-1]

setImageType('FLUORESCENCE');
runPlugin('qupath.lib.plugins.objects.FillAnnotationHolesPlugin', '{}');
runPlugin('qupath.imagej.detect.cells.WatershedCellDetection', '{"detectionImage":"Channel 1","backgroundByReconstruction":true,"backgroundRadius":15.0,"medianRadius":0.0,"sigma":3.0,"minArea":30.0,"maxArea":2000.0,"threshold":25.0,"watershedPostProcess":true,"cellExpansion":0.0,"includeNuclei":true,"smoothBoundaries":true,"makeMeasurements":true}')
runPlugin('qupath.opencv.features.DelaunayClusteringPlugin', '{"distanceThresholdMicrons": 0.0,  "limitByClass": false,  "addClusterMeasurements": false}');

saveAnnotationMeasurements("${annotation_measurements}/${filename}.txt")
saveDetectionMeasurements("${detection_measurements}/${filename}.txt")
writeRenderedImage(viewer, "${annotated_images}/${filename}.png")

