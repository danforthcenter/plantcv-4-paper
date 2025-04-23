#!/usr/bin/env python
# coding: utf-8

## Imports
import os
import numpy as np
from plantcv import plantcv as pcv
from plantcv.parallel import workflow_inputs
"""
updated on April 1, 2025
by Haley Schuhl 

- adjusted ROI to separate plants
"""

# Parse command-line arguments
args = workflow_inputs()

# ## About this workflow
# Segment and save out separate binary mask per plant
# mask name is the filename + "-1" for the left-hand plant
# and +"-2" in the right-hand plant 

## Read img 
img, path, filename = pcv.readimage(filename=args.image1)

## Transform color space for segmentation
gray_b = pcv.rgb2gray_lab(rgb_img=img, channel="b")

## Roughly segment the plants from background
plants = pcv.threshold.binary(gray_img=gray_b, threshold=133, object_type="light")
plants = pcv.fill(bin_img=plants, size=400)

## Detect the stick for removal 
gray_v = pcv.rgb2gray_hsv(rgb_img=img, channel="v")
mask = pcv.threshold.binary(gray_img=gray_v, threshold=205, object_type="light")
mask = pcv.fill_holes(bin_img=mask)
mask = pcv.fill(bin_img=mask, size=40000)
stick = pcv.dilate(gray_img=mask, ksize=5, i=3)
plants = pcv.image_subtract(gray_img1=plants, gray_img2=stick)

## Remove the pots from the mask with a Cut-To ROI 
pot_roi = pcv.roi.rectangle(img=img, x=1500, y=1855, w=1500, h=700)
pot = pcv.roi.filter(mask=plants, roi=pot_roi, roi_type="cutto")
plants = pcv.image_subtract(gray_img1=plants, gray_img2=pot)
## Fill small objects (noise) in the mask
plants = pcv.fill(bin_img=plants, size=400)
## Fill in small holes in the mask
plants = pcv.closing(gray_img=plants, kernel=np.array([[1, 0, 1], [0, 1, 0], [1, 0, 1]]))
## Fill in smallish holes in the mask
plants = ~pcv.fill(bin_img=~plants, size=100)


## Separate the two plants with ROIs
plant_rois = pcv.roi.multi(img=img,
                           coord=[(1650,1500), (2605,1500)],  ## Center point of each plant
                           radius=300)

# Separate the plants
labeled_mask, num_labels = pcv.create_labels(mask=plants, rois=plant_rois, roi_type="partial")

# Save out each mask with appended filename A=left B=right
if len(np.unique(labeled_mask)) == 3:  ## check that plants were detected separately
    plant_label = ["A", "B"]
    for i in [1,2]:
        mask_copy = np.copy(labeled_mask)
        np.unique(mask_copy)
        # Separate mask per plant
        submask = np.where(mask_copy == i, 255, 0)
        submask = submask.astype(np.uint8)
        # Format the filename to include which plant, left or right
        fname = filename.split(".")[0] + "-" + plant_label[i - 1] + ".png"
        # Format filepath for output masks
        # out_path = os.path.join("/data/datascience/users/hschuhl/rice_morphology/masks/", fname)
#         pcv.print_image(img=submask, filename=out_path)
        # Also save out overlay image for easier visualization of segmentation accuracy 
        overlap = pcv.visualize.overlay_two_imgs(submask, img)
        out_path = os.path.join("/data/datascience/users/hschuhl/rice_morphology/debug/mask_overlap/", fname)
        pcv.print_image(img=overlap, filename=out_path)
    

