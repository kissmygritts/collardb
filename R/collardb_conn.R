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

# an alternative??
# collardb_connection <- function (path = '~/.collardb/collardb.sqlite3') {
#   conn <- DBI::dbConnect(RSQLite::SQLite(), path)
#
#   open <- function () DBI::dbConnect(conn)
#
#   close <- function () DBI::dbDisconnect(conn)
#
#   conn_list <- list(
#     open = open,
#     close = close
#   )
#
#   return(conn_list)
# }
#
# connection <- collardb_connection()
# connection
#
# DBI::dbReadTable(connection$open(), 'animals')
# connection$close()
