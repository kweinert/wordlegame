# Play & Analyse Wordle Games

This repository contains an R package with functions that make playing Wordle easy.

[English](https://www.nytimes.com/games/wordle/index.html) and [German](https://wordle.at/) Wordle Games are supported.

## Installation

You will need the statistical software environment R. See [here](https://www.r-project.org/) for installation notes. 

To install this github repository, run the following code at the R console:

```
install.packages("remotes")
library(remotes)
install_github("kweinert/wordlegame")
```

That's basically it! If you installed the package `tinytest`, you can optionally check if the installation worked:

```
library(tinytest)
test_package("wordlegame")
```

## Play Wordle

To use the tool while playing Wordle, the following steps are necessary. First, you set up a "knowledge model" in which all permissible words are stored and later the findings from your guessing attempts are also stored:

```
library(wordlegame)
kn <- knowledge("en") # 'de' is also supported
```

The wordlists of permissible words are taken from github ([en](https://raw.githubusercontent.com/tabatkins/wordle-list/main/words), [de](https://raw.githubusercontent.com/SchulzKilian/GermanWordle/main/germandict.txt)).

Now you can use this object to output one or more suggestions for your first guess attempt. For this purpose, there is the function `suggest_guess`, which takes as arguments the knowledge object, the current round (between 1 and 6) and the number of words to be output:

```
suggest_guess(kn, num_guess=1, n=10)
#[1] "ables" "spire" "rones" "maise" "skean" "sorda" "cries" "tines" "togae"
#[10] "safer"
```

Wordle gives you feedback on your guess attempt. This feedback can be passed on to the knowledge object. Wordle feedback uses colours that need to be translated into letter codes. There are three codes:

- green means: the letter is in the correct position. This is to be coded as "t" (true).
- beige means: the letter occurs, but in a different position. This is to be coded as "p" (position).
- grey means: the letter does not occur. This is to be coded as "f" (false).
	
So if your guess attempt is e.g. "safer" and the feedback is "grey, beige, beige, green, beige", then this translates into:

```
kn <- learn(kn, "safer", "fpptf")
```

and you can use `suggest_guess` again to get new suggestions:

```
suggest_guess(kn, num_guess=2, n=10)
# 5 fits: fubar, iftar, friar, filar, flair
#[1] "filar" "flair" "friar" "iftar" "fubar"
```

And so on.

# Some Tricks

## Popularity

Many words from the word lists are rare words. It is plausible to assume that these are unlikely to be the solution. To estimate the popularity of words, the function `popularity` can be used:

```
popularity(c("fubar", "filar", "friar", "iftar", "flair"))
#   fubar    filar    friar    iftar    flair 
# 1216001   434000  3212094  2630000 13500000 
```

Here we can see that 'flair' is by far the most popular word and thus a good candidate.

The idea for the `popularity` function came from [Kework K. Kalustian](https://github.com/KewKalustian/wordle_cracker/blob/master/script.R) -- kudos.

## Non-Strict Candidates

Manchmal reduzieren die Rateversuche die zulässigen Worte auf relativ wenige, gleichzeitig recht ähnliche Worte. Hier ein Beispiel:

```
kn <- knowledge("en")
kn <- learn(kn, "safer", "fffpf")
kn <- learn(kn, "glide", "ttfft")
```

In this example, after two guesses, only 6 words are possible: glute, glume, gloze, 
glebe, globe, glove. Now there is the possibility to choose one of these words and rely on luck. Or we can strategically choose a word that, while certainly not the solution, effectively limits the words allowed. The function `suggest_guess` has the parameter `fitting_only`. If this is `FALSE`, then non-permissible words are also suggested. This allows the second strategy to be implemented:

```
suggest_guess(kn, num_guess=3, n=10, fitting_only=FALSE)
# [1] "cobza" "bloat" "vocab" "above" "tabun" "novum" "combs" "baton" "embox"
# [10] "bokeh"
kn <- learn(kn, "above", "fptft")
# 1 fits: globe
```








