#!/usr/bin/env Rscript

get_param_names = function(text){
    line = text[1]
    parsed = c("run", unlist(strsplit(line, "[\t,]")))
    len = length(parsed)
    namepos = (1:(len/2))*2-1
    names = parsed[namepos]
    return(names)
    }


parse_params = function(text){
    len = length(text)
    parsed = strsplit(text, "[\t,]")
    table = matrix(unlist(parsed), nrow=len, byrow=TRUE)
    col = ncol(table)
    colpos = seq(1, col, 2)
    data = table[,colpos]
    data = as.data.frame(data, stringsAsFactors=FALSE)
    data = sapply(data, as.numeric)
    return(data)
    }


read_params = function(filepath){
    text = readLines(filepath)
    names = get_param_names(text)
    data = parse_params(text)
    colnames(data) = names
    return(data)
    }


save_params = function(data, filepath){
    write.table(data, file=filepath, col.names=TRUE, row.names=FALSE)
    }


if(!interactive()){
    args = commandArgs(TRUE)
    data = read_params(args[1])
    save_params(data, args[2])
    }
