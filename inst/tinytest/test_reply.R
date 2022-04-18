library(tinytest)
expect_equal(reply(guess="cheer", ans="close"),"tfpff")
expect_equal(reply(guess="cocks", ans="close"), "tpffp")
expect_equal(reply(guess="leave", ans="close"), "pffft")
expect_equal(reply(guess="unfit", ans="ulmin"), "tpftf")
expect_equal(reply(guess="menge", ans="genom"), "pttpf")

