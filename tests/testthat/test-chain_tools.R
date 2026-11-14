test_that("chain_discrepancy", {
	d <- make_chain("ao")
	res <- chain_discrepancy(d$x, d$z)
	# additive in the year after the base year with the annual overlap technique
	expect_lt(max(abs(window(res, end = c(2011, 4)))), 1e-8)
	expect_gt(max(abs(window(res, start = c(2012, 1)))), 1e-6)
	xt <- ts(cbind(as.matrix(d$x), Total = as.numeric(d$z)),
			 start = start(d$x), frequency = frequency(d$x))
	expect_equal(chain_discrepancy(xt), res)
	expect_equal(chain_discrepancy(xt, relative = TRUE), 100 * res / d$z)
	# sum of the components minus the total (sign of the manual)
	expect_equal(as.numeric(res), as.numeric(rowSums(as.matrix(d$x)) - d$z))
})

test_that("chain_contrib accepts the output of chain_laspeyres", {
	x <- chain_laspeyres(data8.2cp, data8.2ep, method = "ao", base_year = 2010,
						 output = "measure")
	res <- chain_contrib(x, data8.2cp, method = "ao")
	exp <- chain_contrib(x[, c("A", "B")], data8.2cp, vo_total = x[, "Total"],
						 method = "ao")
	expect_equal(res, exp)
	expect_equal(colnames(res), c("A", "B"))
	# the total of cp can be in cp
	cp_all <- ts(cbind(as.matrix(data8.2cp), Total = rowSums(data8.2cp)),
				 start = start(data8.2cp), frequency = 4)
	expect_equal(chain_contrib(x, cp_all, method = "ao"), res)
})

test_that("chain_rebase", {
	d <- make_chain("ao")
	idx <- chain_link(d$vo, d$cp, method = "ao", base_year = 2010)
	r <- chain_rebase(idx, 2012)
	expect_equal(colnames(r), colnames(idx))
	avg <- colMeans(as.matrix(window(r, start = c(2012, 1), end = c(2012, 4))))
	expect_equal(as.numeric(avg), rep(100, 3))
	# measures: annual sum of the new reference year = annual current prices
	m <- chain_rebase(d$x, 2012, cp = d$cp)
	sum_m <- colSums(as.matrix(window(m, start = c(2012, 1), end = c(2012, 4))))
	sum_cp <- colSums(as.matrix(window(d$cp, start = c(2012, 1), end = c(2012, 4))))
	expect_equal(as.numeric(sum_m), as.numeric(sum_cp))
	# growth rates are unchanged
	g <- function(x) as.matrix(x / stats::lag(x, -1))
	expect_equal(g(m), g(d$x))
	expect_error(chain_rebase(idx, 2020), "cover the reference year")
})
