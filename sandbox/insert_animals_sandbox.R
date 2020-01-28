insert_animal <- function (dat, conn = NULL) {
  # dat has deployment data as well
  # isolate unique animals
  # check which animals are in the database
  ## assign animals the id from database

  if (!(inherits(dat, what = 'data.frame'))) {
    stop('dat must inherit from a `data.frame`')
  }

  # use default connection in conn is null
  if (is.null(conn)) {
    conn <- collardb::collardb_conn()
  }

  # get list of animals already in the database ---
  animals <- DBI::dbGetQuery(conn, 'SELECT animal_id FROM animals')
  animal_ids <- animals$animal_id

  check <- dat$animal_id %in% animal_ids
  if (all(check)) {
    DBI::dbDisconnect(conn)
    stop(paste0('animal_id(s) already in database: '),
         paste0(animal_ids[check], collapse = ', '))
  }

  return(check)
}

insert_animal(animals)

