#' Compare methods
#'
#' 
#' @param kn	S3 object of class 'wordle_knowledge'
#' @return data.frame
#' @export
compare_methods <- function(kn) {
	m <- c("entropy", "contrasts", "reductions")
	one_method <- function(m) suggest_guess(
		kn, num_guess=1, 
		sample_size=500, n=500, 
		method=m,
		verbose=FALSE,
		with_scores=TRUE
	)
	x <- lapply(m, one_method)
	names(x) <- m
	idx <- names(x[[1]])
	x <- data.frame(entr=x$entropy[idx], contr=x$contrasts[idx], redu=x$reductions[idx])
	browser()
}