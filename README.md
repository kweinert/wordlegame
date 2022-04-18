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

## Some Tricks

### Popularity

Many words from the word lists are rare words. It is plausible to assume that these are unlikely to be the solution. To estimate the popularity of words, the function `popularity` can be used:

```
popularity(c("fubar", "filar", "friar", "iftar", "flair"))
#   fubar    filar    friar    iftar    flair 
# 1216001   434000  3212094  2630000 13500000 
```

Here we can see that 'flair' is by far the most popular word and thus a good candidate.

The idea for the `popularity` function came from [Kework K. Kalustian](https://github.com/KewKalustian/wordle_cracker/blob/master/script.R) -- kudos.

### Non-Strict Candidates

Sometimes the guessing attempts reduce the permissible words to relatively few words that are at the same time quite similar. Here is an example:

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

The parameter `fitting_only` is only evaluated in rounds 2 to 5. If it is not explicitly set, then a heuristic is applied: if there are less than 100 permissible words, non-striked candidates are also included in the consideration, otherwise not.

## Evaluating Strategies By Simulations

The most fun is the search for an algorithm that quickly and reliably finds a solution to the puzzles. In my search for a strategy, I came up with four approaches:

- *Probability*: Take the words currently allowed and determine which letter/position combinations occur particularly frequently. Then find a word that best fits this probability distribution.
- *Contrasts*: Take the currently permissible words and form all two-way combinations from them. For each combination of two, determine the letters that appear in only one of the two words. These so-called contrast letters are good for separating the two words. Now find a word that contains as many contrast letters as possible.
- *Answer entropy*: For one word $w$ and the currently allowed words, determine the answer that Wordle would return. These answers form a probability distribution on the space of possible return values, given the word $w$. Calculate the entropy of these distributions for each admissible word $w$ and take the word with the highest entropy.
- *Full entropy*: For each word $w$ and the currently admissible words, determine the answer that Wordle would return. Now additionally determine the allowed words for each possible Wordle pattern. These two pieces of information, frequency of the answer pattern and admissible words, form a probability distribution on the Cartesian product of the answer patterns and the admissible words, given the word $w$. Calculate the entropy of these distributions for each admissible word $w$ and take the word with the highest entropy.

As can be seen: the strategy can become arbitrarily complicated. Unfortunately, so can the computational time: the above approaches would take -- for my patience and the computational power available to me -- too long. Therefore, I limited the number of allowed words to a maximum of 50 (parameter `sample_size` in `suggest_guess`.). 

To see how good the strategies are, there are some help functions in the package. With `sim_wordle` a game is simulated. With `distr_wordle` several games are simulated. The function `compare_methods` calls `distr_wordle` for the above methods and returns the result as `data.frame`.

Here is the result of 200 simulations for each method except 'full_entropy', which takes too long.

|method        | n_runs| duration| avg_guess| fails|
|:-------------|------:|--------:|---------:|-----:|
|prob          |    200|    53.87|  4.431818|    24|
|contrasts     |    200|    88.15|  4.699422|    27|
|reply_entropy |    200|    66.68|  4.469613|    19|

In my opinion there is much room for improvement. Unfortunately, I no longer have the time.

To invent your own strategies, you need to fork the repository and change the function `suggest_guess`.
