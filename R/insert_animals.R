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
  # dat has deployment data as well
  # isolate unique animals
  # check which animals are in the database
  ## assign animals the id from database

  # parameter and data checks ----
  ## dat is inherits from data.frame
  if (!(inherits(dat, what = 'data.frame'))) {
    stop('dat must inherit from a `data.frame`')
  }

  ## use default connection in conn is null
  if (is.null(conn)) {
    conn <- collardb::collardb_conn()
  }

  ## check if the animals are already in the database
  ### get list of animals in database
  animals <- DBI::dbGetQuery(conn, 'SELECT animal_id FROM animals')
  animal_ids <- animals$animal_id

  check <- dat$animal_id %in% animal_ids
  if (all(check)) {
    ## if animal already exists, throw error with duplicate animals
    ## no animals will be uploaded to the database
    DBI::dbDisconnect(conn)
    stop(paste0('animal_id(s) already in database: '),
         paste0(animal_ids[check], collapse = ', '))
  }

  # format animal data ----
  dat$id <- vapply(seq_len(nrow(dat)), uuid::UUIDgenerate, character(1))
  animals_up <- dat[, c('id', 'animal_id', 'name', 'species', 'study', 'sex', 'age_class')]

  # format deployment data ----
  ## get device_id from database
  sql <- glue::glue_sql('SELECT id AS device_id FROM devices WHERE serial_number in ({vals*})',
                        vals = dat$serial_num, .con = collardb::collardb_conn())
  device_uuid <- DBI::dbGetQuery(collardb::collardb_conn(), sql)

  deployments <- cbind(device_uuid, dat[, c('id', 'inservice', 'outservice')])
  colnames(deployments)[1:2] <- c('device_fk', 'animal_fk')
  deployments$id <- vapply(seq_len(nrow(deployments)), uuid::UUIDgenerate, character(1))

  # insert ----
  ## insert animals into collardb
  sql <- glue::glue_sql(
    '
    INSERT INTO `animals`
      (`id`, `animal_id`, `name`, `species`, `study`, `sex`, `age_class`)
    VALUES
      (:id, :animal_id, :name, :species, :study, :sex, :age_class)
    '
  )

  ### send query to database
  res <- DBI::dbSendStatement(conn, sql)
  DBI::dbBind(res, animals_up)

  ### get number of rows affected
  # rows_appended <- DBI::dbGetRowsAffected(res)
  DBI::dbClearResult(res)

  ## insert deployments into collardb
  sql <- glue::glue_sql(
    '
    INSERT INTO `deployments`
      (`id`, `animal_fk`, `device_fk`, `inservice`, `outservice`)
    VALUES
      (:id, :animal_fk, :device_fk, :inservice, :outservice)
    '
  )
  res <- DBI::dbSendStatement(conn, sql)
  DBI::dbBind(res, deployments)

  DBI::dbClearResult(res)
  DBI::dbDisconnect(conn)

  message('succesfully appended animals and deployments to collardb')
}
