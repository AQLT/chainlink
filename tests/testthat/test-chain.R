# Reference values: IMF QNA Manual, chapter 8, examples 8.6 (annual overlap)
# and 8.7 (one-quarter overlap), from data/Chapter 8_Tables_Charts.xlsx.
# The sheet gives current prices from 2011Q1; 2010 is only given as an annual
# sum (600 / 900 / 1500) and is spread evenly: only the annual sum matters.
tol <- 1e-3
cp <- ts(cbind(A = c(rep(150, 4), c(159.7, 163.2, 167.4, 169.7, 174.2, 180.4, 188.9, 215.5, 224.7, 235.8, 242.9, 245.4)),
               B = c(rep(225, 4), c(218.9, 213.7, 210.6, 211.7, 204.1, 201.4, 192.3, 171.7, 166, 156.3, 148.5, 144.8)),
               Sum = c(rep(375, 4), c(378.6, 376.9, 378, 381.4, 378.3, 381.8, 381.2, 387.2, 390.7, 392.1, 391.4, 390.2))),
         start = c(2010, 1), frequency = 4)
q_ts <- function(x) ts(x, start = c(2011, 1), frequency = 4)

# --- annual overlap (example 8.6)
vo_ao <- q_ts(cbind(A = c(104.379085, 106.146341, 108.349515, 109.838188, 103.000739, 107.189542, 113.351335, 128.675922, 117.829823, 124.893241, 129.303576, 131.297526), B = c(98.271605, 96.9161, 95.510204, 95.039282, 98.450051, 95.185095, 91.34562, 81.148365, 86.289799, 80.443132, 76.052199, 73.79378), C = c(100.714597, 100.608196, 100.645928, 100.958844, 100.43266, 100.4151, 100.932901, 101.854806, 101.951479, 102.515512, 102.494983, 102.348143)))
idx_ao <- q_ts(cbind(A = c(104.379, 106.146, 108.35, 109.838, 110.394, 114.884, 121.488, 137.913, 142.774, 151.333, 156.677, 159.093), B = c(98.272, 96.916, 95.51, 95.039, 94.94, 91.791, 88.089, 78.255, 76.167, 71.006, 67.13, 65.137), C = c(100.715, 100.608, 100.646, 100.959, 101.168, 101.15, 101.672, 102.6, 103.631, 104.204, 104.183, 104.034)))
mea_ao <- q_ts(cbind(A = c(156.569, 159.22, 162.524, 164.757, 165.592, 172.326, 182.232, 206.869, 214.161, 226.999, 235.015, 238.639), B = c(221.111, 218.061, 214.898, 213.838, 213.614, 206.53, 198.199, 176.073, 171.375, 159.763, 151.043, 146.558), C = c(377.68, 377.281, 377.422, 378.596, 379.379, 379.313, 381.269, 384.751, 388.616, 390.766, 390.688, 390.128)))
# --- one-quarter overlap (example 8.7)
vo_oqo <- q_ts(cbind(A = c(104.379085, 106.146341, 108.349515, 109.838188, 100.148037, 104.220828, 110.211964, 125.112122, 103.75039, 109.969803, 113.853149, 115.608843), B = c(98.271605, 96.9161, 95.510204, 95.039282, 99.391767, 96.09558, 92.219379, 81.924584, 96.680256, 90.129572, 85.209912, 82.679548), C = c(100.714597, 100.608196, 100.645928, 100.958844, 99.728262, 99.710826, 100.224995, 101.140434, 100.615209, 101.171849, 101.151589, 101.006674)))
idx_oqo <- q_ts(cbind(A = c(104.379, 106.146, 108.35, 109.838, 110.001, 114.474, 121.055, 137.421, 142.575, 151.121, 156.458, 158.871), B = c(98.272, 96.916, 95.51, 95.039, 94.461, 91.329, 87.645, 77.861, 75.276, 70.175, 66.345, 64.375), C = c(100.715, 100.608, 100.646, 100.959, 100.685, 100.667, 101.186, 102.11, 102.738, 103.307, 103.286, 103.138)))
mea_oqo <- q_ts(cbind(A = c(156.569, 159.22, 162.524, 164.757, 165.001, 171.711, 181.582, 206.131, 213.862, 226.682, 234.687, 238.306), B = c(221.111, 218.061, 214.898, 213.838, 212.538, 205.489, 197.2, 175.186, 169.37, 157.895, 149.276, 144.843), C = c(377.68, 377.281, 377.422, 378.596, 377.567, 377.501, 379.447, 382.913, 385.269, 387.4, 387.323, 386.768)))
# --- annual links (example 8.6, annual part)
vo_y <- ts(cbind(A = c(107.186358, 113.022113, 125.792793), B = c(96.43542, 91.49736, 79.110012), C = c(100.735795, 100.875099, 102.291059)), start = 2011, frequency = 1)
idx_y <- ts(cbind(A = c(100, 107.186, 121.144, 152.391), B = c(100, 96.435, 88.236, 69.803), C = c(100, 100.736, 101.617, 103.945)), start = 2010, frequency = 1)

test_that("chain_link(method = 'ao') matches example 8.6", {
	res <- chain_link(vo_ao, cp, method = "ao", base_year = 2010)
	expect_lt(max(abs(res - idx_ao)), tol)
	res <- chain_link(vo_ao, cp, method = "ao", base_year = 2010, output = "measure")
	expect_lt(max(abs(res - mea_ao)), tol)
	both <- chain_link(vo_ao, cp, base_year = 2010, output = "both")
	expect_equal(ncol(both), 6)
})

test_that("chain_link(method = 'oqo') links the volume indices of the spreadsheet version of example 8.7", {
	res <- chain_link(vo_oqo, cp, method = "oqo", base_year = 2010)
	expect_lt(max(abs(res - idx_oqo)), tol)
	res <- chain_link(vo_oqo, cp, method = "oqo", base_year = 2010, output = "measure")
	expect_lt(max(abs(res - mea_oqo)), tol)
})

test_that("chain_link works on a single series and without cp", {
	res <- chain_link(vo_ao[, "A"], method = "ao")
	expect_s3_class(res, "ts")
	expect_lt(max(abs(res - idx_ao[, "A"])), tol)
	expect_error(chain_link(vo_ao, method = "ao", output = "measure"), "cp")
	expect_error(chain_link(vo_ao, method = "pq"), "should be one of")
})

test_that("annual_chain matches example 8.6 (annual part)", {
	res <- annual_chain(vo_y, base_year = 2010)
	expect_equal(start(res), c(2010, 1))
	expect_lt(max(abs(res - idx_y)), tol)
})

test_that("chain_laspeyres matches example 8.6", {
	res <- chain_laspeyres(data8.2cp, data8.2ep, method = "ao", base_year = 2010)
	expect_equal(colnames(res), c("A", "B", "Total"))
	expect_lt(max(abs(as.matrix(res) - as.matrix(idx_ao))), tol)
	res <- chain_laspeyres(data8.2cp, data8.2ep, method = "ao", base_year = 2010,
						   output = "measure")
	expect_lt(max(abs(as.matrix(res) - as.matrix(mea_ao))), tol)
})
