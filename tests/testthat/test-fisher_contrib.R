random_data <- function(f = 4, n = 12, k = 4, seed = 2) {
    set.seed(seed)
    mk <- function(m) {
        m <- matrix(m, n, k, dimnames = list(NULL, LETTERS[seq_len(k)]))
        ts(m, start = c(2010, 1), frequency = f)
    }
    list(cp = mk(exp(stats::rnorm(n * k, 5, 0.3))), pi = mk(100 * exp(stats::rnorm(n * k, 0.01, 0.03))))
}

for (f in c(1, 4, 12)) {
    local({
        f <- f
        test_that(paste("fisher_contrib adds up exactly, f =", f), {
            d <- random_data(f = f, n = 3 * f + 2)
            res <- fisher_contrib(d$cp, d$pi, extra = c("total", "residual"))
            expect_equal(colnames(res), c("A", "B", "C", "D", "Total", "Residual"))
            expect_true(all(is.na(res[1, ])))
            expect_lt(max(abs(res[-1, "Residual"])), 1e-10)
            # the total is the percent change of the Fisher index of the package
            fis <- fisher(d$cp, d$pi, output = "index", reference_freq = f)
            expect_equal(as.numeric(res[-1, "Total"]), as.numeric(100 * (fis / 100 - 1)))
        })
    })
}

test_that("fisher_contrib is the equation (32) of the manual", {
    d <- random_data(k = 3)
    res <- fisher_contrib(d$cp, d$pi)
    fis <- fisher(d$cp, d$pi, output = "index", reference_freq = 4)
    cp <- matrix(as.numeric(d$cp), 12, 3)
    r <- matrix(as.numeric(d$pi), 12, 3) / 100
    expected <- matrix(NA_real_, 12, 3)
    for (t in 2:12) {
        z1 <- sum(cp[t, ])
        z0 <- sum(cp[t - 1, ])
        fq <- as.numeric(fis)[t - 1] / 100 # Fisher index of the package
        denom <- z1 + fq * sum(cp[t - 1, ] * r[t, ])
        for (x in 1:3) {
            expected[t, x] <- 100 *
                (z1 / z0 * (cp[t, x] / r[t, x] - cp[t - 1, x]) + fq * (cp[t, x] - cp[t - 1, x] * r[t, x])) /
                denom
        }
    }
    expect_equal(as.numeric(as.matrix(res)), as.numeric(expected))
    # and the contributions add up to the percent change of the Fisher index
    expect_equal(as.numeric(rowSums(as.matrix(res))[-1]), as.numeric(fis) - 100)
})

test_that("fisher_contrib matches the Fisher index of example 8.4", {
    res <- fisher_contrib(imf_cp, pi_py2pp(imf_pi), extra = c("total", "residual"))
    res <- window(res, start = c(2011, 1))
    expect_lt(max(abs(res[, "Residual"])), 1e-10)
    # Fisher volume index of the example 8.4 (percent change)
    exp_total <- c(
        0.73654,
        -0.07769,
        0.07835,
        0.33142,
        0.17546,
        0.06025,
        0.58254,
        1.06762,
        0.75624,
        0.53763,
        -0.06298,
        -0.17498
    )
    expect_lt(max(abs(as.numeric(res[, "Total"]) - exp_total)), 1e-3)
})

test_that("fisher_contrib with one component and with a total component", {
    d <- random_data(k = 1)
    res <- fisher_contrib(d$cp, d$pi)
    expect_s3_class(res, "ts")
    fis <- fisher(d$cp, d$pi, output = "index", reference_freq = 4)
    expect_equal(as.numeric(res[-1]), as.numeric(100 * (fis / 100 - 1)))
    expect_error(fisher_contrib(1:3, d$pi), "must be a time series")
})

test_that("the equation (32) as printed in the manual does not add up", {
    d <- random_data(k = 3)
    fis <- fisher(d$cp, d$pi, output = "index", reference_freq = 4)
    cp <- matrix(as.numeric(d$cp), 12, 3)
    r <- matrix(as.numeric(d$pi), 12, 3) / 100
    gap <- numeric(0)
    for (t in 2:12) {
        z1 <- sum(cp[t, ])
        z0 <- sum(cp[t - 1, ])
        fq <- as.numeric(fis)[t - 1] / 100
        denom <- z1 + fq * sum(cp[t - 1, ] * r[t, ])
        printed <- 100 * (z0 / z1 * (cp[t, ] / r[t, ] - cp[t - 1, ]) + fq * (cp[t, ] - cp[t - 1, ] / r[t, ])) / denom
        gap <- c(gap, sum(printed) - (as.numeric(fis)[t - 1] - 100))
    }
    expect_gt(max(abs(gap)), 1e-3)
})
