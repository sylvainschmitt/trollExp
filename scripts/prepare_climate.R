# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
climate <- as.character(snakemake@params$climate)
data_path <- snakemake@params$data_path

# test
fileout <- "guyaflux_sampled.tsv"
figureout <- "guyaflux_sampled.png"
type <- "current"
period <- "10-years"
period <- "guyaflux"
data_path <- "/home/sschmitt/Documents/data/"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(datatrollr)) 

# folder
path <- gsub("selected_years.tsv", "", fileout)
if(!dir.exists(path))
  dir.create(path, recursive = TRUE)

# climate
absent <- TRUE

if(climate == "guyaflux") {
  absent <- FALSE
  data <- get_guyaflux(path = data_path)
}

if(climate == "era") {
  absent <- FALSE
  data <- get_era(path = data_path)
}

if(absent)
  cat("try splitting in two the codex name with _ and if it exists with get_cordex()")
  
if(absent)
    stop(paste0("The climate  ", climate, " is not available."))

# left_join on years

# write_tsv(years, fileout)
# g <- ggplot(years, aes(year)) +
#   geom_histogram() +
#   theme_bw()
# ggsave(plot = g, filename = figureout, bg = "white")
