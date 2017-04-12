#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

args = commandArgs(trailingOnly=TRUE)
stopifnot(length(args) == 1)

names_c <- readLines(args[1])
funtab <- grep('^\\{".+\\},$', names_c, value=T)
funtab <- sub(",$", "", funtab)
funtab <- gsub("\t", "", funtab)

funtab <-
    read_csv(
        paste0(funtab, collapse="\n"),
        col_name=c("print_name", "c_entry", "offset", "eval", "arity", "pp_kind", "precedence", "rightassoc"),
        trim_ws=T,
        quote=NULL) %>%
    tbl_df()

funtab <-
    funtab %>%
    mutate(
        print_name=substr(print_name, 3, nchar(print_name)-1),
        signature="",
        Z=eval %% 10,
        Y=(eval %/% 10) %% 10,
        X=(eval %/% 100) %% 10,
        pp_kind=substr(pp_kind, 2, nchar(pp_kind)),
        rightassoc=substr(rightassoc, 1, nchar(rightassoc)-2)) %>%
    select(print_name, c_entry, offset, eval, arity, signature, everything())

specials <- funtab %>% filter(Z==0)

specials %>% knitr::kable()
