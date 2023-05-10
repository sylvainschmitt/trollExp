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
library(lubridate)
library(vroom)
library(REddyProc)

# function
rh2vpd <- function(hr, temp) {
  svp <- 0.61121 * exp((18.678 - temp/234.5) * (temp/(257.14+temp)))
  ((100 - hr)/100)*svp
}

clim_gapfill <- function(year, data) {
  cat(year)
  cat("\n")
  y <- year
  data_gaps <- sEddyProc$new(
    "guyaflux", filter(data, year(time) == y),
    c("rainfall", "snet", "ws", "vpd", "temperature"), "time"
  )
  data_gaps$sSetLocationInfo(LatDeg = 5.27, LongDeg = -52.92, TimeZoneHour = -3)
  data_gaps$sMDSGapFill("temperature")
  data_gaps$sMDSGapFill("vpd")
  data_gaps$sMDSGapFill("ws")
  data_gaps$sMDSGapFill("snet")
  data_preds <- filter(data, year(time) == y)
  data_preds$temperature <- data_gaps$sExportResults()$temperature_fall
  data_preds$vpd <- data_gaps$sExportResults()$vpd_fall
  data_preds$ws <- data_gaps$sExportResults()$ws_fall
  data_preds$snet <- data_gaps$sExportResults()$snet_fall
  return(data_preds)
}


# code
guyaflux <- vroom(file.path(data_path, "guyaflux",
                "GX-METEO^MEDDY-2004-2022.csv"),
      locale = locale(decimal_mark = ",")
) %>%
  group_by(Year) %>%
  mutate(date = as_date(paste0(
    min(Year), "/", min(Month),
    "/", min(`Julian Day`)
  )) +
    (`Julian Day` - 1)) %>%
  separate(`Hour/min`, c("hour", "minute")) %>%
  ungroup() %>%
  mutate(minute = ifelse(is.na(minute), 0, 60 * as.numeric(minute) / 10)) %>%
  mutate(time = as_datetime(paste(
    as.character(date),
    paste0(hour, ":", minute, ":00")
  ))) %>%
  mutate(
    rainfall = Rain,
    snet = `Rg-I-CNR4` - `Rg-R-CNR4`,
    ws = `Wind-S`,
    vpd = rh2vpd(`Hr(55)`, `Temp(55)`),
    temperature = `Temp(55)`
  ) %>%
  select(time, rainfall, snet, ws, vpd, temperature) %>%
  filter(year(time) != 2022)

years <- c(
  2004, 2005, 2008, 2009, 2010,
  2011, 2012, 2013, 2014, 2016, 2020
)

guyaflux_filled <- lapply(years, clim_gapfill, guyaflux) %>%
  bind_rows() %>% 
  mutate(snet = ifelse(snet <= 0, 1, snet)) %>% 
  mutate(vpd = ifelse(vpd <= 0, 0.001, vpd)) %>% 
  mutate(ws = ifelse(ws <= 0, 0.1, ws))

write_tsv(x = guyaflux_filled, file = fileout)

g <- guyaflux_filled %>% 
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
