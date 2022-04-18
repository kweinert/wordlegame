#' Construct Knowledge Object
#'
#' Loads wordlist of admissable words. 
#'
#' @param lang, character 'en' (default) or 'de'
#' @return knowledge object of S3 class 'wordle_knowledge'
#' @export
#' @references en: https://raw.githubusercontent.com/tabatkins/wordle-list/main/words
#' @references de: https://raw.githubusercontent.com/SchulzKilian/GermanWordle/main/germandict.txt
knowledge <- function(lang=c("en", "de", "en_short")) {
	if(length(lang)>1) lang <- lang[1]
	fn <- system.file(paste0("wordlists/wl_", substring(lang,1,2), ".txt"), package="wordle")
	wl <- suppressWarnings(readLines(fn))
	if(grepl("_short$", lang)) wl <- sample(wl, 500)
	wl_num <- embed_wordlist(wl)
	agg_letter <- diag(26)
	agg_letter <- rbind(agg_letter, agg_letter, agg_letter, agg_letter, agg_letter)
	agg_letter <- wl_num %*% agg_letter
	single_only <- apply(agg_letter, 1, function(x) all(x<=1))
	single_only <- names(single_only[single_only])
	fitting_only <- rownames(wl_num)
	obj <- list(
		wl_num=wl_num, single_only=single_only, # independent from guesses
		fitting_only=fitting_only, # reduces with guesses
		A=NULL, rhs=NULL # conditions; increase with guesses
	)
	class(obj) <- "wordle_knowledge"
	return(obj)
}
