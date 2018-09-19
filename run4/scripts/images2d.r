# Got two tables, table with param and table with evaluated runs.
# I want to make images based on variable and observed stat.

options(warn=1)

dir_create = function(directory){
    if(!dir.exists(directory)){
        dir.create(directory)
        }
    }


# reads params
read_params = function(filepath){
    data = read.table(filepath, sep=" ", header=TRUE, stringsAsFactors=FALSE, check.names=FALSE)
    return(data)
    }


# read runs
read_runs = function(filepath){
    data = read.table(filepath, sep=",", header=TRUE, stringsAsFactors=FALSE, check.names=FALSE)
    return(data)
    }


# produce image for one variable and one stat
image = function(params, stats){
    }


construct_image_name = function(param_name, stat_name){
    image_name = paste0(param_name, "_", stat_name, ".png")
    return(image_name)
    }


make_png = function(file, x, y, xlab="", ylab=""){
    png(file)
    
    col = adjustcolor("black", alpha.f=0.2)
    bg = adjustcolor("black", alpha.f=0.05)
    plot(x, y, type="p", col=col, bg=bg, pch=21, xlab=xlab, ylab=ylab)

    dev.off()
    }


main = function(parampath, runpath, outputpath){
    params = read_params(parampath)
    runs = read_runs(runpath)
    
    params = params[params$run %in% runs$run,]

    param_names = colnames(params)
    stat_names = colnames(runs)

    for(stat_name in stat_names){
    dirpath = file.path(outputpath, stat_name)
    dir_create(dirpath)
        for(param_name in param_names){
            image_name = construct_image_name(param_name, stat_name)
            image_path = file.path(outputpath, stat_name, image_name)

            parameter = params[, param_name]
            stat = runs[, stat_name]
            make_png(
                image_path,
                parameter,
                stat,
                xlab = param_name,
                ylab = stat_name
                )
            }
        }
    }

if(!interactive()){
    args = commandArgs(TRUE)
    print(args)
    main(args[1], args[2], args[3])
    }
