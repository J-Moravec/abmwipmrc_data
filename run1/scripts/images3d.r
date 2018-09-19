# Got two tables, table with param and table with evaluated runs.
# I want to make images based on variable and observed stat.
library(scatterplot3d)
options(warn=1)
source("scripts/addgrids3d.r")


# reads params
read_params = function(filepath){
    data = read.table(filepath, sep=" ", header=TRUE, stringsAsFactors=FALSE)
    return(data)
    }


# read runs
read_runs = function(filepath){
    data = read.table(filepath, sep=",", header=TRUE, stringsAsFactors=FALSE)
    return(data)
    }


# produce image for one variable and one stat
image = function(params, stats){
    }


construct_image_name = function(...){
    names = list(...)
    names = paste0(names, collapse="_")
    image_name = paste0(names, ".png")
    return(image_name)
    }


make_png = function(object, file){
    o = object
    png(file, width=1024, height=768)

    transparent = adjustcolor("black", alpha.f=0.2)
    graph = scatterplot3d(
        o$x, o$y, o$z,
        xlab=o$xlab, ylab=o$ylab, zlab=o$zlab,
        pch="", grid=FALSE, box=FALSE
        )
    addgrids3d(o$x, o$y, o$z, grid=c("xy", "xz", "yz"))
    graph$points3d(o$x, o$y, o$z, pch=16, type="h", lty=2, col=transparent)

    dev.off()
    }


plot_images = function(xs, ys, zs, outputpath){
    xs_names = colnames(xs)
    ys_names = colnames(ys)
    zs_names = colnames(zs)

    for(x_name in xs_names){
        for(y_name in ys_names){
            if(x_name == y_name){
                next
                }

            for(z_name in zs_names){
                if(x_name == z_name){
                    next
                    }

                if(y_name == z_name){
                    next
                    }

                object = list()
                object$x = xs[, x_name]
                object$xlab = x_name

                object$y = ys[, y_name]
                object$ylab = y_name

                object$z = zs[, z_name]
                object$zlab = z_name

                image_name = construct_image_name(x_name, y_name, z_name)
                image_path = file.path(outputpath, image_name)

                make_png(object, image_path)
                }
            }
        }
    }


main = function(parampath, runpath, outputpath){
    params = read_params(parampath)
    runs = read_runs(runpath)
    
    params = params[params$run %in% runs$run,]

    plot_images(params, params, runs, outputpath)
    }

if(!interactive()){
    args = commandArgs(TRUE)
    #print(args)
    main(args[1], args[2], args[3])
    }
