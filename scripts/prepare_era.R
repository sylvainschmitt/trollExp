# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
data_path <- snakemake@params$data_path

# test
# data_path <- "data"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(rcontroll))

# function
# era <- prepare_era_batch(list.files("paracou_nc", full.names = TRUE))
# readr::write_tsv(era, "ERA5land_Paracou.tsv")

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
