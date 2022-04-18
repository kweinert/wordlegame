library(tinytest)
chosen <- "colls"
chosen_num <- t(embed_wordlist(chosen))
kn <- knowledge("en")
kn <- learn(kn, "gools", "ftftt")
expect_true(all(kn$A %*% chosen_num <= kn$rhs))

