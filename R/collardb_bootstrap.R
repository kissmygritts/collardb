#' Builds the collardb database
#'
#' Create the collardb database. This function creates the tables,
#' views, etc. required to efficiently manage GPS telemetry data
#'
#' @param dirpath character
#' @param dbname character
#'
#' @return null
#' @export
#'
#' @examples
#' \donttest{
#' build_collardb()
#' }

build_collardb <- function (dirpath = '~/.collardb', dbname = 'collardb.sqlite3') {
  fullpath <- paste(dirpath, dbname, sep = '/')

  # create collarsdb directory ----
  ## according to fs, fs::dir_create fails silently if dir exists
  fs::dir_create(dirpath)

  # create collarsdb.sqlite3 file ----
  ## according to fs, fs::file_create fails silently if dir exists
  fs::file_create(fullpath)

  # read bootstrap sql query file ----
  ## create sql statement list
  query_file <- system.file('sql', 'bootstrap-collardb.sql', package = 'collardb')
  sql <- readr::read_file(query_file)
  sql_list <- chunk_multi_statement_sql(sql)

  ## connect to database
  db_conn <- DBI::dbConnect(RSQLite::SQLite(), fullpath)

  ## loop over sql_list and execute sql
  lapply(sql_list, function (x) {
    DBI::dbExecute(db_conn, x)
  })

  ## disconnect
  DBI::dbDisconnect(db_conn)
}
