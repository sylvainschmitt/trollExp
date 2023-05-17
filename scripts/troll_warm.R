# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
plot <- as.character(snakemake@params$plot)
depth <- as.character(snakemake@params$depth)
rep <- as.character(snakemake@params$rep)
n_layers <- as.numeric(snakemake@params$n_layers)
layer_thickness <-  as.numeric(snakemake@params$layer_thickness)
verbose <- snakemake@params$verbose
mature_years <- snakemake@params$mature_years
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/soil/soil.tsv"
# folderout <- "results/simulations/Réserve naturelle des nouraguesu_0-5cm/R1"
# plot <- "Saint-Elie"
# depth <- "0-5cm"
# rep <- "R1"
# n_layers <-  5
# layer_thickness <-  c(0.1, 0.23, 0.4, 0.8, 0.97)
# verbose <- TRUE
# mature_years <- 600
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse) 
library(rcontroll)
library(vroom)

# code
path <- gsub(rep, "", folderout)
# dir.create(path, recursive = T)

data("TROLLv4_species")
data("TROLLv4_climate")
data("TROLLv4_dailyvar")
# data("TROLLv4_pedology")

data <- vroom(filein)

if(depth != "all") {
  
  if(!(depth %in% data$depth))
    stop("The depth asked for the experiment is not available, be sure you donwloaded it first.")

  d <- depth
  pedo <- data %>% 
    filter(grepl(plot, address)) %>% 
    filter(depth == d) %>% 
    select(-address, -depth) %>% 
    pivot_wider(names_from = variable, values_from = value) %>% 
    mutate(layer_thickness = list(layer_thickness[1:n_layers])) %>% 
    unnest() %>% 
    rename(proportion_Silt = silt, 
           proportion_Clay = clay, 
           proportion_Sand = sand, 
           SOC = soc, 
           DBD = bdod,
           pH =phh2o,
           CEC = cec) %>% 
    select(layer_thickness, proportion_Silt, 
           proportion_Clay, proportion_Sand, SOC, DBD, pH, CEC) %>% 
    mutate(proportion_Silt = proportion_Silt/10, 
           proportion_Clay = proportion_Clay/10,
           proportion_Sand = proportion_Sand/10,
           SOC = SOC/100, 
           DBD = DBD/100, 
           pH = pH/100, 
           CEC = CEC/100)
  
} else {
  
  subdata <- data %>% 
    filter(grepl(plot, address)) %>% 
    select(-address) %>% 
    separate(depth, c("depth_min", "depth_max"), "-", 
             convert = TRUE, remove = FALSE) %>% 
    mutate(depth_max = as.numeric(gsub("cm", "", depth_max))) %>% 
    mutate(depth_min = ifelse(depth_min != 0, depth_min+1, depth_min)) %>% 
    rowwise() %>% 
    mutate(depth_ref = median(c(depth_min, depth_max))) %>% 
    select(-depth_min, -depth_max, -depth)
  
  pedo <- data.frame(layer_thickness = layer_thickness[1:n_layers]) %>% 
    mutate(depth_max = cumsum(layer_thickness*100)) %>% 
    mutate(depth_min = lag(depth_max)+1) %>% 
    mutate(depth_min = ifelse(is.na(depth_min), 0, depth_min)) %>% 
    group_by(layer_thickness) %>% 
    mutate(depth = median(c(depth_min, depth_max))) %>% 
    select(-depth_min, -depth_max) %>% 
    mutate(subdata = list(subdata)) %>%
    unnest() %>% 
    group_by(layer_thickness) %>%
    mutate(dist = sqrt((depth - depth_ref)^2)) %>% 
    filter(dist == min(dist)) %>% 
    select(-depth, -depth_ref) %>% 
    pivot_wider(names_from = variable, values_from = value) %>% 
    rename(proportion_Silt = silt, 
           proportion_Clay = clay, 
           proportion_Sand = sand, 
           SOC = soc, 
           DBD = bdod,
           pH =phh2o,
           CEC = cec) %>% 
    select(layer_thickness, proportion_Silt, 
           proportion_Clay, proportion_Sand, SOC, DBD, pH, CEC) %>% 
    mutate(proportion_Silt = proportion_Silt/10, 
           proportion_Clay = proportion_Clay/10,
           proportion_Sand = proportion_Sand/10,
           SOC = SOC/100, 
           DBD = DBD/100, 
           pH = pH/100, 
           CEC = CEC/100)
}

n <- as.numeric(mature_years)*365
if(test)
  n <- round(test_years*365)

sim <- troll(
  name = rep,
  path = path,
  global = generate_parameters(nbiter = n),
  species = TROLLv4_species,
  climate = TROLLv4_climate,
  daily = TROLLv4_dailyvar,
  pedology = pedo,
  load = TRUE,
  verbose = verbose,
  overwrite = TRUE
)

g <- rcontroll::autoplot(sim)

ggsave(plot = g, filename = figureout, bg = "white", width = 20, height = 10)
