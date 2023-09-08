# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
raw <- snakemake@input[[1]]
climate <- snakemake@output[[1]]
site <- as.character(snakemake@params$site)

# test
# raw <- "results/data/BR-Sa3_raw.csv"
# site <- "BR-Sa3"

# libraries
library(tidyverse)
library(vroom)

vroom(raw, na = "-9999") %>% 
  select(TIMESTAMP_START, TIMESTAMP_END, P_F, SW_IN_F, TA_F, VPD_F, WS_F) %>% 
  mutate(time = as_datetime(as.character(as.POSIXlt(as.character(TIMESTAMP_START), format = "%Y%m%d%H%M")))) %>% 
  rename(rainfall = P_F, snet = SW_IN_F, temperature = TA_F, vpd = VPD_F, ws = WS_F) %>% 
  mutate(vpd = vpd/10) %>% 
  select(time, rainfall, snet, temperature, vpd, ws) %>% 
  vroom_write(climate)
