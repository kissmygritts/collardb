#' Insert animal data into collardb database
#'
#' Insert a data.frame, or an object that inherits from a table, into
#' the collardb SQLite database.
#'
#' @param dat data.frame. This data.frame needs to match the following
#' vector of column names c('serial_number', 'purchase_date', 'frequency', 'vendor', 'model')
#' @param conn a SQLite database connection. Optional if using the default database connection
#' parameters. Otherwise provide your own database connection
#'
#' @return NULL
#' @export
#'
#' @examples
#' \donttest{
#' insert_animals(animals)
#' }
#'
insert_animals <- function (dat, conn = NULL) {
  # parameter and data checks ----
  if (!(inherits(dat, what = 'data.frame'))) {
    stop('dat must inherit from a `data.frame`')
  }

  # check col names ----
  ## animal columns
  animal_cols <- c('animal_id', 'name', 'sex', 'age_class', 'species', 'study')
  # TODO: implement animals columns check

  ## deployment columns
  deployment_cols <- c('animal_id', 'serial_num', 'inservice', 'outservice')
  # TODO: implement deploy columns check

  ## use default connection in conn is null
  if (is.null(conn)) {
    conn <- collardb::collardb_conn()
  }

  # check if devices are in the database ----
  sql <- glue::glue_sql('SELECT id AS device_uuid, serial_number
                         FROM devices WHERE serial_number in ({vals*})',
                        vals = dat$serial_num, .con = collardb::collardb_conn())
  devices_in_db <- DBI::dbGetQuery(collardb::collardb_conn(), sql)
  serial_number_check <- dat$serial_num %in% devices_in_db$serial_number

  if (!(all(serial_number_check))) {
    DBI::dbDisconnect(conn)
    stop(paste0('device(s) not in the database, insert devices first: '),
         paste0(dat$serial_num[!(serial_number_check)], collapse = ', '))
  }

  ## merge database ids with dat
  dat <- merge(dat, devices_in_db, by.x = "serial_num", by.y = 'serial_number')

  # check if any of the animals are in the database ----
  sql <- glue::glue_sql('SELECT id AS animal_uuid, animal_id
                         FROM animals WHERE animal_id in ({vals*})',
                        vals = dat$animal_id, .con = collardb::collardb_conn())
  animals_in_db <- DBI::dbGetQuery(collardb::collardb_conn(), sql)

  ## merge database animal ids with dat
  dat <- merge(dat, animals_in_db, by.x = 'animal_id', by.y = 'animal_id', all.x = T)

  ## should check here for duplicate deployments and warn user

  # format data  ----
  ## add animal_uuid to rows that need it
  condition <- is.na(dat$animal_uuid)
  n <- nrow(dat[condition, ])
  dat$animal_uuid[condition] <- gen_uuid(n)

  ## format animal data & run insert
  animals_up <- dat[, c(animal_cols, 'animal_uuid')]
  colnames(animals_up)[7] <- 'id'

  ## format deployment data & run inserts
  deployments_up <- dat[, c('animal_uuid', 'device_uuid', 'inservice', 'outservice')]
  deployments_up$id <- gen_uuid(nrow(deployments_up))
  colnames(deployments_up) <- c('animal_fk', 'device_fk', 'inservice', 'outservice', 'id')

  # insert data ----
  animal_sql <- glue::glue_sql(
    '
    INSERT INTO `animals`
      (`id`, `animal_id`, `name`, `species`, `study`, `sex`, `age_class`)
    VALUES
      (:id, :animal_id, :name, :species, :study, :sex, :age_class)
    '
  )
  deployment_sql <- glue::glue_sql(
    '
    INSERT INTO `deployments`
      (`id`, `animal_fk`, `device_fk`, `inservice`, `outservice`)
    VALUES
      (:id, :animal_fk, :device_fk, :inservice, :outservice)
    '
  )

  DBI::dbBegin(conn)

  res_animal <- DBI::dbSendStatement(conn, animal_sql)
  DBI::dbBind(res_animal, animals_up)
  DBI::dbClearResult(res_animal)

  res_deployments <- DBI::dbSendStatement(conn, deployment_sql)
  DBI::dbBind(res_deployments, deployments_up)
  DBI::dbClearResult(res_deployments)

  DBI::dbCommit(conn)

  # cleanup connections ----
  DBI::dbDisconnect(conn)

  message('succesfully appended animals and deployments to collardb')
}
