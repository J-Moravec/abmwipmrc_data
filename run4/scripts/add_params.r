#!/usr/bin/env Rscript

library("data.table")
library("magrittr")


main = function(statpath, parampath, outputpath){
    stats = fread(statpath, header=TRUE, sep=",")
    params = fread(parampath, header=TRUE, sep=" ")

    merged = merge(stats, params, by="run")
    attr(merged, "stats") = names(stats)[-1]
    attr(merged, "params") = names(params)[-1]

    fwrite(merged, outputpath, sep=",")
    }


if(!interactive()){
    args = commandArgs(TRUE)
    main(args[1], args[2], args[3])
    }
