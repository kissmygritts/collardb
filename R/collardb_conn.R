#' create connection to collardb
#'
#' @param db character
#'
#' @return character
#' @export
#'
#' @examples
#' \donttest{
#' conn <- collardb_conn()
#' }

collardb_conn <- function (db = '~/.collardb/collardb.sqlite3') {
  return(DBI::dbConnect(RSQLite::SQLite(), db))
}
