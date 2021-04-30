# Tecan-Microplate-Plotter

R Shiny app to normalize and plot bulk fluorescence data from Tecan Microplate Readers for exploratory data analysis.

## Installation

Clone the repository and ensure that all of the libraries in the [```server.R```](https://github.com/quoctran98/Tecan-Microplate-Plotter/blob/main/server.R) script are installed. Run the script once to load all of the libraries and required functions and start the app with ```R -e "shiny::runApp('~/PATHNAME')"```where ```PATHNAME ``` is the path to the folder.

## Usage

1. Upload the data output fom the plate reader. Currently the script only works with the Excel Workbook (.xlsx) output from the iContol software.
2. Define each well on 96-well plate. Under "Define Wells," select ```Strains``` to define different strains and ```Treatment``` to define different concentrations of a treatment. This table can be saved and uploaded for use with a different analysis.
3. Select the fluoresence and OD measurements as well as the background and blank strain. The normalization subtracts the blank media fluoresence and OD from each well with the same teatment, then divides fluoresence by OD for all wells, and then divides each well by the background strain with the same treatment for a fold-over-background measurement.
4. Choose the strains to be plotted (delete stains with the backspace button) and click ```Render Plot```
