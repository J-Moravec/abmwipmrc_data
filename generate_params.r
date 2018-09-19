#
# This script will generate parameters for repast_simphony model
#
# Parameters are in form:
# id\tparam\tparam_value,param\tparam_value
# and so on.


parameters = list(
# Growth rate:
    # For basic run:
    "growth_rate" = seq(from=0.4, to=0.8, by=0.05),
    # For other runs:
    #"growth_rate" = seq(from=0.4, to=0.8, by=0.1),

# Warfare pressure:
    # For basic run:
    "warfare_pressure" = c(0, 100, 200, 300),
    # For other runs:
    #"warfare_pressure" = c(100, 200, 300),

# Carrying capacity:
    # For basic run:
    "carrying_capacity" = c(100, 500, 1000),
    # For other runs:
    #"carrying_capacity" = c(500, 1000),

# yearly_warfare_mortality:
    # For basic run:
    "yearly_warfare_mortality" = seq(from=0.005, to=0.06, by=0.005),
    # For other runs:
    #"yearly_warfare_mortality" = seq(from=0.005, to=0.06, by=0.01),

# SizeX:
    # For most runs:
    "sizeX" = 5,
    # For specific run:
    #"sizeX" = seq(from=1, to=3, by=1),

# allow matrilocal:
    # For most runs:
    "allow_matrilocal" = 1,
    # For specific run:
    #"allow_matrilocal" = c(0, 1),

# matrilocal pressure:
    # For most runs:
    "matrilocal_pressure" = 0,
    # For specific run:
    #"matrilocal_pressure" = c(0.1, 0.3, 0.5, 1, 2),

# Fixed stuff:
    "change_residence_pause" = 0,
    "sizeY" = 10,
    "newborn_male_bias" = 116,
    "preferred_marriage_weight" = seq(from=0.5, to=0.9, by=0.1)
    )


total_runs = function(){
    param_lengths = sapply(parameters, length)
    total_runs = prod(param_lengths)
    total_runs
    }


make_param_table = function(){
    params = expand.grid(parameters)
    names = names(params)
    for(i in 1:ncol(params)){
        params[, i] = paste0(names[i], "\t", params[, i])
        }
    params = apply(params, 1, paste, collapse=",")
    params = paste(seq_along(params), params, sep="\t")
    params
    }


write_param_table = function(filepath, text){
    writeLines(text, filepath)
    }

main = function(){
    filepath = "unrolledParamFile.txt"
    params = make_param_table()
    write_param_table(filepath, params)
    cat("In total, there will be: ", total_runs(), " parameter combinations.\n")
    }

if(!interactive()){
    main()
    }
