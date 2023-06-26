# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
flux_path <- snakemake@input[["flux"]]
met_path <- snakemake@input[["met"]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
site <- as.character(snakemake@params$site)
spinup <- snakemake@params$spinup
seed <- snakemake@params$seed

# test
# met_path <- "results/data/BR-Sa3_2001-2003_FLUXNET2015_Met.nc"
# flux_path <- "results/data/BR-Sa3_2001-2003_FLUXNET2015_Flux.nc"
# site <- "BR-Sa3_2001-2003"
# spinup <- 600
# seed <- 42

# libraries
library(tidyverse)
library(vroom)
library(ncdf4)
set.seed(seed)

# funs
extract_nc <- function(path) {
  r <- nc_open(path)
  vars <- names(r$var)
  names(vars) <- vars
  df <- lapply(vars, function(x) ncvar_get(r, x)) %>% 
    bind_rows() %>% 
    mutate(time  = as_datetime(ncatt_get(r, "time")$units) +
             ncvar_get(r, "time"))
  nc_close(r)
  return(df)
}

# climate
climate <- extract_nc(met_path) %>% 
  left_join(extract_nc(flux_path)) %>% 
  mutate(rainfall = Precip*1000,
         snet = ifelse(is.na(Rnet), SWdown - SWup, Rnet),
         temperature = Tair  - 273.15,
         vpd = VPD/10,
         ws = Wind) %>% 
  mutate(snet = ifelse(snet < 0, 0, snet)) %>% 
  select(time, rainfall, snet, temperature, vpd, ws) %>% 
  mutate_at(c("rainfall", "snet", "temperature", "vpd", "ws"), as.numeric)

# years
years <- unique(year(climate$time))
ymax <- max(years)

if(spinup > length(years))
  sampled_years <- sample(years, spinup, replace = TRUE)
if(spinup <= length(years))
  sampled_years <- sample(years, spinup, replace = FALSE)
sampled_years <- data.frame(orig_year = sampled_years) %>% 
  mutate(sim_year = (ymax-spinup+1):ymax)

# spinup
spinup <- sampled_years %>% 
  left_join(mutate(climate, orig_year = year(time)),
            multiple = "all",
            by = join_by(orig_year)) %>% 
  mutate(months_diff = (sim_year - orig_year)*12) %>% 
  mutate(time = time %m+% months(months_diff)) %>% 
  select(-months_diff) %>% 
  arrange(time) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29")

write_tsv(x = spinup, file = fileout)

# fig
g <- spinup %>%
  select(-orig_year, -sim_year) %>% 
  group_by(year = year(time)) %>%
  select(-time) %>%
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  gather(variable, value, -year) %>%
  ggplot(aes(year, value)) +
  geom_point(alpha = 0.5) +
  geom_smooth(se = FALSE, method = "lm") +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() +
  xlab("") + ylab("")

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
