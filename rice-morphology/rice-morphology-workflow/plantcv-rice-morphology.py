#!/usr/bin/env python
# coding: utf-8

## Imports
import os
import numpy as np
from plantcv import plantcv as pcv
from plantcv.parallel import workflow_inputs
"""
updated on on April 1, 2025
by Haley Schuhl 

added analyze_stem & analyze.size
added filtering and re-labeling of angles
- 
updated size to 80, affecting 
segment_tangent_angle & 
segment_insertion_angle
- 
added leaf curvature

"""

# Parse command-line arguments
args = workflow_inputs()

# ## About this workflow
# Skeletonize a plant mask, sort the segments into stem or leaf,
# then sort leaves by branch point coordinate,  then measure traits
# about the leaf morphology including leaf length & angle 

## Set the size parameter, which is how many pixels should be considered while making tangent angles
size_param = 80

## Read img 
mask, mask_path, mask_filename = pcv.readimage(args.image1)
rgb_filename = mask_filename.split("-")[0] + ".JPG"
img, rgb_path, filename = pcv.readimage(os.path.join("/data/datascience/users/hschuhl/rice_morphology/imgs/", rgb_filename))

## Clean and smooth the mask
mask = pcv.median_blur(gray_img=mask, ksize=4)
mask = pcv.closing(gray_img=mask)
mask = pcv.dilate(gray_img=mask, ksize=3, i=1)
mask = pcv.closing(gray_img=mask)
mask = pcv.closing(gray_img=mask)

## Skeletonize the plant and prune barbs
skel = pcv.morphology.skeletonize(mask=mask)
pruned, segmented_img, segment_objects = pcv.morphology.prune(skel, 50)
pruned, segmented_img, segment_objects = pcv.morphology.prune(pruned, 30)

# Sort leaves into stem and leaf
leaf_objects, other_objects = pcv.morphology.segment_sort(skel_img=pruned, objects=segment_objects, mask=mask)
# Make a segmente image 
segmented_img, segment_objects = pcv.morphology.segment_skeleton(skel_img=pruned, mask=mask)

# Format filename
fname_before = mask_filename[:-4] + "_before.png"
fname_after = mask_filename[:-4] + "_size80.png"

pcv.params.text_size = 5
vis, labeled = pcv.morphology.segment_id(skel_img=pruned, objects=leaf_objects, mask=mask)
# destination_file = os.path.join("/data/datascience/users/hschuhl/rice_morphology/debug/", fname_before)
# pcv.print_image(labeled, filename=destination_file)

## segment end analysis, this also re-orders leaves according to branch point y-coord
sorted_leaves, labeled_img, _, _ = pcv.morphology.segment_ends(skel_img=pruned, leaf_objects=leaf_objects, mask=mask)

vis, labeled = pcv.morphology.segment_id(skel_img=pruned, objects=sorted_leaves, mask=mask)
# destination_file = os.path.join("/data/datascience/users/hschuhl/rice_morphology/debug/", fname_after)
# pcv.print_image(labeled, filename=destination_file)

## Set debugging parameters
pcv.params.text_size = 2
pcv.params.text_thickness = 5
pcv.params.line_thickness = 15
## Extract leaf lengths
labeled_img = pcv.morphology.segment_path_length(segmented_img=segmented_img, objects=sorted_leaves)
# destination_file = os.path.join("/data/datascience/users/hschuhl/rice_morphology/debug/path_length", fname_after)
# pcv.print_image(labeled_img, filename=destination_file)
# ## Filter outputs and only keep the three youngest leaves (to better match manual data)
# pcv.outputs.observations['default']['segment_path_length']['value'] = pcv.outputs.observations['default']['segment_path_length']['value'][-3:]
# pcv.outputs.observations['default']['segment_path_length']['label'] = [2,1,0]

## Extract leaf curvature
labeled_img = pcv.morphology.segment_curvature(segmented_img=segmented_img, objects=sorted_leaves)

## Measure leaf curvature angle 
labeled_img = pcv.morphology.segment_tangent_angle(segmented_img=segmented_img, objects=sorted_leaves, size=size_param)
destination_file = os.path.join("/data/datascience/users/hschuhl/rice_morphology/debug_80/tangent_angle", fname_after)
pcv.print_image(labeled_img, filename=destination_file)
# ## Filter outputs and only keep the three youngest leaves (to better match manual data)
# pcv.outputs.observations['default']['segment_tangent_angle']['value'] = pcv.outputs.observations['default']['segment_tangent_angle']['value'][-3:]
# pcv.outputs.observations['default']['segment_tangent_angle']['label'] = [2,1,0]

## Measure leaf insertion angle (angel between leaf and stem)
labeled_img = pcv.morphology.segment_insertion_angle(segmented_img=segmented_img, leaf_objects=sorted_leaves, skel_img=pruned, stem_objects=other_objects, size=size_param)
destination_file = os.path.join("/data/datascience/users/hschuhl/rice_morphology/debug_80/insertion_angle", fname_after)
pcv.print_image(labeled_img, filename=destination_file)
# ## Filter outputs and only keep the three youngest leaves (to better match manual data)
# pcv.outputs.observations['default']['segment_insertion_angle']['value'] = pcv.outputs.observations['default']['segment_insertion_angle']['value'][-3:]
# pcv.outputs.observations['default']['segment_insertion_angle']['label'] = [2,1,0]

## Analyze stem size & angle 
_ = pcv.morphology.analyze_stem(rgb_img=img, stem_objects=other_objects)

## Analyze the size of the whole plant for height 
_ = pcv.analyze.size(img=img, labeled_mask=mask, n_labels=1)

## Save out data to file 
pcv.outputs.save_results(filename=args.result)

