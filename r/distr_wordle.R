#' Simulate n Wordle Games
#'
#' Given a knowledge object, the function simulates several Wordle games. It is a wrapper to
#' sim_wordle.
#'
#' @param n	numeric, number of games to play
#' @param knowledge object of S3 class 'wordle_knowledge'
#' @return numeric, vector of numbers of guesses needed (or NA if not guessed in 6 or less tries)
#' @export
distr_wordle <- function(n, knowledge) {
	
	ans <- replicate(n, sim_wordle(knowledge, verbose=FALSE))
	# ans <- table(ans, useNA="always")
	return(ans)
}
