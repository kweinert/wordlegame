#' Compare methods
#'
#' 
#' @param kn	S3 object of class 'wordle_knowledge'
#' @return data.frame
#' @export
compare_methods <- function(n_runs=50) {
	m <- c("prob", "contrasts", "reply_entropy") #, "full_entropy")
	kn <- knowledge("en")
	one_method <- function(m) {
		tm <- system.time(ans <- distr_wordle(n_runs, knowledge=kn, 
			sample_size=50,  
			method=m,
			verbose=FALSE
		))
		ret <- data.frame(
			method=m,
			n_runs=n_runs,
			duration=as.numeric(tm)[1],
			avg_guess=mean(ans, na.rm=TRUE),
			fails=sum(is.na(ans)),
			stringsAsFactors=FALSE
		)
		return(ret)
	}
	ans <- do.call(rbind, lapply(m, one_method))
	return(ans)
}