#' Incorporate Wordle's Feedback
#'
#' Given current knowledge, guess and Wordle's reply, this function updates the
#' knowledge object.
#'
#' @param knowledge object of S3 class 'wordle_knowledge'
#' @param guess character, the guess
#' @param reply character, wordle's reply (5 characters out of 'f', 't', 'p')
#' @return updated knowledge object of S3 class 'wordle_knowledge'
#' @export
learn <- function(knowledge, guess, reply) {
	guess <- strsplit(guess, "")[[1]]
	reply <- strsplit(reply, "")[[1]]
	
	# update A & rhs
	for (i in 1:5) {
		if(reply[i]=="t") {
			pos <- (i-1)*26+utf8ToInt(guess[i])-96
			new_row <- rep(0, 5*26)
			new_row[pos] <- -1
			knowledge$A <- rbind(knowledge$A, new_row)
			knowledge$rhs <- c(knowledge$rhs, -1) 
			new_row[pos] <- 1
			knowledge$A <- rbind(knowledge$A, new_row)
			knowledge$rhs <- c(knowledge$rhs, 1)
		} else if(reply[i]=="f") {
			idx <- setdiff(which(guess==guess[i]),i) # where else 
			if(length(idx)==0) { # nowhere, disallow letter everywhere
				pos <- (0:4)*26+utf8ToInt(guess[i])-96
				new_row <- rep(0, 5*26)
				new_row[pos] <- 1
				knowledge$A <- rbind(knowledge$A, new_row)
				knowledge$rhs <- c(knowledge$rhs, 0)
			} else if(any(reply[idx]!="f")) { # somewhere, disallow letter only on spot
				pos <- (i-1)*26+utf8ToInt(guess[i])-96 
				new_row <- rep(0, 5*26)
				new_row[pos] <- 1
				knowledge$A <- rbind(knowledge$A, new_row)
				knowledge$rhs <- c(knowledge$rhs, 0)
			}
		} else if(reply[i]=="p") {
			pos <- (i-1)*26+utf8ToInt(guess[i])-96
			new_row <- rep(0, 5*26)
			new_row[pos] <- 1
			knowledge$A <- rbind(knowledge$A, new_row)
			knowledge$rhs <- c(knowledge$rhs, 0)
			pos <- setdiff(0:4,i-1)*26+utf8ToInt(guess[i])-96
			new_row <- rep(0, 5*26)
			new_row[pos] <- -1
			knowledge$A <- rbind(knowledge$A, new_row)
			knowledge$rhs <- c(knowledge$rhs, -1)
		}
	}
	rownames(knowledge$A) <- NULL
	
	# update fitting_only
	cond_applied <- knowledge$wl_num %*% t(knowledge$A)
	cond_fullfilled <- apply(cond_applied,1,function(y) all(y<=knowledge$rhs))
	idx <- which(cond_fullfilled)
	knowledge$fitting_only <- rownames(knowledge$wl_num)[idx]
	
	return(knowledge)
}
