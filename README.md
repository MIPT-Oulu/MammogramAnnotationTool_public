# Mammogram Annotation Tool

This repository contains a MATLAB implementation of a tool for annotating mammographic images.

## Dependencies

* MATLAB R2023a
* Image Processing Toolbox

Add the annotation tool folder to search path (when located in the tool root folder)

```Matlab
addpath '2dannotationtool'
```

From MATLAB Command Window run

```Matlab
[checks_flag, required_products] = check_dependencies()
```

## Data requirements and expected outputs

Each examination is required to have 4 standard mammographic views. These examinations should be listed in a dedicated `study_info.csv` file, an example file is provided. The `study_info.csv` file should be located within the root of your `CUSTOMDATASET` folder. Mammograms should be located in `images` within the same root folder, e.g.,

```
CUSTOMDATASET
 ├─ images
 │  ├─ 1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48
 │  │     └─ 1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48.20586908.dcm
 │  │     └─ 1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48.20586986.dcm
 │  │     └─ 1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48.20586960.dcm
 │  │     └─ 1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48.20586934.dcm
 │  └─ ...
 └─ study_info.csv
```
where `1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48` is (in this example) a unique identifier-type folder name referring to a certain study.

The software will make additional study-wise subfolders for saving annotation masks and other results in `MAT` and `CSV` format. `MAT`-file contents will be as follows: 
```Matlab
       annotations: [1×4 struct]
    breast_density: '1'
    classification: [1×1 struct]
              inds: [1×1 struct]
      remarks_text: 'n/a'
      status_ready: 1
             study: '1.3.6.1.4.1.9590.100.1.1.134970997511.22275.48'
```
where, e.g., the visual and characterizing information of the annotations _for each of the standard views_ are stored as a cell array
```Matlab
    {'annotation_malignant_mass'                           }
    {'annotation_benign_mass'                              }
    {'annotation_malignant_calc'                           }
    {'annotation_benign_calc'                              }
    {'annotation_malignant_architechtural_distortion'      }
    {'annotation_benign_architechtural_distortion'         }
    {'annotation_malignant_mass_count'                     }
    {'annotation_benign_mass_count'                        }
    {'annotation_malignant_calc_count'                     }
    {'annotation_benign_calc_count'                        }
    {'annotation_malignant_architechtural_distortion_count'}
    {'annotation_benign_architechtural_distortion_count'   }
    {'annotation_malignant_mass_char'                      }
    {'annotation_malignant_mass_x_center'                  }
    {'annotation_malignant_mass_y_center'                  }
    ...
``` 

## Getting started

From MATLAB Command Window run 

```Matlab
Main_GUI
```

User instructions are available in `HTML` format and can be viewed by running
```Matlab
web help/user_guide.html
```

## License

This software is published under the [MIT licence](https://github.com/MIPT-Oulu/MammogramAnnotationTool_public/blob/main/LICENSE).

Licenses for third party components are listed in the [NOTICE](https://github.com/MIPT-Oulu/MammogramAnnotationTool_public/blob/main/NOTICE.txt) file.

The software has not been certified as a medical device and, therefore, must not be used for diagnostic purposes.

## Acknowledgements

### Jane and Aatos Erkko Foundation and the Technology Industries of Finland Centennial Foundation

Financial support from Jane and Aatos Erkko Foundation and the Technology Industries of Finland Centennial Foundation is gratefully acknowledged.

### The research group

Pieta Ipatti, MD, Lucia Prostedná, MD, and Professor Jarmo Reponen, MD, PhD, are acknowledged for their insightful remarks regarding the tool.

## Authors

[Antti Isosalo](https://github.com/aisosalo), [Helinä Heino](https://github.com/hheino), [Satu I. Inkinen](https://github.com/siinkine), Topi Turunen & Miika T. Nieminen (PI), Research Unit of Health Sciences and Technology, University of Oulu, Oulu, Finland.

## How to cite

If you found our work useful, consider citing the repository or one of the following publications:

> Antti Isosalo, Henrik Mustonen, Topi Turunen, Pieta S. Ipatti, Jarmo Reponen, Miika T. Nieminen & Satu I. Inkinen, "Evaluation of different convolutional neural network encoder-decoder architectures for breast mass segmentation," Proc. SPIE 12037, Medical Imaging 2022: Imaging Informatics for Healthcare, Research, and Applications, 120370W (4 April 2022); https://doi.org/10.1117/12.2628190

> Antti Isosalo, Satu I. Inkinen, Topi Turunen, Pieta S. Ipatti, Jarmo Reponen, & Miika T. Nieminen, "Independent evaluation of a multi-view multi-task convolutional neural network breast cancer classification model using Finnish mammography screening data," Computers in Biology and Medicine, 107023 (2023); https://doi.org/10.1016/j.compbiomed.2023.107023

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
* Ctrl+s - save progress (optional)

Mouse functionalities
* left mouse button - panning when zoomed in by dragging the mouse
* mouse roll - zoom in / zoom out
* mouse roll click - zoom out (same as key press z)
* right mouse button - window/level by dragging the mouse

## Known issues

There are reported issues with MATLAB and the native file chooser in MacOS Catalina (10.15.1).
