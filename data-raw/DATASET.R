library(magrittr)

## code to prepare `DATASET` dataset goes here
file_name <- 'http://extras.springer.com/2014/978-3-319-03742-4/trackingDB_datasets.zip'
download.file(file_name, destfile = 'data-raw/trackingdb_datasets.zip')
unzip(zipfile = 'data-raw/trackingdb_datasets.zip', exdir = 'data-raw')

# animals dataset ----
animals <- readr::read_delim(here::here('data-raw', 'tracking_db', 'data', 'animals', 'animals.csv'),
                             delim = ';',
                             col_names = c('id', 'animal_id', 'name', 'sex', 'age_class', 'species'))
animals$age_class <- rep('adult', n = nrow(animals))
animals$species <- rep('roe deer', n = nrow(animals))

# devices ----
devices <- readr::read_delim(here::here('data-raw', 'tracking_db', 'data', 'sensors', 'gps_sensors.csv'),
                             delim = ';',
                             col_names = c('id', 'sensor_id', 'purchase_date',
                                            'frequency', 'vendor', 'model', 'sim'))
devices
readr::write_csv(devices, 'data-raw/devices.csv')

# deployments ----
deployments <- readr::read_delim(here::here('data-raw', 'tracking_db', 'data', 'sensors_animals', 'gps_sensors_animals.csv'),
                                 delim = ';',
                                 col_names = c('animal_id', 'sensor_id', 'start_time', 'end_time', 'notes'))

# example files animals.csv ----
dat <- dplyr::full_join(animals, deployments, by = c('id' = 'animal_id')) %>%
  dplyr::full_join(devices, by = c('sensor_id' = 'id')) %>%
  dplyr::select(animal_id, name, sex, age_class, species,
                inservice = start_time, outservice = end_time,
                notes = notes, serial_num = sensor_id.y)
dat

dat$inservice <- lubridate::as_date(
  stringr::str_sub(dat$inservice,
                   start = 1,
                   end = stringr::str_length(dat$inservice) - 3)
  )

dat$outservice <- lubridate::as_date(
  stringr::str_sub(dat$outservice,
                   start = 1,
                   end = stringr::str_length(dat$outservice) - 3)
)

readr::write_csv(dat, here::here('data-raw', 'animals.csv'))
readr::write_csv(devices[, 2:6], here::here('data-raw', 'devices.csv'))

# telemetry data ----
telemetry_dir <- here::here('data-raw', 'tracking_db', 'data', 'sensors_data')
!(is.na(stringr::str_extract(dir(telemetry_dir), 'GSM\\d*.csv')))

files <- Filter(x = dir(telemetry_dir),
       f = function (x) {
         !(is.na(stringr::str_extract(x, 'GSM\\d*.csv')))
       })

dat <- Reduce('rbind', lapply(files, function (x) {
  path <- file.path(telemetry_dir, x)
  readr::read_delim(path, delim = ';')
}))

dat_out <- dat[, c(1, 3, 4, 5, 6, 10, 11)]
names(dat_out) <- c('collar_id', 'utc_date', 'utc_time', 'lmt_date', 'lmt_time', 'y', 'x')

dat_out$acq_timestamp_utc <- lubridate::dmy_hms(paste(
  dat_out$utc_date, dat_out$utc_time, sep = ' '
))

dat_out

## figure out what timezone these are in to best set local time
telemetry_trunc$acq_timestamp_local <- lubridate::ymd_hms(paste(
  telemetry_trunc$lmt_date, telemetry_trunc$lmt_time, sep = ' '
), tz = 'LMT')
head(telemetry_trunc$acq_timestamp_local)

# save files to package ----
usethis::use_data("DATASET")
