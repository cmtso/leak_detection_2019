# leak_detection_2019
Repo for Tso et al (2020) paper / thesis chapter 5

How to cite: 

https://doi.org/10.1016/j.jconhyd.2020.103679

Tso et al. (2020) Integrated hydrogeophysical modelling and data assimilation for geoelectrical leak detection. *Journal of Contaminant Hydrology*

Tso C-HM (2019) Enhancing the information content of geophysical data for nuclear site characterisation. PhD thesis. Lancaster University.



### Example folders

| Folder   | Figure in paper|  Location |
|----------|:--------------:|--------------------------:|---------------------------------------------------------------------------------:|
| SLqloc2  |    Fig XX      |        Synthetic          | Problem Estimating (x,y) of leak location, solute loading                        |
| col 2 is |    Fig XX      |   Hatfield, Yorkshire, UK | Estimating (x,y) of leak location, solute loading, Archie parameters, K etc.     |

XX is an example for running Morris sensitivity analysis as in Fig. XX (scroll down for details).

### Pre-requisites:
- Python (only for visualization, using PFLOTRAN's python tools)
- R
- PFLOTRAN (https://bitbucket.org/pflotran/pflotran/wiki/Home)
- E4D (https://e4d.pnnl.gov/Pages/Home.aspx, code: https://bitbucket.org/john775/e4d_dev/src/default/)

One may find Xuehang's PFLOTRAN tools useful: https://github.com/xuehangsong/pflotran_tools

The analysis was performed on an HPC with SLURM scheduler but it should work, in general, on a Linux machine with the above installed.

### A note on PFLOTRAN-E4D
we used the 2017 version of PFLOTRAN, which has the now-deprecated "hydrogeophysics" mode or PFLOTRAN-E4D. You will need to run PFLOTRAN first, use a mapping routine to map its output to E4D, then run E4D to achieve the same results.

#### PFLOTRAN-E4D special input files:
- 

#### PFLOTRAN-E4D special output files:
- 

### The workflow:

#### Key files:
- `R` contains R and python scriptsf
- `data` contains observed ERT data in PF-E4D format. For synthetic problems, you can run your 'true' case here
- `template` contains base template input files for PF-E4D, which will be copied and modified by `R/prepare_input_files_*.R`
- `results` contains simulation results in R compressed object and csv formats. Prior and posterior mass discharge curves are in `shell/int0` and `shell/int` respectively, following PFLOTRAIN time series data format.


#### Key files:
- `run.entire.job.sh` is the main job script.
- `dainput/parameter.sh` specifies the run time parameter and PFLOTRAN input file prefix
- `shell/mc_fuji.sh`runs PFLOTRAN-E4D in batch
- `R/ert_true.R`reads the observed ERT files. Make sure it points to the right path in the `data` folder and contains a file containting the ERT timesteps to use.
- `R/prepare_input_files_*.R`. Change accordingly to estimate different parameters and specify priors.
- `R/assemble.simulation.R` extracts simulation results.DO NOT CHANGE.
- `R/mda.update.R` update the parameters using the ES-MDA algorithm. DO NOT CHANGE.


#### Setting it up:
1. Set up a baseline problem and make sure it runs fine. It may help to run PFLOTRAN and E4D seperately
2. Copy the input files to `template`. For synthetic problem, copy the data files to somewhere in `data`. For field problems, put your data in PF-E4D format somewhere in `data.
3. Modify `R/prepare_input_files_*.R` to set up your parameter estimation problem.
4. Change run parameters if needed.
5. Run!


#### Troubleshoot:
- Make sure you include a INTEGRAL_FLUX card in your PFLOTRAN `(prefix).in` file in order to output the mass discharge
- If the data assimilation is struggling, consider increase ALPHA OR the ensemble size
