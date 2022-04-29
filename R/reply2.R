reply2 <- function(w, allowed) {
	prob <- repm[w,allowed] 
	prob <- table(prob)
	prob <- as.vector(prob)
	prob <- prob / sum(prob)
	entr <- -sum(prob*log2(prob))
	return(entr)
}
