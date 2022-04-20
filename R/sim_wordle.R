#' Simulate one Wordle Game
#'
#' Given a knowledge object, the function simulates one Wordle game.
#'
#' @param knowledge object of S3 class 'wordle_knowledge'
#' @param verbose	logical, print out diagnostic messages (default TRUE)
#' @return numeric, number of guesses needed (or NA if not guessed in 6 or less tries)
#' @export
sim_wordle <- function(knowledge, ...) {
	dots <- list(...)
	verbose <- if("verbose" %in% names(dots)) dots[["verbose"]] else TRUE
	dots[["knowledge"]] <- knowledge
	
	chosen <- sample(rownames(knowledge$wl_num),1)
	i <- 1
	repeat {
		dots[["num_guess"]] <- i
		guess <- do.call(suggest_guess, dots)
		if(is.na(guess)) {
			if(verbose) message("giving up...")
			break
		}
		feedb <- reply(guess=guess, ans=chosen)
		if(verbose) message(i, ": ", guess, " - ", feedb)
		success <- feedb=="ttttt"
		if(success) {
			if(verbose) message("success")
			break
		}
		dots[["knowledge"]] <- learn(knowledge=dots[["knowledge"]], guess=guess, reply=feedb)
		i <- i + 1
		if(i>6) break
	}
	if(!success) {
		if(verbose) message("failed to guess: ", chosen)
		return(NA)
	} else return(i)
}

