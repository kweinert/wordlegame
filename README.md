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


