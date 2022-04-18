#' Search Bing for Words
#'
#' This functions searches bing for the provided words and returns the number of search
#' results for each word.
#'
#' @param fits	character, words to lookup
#' @return numeric, vector of numbers of search results
#' @references https://github.com/KewKalustian/wordle_cracker/blob/master/script.R
#' @export
popularity <- function(fits) {
	x <- sprintf("https://www.bing.com/search?q=%s", fits) |> 
		lapply(rvest::read_html) |>
		lapply(rvest::html_nodes, css=".sb_count") |>
		lapply(rvest::html_text) |>
		lapply(function(s) strsplit(s, " ")[[1]][[1]])
	x <- gsub("\\.", "", x) |>
		as.numeric()
	names(x) <- fits
	return(x)
}
