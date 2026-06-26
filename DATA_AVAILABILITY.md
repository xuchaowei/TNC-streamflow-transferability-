# Data availability and placement

This repository includes source code, compact example files, and key small benchmark outputs. Complete large-sample datasets should be obtained from their original providers.

## Public datasets used in the transferability experiments

- CAMELS-USA: https://ral.ucar.edu/solutions/products/camels
- CAMELS-GB: https://catalogue.ceh.ac.uk/documents/8344e4f3-d2ea-44f5-8afa-86d2987543a9
- LamaH-CE: https://zenodo.org/records/5153305
- CAMELS-CL: https://camels.cr2.cl/
- CCAM / Yellow River attributes and meteorology: https://zenodo.org/records/5729444
- ArcticNet: https://www.r-arcticnet.sr.unh.edu/v4.0/AllData/index.html
- CAMELS-AUS / Australian large-sample hydrology data: see the dataset cited in the manuscript and the associated ESSD record.

## Recommended local placement after cloning

```text
global_transfer_nrbo/
  regions/
    great_britain/
      basin_timeseries/      # put full GB basin CSV files here
    usa/
      basin_timeseries/      # put full USA basin CSV files here
```

The included `example_data/` folders contain only a few representative CSV files so that reviewers can inspect the expected input format without downloading all large-sample data.

## Process-model data

The SWAT project originally included large GIS rasters, SWAT databases, and very large output files. These were excluded from GitHub. The retained files include calibration parameter files, compact summary outputs, and scripts needed to document the benchmark setup.
