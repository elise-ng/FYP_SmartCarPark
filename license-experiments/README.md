## License Plate Recognition Experimentation

### Setup

Setup a python virtual environment by running the following command

`conda env create -f environment.yml`

Character clustering approach requires the EAST text detection model. Download it [officially here](https://www.dropbox.com/s/r2ingd0l3zt8hxs/frozen_east_text_detection.tar.gz?dl=1) and put the `frozen_east_text_detection.pb` in this folder. Refer to [OpenCV_Extra Repo](https://github.com/opencv/opencv_extra) for more information

### Color filtering approach

Try this approach by running `plate_recognition_color_filter.ipynb` notebook.

The approach filters only yellow and white color from the target image, performs OCR on filtered image and attempts to get the license number of the vehicle.

### Character clustering approach

Try this approach by running `plate_recognition_character_clustering.ipynb` notebook.

The approach identitfies any characters from the target image, perform character clustering and attempts to get the license number of the vehicle.