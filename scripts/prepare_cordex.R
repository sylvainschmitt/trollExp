# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)
data_path <- snakemake@params$data_path

# test
model <- "MPI-M-MPI-ESM-MR"
rcm <- "ICTP-RegCM4-7"
data_path <- "data"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(vroom))

# function
climate = paste0(model, "-", rcm)
path <- file.path(data_path, "cordex", "table")
files <- data.frame(file = list.files(path, pattern = ".formatted.tsv")) %>% 
  mutate(climate = gsub(".formatted.tsv", "", file)) %>% 
  separate(climate, c("model", "rcm", "exp"), "_") %>% 
  filter(model == model) %>% 
  filter(rcm == rcm)

to_read <- files$file
names(to_read) <- files$exp

cordex <- lapply(to_read, function(x) file.path(path, x)) %>% 
  lapply(vroom) %>% 
  bind_rows(.id = "exp") %>% 
  mutate(snet = ifelse(snet <= 0, 1, snet)) %>% 
  mutate(vpd = ifelse(vpd <= 0, 0.001, vpd)) %>% 
  mutate(ws = ifelse(ws <= 0, 0.1, ws))

write_tsv(x = cordex, file = fileout)

g <- cordex %>% 
  group_by(exp, month = floor_date(time, "month")) %>% 
  select(-time) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  gather(variable, value, -month, -exp) %>% 
  ggplot(aes(month, value, col = exp)) +
  geom_point(alpha = 0.1) +
  geom_smooth() +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() + 
  xlab("") + ylab("") +
  theme(legend.position = c(0.8, 0.2))

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
