#' Suggest Guess
#'
#' Given current knowledge (including number of guesses and previous guesses/replies),
#' suggest some words for the next guess.
#'
#' Complexity of computation grows quadratically with the sample_size parameter.
#'
#' @param knowledge object of S3 class 'wordle_knowledge'
#' @param num_guess numeric, 1..6
#' @param fitting_only	logical, use only fitting words as candidates (TRUE) or 
#'                      use single-letter-only words (FALSE) or 
#'						decide by num_guess (NA, default)
#' @param method	character, either one of "entropy" (default), "contrasts", or "reductions"
#' @param sample_size numeric (default=30), maximum number of candidates to consider
#' @param with_scores	logical, return words only (FALSE, default), or include scores
#' @param verbose	logical, print out diagnostic messages (default TRUE)
#' @return updated knowledge object of S3 class 'wordle_knowledge'
#' @export
suggest_guess <- function(
	knowledge, num_guess, n=1, fitting_only=NA,
	method=c("prob", "entropy", "contrasts", "reductions"),
	sample_size=500, 
	with_scores=FALSE,
	verbose=TRUE) {
	if(length(method)>1) method <- method[2]

	# last guess
	if(num_guess==6) {
		cand <- knowledge$fitting_only
		if(verbose) message("  ", length(cand), " fits: ", paste(head(cand, 10), collapse=", "))
		return(sample(cand, min(c(n, length(cand)))))
	}
		
	# first guess
	if(num_guess==1) {
		scores <- if(knowledge$lang=="en") 
			c(
				"skran", "skean", "togae", "spean", "shone", "etnas", "spire", 
				"auris", "tines", "cries", "sorda", "ables", "safer", "maise", 
				"lyres", "teals", "rones"
			)
		else if(knowledge$lang=="de") 
			c(
				"blies", "loser", "keilt", "tiers", "taues", "route", "laser", 
				"staue", "sinke", "reimt", "parte", "salbe", "senkt", "lasur", 
				"samen", "gares"
			)
		ret <- sample(scores, min(c(n,length(scores))))
		return(ret)
	} 
	
	# allowed & candidates
	allowed <- knowledge$fitting_only
	n_allowed <- length(allowed)
	if(!is.na(sample_size) && n_allowed>sample_size) 
		allowed <- sample(allowed, sample_size)
	if(verbose) message(
		"  ", n_allowed, " fits: ", 
		paste(sample(allowed, min(c(length(allowed),10))), collapse=", ")
	)
	if(length(allowed)==0) return(NA) # give up
	if(length(allowed)==1) return(allowed) # solution found

	# candidates for the solution: only single letters, only fitting
	cand <- if(is.na(fitting_only)) 
		if(num_guess==5 || length(allowed)>100) {
			if(verbose) message("  using only fitting words as candidates.")
			allowed
		} else {
			if(verbose) message("  using all single-lettered words as candidates.")
			knowledge$single_only
		}
	else if(!fitting_only)
		knowledge$single_only
	else
		allowed
	if(!is.na(sample_size) && length(cand)>sample_size) 
			cand <- sample(cand, sample_size) # and at most sample_size

	if(method=="prob") {
		# most likely green answer
		prob <- colSums(embed_wordlist(allowed))
		scores <- knowledge$wl_num[cand,] %*% prob
		scores <- setNames(as.vector(scores), rownames(scores))	
	} else if(method=="reductions") {
		# average reduction
		estimate_reduction <- function(w, cand, kn) {
			patterns <- sapply(cand, function(chosen) reply(guess=w, ans=chosen))
			one_pattern <- function(p) {
				imagine <- learn(knowledge=kn, guess=w, reply=p)
				return(1-length(imagine$fitting_only)/length(kn$fitting_only))
			}
			reductions <- sapply(patterns, one_pattern)
			return(mean(reductions, na.rm=TRUE))
		}
		scores <- sapply(cand, estimate_reduction, cand=allowed, kn=knowledge)	
	} else if(method=="entropy") {
		# estimate entropy
		estimate_entropy <- function(w, cand) {
			patterns <- sapply(cand, function(chosen) reply(guess=w, ans=chosen))
			prob <- as.vector(table(patterns))
			prob <- prob / sum(prob)
			entr <- sum(-prob * log2(prob))
			return(entr)
		}
		scores <- sapply(cand, estimate_entropy, cand=allowed)
	} else if(method=="contrasts") {
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
		ctr <- expand.grid(w1=allowed, w2=allowed, stringsAsFactors=FALSE)
		ctr <- ctr[ctr$w1!=ctr$w2,]
		ctr <- mapply(embed_contrast, ctr$w1, ctr$w2)
		ctr <- rowSums(ctr)
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

