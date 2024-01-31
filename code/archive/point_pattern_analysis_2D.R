library(tidyverse)
library(spatstat)
library(plotly)
library(stringr)
library(ggthemes)

setwd("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/code/")
inputdir <- file.path("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/midsections/")


##############################################################################
# Create ppp object for each abdomen section hemocyte coordinates
##############################################################################
abdomen_coordinates <- read.table("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/midsections/abdomen_coordinates_midsections.csv",
                                  sep="\t", header=TRUE)
hemocyte_coordinates <- read.table("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/results/midsections/hemocyte_coordinates_midsections.csv",
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

scaled_hemocyte_coordinates_2D_hyperframe$Gfunc <- with(scaled_hemocyte_coordinates_2D_hyperframe,
                                                          Gest(scaled_2D_coordinates, ratio=FALSE))

g_estimates <- anylapply(split(scaled_hemocyte_coordinates_2D_hyperframe$Gfunc, 
                          scaled_hemocyte_coordinates_2D_hyperframe$experimental_condition), pool) 

Genv <- envelope(scaled_hemocyte_coordinates_2D_hyperframe, Gest, nsim=39, fix.n=TRUE) 

swp <- data("swedishpines")
data("swedishpines")

plot(g_estimates$Fed$poolrs)
plot(g_estimates$Starved$poolrs)

plot(g_estimates)

test_hemocytes <- studpermu.test(scaled_hemocyte_coordinates_2D_hyperframe, scaled_2D_coordinates ~ experimental_condition,
                                 summaryfunction = Gest, use.Tbar = TRUE) 


