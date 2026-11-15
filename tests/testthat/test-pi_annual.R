# Reference values: original spreadsheet of the IMF QNA Manual, chapter 8
# (examples 8.3, 8.8 and 8.9), where the annual price indices are the weighted
# averages of the quarterly ones.
tol <- 1e-3

test_that("pi_annual(method = 'weighted') matches example 8.3 of the manual", {
	pa <- pi_annual(imf_pi, imf_cp)
	expect_equal(start(pa), c(2010, 1))
	expect_equal(frequency(pa), 1)
	expect_equal(colnames(pa), colnames(imf_pi))
	expect_true(all(is.na(pa[1, ])))
	exp_pa <- cbind(A = c(102.632728, 101.720963, 99.344788),
					B = c(98.501147, 98.337467, 101.080639))
	expect_lt(max(abs(as.matrix(pa)[2:4, ] - exp_pa)), tol)
	cp_a <- stats::aggregate(imf_cp)
	expect_lt(max(abs(as.numeric(laspeyres(cp_a, pa)) - c(100.731865, 100.908775, 102.328181))), tol)
	expect_lt(max(abs(as.numeric(paasche(cp_a, pa)) - c(100.838343, 101.088331, 102.124708))), tol)
	expect_lt(max(abs(as.numeric(fisher(cp_a, pa)) - c(100.785090, 100.998513, 102.226394))), tol)
	# example 8.8: annual chain Fisher index
	chain_a <- annual_chain(fisher(cp_a, pa), base_year = 2010)
	expect_lt(max(abs(as.numeric(chain_a) - c(100, 100.785, 101.791, 104.058))), tol)
})

test_that("weighted annual prices are consistent with the quarterly volumes", {
	pa <- pi_annual(imf_pi, imf_cp)
	cp_a <- stats::aggregate(imf_cp)
	# annual volume at the prices of the previous year = sum of the quarterly ones
	expect_equal(as.numeric(window(cp_a / pa * 100, start = 2011)),
				 as.numeric(window(stats::aggregate(imf_cp / imf_pi * 100), start = 2011)))
	# annual overlap: annual chain volume measures = annual sums of the quarterly ones
	# (example 8.9 of the manual)
	cp_tot <- ts(rowSums(imf_cp), start = 2010, frequency = 4)
	x_q <- chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
						   output = "measure")
	x_a <- chain_laspeyres(cp_a, pa, method = "ao", base_year = 2010,
						   output = "measure")
	expect_equal(as.numeric(x_a), as.numeric(stats::aggregate(x_q)))
	expect_lt(max(abs(as.numeric(x_a[, "Total"]) - c(1510.978, 1524.711, 1560.199))), tol)
	# cp_pi2cy: annual sums are the current prices
	expect_equal(as.numeric(window(stats::aggregate(cp_pi2cy(imf_cp, imf_pi)), start = 2011)),
				 as.numeric(window(cp_a, start = 2011)))
})

test_that("pi_annual(method = 'mean') is the simple average", {
	expect_equal(pi_annual(imf_pi, method = "mean"),
				 stats::aggregate(imf_pi, FUN = mean))
	# cp is ignored with method = "mean"
	expect_equal(pi_annual(imf_pi, imf_cp, method = "mean"),
				 pi_annual(imf_pi, method = "mean"))
})

test_that("pi_annual works on single series and incomplete years", {
	pa <- pi_annual(imf_pi, imf_cp)
	pa_a <- pi_annual(imf_pi[, "A"], imf_cp[, "A"])
	expect_null(dim(pa_a))
	expect_equal(as.numeric(pa_a), as.numeric(pa[, "A"]))
	# incomplete last year: NA
	pi_inc <- window(imf_pi, end = c(2013, 2))
	cp_inc <- window(imf_cp, end = c(2013, 2))
	pa_inc <- pi_annual(pi_inc, cp_inc)
	expect_true(all(is.na(pa_inc[4, ])))
	expect_equal(as.matrix(pa_inc)[2:3, ], as.matrix(pa)[2:3, ])
	expect_true(all(is.na(pi_annual(pi_inc, method = "mean")[4, ])))
})

test_that("pi_annual checks its inputs", {
	expect_error(pi_annual(imf_pi), "`cp` is needed")
	expect_error(pi_annual(stats::aggregate(imf_pi)), "quarterly or monthly")
	expect_error(pi_annual(imf_pi, imf_cp[, "A"]))
	expect_error(pi_annual(as.numeric(imf_pi[, 1]), method = "mean"))
})
