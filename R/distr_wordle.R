#' Simulate n Wordle Games
#'
#' Given a knowledge object, the function simulates several Wordle games. It is a wrapper to
#' sim_wordle.
#'
#' @param n	numeric, number of games to play
#' @param knowledge object of S3 class 'wordle_knowledge'
#' @return numeric, vector of numbers of guesses needed (or NA if not guessed in 6 or less tries)
#' @export
distr_wordle <- function(n, knowledge, ...) {
	dots <- list(...)
	dots[["knowledge"]] <- knowledge
	ans <- replicate(n, do.call(sim_wordle, dots))
	# ans <- table(ans, useNA="always")
	return(ans)
}
