#' Transforms Character To Numeric
#'
#' Takes a vector of character (each with 5 letters) and transforms it to a
#' numeric vector of length 26*5=130. 
#'
#' E.g. 3rd letter is m (13th letter in the alphabet), then the 26*2+13=65th position of
#' the answer is 1.
#'
#' @param wl	 character, each 5 letters long, all lowercase letters
#' @return numeric
#' @export
embed_wordlist <- function(wl) {
	one_word <- function(w) {
		ones <- as.vector(sapply(w, utf8ToInt)-96)
		ret <- (seq_along(w)-1)*26+ones
		return(ret)
	}
	ones <- lapply(strsplit(wl, ""), one_word)
	ret <- matrix(0, nrow=length(wl), ncol=26*5)
	rownames(ret) <- wl
	for (i in seq_along(ones)) ret[i, ones[[i]]] <- 1
	return(ret)
}

