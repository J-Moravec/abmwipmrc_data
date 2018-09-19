#!/usr/bin/env Rscript

library("data.table") # efficient operation with larger files
                      #(but my files are not large!)
library("magrittr") # pipe %>% command

library("randomcoloR") # for random color palette

# to get variable with the same name as column name
`..` <- function (..., .env = sys.frame(sys.parent(4))){
#`..` <- function (..., .env = .GlobalEnv){
    get(deparse(substitute(...)), env = .env)
    }


read_gzip_table = function(filepath){
    command = paste0("gunzip -c ", filepath)
    table = fread(command, header=TRUE, sep=",")
    return(table)
    }

# get_runs_ids
#
# get IDs of runs
get_runs_ids = function(table){
    runs = table[, `run` %>% unique %>% sort]
    return(runs)
    }


# get_runs
#
# get subset of runs from table
get_runs = function(table, runid){
    subset = table[`run` == runid]
    return(subset)
    }


# get_repeats_ids
#
# get IDs of repeats from table
get_repeats_ids = function(table){
    repeats = table[, `repeat` %>% unique %>% sort]
    return(repeats)
    }


# get_repeats
#
# get subset of repeats from table
get_repeats = function(table, rep){
    subset = table[`repeat` == rep]
    return(subset)
    }


# listmax
#
# get maximum value from list
# only works if all items in list are numeric
# and only if list is flat, unstructured.
listmax = function(x){
    sapply(x, max) %>% max
    }


# listmin
#
# get minimum value from list
# only works if all items in list are numeric
# and only if list is flat, unstructured.
listmin = function(x){
    sapply(x, min) %>% min
    }


plot_time_series = function(time_series, outputpath, stat){
    ########################################
    # prepare image:
    # values are in range of 0-1 and represent borders of particular plot area
    # borders are in this order: left, right, bottom and top
    png(outputpath, width=1024, height=768)
    mat = rbind(
    c(0, 0.7, 0, 1),
    c(0.7, 1, 0, 1)
        )
    split.screen(mat)

    #########################################
    # plot legend:

    screen(2)
    par(mar = c(0, 0, 2, 0))
    plot.new()
    plot.window(xlim=c(0,1), ylim=c(0,1))

    legend = names(time_series)
    set.seed(1)
    colors = distinctColorPalette(length(time_series))
    set.seed(NULL)
    colors = adjustcolor(colors, alpha.f=0.85)
    legend(
        "top",
        legend = legend,
        col = colors,
        bty="n", lwd=5, lty=1, ncol=2
        )
    ##########################################
    # prepare area for plotting:
    screen(1)
    par(mar = c(4, 4, 2, 1))

    xmax = time_series[[1]] %>% length
    ymax = listmax(time_series)

    plot(0, type="n", xlab="time", ylab=stat, xlim=c(0, xmax), ylim=c(0, ymax))

    # plot individual time-series
    for(i in 1:length(time_series)){
        series = time_series[[i]]
        lines(series, lwd=3, col=colors[i])
        }
    close.screen(all.screens = TRUE)
    invisible(dev.off())
    }


plot_file = function(filepath, outputpath, stat){
    # temporarily for single stat only
    # stat = "total_population"

    table = read_gzip_table(filepath)
    runs_ids = get_runs_ids(table)

    time_series = list()

    runs = paste("Run:", runs_ids)
    for(run_id in runs_ids){
        runs_subset = get_runs(table, run_id)
        repeat_ids = get_repeats_ids(runs_subset)

        # Single vector with results for single time_series
        from = min(runs_subset$tick)
        to = max(runs_subset$tick)
        len = to - from + 1
        
        cumul_stat = vector(mode="numeric", length=len)

        for(repeat_id in repeat_ids){
            repeat_subset = get_repeats(runs_subset, repeat_id)
            cumul_stat = cumul_stat + repeat_subset[[stat]]
            }

        mean_stat = cumul_stat / length(repeat_ids)

        run = runs[run_id - min(runs_ids) + 1]
        time_series[[run]] = mean_stat
        }
        plot_time_series(time_series, outputpath, stat)
    }


main = function(sourcepath, outputpath, stat){
    files = dir(sourcepath, pattern="\\.gz")
    outputpath = file.path(outputpath, stat)
    if(!dir.exists(outputpath)){
        dir.create(outputpath)
        }
    for(file in files){
        inputfile = file.path(sourcepath, file)
        outputfile = tools::file_path_sans_ext(file) %>% paste0(., ".png")
        outputfile = file.path(outputpath,  outputfile)
        plot_file(inputfile, outputfile, stat)
        }
    }



if(!interactive()){
    args = commandArgs(TRUE)
    # 1. path to source folder with gzip files
    # 2. path where folder with images will be created
    # 3. name of particular stat:
    main(args[1], args[2], args[3])
    }
