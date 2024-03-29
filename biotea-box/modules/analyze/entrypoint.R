# This file, when sourced, must do the following:
# - Load necessary packages for the module
# - Handle the incoming command line argument(s)
# - Run the actual command.
#
# The environment is shaped as such:
# bioTEA/
#   src/
#       shared/
#           ...
#       modules/
#           ...
#   input/  < Mounted to the input folder
#   target/ < Mounted to the output folder
#   logs/   < Mounted to the logs folder
#
# This script has access to the following:
# > The tidyverse;
# > The `tools` library in src/shared/tools.R;
#
# The logging module is already sourced, so the log object is present in the
# environment.
#
# The command line options passed by the user (the wrapper), are in the
# `module.args` global option.

# Load the arguments -----------------------------------------------------------
args <- getOption("module.args")

# Test that the arguments are valid --------------------------------------------
# I expect these arguments, in order:
# options.path, input.file
# Pass "NULL" or NULL to use the defaults. Setting NULL in the defaults
# signifies a required argument.

defaults = list(
    input.file = NULL,
    experimental_design = NULL,
    contrasts = NULL,
    min_log2_expression = 4,
    fc_threshold = 0.5,
    min_groupwise_presence = 0.8,
    show_data_snippets = TRUE,
    annotation_database = TRUE,
    dryrun = FALSE,
    renormalize = FALSE,
    convert_counts = FALSE,
    run_limma_analysis = TRUE,
    run_rankprod_analysis = TRUE,
    batches = NA,
    extra_limma_vars = NA,
    group_colors = c("cornflowerblue", "firebrick3", "olivedrab3", "darkgoldenrod1", "purple", "magenta3"),
    # Plot options
    use_pdf = TRUE,
    plot_width = 16,
    plot_height = 9,
    png_ppi = 250,
    enumerate_plots = TRUE
)

fun_args <- validate_arguments(args, defaults)

# Add the hardcoded arguments
fun_args$input.file <- paste0("/bioTEA/input/", fun_args$input.file)
fun_args$output.dir <- paste0("/bioTEA/target/")

# Load required libraries.
module.packages <- c(
    "limma", "RankProd", "reshape2", "EnhancedVolcano", "gplots", "UpSetR",
    "yaml", "statmod", "PCAtools", "VennDiagram"
)
graceful_load(module.packages)

# Load the functions for this module
source("/bioTEA/modules/analyze/analysis_core.R")

# Run the module
# Set options for printPlots
options(
    scriptName = "analyze",
    save.PNG.plot = !fun_args$use_pdf,
    save.PDF.plot = fun_args$use_pdf,
    plot.width = fun_args$plot_width,
    plot.height = fun_args$plot_height,
    png_ppi = fun_args$png_resolution,
    enumerate.plots = fun_args$enumerate_plots
)
# Remove plot-related options
fun_args[c("use_pdf", "plot_width", "plot_height", "png_ppi", "enumerate_plots")] <- NULL
do.call("bioTEA", args = fun_args)
