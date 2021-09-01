#' Data from the DAGI API
#'
#' @docType data
#'
#' @usage data(geo_kommuner)
#'
#' @format A data frame with 9882 rows and 7 variables:
#' \describe{
#'   \item{id}{id seperating individuals}
#'   \item{start}{start of specified cost}
#'   \item{stop}{end of specified cost}
#'   \item{cost}{cost in given period}
#'   \item{trt}{treatment variable}
#'   \item{delta}{event variable, 0 = censored}
#'   \item{surv}{survival period}
#' }
#'
#' @keywords datasets
#'
#' @references
#' \insertRef{Chen2015}{ccostr}
#'
#' @source \href{http://dawa.dk}{Website}
#'
#' @examples
#' data(geo_kommuner)
#'
#'
#' @importFrom Rdpack reprompt
"geo_kommuner"
