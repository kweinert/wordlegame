reply2 <- function(w, allowed) {
	prob <- repm[w,allowed] |> 
		table() |>
		as.vector()
	prob <- prob / sum(prob)
	entr <- -sum(prob*log2(prob))
	return(entr)
}
