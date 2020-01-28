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
      (`serial_number`, `purchase_date`, `frequency`, `vendor`, `model`)
    VALUES
      (:serial_number, :purchase_date, :frequency, :vendor, :model)
    '
  )

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

insert_devices(as.matrix(devices_tbl))

conn <- collardb::collardb_conn()

serial_number <- DBI::dbGetQuery(conn, 'SELECT serial_number FROM devices')
serial_number

serial_number$serial_number %in% devices$serial_number
