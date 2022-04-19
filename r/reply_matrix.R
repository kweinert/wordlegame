#' Build Reply Matrix
#'
#' 
#' @param kn	S3 object of class 'wordle_knowledge'
#' @param ncl	numeric, number of cores. Default 1, greater values start parallel computing.
#' @return matrix
#' @export
reply_matrix <- function(kn, ncl=1) {
	wl <- rownames(kn$wl_num)
	n_wl <- length(wl)
	ans <- matrix(NA, ncol=n_wl, nrow=n_wl)
	dimnames(ans) <- list(wl, wl)
	if(ncl==1)
		for (w in wl) ans[w,] <- sapply(wl, function(x) reply(guess=w, ans=x), USE.NAMES=FALSE)
	else {
		cl <- parallel::makeCluster(ncl)
		for (w in wl) 
			ans[w,] <- parallel::parSapply(
				cl, wl, function(x) reply(guess=w, ans=x), USE.NAMES=FALSE
			)
		parallel::stopCluster(cl)
	}
	return(ans)
}