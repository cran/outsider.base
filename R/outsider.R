#' outsider.base: Base Package for outsider.
#' 
#' For more information visit the outsider website
#' (\url{https://docs.ropensci.org/outsider/}).
#'
#' @docType package
#' @name outsider.base
NULL

#' @name outsider-class
#' @aliases outsider-methods
#' @title Construct outsider object
#' @description Returns an outsider object. The outsider object describes a
#' outsider module's program and arguments. The object is generated every
#' time an outsider module program is called. It details the arguments of a
#' call, the command as well as the files to send to the docker container.
#' @details The outsider module runs a docker container that acts like a 
#' separate machine on the host computer. All the files necessary for the 
#' program to be run must be sent to the remote machine before the program
#' is called.
#' The arguments, wd and files_to_send can all be defined after the outsider
#' has been initiated using \code{$} notation.
#' Once a outsider has been defined, the command can be run using
#' \code{.run()}.
#' The \code{arglist}, \code{wd} or \code{files_to_send} do not need to be
#' defined for the outsider to be run.
#' @param pkgnm Name of the installed R package for the outsider module
#' @param cmd Command to be called in the container
#' @param arglist Arguments for command, character vector
#' @param wd Directory to which program generated files will be returned
#' @param files_to_send Files to be sent to container
#' @param ignore_errors Ignore raised errors? Default FALSE.
#' @param ... Additional arguments
#' @return A list of class \code{outsider} with the following items:
#' \item{pkgnm}{Package name of the outsider module}
#' \item{cmd}{Command to be called in the container}
#' \item{arglist}{Arguments for command, character vector}
#' \item{wd}{Directory to which program generated files will be returned}
#' \item{files_to_send}{Files to be sent to container}
#' \item{container}{Docker container object}
#' \item{ignore_errors}{Prevent errors being raised}
#' @export
#' @example examples/outsider-class.R
outsider_init <- function(pkgnm, cmd = NA, arglist = NULL, wd = NULL,
                          files_to_send = NULL, ignore_errors = FALSE) {
  container <- container_init(pkgnm = pkgnm)
  parts <- list(pkgnm = pkgnm, cmd = cmd, arglist = arglist, wd = wd,
                files_to_send = files_to_send, container = container,
                ignore_errors = FALSE)
  structure(parts, class = 'outsider')
}

#' @rdname outsider-class
#' @export
run <- function(x, ...) {
  UseMethod('run', x)
}

#' @rdname outsider-class
#' @param x outsider object
#' @export
run.outsider <- function(x, ...) {
  if (is.na(x[['cmd']])) {
    stop('Command not set')
  }
  cntnr <- x[['container']]
  successes <- list()
  successes[['start']] <- start(cntnr)
  on.exit(halt(x = cntnr))
  if (length(x[['files_to_send']]) > 0) {
    successes[['send']] <- copy(x = cntnr, send = x[['files_to_send']])
  }
  successes[['run']] <- run(x = cntnr, cmd = x[['cmd']], args = x[['arglist']])
  if (length(x[['wd']]) > 0) {
    successes[['return']] <- copy(x = cntnr, rtrn = x[['wd']])
  }
  if (x[['ignore_errors']]) {
    return(TRUE)
  }
  are_errors <- vapply(X = successes, FUN = inherits, FUN.VALUE = logical(1),
                       'error')
  success <- all(vapply(X = successes, FUN = is.logical,
                        FUN.VALUE = logical(1))) && all(unlist(successes))
  if (any(are_errors)) {
    message('An error occurred in the following container ...')
    message(print(x))
    stop(successes[are_errors][[1]])
  }
  if (!success) {
    message('Command and arguments failed to run for ...')
    message(print(x))
  }
  invisible(success)
}

#' @export
print.outsider <- function(x, ...) {
  cat_line(cli::rule())
  cat_line(crayon::bold('Outsider module:'))
  cat_line('Package ', char(x[['pkgnm']]))
  cat_line('Command ', char(x[['cmd']]))
  arglist <- lapply(X = x[['arglist']], FUN = function(x) {
    ifelse(is.numeric(x), stat(x), char(x))
  })
  # TODO: add column width
  cat_line('Args ', paste0(arglist, collapse = ', '))
  cat_line('Files to send ', paste0(x[['files_to_send']], collapse = ', '))
  cat_line('Working dir ', char(x[['wd']]))
  cat_line('Container image ', char(x[['container']][['img']]))
  cat_line('Container name ', char(x[['container']][['cntnr']]))
  cat_line('Container tag ', char(x[['container']][['tag']]))
  cat_line('Container status ', char(status(x[['container']])))
  cat_line(cli::rule())
}
