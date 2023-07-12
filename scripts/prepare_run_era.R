# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
era_path <- snakemake@input[[1]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
site <- as.character(snakemake@params$site)

# test
# era_path <- "data/ERA5land_Paracou.tsv"

# libraries
library(tidyverse)
library(vroom)

# climate
climate <- vroom(era_path) %>% 
  arrange(time) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29") %>% 
  as.data.frame()

write_tsv(x = climate, file = fileout)

# fig
g <- climate %>%
  group_by(month = floor_date(time, "month")) %>%
  select(-time) %>%
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  gather(variable, value, -month) %>%
  ggplot(aes(month, value)) +
  geom_line(alpha = 0.5) +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() +
  xlab("") + ylab("")

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
