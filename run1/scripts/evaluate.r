#!/usr/bin/env Rscript

# What is this about:
#
# Output of model is divided into RUNs, each RUN is for specific parameter combination
# Each RUN has multiple REPEATS, which repeat the same combination of parameters.
#
# Additionally, the output is divided into several gzipped filles, each has 50--100 runs.
#
# This script will process the output. Each set of outputs explore different time point
# (5, 10, 100, 500, 1000; +100 each for warmup phase).
# Each timepoint is explored from several historic angles (5, 10 and 100 steps)



library("data.table", quietly=TRUE) # efficient operation with larger files
                      #(but my files are not large!)
library("magrittr") # pipe %>% command

# to get variable with the same name as column name
`..` <- function (..., .env = sys.frame(sys.parent(4))){
#`..` <- function (..., .env = .GlobalEnv){
    get(deparse(substitute(...)), env = .env)
    }



################################################################################
# Utility
################################################################################


colMeans = function(table){
    lapply(table, mean)
    }


colVars = function(table){
    lapply(table, var)
    }

colAllNA = function(table){
    lapply(table, function(x) {is.na(x) %>% all})
    }


colSomeNA = function(table){
    lapply(table, function(x) {is.na(x) %>% any})
    }

################################################################################
# FILE MANIPULATIONS
################################################################################


# read_gzip_table
#
# read gzipped file and creates a data_table out of it
read_gzip_table = function(filepath){
    command = paste0("gunzip -c ", filepath)
    table = fread(command, header=TRUE, sep=",")
    return(table)
    }


# save_file
#
# save data_table into file
save_file = function(file, filepath){
    fwrite(file, filepath, sep=",")
    }


################################################################################
# TIME ESTIMATES
################################################################################


# get_point
#
# gets a point estimate from particular series
get_point = function(series, time){
    series[time]
    }


# get_stability
#
# get particular subset of time series
get_stability = function(series, time, history){
    if(history > time){
        return(NA)
        } else {
        from = time - history + 1
        return(series[from:time])
        }
    }


# get_stability_mean
#
# get mean of some subset of time series
get_stability_mean = function(series, time, history){
    get_stability(series, time, history) %>% mean
    }


# get_stability_var
#
# get variance of some subset of time series
get_stability_var = function(series, time, history){
    get_stability(series, time, history) %>% var
    }


# get_trend
#
# get change between some two time points
get_trend = function(series, time, history){
    from = time - history + 1
    if(history > time){
        return(NA)
        } else if(series[time] == 0 || series[from] == 0){
        return(0)
        } else {
        return(series[time]/series[from])
        }
    }

################################################################################
# Calculate statstics
################################################################################


get_point_estimate = function(table, name, variable, time){
    result = list()
    name = paste(name, "point", sep="-")
    result[name] = get_variable(table, variable) %>% get_point(., time)
    return(result) 
    }


get_stability_estimate = function(table, name, variable, time, history){
    result = list()
    name_mean = paste(name, "stability", "mean", history, sep="-")
    name_var = paste(name, "stability", "var", history, sep="-")
    result[name_mean] =
        get_variable(table, variable) %>% get_stability_mean(., time, history)
    result[name_var] =
        get_variable(table, variable) %>% get_stability_var(., time, history)
    return(result)
    }


get_trend_estimate = function(table, name, variable, time, history){
    result = list()
    name = paste(name, "trend", history, sep="-")
    result[name] = get_variable(table, variable) %>% get_trend(., time, history)
    return(result)
    }


get_stability_estimates = function(table, name, variable, time, histories){
    result = list()
    for(history in histories){
        result = c(
            result,
            get_stability_estimate(table, name, variable, time, history)
            )
        }
    return(result)
    }


get_trend_estimates = function(table, name, variable, time, histories){
    result = list()
    for(history in histories){
        result = c(
            result,
            get_trend_estimate(table, name, variable, time, history)
            )
        }
    return(result)
    }

################################################################################
# GETTERS
################################################################################


# get_variable
#
# get particular variable out of table
get_variable = function(table, variable){
    variable = table[[variable]]
    }


# get_runs_ids
#
# get IDs of runs
get_run_ids = function(table){
    runs = table[, `run` %>% unique %>% sort]
    return(runs)
    }


