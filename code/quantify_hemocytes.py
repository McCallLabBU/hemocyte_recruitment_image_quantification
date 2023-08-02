#This script takes in fluorescence microscopy images and applies white top hat as a preprocessing step for quantification
#Usage- python quantify_hemocytes.py --input_image full_path_to_input_image --outpufull_path_to_output_directory
#Author : Shruthi Bandyadka (sbandya@bu.edu)

import sys
from os import path, makedirs
import argparse 
import numpy as np
from skimage.io import imread, imsave
from skimage.color import rgb2gray
from skimage.morphology import disk, square
import matplotlib.pyplot as plt
from skimage.morphology import white_tophat

parser = argparse.ArgumentParser(description='Arguments for image pre-processing')
parser.add_argument('--input_image', 
                    help='full path to raw image for preprocessing')
parser.add_argument('--footprint', default=15,
                    help='optional disk radius parameter supplied to skimage.morphology.white_tophat()')
parser.add_argument('--output', 
                    help='full path to output directory to save preprocessed images')

args = parser.parse_args()


def preprocess_image(input_image,footprint):
    raw_image = imread(input_image) 
    grayscale = rgb2gray(raw_image)
    top_hat = white_tophat(grayscale,disk(footprint))
    
    return top_hat

def quantify_intensities():
    pass

if __name__ == "__main__":
    
    output_image = preprocess_image(args.input_image,args.footprint)
    plt.imshow(output_image,cmap='gray')
    plt.axis('off')
    
    makedirs(args.output, exist_ok=True)
    output_filename = path.join(args.output,path.split(args.input_image)[-1].split(".")[0]+"_preprocessed.tif")
    plt.savefig(output_filename,bbox_inches="tight", pad_inches=0.0,dpi=500)
    
    