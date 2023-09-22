library(tidyverse)
library(spatstat)
library(plotly)
library(stringr)
library(ggthemes)

setwd("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/code/")
inputdir <- file.path("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/analysis/")

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
# Reconstruct 3D fly abdomen from sections
# Create pp3 object for each 3D abdomen hemocyte coordinates
##############################################################################
scaled_hemocyte_coordinates_3D <- list()
for(fly in flyIDs){
  #print(fly)
  abdomen_section_IDS <- grep(fly, names(scaled_hemocyte_coordinates), value = TRUE)
  all_zstacks_df <- bind_rows(scaled_hemocyte_coordinates[abdomen_section_IDS], .id = "Image")
  
  spatstat_object <- pp3(x=all_zstacks_df$centroid_x_zeroscaled,
                         y=all_zstacks_df$centroid_y_zeroscaled,
                         z=as.numeric(all_zstacks_df$z_stack), 
                         box3(xrange= c(min(all_zstacks_df$centroid_x_zeroscaled)-100,max(all_zstacks_df$centroid_x_zeroscaled)+100),
                              yrange= c(min(all_zstacks_df$centroid_y_zeroscaled)-100,max(all_zstacks_df$centroid_y_zeroscaled)+100),
                              zrange= c(0,max(as.numeric(all_zstacks_df$z_stack))+15)
                              #zrange= c(0,1000)
                         ))
  plot.pp3(spatstat_object)
  scaled_hemocyte_coordinates_3D[[fly]] <- spatstat_object
  #break
}

##############################################################################
# Create a hyperframe of abdomen pp3 objects with replicate/condition information
##############################################################################

conditions <- append(rep("wellfed",33), rep("starved",34)) #Placeholder
scaled_hemocyte_coordinates_3D_hyperframe <- hyperframe(scaled_3D_coordinates = scaled_hemocyte_coordinates_3D,
                                                        samples = names(scaled_hemocyte_coordinates_3D),
                                                        experimental_condition = factor(conditions))

scaled_hemocyte_coordinates_3D_hyperframe

plot(scaled_hemocyte_coordinates_3D_hyperframe,)
plot(scaled_hemocyte_coordinates_3D_hyperframe, quote(plot(K3est(scaled_3D_coordinates))))   

dim(scaled_hemocyte_coordinates_3D_hyperframe)

K3est(spatstat_object)
E <- envelope(spatstat_object, K3est, nsim=100, nrank=50, nrval=512) 
plot(E, sqrt(.) ~ r) 

