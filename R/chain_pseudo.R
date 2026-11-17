#' Pseudo chain volume series of a variable that changes sign
#'
#' Growth rates and chain volume measures cannot be calculated for variables that
#' can take positive, negative and zero values, such as changes in inventories or
#' the external trade balance (IMF QNA Manual, paragraph 8.56). The solution of the
#' 2008 SNA (paragraphs 8.57 and 8.58) is to write the variable as the difference
#' of two series that only take positive values, to chain-link each of them
#' separately, and to take the difference of the chain volume measures.
#' For instance, changes in inventories are closing inventories minus opening
#' inventories, and the trade balance is exports minus imports.
#'
#' With \eqn{x^{+}_t} and \eqn{x^{-}_t} the chain volume measures of the two
#' series ([chain_laspeyres()]), the pseudo chain volume series is
#' \eqn{x^{+}_t - x^{-}_t}.
#'
#' The result is a pseudo chain volume series: it is the difference of two chained
#' components, which are not additive by construction. It is expressed in monetary
#' terms (its growth rates are meaningless). The measure of each series is that of
#' [chain_laspeyres()].
#'
#' If the two series are already chain-linked (in monetary terms, with the same
#' reference year), their simple difference is the pseudo chain volume series.
#'
#' @param cp_pos Current prices of the series that takes positive values (`ts`; an
#' `mts` is the aggregate of its columns): closing inventories, exports, etc.
#' @param pi_pos Price indices of `cp_pos` over the previous year (previous year
#' average = 100), with the same structure.
#' @param cp_neg,pi_neg The same for the series that is subtracted (opening
#' inventories, imports, etc.).
#' @inheritParams chain_laspeyres
#'
#' @return A `ts`: the chain volume measure (in monetary terms) of `cp_pos` minus
#' the one of `cp_neg`.
#' @examples
#' # Illustration: the two products of the example 8.2 stand in for closing and
#' # opening inventories
#' chain_pseudo(imf_cp[, "A"], imf_pi[, "A"],
#' 			 imf_cp[, "B"], imf_pi[, "B"], base_year = 2010)
#' @seealso [chain_laspeyres()], [chain_contrib()]
#' @export
chain_pseudo <- function(cp_pos, pi_pos, cp_neg, pi_neg, method = c("ao", "oqo"), base_year = NULL) {
    method <- match.arg(method)
    check_ts(cp_pos, "cp_pos")
    check_ts(cp_neg, "cp_neg")
    check_same_frequency(cp_pos = cp_pos, cp_neg = cp_neg)
    chain_total <- function(cp, pi) {
        x <- chain_laspeyres(cp, pi, method = method, base_year = base_year, output = "measure")
        x[, ncol(x)] # the last column is the total
    }
    chain_total(cp_pos, pi_pos) - chain_total(cp_neg, pi_neg)
}
