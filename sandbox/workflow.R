library(here)

# create the database ----
## don't do this if you've already run this.
## if you want to check that the database exists, run the following command
## if this throws an error, then the database doesn't exists
conn <- collardb::collardb_conn()

## if you need to create a database, run this command.
## you can specify a path and a database name, however,
## I recommend using the default behavoir for consistency
collardb::collardb_bootstrap()

## reconnect to the database
conn <- collardb::collardb_conn()

## list the tables in the database
DBI::dbListTables(conn)

## disconnect from the database if finished using the connection
DBI::dbDisconnect(conn)

# devices ----
## the first step is to insert all the devices into the database
## I always recommend this as the first step because you'll know all
## the device information prior to capturing any animals. This will
## also ensure that animals entered into the database have an device id
## that exists in the database

## read the device data
devices <- readr::read_csv(here('data-raw', 'devices.csv'))
devices
## check the fields of the device table in the database
conn <- collardb::collardb_conn()
DBI::dbListFields(conn, 'devices')

## rename the fields of the devices table to match
names(devices) <- c('serial_number', 'purchase_date', 'frequency', 'vendor', 'model')
devices

## write table to the database
DBI::dbWriteTable(conn, 'devices', devices, append = T)

## remove devices
rm(devices)

## retreive the data and save to new variable
(db_devices <- DBI::dbReadTable(conn, 'devices'))

# animals ----
## now read the animals data
animals <- readr::read_csv(here('data-raw', 'animals.csv'))

## check fields
DBI::dbListFields(conn, 'animals')
names(animals)

## use dplyr functions to rename functions
animals_up <- dplyr::select(animals, animal_id, name, species, sex, age = age_class)
animals_up

## and now write to the database this time using the
## DBI::dbAppendTable function instead of the write table function
DBI::dbAppendTable(conn, 'animals', animals_up)
rm(animals)

## read the data from the database
(db_animals <- DBI::dbReadTable(conn, 'animals'))

# deployments ----
## deployments are animal - device associations.
## An animal can have many collars at different times during its life
## and a device can deployed onto different animals, just not at the same
## time. The deployments associate an animal with a collar, and add an
## inservice and outservice date to each record to help manage the
## telemetry data.
## In this case, the animals table we loaded above has a start_time and end_time
## We will use this to fill data into the deployments table

## create the dployments table below, we need to grab the id from the devices
## in the device table
deploys <- dplyr::full_join(db_animals, animals[, c(1, 6:7, 9)], by = c('animal_id' = 'animal_id')) %>%
  dplyr::full_join(db_devices, by = c('serial_num' = 'serial_number')) %>%
  dplyr::select(animal_fk = id.x, devices_fk = id.y, inservice, outservice)

deploys

## write to deployments table
DBI::dbAppendTable(conn, 'deployments', deploys)

## fetch data
DBI::dbReadTable(conn, 'deployments')
