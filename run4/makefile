# This makefile will evaluate output from Azure
#
# It consist of following steps:
# 1. evaluate each file using R script
# 2. merge files

# setting RECIPEPREFIX to plus sign:
.RECIPEPREFIX = +

# VARIABLES
times = 105 110 200 600 1100 

# FOLDERS:
SCRIPTS = scripts

PHONY = phony
SOURCE = source
EVAL = evaluate
MERGE = merged
PARAMS = parameters
GRAPHS2D = graphs2d
GRAPHS3D = graphs3d
STATS = stats


TIMES = $(foreach time, $(times), $(EVAL)/time_$(time))
GRAPHS2DS = $(foreach time, $(times), $(GRAPHS2D)/time_$(time))
DIRS = $(PHONY) $(EVAL) $(MERGE) $(PARAMS) $(GRAPHS2D) $(GRAPHS3D) $(STATS) $(TIMES) $(GRAPHS2DS)


# stats
POP = total_population
VILL = village_count
MATRI = matrilocal_proportion



# SCRIPTS:
EVALUATE = Rscript $(SCRIPTS)/evaluate.r
TRANSFORM_PARAMS = Rscript $(SCRIPTS)/transform_params.r
PLOT2D = Rscript $(SCRIPTS)/images2d.r
PLOT3D = Rscript $(SCRIPTS)/images3d.r
PLOT_STATS = Rscript $(SCRIPTS)/plot_time_series.r
ADDPARAMS = Rscript $(SCRIPTS)/add_params.r


# UNUSED
#FILTER = Rscript $(SCRIPTS)/survived.r

all: prepare process merge visualize statistics addparams

.PHONY: prepare process merge visualize statistics clean addparams

# take specific dir only as order prerequisite
$(DIRS):
+ mkdir -p $@

################################################################################
# Convert data to nice form
################################################################################
prepare: $(PARAMS)/params.txt 

# -- Done in get_runs.sh due to larger size of raw data and online depedency
sources != ls $(SOURCE)
names := $(sources:.gz=)

# -- params -- #
$(PARAMS)/params.txt: model_params.txt | $(PARAMS)
+ $(TRANSFORM_PARAMS) $< $@


################################################################################
# Filter/evaluate
################################################################################
# evaluating:
# -- transforming model runs to sinle line of stats
# filtering:
# -- filtering those stats according to some rule -- not used after all


# -- evaluate -- #
processed := $(foreach time, $(times), $(foreach name, $(names), $(EVAL)/time_$(time)/$(name).txt ) )
#evaluates := $(foreach time, $(times), $(PHONY)/evaluate_$(time) )

process: $(PHONY)/evaluate

# process: $(processed)




#$(foreach time, $(times), $(EVAL)/time_$(time)/%.txt ): $(SOURCE)/%.gz | $(EVAL) $(TIMES)
#+ $(EVALUATE) $< $@ $$(echo $(dir $@) | tr -dc '0-9')


$(PHONY)/evaluate : | $(PHONY) $(EVAL) $(TIMES)
+ for time in $(times); do \
    for name in $(names); do \
        file=$(EVAL)/time_$${time}/$${name}.txt; \
        if [ -e "$$file" ]; then \
            echo "File: $${file} already exists!"; \
        else \
            $(EVALUATE) $(SOURCE)/$${name}.gz $${file} $${time}; \
        fi \
    done \
  done
+ touch $@

#$(evaluates) : $(PHONY)/evaluate_% : $(foreach name, $(names), $(EVAL)/time_%/$(name).txt ) | $(PHONY)
#+ touch $@

# -- merge -- #
merges := $(foreach time, $(times), $(MERGE)/merged_$(time).txt )

merge: $(merges)

#$(MERGE)/header_%.txt: $(addsuffix .txt, $(addprefix $(EVAL)/time_%/, $(names))) | $(MERGE)

$(foreach time, $(times), $(MERGE)/header_$(time).txt ): $(MERGE)/header_%.txt:  $(PHONY)/evaluate | $(MERGE)
+ echo $^
+ cat $(EVAL)/time_$*/`ls $(EVAL)/time_$* | head -n 1` | head -n 1 > $@

$(merges): $(MERGE)/merged_%.txt: $(MERGE)/header_%.txt $(PHONY)/evaluate | $(MERGE)
+ tail -q -n +2 $(EVAL)/time_$*/*.txt | sort -V > output_$*.txt
+ cat $< output_$*.txt > $@
+ rm output_$*.txt

################################################################################
# Add params to merged files, good for further comparison
################################################################################

withparams := $(foreach time, $(times), $(MERGE)/merged_$(time)_params.txt)

addparams: $(withparams)

$(withparams): $(MERGE)/merged_%_params.txt : $(MERGE)/merged_%.txt $(PARAMS)/params.txt | $(MERGE)
+ $(ADDPARAMS) $< $(PARAMS)/params.txt $@


################################################################################
# Visualize
################################################################################
plots := $(foreach time, $(times), $(PHONY)/plot2d_$(time) )

visualize: $(plots)



$(plots): $(PHONY)/plot2d_% : $(MERGE)/merged_%.txt $(PARAMS)/params.txt | $(PHONY) $(GRAPHS2D) $(GRAPHS2DS)
+ $(PLOT2D) $(PARAMS)/params.txt $(MERGE)/merged_$*.txt $(GRAPHS2D)/time_$*
+ touch $@

################################################################################
# Visualize stats
################################################################################
statistics: $(PHONY)/$(POP) $(PHONY)/$(VILL) $(PHONY)/$(MATRI)

$(PHONY)/$(POP): | $(STATS)
+ $(PLOT_STATS) $(SOURCE) $(STATS) $(POP)
+ touch $@


$(PHONY)/$(VILL): | $(STATS)
+ $(PLOT_STATS) $(SOURCE) $(STATS) $(VILL)
+ touch $@


$(PHONY)/$(MATRI): | $(STATS)
+ $(PLOT_STATS) $(SOURCE) $(STATS) $(MATRI)
+ touch $@

################################################################################
# clean
################################################################################

clean:
+ rm -r $(DIRS)




#//////////////////////////////////////////////////////////////////////////////#
# Old or Unused
#//////////////////////////////////////////////////////////////////////////////#

#$(PHONY)/plot3d: $(MERGE)/merged.txt $(PARAMS)/params.txt | $(PHONY) $(GRAPHS3D)
#+ $(PLOT3D) $(PARAMS)/params.txt $(MERGE)/merged.txt $(GRAPHS3D)
#+ touch $@


# -- filter -- #

#merge: $(MERGE)/filtered.txt $(MERGE)/filtered_params.txt

#$(MERGE)/filtered.txt: $(MERGE)/merged.txt
#+ $(FILTER) $< $@


#$(MERGE)/filtered_params.txt: $(MERGE)/filtered.txt
#+ ADDPARAMS model_params.txt $< $@

