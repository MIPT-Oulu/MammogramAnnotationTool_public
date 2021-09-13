# Mammogram Annotation Tool

This repository contains a MATLAB implementation of a tool for annotating mammographic images.

## Dependencies

* MATLAB R2019b
* Image Processing Toolbox

From MATLAB Command Window run

```
[checks_flag, required_products] = check_dependencies()
```

## Data requirements

Each examination is required to have 4 standard mammographic views. These examinations should be listed in a dedicated `study_info.csv` file. The `study_info.csv` file within the root of your `CUSTOMDATASET` folder, an example file is also provided. Mammograms should be located in `images` within the same root folder. The software will make folders for saving annotation masks and other results in `mat` and `csv` format.

## Getting started

From MATLAB Command Window run

```
Main_GUI
```

## License

This software is published under the [MIT licence](https://github.com/MIPT-Oulu/MammogramAnnotationTool_public/blob/main/LICENSE).

Licenses for third party components are listed in the [NOTICE](https://github.com/MIPT-Oulu/MammogramAnnotationTool_public/blob/main/NOTICE.txt) file.

The software has not been certified as a medical device and, therefore, must not be used for diagnostic purposes.

## Acknowledgements

### Jane and Aatos Erkko Foundation and the Technology Industries of Finland Centennial Foundation

Financial support from Jane and Aatos Erkko Foundation and the Technology Industries of Finland Centennial Foundation is gratefully acknowledged.

### The research group

Pieta Ipatti, MD, Topi Turunen, MD, Lucia Prostedná, MD, and Professor Jarmo Reponen, MD, PhD, are acknowledged for their insightful remarks regarding the tool.

## Authors

[Antti Isosalo](https://github.com/aisosalo), [Satu Inkinen](https://github.com/siinkine) & Miika T. Nieminen, Research Unit of Medical Imaging, Physics and Technology, University of Oulu, Oulu, Finland.

## Keyboard and mouse shortcuts

With the desired view (GUI window) active, freehand ROI can be drawn by holding left mouse button down, cancel before releasing left mouse button by pressing ESC
* F1 - annotate malignant mass
* F2 - annotate benign mass
* F3 - annotate malignant calcification
* F4 - annotate benign calcification
* F5 - annotate malignant architectural distortion
* F6 - annotate benign architectural distortion

With the desired view (GUI window) active, annotation can be removed by clicking the ROI in question, cancel without removing any annotations with right mouse click
* r - remove annotation (mouse click inside the perimeter)

With any of the GUI windows active
* i - invert image
* z - zoom out, clears adjustments made using window/level tool
* v - switch view
* left arrow - previous study (if exists)
* right arrow - next study (if exists)

With main GUI window active
* Ctrl+s - save progress

Mouse functionalities
* left mouse button - panning when zoomed in by dragging the mouse
* mouse roll - zoom in / zoom out
* mouse roll click - zoom out (same as key press z)
* right mouse button - window/level by dragging the mouse

