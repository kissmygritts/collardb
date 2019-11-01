#' Delete collardb
#'
#' @param dirpath character
#' @param force boolean
#'
#' @return null
#' @export
#'
#' @examples
#' \donttest{
#' delete_collardb(force = T)
#' }

delete_collardb <- function (dirpath = '~/.collardb', force = FALSE) {
  if (force) {
    fs::dir_delete(dirpath)
  } else {
    warning('you must explicitly force deletion for safety')
  }
}
