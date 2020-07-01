# leak_detection_2019
Repo for Tso et al (2020) paper / thesis chapter 5

How to cite: 
Tso et al. (2020) Integrated hydrogeophysical modelling and data assimilation for geoelectrical leak detection. *Journal of Contaminant Hydrology*

Tso C-HM (2019) Enhancing the information content of geophysical data for nuclear site characterisation. PhD thesis. Lancaster University.



Example script files.

### The workflow:


### Pre-requisites:
- Python
- R
- PFLOTRAN (https://bitbucket.org/pflotran/pflotran/wiki/Home)
- E4D (https://e4d.pnnl.gov/Pages/Home.aspx, code: https://bitbucket.org/john775/e4d_dev/src/default/)

One may find Xuehang's PFLOTRAN tools useful: https://github.com/xuehangsong/pflotran_tools

### A note on PFLOTRAN-E4D
we used the 2017 version of PFLOTRAN, which has the now-deprecated "hydrogeophysics" mode or PFLOTRAN-E4D. You will need to run PFLOTRAN first, use a mapping routine to map its output to E4D, then run E4D to achieve the same results.
