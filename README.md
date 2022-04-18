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



