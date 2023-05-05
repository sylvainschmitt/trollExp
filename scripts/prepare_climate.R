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
# filein <- "results/simulations/projections/full/selected_years.tsv"
# fileout <- "guyaflux_sampled.tsv"
# figureout <- "guyaflux_sampled.png"
# type <- "current"
# period <- "10-years"
# climate <- "MPI-M-MPI-ESM-MR_ICTP-RegCM4-7"
# data_path <- "/home/sschmitt/Documents/data/"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(datatrollr)) 

# folder
path <- gsub(paste0(climate, "_sampled.tsv"), "", fileout)
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

if(absent) {
  test_cordex <- str_split_1(climate, "_")
  if(length(test_cordex) != 2)
    stop(paste0("The climate  ", climate, " is not available."))
  model <- test_cordex[1]
  rcm <- test_cordex[2]
  availables <- list.files(file.path(data_path, "cordex", "table"),
                           pattern = "_historical.formatted.tsv")
  availables <- gsub("_historical.formatted.tsv", "", availables) %>% 
    data.frame(file = .) %>% 
    separate(file, c("model", "rcm"), "_")
  if(!(model %in% availables$model))
    stop(paste0("The model  ", model, " is not available for CORDEX data."))
  if(!(rcm %in% availables$rcm))
    stop(paste0("The RCM model  ", rcm, 
                " is not available for CORDEX data and model ", model, " ."))
  absent <- FALSE
  data <- get_cordex(model = model, rcm = rcm,
                     scenario = "historical", path = data_path)
  data2 <- get_cordex(model = model, rcm = rcm,
                      scenario = "rcp26", path = data_path)
  data <- bind_rows(data, data2)
}
  
if(absent)
    stop(paste0("The climate ", climate, " is not available."))

climate <- read_tsv(filein) %>%
  rename(original_year = year) %>% 
  mutate(year = 1:n()) %>% 
  left_join(
    mutate(data, original_year = year(time)),
    by = "original_year", multiple = "all",
    relationship = "many-to-many")

climate <- climate %>% 
  mutate(
    year = year + 1000, # stupid trick to be read back correctly
    month = month(time),
    day = day(time),
    hour = hour(time),
    minute = minute(time)
    ) %>% 
  mutate(time = as_datetime(paste0(
    sprintf("%04d", year), 
    "-", 
    sprintf("%02d", month),
    "-", 
    sprintf("%02d", day),
    " ",
    sprintf("%02d", hour),
    ":", 
    sprintf("%02d", minute),
    ":00" 
  ))) %>% select(-original_year, -year, -month, -day,
                 -hour, -minute)

write_tsv(x = climate, file = fileout)

g <- climate %>% 
  group_by(year = year(time)) %>% 
  select(-time) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  gather(variable, value, -year) %>% 
  ggplot(aes(year, value)) +
  geom_line(alpha = 0.5) +
  geom_smooth(col = "red") +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() + 
  xlab("") + ylab("")

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
