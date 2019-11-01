library(magrittr)

## code to prepare `DATASET` dataset goes here
file_name <- 'http://extras.springer.com/2014/978-3-319-03742-4/trackingDB_datasets.zip'
download.file(file_name, destfile = 'data-raw/trackingdb_datasets.zip')
unzip(zipfile = 'data-raw/trackingdb_datasets.zip', exdir = 'data-raw')

# animals dataset ----
animals <- readr::read_delim('data-raw/tracking_db/data/animals/animals.csv',
                             delim = ';',
                             col_names = c('id', 'animal_id', 'name', 'sex', 'age_class', 'species'))
animals$age_class <- rep('adult', n = nrow(animals))
animals$species <- rep('roe deer', n = nrow(animals))

readr::write_csv(animals, 'data-raw/animals.csv')

# sensors ----
sensors <- readr::read_delim('data-raw/tracking_db/data/sensors/gps_sensors.csv',
                             delim = ';',
                             col_names = c('id', 'sensor_id', 'purchase_date',
                                            'frequency', 'vendor', 'model', 'sim'))

# deployments ----
deployments <- readr::read_delim('data-raw/tracking_db/data/sensors_animals/gps_sensors_animals.csv',
                                 delim = ';',
                                 col_names = c('animal_id', 'sensor_id', 'start_time', 'end_time', 'notes'))

# example file ----
single_file_collars <- dplyr::full_join(animals, deployments, by = c('id' = 'animal_id')) %>%
  dplyr::full_join(sensors, by = c('sensor_id' = 'id')) %>%
  dplyr::select(-id, -sensor_id) %>%
  dplyr::rename(sensor_id = sensor_id.y)
readr::write_csv(single_file_collars, 'data-raw/animal-collars.csv')




usethis::use_data("DATASET")
