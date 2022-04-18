#' Emulates Wordle's Feedback
#'
#' Given guess and actual answer, this function computes a character string of length 5.
#' 't' corresponds to green, 'f' to grey, and 'p' to yellow.
#' 
#' @param guess	 character, the guess to check
#' @param chosen character, the correct answer
#' @return character
#' @export
#' @references https://stackoverflow.com/a/71326031/216064
reply <- memoise::memoise(function(guess, ans) {
	guess <- strsplit(guess, "")[[1]]
	ans <- strsplit(ans, "")[[1]]
	ret <- rep("f", 5)
	remaining <- ans
	for (i in 1:5) {
		if(guess[i]==ans[i]) {
			remaining[i] <- ""
			ret[i] <- "t"
		} 
	}
	remaining <- remaining[remaining!=""]
	for (i in 1:5) {
		if(guess[i] %in% remaining && guess[i]!=ans[i]) {
			idx <- which(remaining==guess[i])[1]
			remaining <- remaining[-idx]
			ret[i] <- "p"
		}
	}
	return(paste(ret, collapse=""))
})

