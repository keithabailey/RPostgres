#' Transaction management.
#'
#' \code{dbBegin} starts a transaction. \code{dbCommit} and \code{dbRollback}
#' end the transaction by either committing or rolling back the changes.
#'
#' @param conn a \code{\linkS4class{PqConnection}} object, produced by
#'   \code{\link[DBI]{dbConnect}}
#' @return A boolean, indicating success or failure.
#' @examples
#' library(DBI)
#' con <- dbConnect(RPostgres::Postgres())
#' dbWriteTable(con, "USarrests", datasets::USArrests, temporary = TRUE)
#' dbGetQuery(con, 'SELECT count(*) from "USarrests"')
#'
#' dbBegin(con)
#' dbGetQuery(con, 'DELETE from "USarrests" WHERE "Murder" > 1')
#' dbGetQuery(con, 'SELECT count(*) from "USarrests"')
#' dbRollback(con)
#'
#' # Rolling back changes leads to original count
#' dbGetQuery(con, 'SELECT count(*) from "USarrests"')
#'
#' dbRemoveTable(con, "USarrests")
#' dbDisconnect(con)
#' @name postgres-transactions
NULL

#' @export
#' @rdname postgres-transactions
setMethod("dbBegin", "PqConnection", function(conn) {
  dbGetQuery(conn, "BEGIN")
  TRUE
})

#' @export
#' @rdname postgres-transactions
setMethod("dbCommit", "PqConnection", function(conn) {
  dbGetQuery(conn, "COMMIT")
  TRUE
})

#' @export
#' @rdname postgres-transactions
setMethod("dbRollback", "PqConnection", function(conn) {
  dbGetQuery(conn, "ROLLBACK")
  TRUE
})


inTransaction <- function(con) {
  dbGetQuery(con, "
    SELECT count(*)
    FROM pg_locks
    WHERE pid = pg_backend_pid()
      AND locktype = 'transactionid'
      AND mode = 'ExclusiveLock'
  ")
}
