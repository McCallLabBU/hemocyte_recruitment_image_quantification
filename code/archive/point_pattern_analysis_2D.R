library(tidyverse)
library(spatstat)
library(plotly)
library(stringr)
library(ggthemes)

setwd("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/code/")
inputdir <- file.path("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/analysis/")


##############################################################################
# Create ppp object for each abdomen section hemocyte coordinates
##############################################################################
abdomen_coordinates <- read.table("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/abdomen_coordinates.csv",
                                  sep="\t", header=TRUE)
hemocyte_coordinates <- read.table("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/hemocyte_coordinates.csv",
                                   sep="\t", header=TRUE)

scaled_hemocyte_coordinates_2D <- list()
abdomen_areas_2D <- list()
experimental_condition <- list()

for(section in unique(hemocyte_coordinates$Image)){
  print(section)
  xcoords <- hemocyte_coordinates %>% filter(Image == section) %>% pull(centroid_x_zeroscaled)
  ycoords <- hemocyte_coordinates %>% filter(Image == section) %>% pull(centroid_y_zeroscaled)

  spatobj <- ppp(x=xcoords, y=ycoords, 
                 #window = owin(c(min(xcoords),max(xcoords)), c(min(ycoords),max(ycoords)))
                 xrange = c(min(xcoords)-100,max(xcoords)+100),
                 yrange = c(min(ycoords)-100,max(ycoords)+100)
                 )
  scaled_hemocyte_coordinates_2D[[section]] <- spatobj
  
  area <- abdomen_coordinates %>% filter(Image == section) %>% pull(Area.µm.2)
  abdomen_areas_2D[[section]] <- area
  
  
  condition <- abdomen_coordinates %>% filter(Image == section) %>% pull(condition)
  experimental_condition[[section]] <- condition
  
}


scaled_hemocyte_coordinates_2D_hyperframe <- hyperframe(scaled_2D_coordinates = scaled_hemocyte_coordinates_2D,
                                                        samples = names(scaled_hemocyte_coordinates_2D),
                                                        experimental_condition = unname(unlist(experimental_condition)),
                                                        abdomen_area = unname(unlist(abdomen_areas_2D)))

scaled_hemocyte_coordinates_2D_hyperframe$RipleyK <- with(scaled_hemocyte_coordinates_2D_hyperframe,
                                                          Gest(scaled_2D_coordinates, ratio=FALSE))

groupK <- anylapply(split(scaled_hemocyte_coordinates_2D_hyperframe$RipleyK, 
                          scaled_hemocyte_coordinates_2D_hyperframe$experimental_condition), pool) 

plot(groupK)

test_hemocytes <- studpermu.test(scaled_hemocyte_coordinates_2D_hyperframe, scaled_2D_coordinates ~ experimental_condition,
                                 summaryfunction = Gest, use.Tbar = TRUE) 


##############################################################################
## OLD
##############################################################################


abdomen_measurements <- file.path("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/analysis/annotation_measurements/")
hemocyte_measurements <- file.path("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/analysis/detection_measurements/")
##############################################################################
# For each fly abdomen section
# set the abdomen centroid to (0,0)
# scale the hemocyte identifications with respect to (0,0)
##############################################################################

flyIDs <- c()
scaled_hemocyte_coordinates <- list()
for(file in list.files(abdomen_measurements)){
  section_abdomen_measurements <- read.table(file = paste0(abdomen_measurements,file),sep="\t",header=TRUE)
  section_hemocyte_measurements <-  read.table(file = paste0(hemocyte_measurements,file),sep="\t",header=TRUE)
  
  section_hemocyte_measurements["centroid_x_zeroscaled"] <- section_hemocyte_measurements["Centroid.X.µm"] - section_abdomen_measurements["Centroid.X.µm"][,1]
  section_hemocyte_measurements["centroid_y_zeroscaled"] <- section_hemocyte_measurements["Centroid.Y.µm"] - section_abdomen_measurements["Centroid.Y.µm"][,1]
  
  basename <- gsub(".txt","",file)
  section_hemocyte_measurements["z_stack"] <- str_split(basename,"_")[[1]][2]
  
  flyIDs <- append(flyIDs,str_split(basename,"_")[[1]][1])
  scaled_hemocyte_coordinates[[basename]] <- section_hemocyte_measurements
}


##############################################################################
# Create ppp object for each abdomen section hemocyte coordinates (old)
##############################################################################


scaled_hemocyte_coordinates_2D <- list()


for(section in names(scaled_hemocyte_coordinates)){

  section_abdomen_area <- grep(fly, names(scaled_hemocyte_coordinates), value = TRUE)
  all_zstacks_df <- bind_rows(scaled_hemocyte_coordinates[abdomen_section_IDS], .id = "Image")
  spatstat_object <- ppp(x=all_zstacks_df$centroid_x_zeroscaled,
                         y=all_zstacks_df$centroid_y_zeroscaled,
                         xrange= c(min(all_zstacks_df$centroid_x_zeroscaled)-100,max(all_zstacks_df$centroid_x_zeroscaled)+100),
                         yrange= c(min(all_zstacks_df$centroid_y_zeroscaled)-100,max(all_zstacks_df$centroid_y_zeroscaled)+100))
                              #zrange= c(0,1000)
                        
  #plot.ppp(spatstat_object)
  scaled_hemocyte_coordinates_2D[[section]] <- spatstat_object
  #break
}

##############################################################################
# Create a hyperframe of abdomen ppp objects with replicate/condition information
##############################################################################

conditions <- append(rep("wellfed",137), rep("starved",138)) #Placeholder
scaled_hemocyte_coordinates_2D_hyperframe <- hyperframe(scaled_2D_coordinates = scaled_hemocyte_coordinates_2D,
                                                        samples = names(scaled_hemocyte_coordinates_2D),
                                                        experimental_condition = factor(conditions))

scaled_hemocyte_coordinates_2D_hyperframe
dim(scaled_hemocyte_coordinates_2D_hyperframe)
#plot(scaled_hemocyte_coordinates_3D_hyperframe, quote(plot(K3est(scaled_3D_coordinates))))   

##############################################################################
# Calculate Ripley's K summary statistic for each abdomen
##############################################################################

scaled_hemocyte_coordinates_2D_hyperframe$RipleyK <- with(scaled_hemocyte_coordinates_2D_hyperframe,
                                                          Kest(scaled_2D_coordinates, ratio=FALSE))

groupK <- anylapply(split(scaled_hemocyte_coordinates_2D_hyperframe$RipleyK, 
                          scaled_hemocyte_coordinates_2D_hyperframe$experimental_condition), pool) 

plot(groupK)

Leach <- anylapply(Lsplit, collapse.fv,  same="theo", different="iso")  
plot(Leach, legend=FALSE, xlim=c(0, 0.2), ylim=c(0, 0.2)) 


coproc <-with(scaled_hemocyte_coordinates_2D_hyperframe,  roc(samples, distfun(experimental_condition), high=FALSE))  
plot(coproc)  


py <- pyramidal  
py$n <- with(py, npoints(Neurons))  
py$area <- with(py, area(Neurons))  
py <- as.data.frame(py, warn=FALSE) 
