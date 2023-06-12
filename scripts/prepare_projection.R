# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climate_file <- snakemake@input[["cordex"]]
era_file <- snakemake@input[["era"]]
years_file <- snakemake@input[["years"]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)
exp <- as.character(snakemake@params$exp)

# test
# climate_file <- "results/climate/cordex_adjusted/NCC-NorESM1-M_REMO2015.tsv"
# era_file <- "data/ERA5land_Paracou.tsv"
# years_file <- "results/climate/projection_years.tsv"
# model <- "NCC-NorESM1-M"
# rcm <- "REMO2015"
# exp <- "rcp85"

# libraries
library(tidyverse)
library(vroom)

# functions
adjust_table <- function(
    data, 
    ref, 
    exp = "historical",
    period = 1970:2005
) {
  ref <- filter(ref, experiment == exp)
  data$rainfall <- adjust_rain_year(data, ref, period = period)
  data$snet <- adjust_var(data, ref,
                          var = "snet", period = period)
  data$temperature <- adjust_var(data, ref,
                                 var = "temperature", period = period)
  data$vpd <- adjust_var(data, ref,
                         var = "vpd", period = period)
  data$ws <- adjust_var(data, ref, 
                        var = "ws", period = period)
  data %>% 
    mutate(snet = ifelse(snet < 0, 0, snet)) %>% 
    mutate(rainfall = ifelse(rainfall < 0, 0, rainfall))
}
adjust_var <- function(
    data, 
    ref,
    var,
    period = 1970:2005
) {
  era_data <- ref %>% 
    select(time, var) %>% 
    filter(year(time) %in% period) %>% 
    rename(value = var)
  cordex_data <- data %>% 
    select(time, var) %>% 
    rename(value = var)
  train_data <- era_data %>% 
    select(time) %>% 
    left_join(cordex_data, by = join_by(time))
  adjusted <- CDFt::CDFt(
    ObsRp = era_data$value, # obs for adjustment
    DataGp = train_data$value, # correspondance for adjustement
    DataGf = cordex_data$value, # serie to be adjusted
    npas = 10^3, 
    dev = 2)
  return(adjusted$DS)
}
adjust_rain_year <- function(
    data, 
    ref,
    period = 1970:2005
) {
  cordex_prop <- data %>%
    select(time, rainfall) %>%
    group_by(date = date(time)) %>%
    mutate(rainfall_day = sum(rainfall, na.rm = TRUE)) %>%
    mutate(pct_halfhour = ifelse(rainfall_day == 0, 0, rainfall/rainfall_day)) %>%
    group_by(month = floor_date(time, "month")) %>%
    mutate(rainfall_month = sum(rainfall, na.rm = TRUE)) %>%
    mutate(pct_day = rainfall_day/rainfall_month) %>%
    group_by(year = floor_date(time, "year")) %>% 
    mutate(rainfall_year = sum(rainfall, na.rm = TRUE)) %>%
    mutate(pct_month = rainfall_month/rainfall_year)
  era_data <- ref %>% 
    filter(year(time) %in% period) %>% 
    group_by(year = floor_date(time, "year")) %>% 
    summarise(rainfall_era = sum(rainfall, na.rm = TRUE))
  cordex_data <- data %>% 
    group_by(year = floor_date(time, "year")) %>% 
    summarise(rainfall = sum(rainfall, na.rm = TRUE))
  train_data <- era_data %>% 
    left_join(cordex_data, by = join_by(year))
  if(length(period) > 1) {
    adjusted <- CDFt::CDFt(
      ObsRp = log(era_data$rainfall_era), # obs for adjustment
      DataGp = log(train_data$rainfall), # correspondance for adjustement
      DataGf = log(cordex_data$rainfall), # serie to be adjusted
      npas = 10^2, 
      dev = 2)
    cordex_data$rainfall_year_adj <- exp(adjusted$DS)
  } else {
    cordex_data$rainfall_year_adj <- era_data$rainfall_era
  }
  res <- cordex_prop %>% 
    ungroup() %>% 
    left_join(select(cordex_data, -rainfall), by = join_by(year)) %>% 
    mutate(rainfall_month_adjusted = pct_month*rainfall_year_adj) %>% 
    mutate(rainfall_day_adjusted = pct_day*rainfall_month_adjusted) %>% 
    mutate(rainfall_adjusted = pct_halfhour*rainfall_day_adjusted)
  return(res$rainfall_adjusted)
}
summarise_year <- function(data) 
  data %>% 
  group_by(model, rcm, experiment, date = date(time)) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean) %>% 
  group_by(model, rcm, experiment, year = year(date)) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean) %>% 
  select(-time, -date)

# code
m <- model
r <- rcm
e <- exp

sampled_years <- vroom(years_file)
era <- vroom(era_file) %>% 
  mutate(experiment = "historical", 
         model = "ERA5-Land",
         rcm = "")
cordex_adj <- vroom(climate_file)

era_sampled <- sampled_years %>% 
  left_join(mutate(era, era_year = year(time)),
            multiple = "all",
            by = join_by(era_year)) %>% 
  mutate(months_diff = (sim_year - era_year)*12) %>% 
  mutate(time = time %m+% months(months_diff)) %>% 
  select(-months_diff)

era_adj <- split(era_sampled, era_sampled$sim_year) %>% 
  lapply(function(x) adjust_table(x, 
                                  ref = cordex_adj,
                                  exp = e,
                                  period = unique(x$sim_year))) %>% 
  bind_rows()

write_tsv(era_adj, fileout)

g <- list("cordex adjusted" = filter(cordex_adj, 
                                     experiment == e),
          "era adjusted" = select(era_adj, -sim_year, -era_year),
          era = era) %>% 
  lapply(summarise_year) %>% 
  bind_rows(.id = "dataset") %>% 
  gather(variable, value, -dataset, -model, -rcm, -experiment, -year) %>% 
  ggplot(aes(year, value, col = dataset, group = paste(dataset, experiment))) +
  geom_line() +
  geom_smooth(se = FALSE, method = "lm") +
  facet_wrap(~ variable, scales = "free") +
  theme_bw() +
  theme(legend.position = c(0.8, 0.2), axis.title = element_blank()) +
  ggtitle(paste("ERA5-Land", e), 
          paste("Based on model", m, "with RCM", r))

ggsave(plot = g, filename = figureout, bg = "white")
