#' @name hello_world
#' @title Say hello!
#' @description Run \code{echo "Hello World!"} in Ubuntu 18.04.
#' @return Logical
#' @example examples/hello_world.R
#' @export
#' @export
hello_world <- function() {
  otsdr <- outsider_init(pkgnm = 'om..hello.world',
                         cmd = 'cat', arglist = '../hello.txt')
  run(otsdr)
}
