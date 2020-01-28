#' Insert device data into collardb database
#'
#' Insert a data.frame, or an object that inherits from a table, int
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
#' insert_devices(devices)
#' }
#'
#'
insert_devices <- function (dat, conn = NULL) {
  # check data.frame ----
  if (!(inherits(dat, 'data.frame'))) {
    stop('dat must inherit from a `data.frame`')
  }
  # rename column names, map from input? ----

  ## if conn isnt provided assume default connection
  if (is.null(conn)) {
    ### check for open connection first?
    conn <- collardb::collardb_conn()
  }

  # get list of collars to check if entered ----
  serial_number <- DBI::dbGetQuery(conn, 'SELECT serial_number from devices')
  serial_number <- serial_number$serial_number

  check <- dat$serial_number %in% serial_number

  if (all(check)) {
    ## if collars already exist, throw error with duplicate collars
    ## no devices will be uploaded to the database
    DBI::dbDisconnect(conn)
    stop(paste('serial_number(s) already in database:',
               paste0(serial_number[check], collapse = ', '))
    )
  }

  # insert ----
  sql <- glue::glue_sql(
    '
    INSERT INTO `devices`
      (`id`, `serial_number`, `purchase_date`, `frequency`, `vendor`, `model`)
    VALUES
      (:id, :serial_number, :purchase_date, :frequency, :vendor, :model)
    '
  )

  ## add uuid field to input data
  dat$id <- vapply(seq_len(nrow(dat)), uuid::UUIDgenerate, character(1))

  ## send query to database
  res <- DBI::dbSendStatement(conn, sql)
  DBI::dbBind(res, dat)

  ## get number of rows updated & disconnect
  rows_appended <- DBI::dbGetRowsAffected(res)
  DBI::dbClearResult(res)
  DBI::dbDisconnect(conn)

  ## message, no return value
  message(paste0(rows_appended, ' rows inserted into collardb'))
}
