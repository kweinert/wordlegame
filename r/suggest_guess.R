#' Suggest Guess
#'
#' Given current knowledge (including number of guesses and previous guesses/replies),
#' suggest some words for the next guess.
#'
#' Complexity of computation grows quadratically with the sample_size parameter.
#'
#' @param knowledge object of S3 class 'wordle_knowledge'
#' @param num_guess numeric, 1..6
#' @param sample_size numeric (default=30), maximum number of candidates to consider
#' @param method	character, either one of "entropy" (default), "contrasts", or "reductions"
#' @param verbose	logical, print out diagnostic messages (default TRUE)
#' @return updated knowledge object of S3 class 'wordle_knowledge'
#' @export
suggest_guess <- function(
	knowledge, num_guess, n=1, sample_size=30, 
	method=c("entropy", "contrasts", "reductions"),
	verbose=TRUE, with_scores=FALSE) {
	if(length(method)>1) method <- method[2]
			
	# contrast: pairwise non-intersecting letters
	embed_contrast <- function(w1, w2) {
		w1 <- strsplit(w1, "")[[1]]
		w2 <- strsplit(w2, "")[[1]]
		ctr <- setdiff(c(w1, w2), intersect(w1, w2))
		ret <- rep(0, 26*5)
		if(length(ctr)>0) {
			ones <- as.vector(sapply(ctr, utf8ToInt)-96)
			ones <- sapply(ones, function(x) (0:4)*26+x)
			dim(ones) <- NULL
			ret[ones] <- 1
		}
		return(ret)
	}

	estimate_entropy <- function(w, cand) {
		patterns <- sapply(cand, function(chosen) reply(guess=w, ans=chosen))
		prob <- as.vector(table(patterns))
		prob <- prob / sum(prob)
		entr <- sum(-prob * log2(prob))
		return(entr)
	}

	estimate_reduction <- function(w, cand, kn) {
		patterns <- sapply(cand, function(chosen) reply(guess=w, ans=chosen))
		one_pattern <- function(p) {
			imagine <- learn(knowledge=kn, guess=w, reply=p)
			return(1-length(imagine$fitting_only)/length(kn$fitting_only))
		}
		reductions <- sapply(patterns, one_pattern)
		return(mean(reductions, na.rm=TRUE))
	}

	# last guess
	if(num_guess==6) {
		cand <- knowledge$fitting_only
		if(verbose) message("  ", length(cand), " fits: ", paste(head(cand, 10), collapse=", "))
		return(sample(cand, min(c(n, length(cand)))))
	}
	
	# 0 or 1 fitting only: trivial cases
	if(length(knowledge$fitting_only)==0) return(NA) # give up
	if(length(knowledge$fitting_only)==1) {
		if(verbose) message("  1 fit: ", knowledge$fitting_only)
		return(knowledge$fitting_only) # solution found
	}
	
	# first guess
	# if(num_guess==1) {
		# scores <- c(
			# "skran", "skean", "togae", "spean", "shone", "etnas", "spire", 
			# "auris", "tines", "cries", "sorda", "ables", "safer", "maise", 
			# "lyres", "teals", "rones"
		# )
		# scores <- sample(scores, max(c(n,3)))
		# scores <- setNames(rep(0.95, length(scores)), scores)
	# } else 
	if(method=="reductions") {
		# average reduction
		allowed <- knowledge$fitting_only
		if(length(allowed)>sample_size) allowed <- sample(allowed, sample_size)
		cand <- knowledge$fitting_only
		if(verbose) message(
			"  ", length(cand), " fits: ", 
			paste(
				sample(cand, min(c(length(cand),10))), collapse=", "
			)
		)
		if(length(cand)>sample_size) cand <- sample(cand, sample_size) 
		scores <- sapply(cand, estimate_reduction, cand=allowed, kn=knowledge)	
	} else if(method=="entropy") {
		# estimate entropy
		allowed <- knowledge$fitting_only
		if(length(allowed)>sample_size) allowed <- sample(allowed, sample_size)
		# cand <- if(num_guess<5) knowledge$single_only else knowledge$fitting_only
		cand <- knowledge$fitting_only
		if(verbose) message(
			"  ", length(knowledge$fitting_only), " fits: ", 
			paste(
				sample(knowledge$fitting_only, min(c(length(knowledge$fitting_only),10))), collapse=", "
			)
		)
		if(length(cand)>sample_size) cand <- sample(cand, sample_size) # and at most sample_size
		scores <- sapply(cand, estimate_entropy, cand=allowed)
	} else if(method=="contrasts") {
		# candidates for the solution: only single letters, only fitting
		cand <- intersect(knowledge$fitting_only, knowledge$single_only)
		if(length(cand)==0) cand <- knowledge$fitting_only # but not zero
		if(verbose) message(
			"  ", length(knowledge$fitting_only), " fits: ", 
			paste(
				sample(knowledge$fitting_only, min(c(length(knowledge$fitting_only),10))), collapse=", "
			)
		)
		if(length(cand)==1) return(cand) # at least two
		if(length(cand)>sample_size) cand <- sample(cand, sample_size) # and at most sample_size
	
		# calculate contrasts
		ctr <- expand.grid(w1=cand, w2=cand, stringsAsFactors=FALSE)
		ctr <- ctr[ctr$w1!=ctr$w2,]
		ctr <- mapply(embed_contrast, ctr$w1, ctr$w2)
		ctr <- rowSums(ctr)
		
		
		# guess is one of the single-letter-only words with high contrast
		cand <- if(num_guess<5) knowledge$single_only else knowledge$fitting_only
		scores <- knowledge$wl_num[cand,] %*% ctr
		scores <- setNames(as.vector(scores), rownames(scores))
	}
	
	# pick
	scores <- sort(scores)
	if(!with_scores) {
		scores <- tail(names(scores), max(c(n,3)))
		ret <- sample(scores, min(c(n, length(scores))))
	} else ret <- scores
	return(ret)
}

