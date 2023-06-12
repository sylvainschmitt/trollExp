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
# figureout <- "test.png"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(vroom))

# function

cordex <- data.frame(path = data_path,
                     file = list.files(data_path, 
                                       pattern = "formatted.tsv")) %>% 
  mutate(type = gsub(".formatted.tsv", "", file)) %>% 
  separate(type, c("model", "rcm", "experiment"), "_") %>% 
  rowwise() %>% 
  mutate(climate = list(vroom::vroom(file.path(path, file),
                                     col_types = c("rainfall" = "numeric")))) %>% 
  unnest()

write_tsv(x = cordex, file = fileout)

g <- cordex %>% 
  mutate(exp = paste(model, rcm, experiment)) %>% 
  select(-path, -file, -model, -rcm, -experiment) %>% 
  group_by(exp, year = year(time)) %>% 
  select(-time) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  gather(variable, value, -year, -exp) %>% 
  ggplot(aes(year, value, col = exp)) +
  geom_point(alpha = 0.1) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() + 
  xlab("") + ylab("") +
  theme(legend.text = element_text(size = 5)) +
  scale_color_discrete("")

ggsave(plot = g, filename = figureout, bg = "white", width = 10, height = 5)
