# Raincloud Plotting Script

This folder contains an R script for drawing combined violin, boxplot, and dotplot diagnostics for regional model-performance distributions.

The script uses `gghalves::geom_half_violin()` for half-violin plots, `geom_boxplot()` for compact quantile summaries, and `geom_dotplot()` for sample-level dispersion. Adjust the dotplot bin width according to the number and distribution of regional samples.
