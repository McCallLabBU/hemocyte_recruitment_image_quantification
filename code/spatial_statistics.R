library(tidyverse)
library(spatstat)
library(plotly)
library(ggthemes)

setwd("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/code/")
inputdir <- file.path("/Users/sbandya/Desktop/hemocyte_recruitment_image_quantification/analysis/")

# Read all abdomen and hemocyte object measurements


abdomen_data <-  read.csv(file.path(paste0(inputdir,"annotation_measurements_compiled.tsv"))
  sep = "\t", header=TRUE)
hemocyte_data <- read.csv(file.path(paste0(inputdir,"detection_measurements_compiled.tsv")),sep = "\t", header=TRUE)
#samples <- 

merged <- dplyr::full_join(abdomen_data, hemocyte_data, by = "Image", suffix = c("_ab","_hm"),keep=TRUE,multiple="all")

## Zero center all abdomen centroids and scale hemocyte centroids in each abdomen
merged_scaled <- merged  %>% 
  mutate("Centroid_X_hm_scaled" = Centroid_X_hm - Centroid_X_ab) %>% 
  mutate("Centroid_Y_hm_scaled" = Centroid_Y_hm - Centroid_Y_ab) %>% 
  select(Image_ab,Centroid_X_hm_scaled,Centroid_Y_hm_scaled,condition,centroid_distances, Area.µm.2)

### Zero-scaled hemocyte distances without area-normalization or log-scaling. 
merged_scaled <- merged_scaled %>% mutate(centroid_distances_scaled = centroid_distances) 
mean_centroid_distance <- plyr::ddply(merged_scaled, "condition", summarise, grp.mean=mean(centroid_distances_scaled)) 

merged_scaled  %>% group_by(condition) %>% ggplot(aes(x=centroid_distances_scaled,fill=condition)) +
  #geom_histogram() + 
  geom_density(alpha=0.9)+
  ggtitle("Distribution of scaled hemocyte distances") + 
  xlab("Hemocyte distance to Abdomen centroid") + 
  geom_vline(data=mean_centroid_distance, aes(xintercept=grp.mean),
             color=c("#924e8f", "#D79309"), linetype="dashed", size=1) + 
  scale_fill_manual(values = c("#924e8f", "#ffbf3c")) +
  theme_clean()

### Zero-scaled hemocyte distances after area-normalization and log-scaling 
merged_scaled_areanormed_log <- merged_scaled %>% mutate(centroid_distances_scaled = -log10(centroid_distances/Area.µm.2)) 
mean_centroid_distance <- plyr::ddply(merged_scaled_areanormed_log, "condition", summarise, grp.mean=mean(centroid_distances_scaled)) 
merged_scaled_areanormed_log  %>% group_by(condition) %>% ggplot(aes(x=centroid_distances_scaled,fill=condition)) +
  #geom_histogram() + 
  geom_density(alpha=0.9)+
  ggtitle("Distribution of scaled hemocyte distances") + 
  xlab("-log10(Hemocyte distance to Abdomen centroid/Area of abdomen)") + 
  geom_vline(data=mean_centroid_distance, aes(xintercept=grp.mean),
             color=c("#924e8f", "#D79309"), linetype="dashed", size=1) + 
  scale_fill_manual(values = c("#924e8f", "#ffbf3c")) +
  theme_clean()

  
head(merged_scaled,10)
head(merged,10)
min(merged_scaled$Centroid_X_hm_scaled)
min(merged_scaled$Centroid_Y_hm_scaled)
max(merged_scaled$Centroid_X_hm_scaled)
max(merged_scaled$Centroid_Y_hm_scaled)

test <- merged_scaled %>% filter(str_detect(Image_ab,"73F"))
test <- test %>% group_by(Image_ab) %>% separate(Image_ab, c("fly", "section"), sep="_")

plot_ly(test, x=~Centroid_X_hm_scaled, y=~Centroid_Y_hm_scaled, 
             z=~section,color=~section) %>% 
  layout(title = 'Zero-scaled 3D reconstruction of Hemocyte Distributions - Sample 73F (Conditioned)')

plot_ly(merged_scaled, x=~Centroid_X_hm_scaled, y=~Centroid_Y_hm_scaled, 
        z=~Image_ab,color=~condition) %>%
  layout(title = 'Zero-scaled 3D reconstruction of Hemocyte Distributions - Sample 73F (Conditioned)')


ggplot(merged_scaled, aes(x=Centroid_X_hm_scaled, y=Centroid_Y_hm_scaled,group=condition))+
  geom_point(aes(col=condition)) + 
  scale_color_manual(values=c("#924e8f", "#ffbf3c")) +
  ggtitle("Hemocyte detections in abdomens") + 
  xlab("zero-scaled X co-ordinates of detected hemocytes") +
  ylab("zero-scaled Y co-ordinates of detected hemocytes") + 
  theme_clean()

merged_scaled_an <- merged_scaled %>% mutate(Centroid_X_hm_scaled_an = (Centroid_X_hm_scaled+1000/ Area.µm.2)) %>%
  mutate(Centroid_Y_hm_scaled_an =(Centroid_Y_hm_scaled+1000 / Area.µm.2))

merged_scaled_areanormed_log <- merged_scaled %>% mutate(x_shift = Centroid_X_hm_scaled) %>%
  mutate(y_shift = Centroid_Y_hm_scaled) %>%
  mutate(x_shift_arealog = 1000*(x_shift/Area.µm.2)) %>% 
  mutate(y_shift_arealog = 1000*(y_shift/Area.µm.2)) 
  
ggplot(merged_scaled_areanormed_log, aes(x=x_shift_arealog, y=y_shift_arealog,group=condition))+
  geom_point(aes(col=condition)) + 
  ggtitle("Hemocyte detections in abdomens") + 
  xlab("1000*( zero-scaled hemocyte X co-ordinates / Area.µm.2)") +
  ylab("1000*( zero-scaled hemocyte Y co-ordinates / Area.µm.2)") + 
  scale_color_manual(values= c("#924e8f", "#ffbf3c")) +
  theme_clean()
