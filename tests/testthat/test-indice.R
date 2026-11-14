# Reference values: IMF QNA Manual, chapter 8, examples 8.2 and 8.3
# (data/Chapter 8_Tables_Charts.xlsx) with the data of the package.
tol <- 1e-3

test_that("cp_pi2vol and laspeyres match example 8.2", {
	vol <- cp_pi2vol(data8.2cp, data8.2ep)
	las <- laspeyres(data8.2cp, data8.2ep, output = "index")
	expect_equal(start(las), c(2011, 1))
	expect_equal(length(las), 12)
	exp_vol <- cbind(A = c(104.379085, 106.146341, 108.349515, 109.838188, 103.000739, 107.189542, 113.351335, 128.675922, 117.829823, 124.893241, 129.303576, 131.297526),
					 B = c(98.271605, 96.9161, 95.510204, 95.039282, 98.450051, 95.185095, 91.34562, 81.148365, 86.289799, 80.443132, 76.052199, 73.79378))
	exp_las <- c(100.714597, 100.608196, 100.645928, 100.958844, 100.43266, 100.4151, 100.932901, 101.854806, 101.951479, 102.515512, 102.494983, 102.348143)
	expect_lt(max(abs(as.matrix(vol)[1:12, ] - exp_vol)), tol)
	expect_lt(max(abs(as.numeric(las) - exp_las)), tol)
})

test_that("laspeyres, paasche and fisher match example 8.3 (annual)", {
	cp_a <- stats::aggregate(data8.2cp)
	ep_a <- stats::aggregate(data8.2ep, FUN = "mean")
	exp_las <- c(100.735795, 100.875099, 102.291059)
	exp_paa <- c(100.84207, 101.053984, 102.087353)
	exp_fis <- c(100.788919, 100.964502, 102.189155)
	expect_lt(max(abs(as.numeric(laspeyres(cp_a, ep_a)) - exp_las)), tol)
	expect_lt(max(abs(as.numeric(paasche(cp_a, ep_a)) - exp_paa)), tol)
	expect_lt(max(abs(as.numeric(fisher(cp_a, ep_a)) - exp_fis)), tol)
	# Fisher is the geometric mean of Laspeyres and Paasche
	all_idx <- fisher(cp_a, ep_a, all_index = TRUE)
	expect_equal(as.numeric(all_idx[, "Fisher"]),
				 sqrt(as.numeric(all_idx[, "Laspeyres"]) * as.numeric(all_idx[, "Paasche"])))
})

test_that("output = 'measure' and 'both'", {
	idx <- laspeyres(data8.2cp, data8.2ep, output = "index")
	mea <- laspeyres(data8.2cp, data8.2ep, output = "measure")
	both <- laspeyres(data8.2cp, data8.2ep, output = "both")
	expect_equal(colnames(both), c("Index", "Measure"))
	expect_equal(as.numeric(both[, "Index"]), as.numeric(idx))
	expect_equal(as.numeric(both[, "Measure"]), as.numeric(mea))
	# the measure is the index times the previous-year current prices / 4
	expect_equal(as.numeric(mea[1:4]) / as.numeric(idx[1:4]) * 100,
				 rep(sum(window(data8.2cp, end = c(2010, 4))) / 4, 4))
	expect_error(fisher(data8.2cp, data8.2ep, output = "ouput"))
})

test_that("a single component gives its elementary volume index", {
	vol <- cp_pi2vol(data8.2cp[, "A"], data8.2ep[, "A"])
	las <- laspeyres(data8.2cp[, "A"], data8.2ep[, "A"])
	expect_equal(as.numeric(las), as.numeric(vol))
})

test_that("pi_py2pp and quarterly indices match example 8.4", {
	ep_pp <- pi_py2pp(data8.2ep)
	expect_equal(colnames(ep_pp), colnames(data8.2ep))
	exp_ep <- cbind(A = c(102, 100.490196, 100.487805, 100, 102.12682, 99.512195, 99.019608, 100.49505, 100.747537, 99.004975, 99.497487, 99.494949),
					B = c(99, 98.989899, 100, 101.020408, 96.510101, 102.061856, 99.494949, 100.507614, 99.368687, 101.0, 100.49505, 100.492611))
	expect_lt(max(abs(as.matrix(ep_pp)[1:12, ] - exp_ep)), tol)
	las <- laspeyres(data8.2cp, ep_pp, reference_freq = 4)
	paa <- paasche(data8.2cp, ep_pp, reference_freq = 4)
	fis <- fisher(data8.2cp, ep_pp, reference_freq = 4)
	expect_equal(start(fis), c(2011, 1))
	expect_lt(max(abs(as.numeric(las) - c(100.714597, 99.916671, 100.076248, 100.333761, 100.17113, 100.083433, 100.588381, 101.068009, 100.745709, 100.568806, 99.947779, 99.830322))), tol)
	expect_lt(max(abs(as.numeric(paa) - c(100.758483, 99.927955, 100.080462, 100.329087, 100.179784, 100.037077, 100.576706, 101.067238, 100.766782, 100.506459, 99.926258, 99.819711))), tol)
	expect_lt(max(abs(as.numeric(fis) - c(100.736538, 99.922313, 100.078355, 100.331424, 100.175457, 100.060252, 100.582544, 101.067624, 100.756245, 100.537628, 99.937018, 99.825016))), tol)
	# single series, and previous-year prices are NOT quarter-to-quarter prices
	expect_equal(as.numeric(pi_py2pp(data8.2ep[, "A"])), as.numeric(ep_pp[, "A"]))
	expect_error(pi_py2pp(stats::aggregate(data8.2ep, FUN = "mean")), "quarterly or monthly")
})

test_that("chain indices of example 8.8", {
	fis_q <- fisher(data8.2cp, pi_py2pp(data8.2ep), reference_freq = 4)
	# quarter-to-quarter indices chained; the four quarters of 2010 are 100
	chain_q <- ts(c(rep(100, 4), cumprod(as.numeric(fis_q) / 100) * 100),
				  start = c(2010, 1), frequency = 4)
	avg_q <- as.numeric(aggregate(chain_q, FUN = mean))
	expect_lt(max(abs(avg_q[2:4] - c(100.801, 101.861, 104.106))), tol)
	fis_a <- fisher(stats::aggregate(data8.2cp), stats::aggregate(data8.2ep, FUN = "mean"))
	chain_a <- annual_chain(fis_a, base_year = 2010)
	expect_equal(start(chain_a), c(2010, 1))
	expect_lt(max(abs(as.numeric(chain_a) - c(100, 100.789, 101.761, 103.989))), tol)
})
