# Source-basin T-N-C MATLAB implementation

This folder contains the MATLAB code used for source-basin daily streamflow forecasting in the Yuan River case study.

## Main files

- `src/VMD_CNNbiLSTM.m`: main CNN-BiLSTM-Attention forecasting workflow using decomposed streamflow components.
- `src/MAIN_VMD.m`: decomposition/preprocessing workflow.
- `src/tvf_emd.m`: time-varying filter based empirical mode decomposition (TVFEMD).
- `src/splinefit.m`, `src/INST_FREQ_local.m`: helper functions used by TVFEMD.
- `src/FlipLayer.m`: custom layer/helper used in the neural-network architecture.
- `src/calc_error.m`: metric calculation helper.
- `example_data/`: source-basin data and MATLAB data files used by the scripts.

## Notes

The files are preserved close to the working manuscript version. If running from a fresh clone, set MATLAB's current folder to this directory or add `src/` to the MATLAB path.
