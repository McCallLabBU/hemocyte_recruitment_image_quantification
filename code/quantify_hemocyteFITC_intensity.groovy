// This script takes in a .tiff image and identifies hemocytes as objects based on FITC (green) fluorescence intensities
// This script has 3 outputs - measurements of user-defined polygon ROI, measurements of objects detected, annotated image 
// with ROI and object detections overlayed.

// Author : Shruthi Bandyadka (sbandya@bu.ed), McCall Lab, Boston University 
import qupath.lib.gui.scripting.QPEx

annotation_measurements = "/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/data/batch2/annotation_measurements"
detection_measurements = "/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/data/batch2/detection_measurements"
annotated_images = "/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/data/batch2/annotated_images"

def imageData = QPEx.getCurrentImageData()
def server = imageData.getServer()
def viewer = getCurrentViewer()

String path = server.getPath()
String path_without_extension =  path.lastIndexOf('.').with {it != -1 ? path[0..<it] : path}
String filename = path_without_extension[path_without_extension.lastIndexOf('/')+1..-1]

setImageType('FLUORESCENCE');
runPlugin('qupath.lib.plugins.objects.FillAnnotationHolesPlugin', '{}');
runPlugin('qupath.imagej.detect.cells.PositiveCellDetection', '{"detectionImage": "Green",  "requestedPixelSizeMicrons": 0.5,  "backgroundRadiusMicrons": 7.0,  "medianRadiusMicrons": 0.0,  "sigmaMicrons": 0.5,  "minAreaMicrons": 1.0,  "maxAreaMicrons": 400.0,  "threshold": 50.0,  "watershedPostProcess": true,  "cellExpansionMicrons": 5.0,  "includeNuclei": true,  "smoothBoundaries": true,  "makeMeasurements": true,  "thresholdCompartment": "Nucleus: Green max",  "thresholdPositive1": 10.0,  "thresholdPositive2": 20.0,  "thresholdPositive3": 30.0,  "singleThreshold": true}');
runPlugin('qupath.opencv.features.DelaunayClusteringPlugin', '{"distanceThresholdMicrons": 0.0,  "limitByClass": false,  "addClusterMeasurements": false}');
saveAnnotationMeasurements("${annotation_measurements}/${filename}.txt")
saveDetectionMeasurements("${detection_measurements}/${filename}.txt")
writeRenderedImage(viewer, "${annotated_images}/${filename}.png")

