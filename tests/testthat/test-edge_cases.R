# Edge cases: incomplete years, base year inside the series, missing values

test_that("series ending in the middle of a year", {
	d <- make_chain("ao")
	full <- chain_link(d$vo, d$cp, method = "ao", base_year = d$base_year)
	short <- chain_link(window(d$vo, end = c(2013, 2)), d$cp, method = "ao",
						base_year = d$base_year)
	# the span is extended to complete years, with NA after the last observation
	expect_equal(end(short), c(2013, 4))
	expect_true(all(is.na(window(short, start = c(2013, 3)))))
	# the available quarters are the same as with the complete series
	expect_equal(window(short, end = c(2013, 2)), window(full, end = c(2013, 2)))
})

test_that("a missing value in a year makes the following years unavailable", {
	d <- make_chain("ao")
	vo <- d$vo
	vo[6, 1] <- NA            # 2012Q2, first component
	res <- chain_link(vo, d$cp, method = "ao", base_year = d$base_year)
	# the annual link of 2012 is not available: the next years are NA
	expect_true(all(is.na(window(res[, "A"], start = c(2013, 1)))))
	expect_false(anyNA(window(res[, "A"], end = c(2011, 4))))
	# the other components are not concerned
	expect_false(anyNA(res[, "B"]))
})

test_that("base year inside the series", {
	d <- make_chain("ao")
	idx10 <- chain_link(d$vo, d$cp, method = "ao", base_year = 2010)
	idx12 <- chain_link(d$vo, d$cp, method = "ao", base_year = 2012)
	avg <- colMeans(as.matrix(window(idx12, start = c(2012, 1), end = c(2012, 4))))
	expect_equal(as.numeric(avg), rep(100, 3))
	# the growth rates do not depend on the reference year
	g <- function(x) as.matrix(x / stats::lag(x, -1))
	expect_equal(g(idx12), g(idx10))
	# in monetary terms, the annual sum of the base year is its current prices
	mea12 <- chain_link(d$vo, d$cp, method = "ao", base_year = 2012,
						output = "measure")
	sum12 <- colSums(as.matrix(window(mea12, start = c(2012, 1), end = c(2012, 4))))
	cp12 <- colSums(as.matrix(window(d$cp, start = c(2012, 1), end = c(2012, 4))))
	expect_equal(as.numeric(sum12), as.numeric(cp12))
})

test_that("the series must start at the latest the year after the base year", {
	d <- make_chain("ao")
	expect_error(chain_link(window(d$vo, start = c(2013, 1)), d$cp, base_year = 2010),
				 "must start at the latest")
})

test_that("contributions with a series starting in the middle of a year", {
	d <- make_chain("ao")
	res <- chain_contrib(window(d$x, start = c(2011, 3)), d$cp,
						 window(d$z, start = c(2011, 3)),
						 method = "ao", base_year = d$base_year)
	# 2011Q4 only needs the relative prices of the reference year
	expect_false(anyNA(window(res, start = c(2011, 4), end = c(2011, 4))))
	# 2012 needs the annual sums of 2011, which are not complete
	expect_true(all(is.na(window(res, start = c(2012, 1), end = c(2012, 4)))))
})

test_that("contributions with a missing value do not fail", {
	d <- make_chain("ao")
	x <- d$x
	x[7, 1] <- NA
	res <- chain_contrib(x, d$cp, d$z, method = "ao", base_year = d$base_year)
	expect_true(anyNA(res[, "A"]))
	expect_false(anyNA(window(res[, "B"], start = c(2011, 2), end = c(2011, 4))))
})
