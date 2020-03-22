# Author: Murat Kirtay, The BioRobotics Inst./SSSA/
# Date: 02/11/2016
# Description: Detect and remove specularity from endoscopic images

import cv2
import numpy as np

def derive_graym(impath):
    ''' The intensity value m is calculated as (r+g+b)/3, yet 
        grayscalse will do same operation!
        opencv uses default formula Y = 0.299 R + 0.587 G + 0.114 B
    '''
    # return cv2.imread(impath, cv2.CV_LOAD_IMAGE_GRAYSCALE)
    return cv2.imread(impath, cv2.IMREAD_GRAYSCALE)

def derive_m(img, rimg):
    return np.sum(img, axis=2, dtype=np.uint8) // 3

def derive_saturation(img, rimg):
    ''' Derive staturation value for a pixel based on paper formula '''
    simg_truth_map = np.greater_equal(np.apply_along_axis(lambda a: a[0] + a[2] - (2*a[1]), 2, img), 0)

    simg_true_array = 1.5 * (img[:,:,2] - rimg)
    simg_false_array = 1.5 * (rimg - img[:,:,0])

    simg = np.array(rimg)
    simg = np.where(simg_truth_map, simg_true_array, simg_false_array)

    return simg

def check_pixel_specularity(mimg, simg):
    ''' Check whether a pixel is part of specular region or not'''

    m_max = np.max(mimg) * 0.5
    s_max = np.max(simg) * 0.33

    mimg_truth_map = np.greater_equal(mimg, m_max)
    simg_truth_map = np.less_equal(simg, s_max)
    truth_map = np.logical_and(mimg_truth_map, simg_truth_map)

    spec_mask = np.where(truth_map, 255, 0).astype(np.uint8)

    return spec_mask

def enlarge_specularity(spec_mask):
    ''' Use sliding window technique to enlarge specularity
        simply move window over the image if specular pixel detected
        mark center pixel is specular
        win_size = 3x3, step_size = 1
    '''

    win_size, step_size = (3,3), 1
    enlarged_spec = np.array(spec_mask)
    for r in range(0, spec_mask.shape[0], step_size):
        for c in range(0, spec_mask.shape[1], step_size):
            # yield the current window
            win = spec_mask[r:r + win_size[1], c:c + win_size[0]]
            
            if win.shape[0] == win_size[0] and win.shape[1] == win_size[1]:
                if win[1,1] !=0:
                    enlarged_spec[r:r + win_size[1], c:c + win_size[0]] = 255 * np.ones((3,3), dtype=np.uint8)

    return enlarged_spec 



