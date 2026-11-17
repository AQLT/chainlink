# References used in the documentation, with inline R code:
# #' @references `r ref_imf()`

ref_imf <- function() {
    paste(
        "International Monetary Fund (2018), *Quarterly National Accounts Manual",
        "(2017 Edition)*, chapter 8 \"Price and Volume Measures\", Washington, DC.",
        "\\doi{10.5089/9781475589870.069}."
    )
}

ref_ess <- function() {
    paste(
        "Eurostat (2015), *ESS Guidelines on Seasonal Adjustment (2015 Edition)*,",
        "Luxembourg, Publications Office of the European Union.",
        "\\doi{10.2785/317290}."
    )
}