# get_run
#
# get subset of runs from table
get_run = function(table, runid){
    subset = table[`run` == runid]
    return(subset)
    }


# get_repeat_ids
#
# get IDs of repeats from table
get_repeat_ids = function(table){
    repeats = table[, `repeat` %>% unique %>% sort]
    return(repeats)
    }


# get_repeat
#
# get subset of repeats from table
get_repeat = function(table, rep){
    subset = table[`repeat` == rep]
    return(subset)
    }


################################################################################
# Data structures
################################################################################


get_stats_table = function(table){
    stats = process_repeat(table, 1)
    stats[] = NA_real_
    stats = as.data.frame(stats, check.names=FALSE)
    return(stats)
    }


make_repeat_table = function(repeat_ids, table){
    stats = get_stats_table(table)
    stats_names = names(stats)

    repeat_table = data.table("rep" = repeat_ids, stats)
    attr(repeat_table, "stats") = stats_names
    return(repeat_table)
    }


make_run_table = function(run_ids, table){
    stats = get_stats_table(table)
    stats_names = names(stats)
    stats_names = paste(stats_names, c("mean", "var"), sep="-")

    # create a data frame with single row:
    stats = rep_len(NA_real_, stats_names %>% length) %>% as.list
    names(stats) = stats_names
    stats = as.data.frame(stats, check.names=FALSE)
    run_table = data.table("run" = run_ids, stats)
    attr(run_table, "stats") = stats_names
    return(run_table)
    }

################################################################################
# PROCESSING
################################################################################


process_repeat = function(rep, time){
    histories = c(5, 10, 100)

    villages = get_point_estimate(rep, "villages", "village_count", time)
    population = c(
        get_point_estimate(rep, "population", "total_population", time),
        get_stability_estimates(
            rep, "population", "total_population", time, histories
            ),
        get_trend_estimates(
            rep, "population", "total_population", time, histories
            )
        )
    matrilocal = c(
        get_point_estimate(rep, "matrilocal", "matrilocal_proportion", time),
        get_stability_estimates(
            rep, "matrilocal", "matrilocal_proportion", time, histories
            )
        )
    result = c(villages, population, matrilocal)
    return(result)
    }


process_repeats = function(run, time){
    repeat_ids = get_repeat_ids(run)
    repeat_table = make_repeat_table(repeat_ids, run)

    for(repeat_id in repeat_ids){
        rep = get_repeat(run, repeat_id)
        result = process_repeat(rep, time)
        repeat_table[
            `rep` == repeat_id,
            names(result) := result
            ]
        }
    return(repeat_table)
    }


process_repeat_table = function(repeat_table){
    means = repeat_table[, -"rep"] %>% colMeans
    vars = repeat_table[, -"rep"] %>% colVars
    names(means) = names(means) %>% paste(., "mean", sep="-")
    names(vars) = names(vars) %>% paste(., "var", sep="-")
    return(c(means, vars))
    }




process_runs = function(table, time){
    run_ids = get_run_ids(table)
    run_table = make_run_table(run_ids, table)

    for(run_id in run_ids){
        run = get_run(table, run_id)
        repeat_table = process_repeats(run, time)
        repeat_summary = process_repeat_table(repeat_table)
        run_table[
            `run` == run_id,
            names(repeat_summary) := repeat_summary
            ]
        }
    return(run_table)
    }


process_azure_output = function(filepath, time){
    table = read_gzip_table(filepath)
    run_table = process_runs(table, time)

    # drop NA columns
    drop_cols = !(run_table %>% colAllNA %>% as.logical)
    run_table = run_table[, drop_cols, with=FALSE]


    # check if any columns contain any NA value:
    if( run_table %>% colSomeNA %>% anyNA){
        head(run_table)
        warning(paste0(
            "WARNING, some of the columns contain NA values,", 
            " this should not happen! Please check the results!"
            ))
        }
    return(run_table)
    }




if(!interactive()){
    args = commandArgs(TRUE)
    print(args)
    filepath = args[1]
    outputpath = args[2]
    time = as.numeric(args[3])
    output = process_azure_output(filepath, time)
    save_file(output, outputpath)
    }
