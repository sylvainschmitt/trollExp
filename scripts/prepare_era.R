# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
data_path <- snakemake@params$data_path
cores <- as.numeric(snakemake@threads)

# test
data_path <- "data"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(rcontroll))

# function
path <- file.path(data_path, "era", "paracou_nc")
files <- list.files(path, full.names = TRUE)
era <- prepare_era_batch(files, cores = cores) %>% 
  mutate(snet = ifelse(snet <= 0, 1, snet)) %>% 
  mutate(vpd = ifelse(vpd <= 0, 0.001, vpd)) %>% 
  mutate(ws = ifelse(ws <= 0, 0.1, ws))
write_tsv(x = era, file = fileout)

g <- era %>% 
  group_by(month = floor_date(time, "month")) %>% 
  select(-time) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  gather(variable, value, -month) %>% 
  ggplot(aes(month, value)) +
  geom_point() +
  geom_smooth(col = "red") +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() + 
  xlab("") + ylab("")

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
