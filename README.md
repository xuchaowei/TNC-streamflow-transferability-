# Hydrological Controls on Deep Learning Streamflow Transferability across Contrasting Basins

This repository contains the code-release package for the manuscript **"Hydrological Controls on Deep Learning Streamflow Transferability across Contrasting Basins"**.

The code supports three parts of the study:

1. Source-basin T-N-C daily streamflow forecasting in the Yuan River basin.
2. Global transferability experiments using NRBO-optimized deep learning workflows.
3. Process-driven benchmark comparison with conceptual XinAnJiang, semi-distributed XinAnJiang, and SWAT/SWAT-CUP settings.

## Repository structure

```text
source_basin_tnc_matlab/      MATLAB source-basin T-N-C and TVFEMD scripts
global_transfer_nrbo/         MATLAB/R scripts for global transferability and plotting
process_benchmarks/           XinAnJiang and SWAT/SWAT-CUP benchmark files
requirements/                 MATLAB toolbox and R package requirements
DATA_AVAILABILITY.md          Dataset sources and data-placement notes
GITHUB_UPLOAD_STEPS.md        Step-by-step GitHub upload instructions
MANIFEST.md                   English summary of included and excluded materials
```

## Quick start

### MATLAB source-basin workflow

```matlab
cd source_basin_tnc_matlab
addpath(genpath('src'))
run('src/MAIN_VMD.m')
run('src/VMD_CNNbiLSTM.m')
```

### Global transfer workflow

The global transfer MATLAB scripts are stored under `global_transfer_nrbo/regions/`. Place the corresponding public basin CSV files in the working folder, or adapt the file path in `main.m`.

```matlab
cd global_transfer_nrbo/regions
run('main.m')
```

### Plotting workflow

```r
setwd("global_transfer_nrbo/plotting/nse_raincloud")
source("raincloud.R")
```

## Large files and public data

The original working folders contain large SWAT outputs, GIS rasters, model databases, and thousands of public basin time-series files. These files are not source code and are not suitable for direct GitHub storage. They were intentionally excluded from this code package. Use `DATA_AVAILABILITY.md` to retrieve the public datasets and reconstruct large model outputs if needed.

## License

No open-source license has been selected automatically. Before making the repository public, choose a license that is compatible with all third-party components and data-provider terms.
