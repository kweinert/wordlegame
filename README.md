# Play & Analyse Wordle Games

This repository contains an R package with functions that make playing [Wordle](https://www.nytimes.com/games/wordle/index.html) easy.

English and German Wordle Games are supported.

## Installation

You will need [R](https://www.r-project.org/). To install this package, run the following code at the console:

```
install.packages("remotes")
library(remotes)
install_github("kweinert/wordlegame")
```

That's it! If you installed the package `tinytest`, you can optionally check if the installation worked:

```
library(tinytest)
test_package("wordlegame")
```

## Usage

To use the tool while playing Wordle, the following steps are necessary. First, you set up a "knowledge model" in which all permissible words are stored and later the findings from your guessing attempts are also stored:

```
library(wordlegame)
kn <- knowledge("en") # 'de' is also supported
```

Now you can use this object to output one or more suggestions for your first guess attempt. For this purpose, there is the function `suggest_guess`, which takes as arguments the knowledge object, the current round (1..6) and the number of words to be output:

```
suggest_guess(kn, num_guess=1, n=10)
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
```

And so on.


