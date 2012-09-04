# Copyright 2008-2012 Alex Zvoleff
#
# This file is part of the chitwanabm agent-based model.
# 
# chitwanabm is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# chitwanabm is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# chitwanabm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact Alex Zvoleff in the Department of Geography at San Diego State 
# University with any comments or questions. See the README.txt file for 
# contact information.

###############################################################################
# Contains functions used to calculate and plot neighborhood-level statistics 
# from a single model run, or from an ensemble of model runs.
###############################################################################

library(ggplot2, quietly=TRUE)
library(reshape)

calc_NBH_LULC <- function(DATA_PATH, timestep) {
    # Make plots of LULC for a model run.
    lulc <- read.csv(paste(DATA_PATH, "/NBHs_time_", timestep, ".csv", sep=""))

    agveg.col <- grep('^agveg.*$', names(lulc))
    nonagveg.col <- grep('^nonagveg.*$', names(lulc))
    pubbldg.col <- grep('^pubbldg.*$', names(lulc))
    privbldg.col <- grep('^privbldg.*$', names(lulc))
    other.col <- grep('^other.*$', names(lulc))

    # Calculate the total land area of each neighborhood
    nbh.area <- apply(cbind(lulc$agveg, lulc$nonagveg, lulc$pubbldg,
            lulc$privbldg, lulc$other), 1, sum)

    # And convert the LULC measurements from units of square meters to units 
    # that are a percentage of total neighborhood area.
    lulc.sd <- lulc/nbh.area

    lulc.nbh <- data.frame(nid=lulc$nid, x=lulc$x, y=lulc$y, agveg=lulc.sd[agveg.col],
            nonagveg=lulc.sd[nonagveg.col], pubbldg=lulc.sd[pubbldg.col],
            privbldg=lulc.sd[privbldg.col], other=lulc.sd[other.col])

    return(lulc.nbh)
}


calc_agg_LULC <- function(DATA_PATH) {
    # Make plots of LULC for a model run.
    lulc <- read.csv(paste(DATA_PATH, "run_results.csv", sep="/"),
            na.strings=c("NA", "nan"))
    time.values <- read.csv(paste(DATA_PATH, "time.csv", sep="/"))
    time.Robj <- as.Date(paste(time.values$time_date, "15", sep=","),
            format="%m/%Y,%d")
    time.values <- cbind(time.values, time.Robj=time.Robj)

    agveg.cols <- grep('^agveg.[0-9]*$', names(lulc))
    nonagveg.cols <- grep('^nonagveg.[0-9]*$', names(lulc))
    pubbldg.cols <- grep('^pubbldg.[0-9]*$', names(lulc))
    privbldg.cols <- grep('^privbldg.[0-9]*$', names(lulc))
    other.cols <- grep('^other.[0-9]*$', names(lulc))

    # Calculate the total land area of each neighborhood
    nbh.area <- apply(cbind(lulc$agveg.1, lulc$nonagveg.1, lulc$pubbldg.1,
            lulc$privbldg.1, lulc$other.1), 1, sum)

    # And convert the LULC measurements from units of square meters to units 
    # that are a percentage of total neighborhood area.
    lulc.sd <- lulc/nbh.area
    lulc.sd.mean <- data.frame(time.Robj=time.Robj,
            agveg=apply(lulc.sd[agveg.cols], 2, mean),
            nonagveg=apply(lulc.sd[nonagveg.cols], 2, mean),
            pubbldg=apply(lulc.sd[pubbldg.cols], 2, mean),
            privbldg=apply(lulc.sd[privbldg.cols], 2, mean),
            other=apply(lulc.sd[other.cols], 2, mean), row.names=NULL)

    return(lulc.sd.mean)
}

calc_NBH_pop <- function(DATA_PATH) {
    model.results <- read.csv(paste(DATA_PATH, "run_results.csv", sep="/"),
            na.strings=c("NA", "nan"))
    # Read in time data to use in plotting. time.Robj will provide the x-axis 
    # values.
    time.values <- read.csv(paste(DATA_PATH, "time.csv", sep="/"))
    time.Robj <- as.Date(paste(time.values$time_date, "15", sep=","),
            format="%m/%Y,%d")
    time.values <- cbind(time.values, time.Robj=time.Robj)

    num_psn.cols <- grep('^num_psn.[0-9]*$', names(model.results))
    num_hs.cols <- grep('^num_hs.[0-9]*$', names(model.results))
    # num_marr is total number of marriages in the neighborhood, whereas marr is 
    # the number of new marriages in a particular month.
    num_marr.cols <- grep('^num_marr.[0-9]*$', names(model.results))
    marr.cols <- grep('^marr.[0-9]*$', names(model.results))
    births.cols <- grep('^births.[0-9]*$', names(model.results))
    deaths.cols <- grep('^deaths.[0-9]*$', names(model.results))
    out_migr_indiv.cols <- grep('^out_migr_indiv.[0-9]*$', names(model.results))
    ret_migr_indiv.cols <- grep('^ret_migr_indiv.[0-9]*$', names(model.results))
    in_migr_HH.cols <- grep('^in_migr_HH.[0-9]*$', names(model.results))
    out_migr_HH.cols <- grep('^out_migr_HH.[0-9]*$', names(model.results))
    fw_usage.cols <- grep('^fw_usage.[0-9]*$', names(model.results))

    model.results <- data.frame(time.Robj=time.Robj,
            marr=apply(model.results[marr.cols], 2, sum), 
            births=apply(model.results[births.cols], 2, sum), 
            deaths=apply(model.results[deaths.cols], 2, sum),
            out_migr_indiv=apply(model.results[out_migr_indiv.cols], 2, sum),
            ret_migr_indiv=apply(model.results[ret_migr_indiv.cols], 2, sum), 
            in_migr_HH=apply(model.results[in_migr_HH.cols], 2, sum), 
            out_migr_HH=apply(model.results[out_migr_HH.cols], 2, sum),
            num_hs=apply(model.results[num_hs.cols], 2, sum), 
            num_marr=apply(model.results[num_marr.cols], 2, sum),
            num_psn=apply(model.results[num_psn.cols], 2, sum),
            fw_usage_kg=apply(model.results[fw_usage.cols], 2, sum))

    return(model.results)
}

make_shaded_error_plot <- function(ens_res, ylabel, typelabel) {
    # The first column of ens_res dataframe should be the times
    # For each variable listed in "variable_names", there should be two columns,
    # one of means, named "variable_name.mean" and one of standard deviations,
    # named "variable_name.sd"
    theme_update(theme_grey(base_size=18))
    update_geom_defaults("line", aes(size=1))

    # Ignore column one in code in next line since it is only the time
    var_names <- unique(gsub("(.mean)|(.sd)", "",
                    names(ens_res)[2:ncol(ens_res)]))
    num_vars <- length(var_names)
    time.Robj <- ens_res$time.Robj

    # Stack the data to use in ggplot2
    mean.cols <- grep("(^time.Robj$)|(.mean$)", names(ens_res))
    sd.cols <- grep(".sd$", names(ens_res))
    ens_res.mean <- melt(ens_res[mean.cols], id.vars="time.Robj")
    names(ens_res.mean)[2:3] <- c("Type", "mean")
    # Remove the ".mean" appended to the Type values (agveg.mean, 
    # nonagveg.mean, etc) so that it does not appear in the plot legend.
    ens_res.mean$Type <- gsub(".mean", "", ens_res.mean$Type)

    sd.cols <- grep("(^time.Robj$)|(.sd$)", names(ens_res))
    ens_res.sd <- melt(ens_res[sd.cols], id.vars="time.Robj")
    names(ens_res.sd)[2:3] <- c("Type", "sd")

    # Add lower and upper limits of ribbon to ens_res.sd dataframe
    ens_res.sd <- cbind(ens_res.sd, lim.up=ens_res.mean$mean + 2*ens_res.sd$sd)
    ens_res.sd <- cbind(ens_res.sd, lim.low=ens_res.mean$mean - 2*ens_res.sd$sd)

    p <- ggplot()
    if (is.na(typelabel)) {
        # Don't use types - used for plotting things like fuelwood and total 
        # populatation, where there is only one class on the plot.
        p + geom_line(aes(time.Robj, mean), data=ens_res.mean) +
            geom_ribbon(aes(x=time.Robj, ymin=lim.low, ymax=lim.up),
                alpha=.2, data=ens_res.sd) +
            scale_fill_discrete(legend=F) +
            labs(x="Years", y=ylabel)
    }
    else {
        p + geom_line(aes(time.Robj, mean, colour=Type), data=ens_res.mean) +
            geom_ribbon(aes(x=time.Robj, ymin=lim.low, ymax=lim.up, fill=Type),
                alpha=.2, data=ens_res.sd) +
            scale_fill_discrete(legend=F) +
            labs(x="Years", y=ylabel, colour=typelabel)
    }
}

calc_ensemble_results <- function(model_results) {
    # The first column of model_results dataframe should be the times
    # For each variable listed in "variable_names", there should be two columns,
    # one of means, named "variable_name.mean" and one of standard deviations,
    # named "variable_name.sd"
    var_names <- unique(gsub(".run[0-9]*$", "",
                    names(model_results)[2:ncol(model_results)]))
    var_names <- var_names[var_names!="time.Robj"]

    # First calculate the mean and standard deviations for each set of runs
    ens_res <- data.frame(time.Robj=model_results$time.Robj.run1)
    for (var_name in var_names) {
        var_cols <- grep(paste("^", var_name, ".", sep=""), names(model_results))
        var_mean <- apply(model_results[var_cols], 1, mean)
        var_sd <- apply(model_results[var_cols], 1, sd)
        ens_res <- cbind(ens_res, var_mean, var_sd)
        var_mean.name <- paste(var_name, ".mean", sep="")
        var_sd.name <- paste(var_name, ".sd", sep="")
        names(ens_res)[(length(ens_res)-1):length(ens_res)] <- c(var_mean.name, var_sd.name)
    }

    ens_res <- ens_res[ens_res$time.Robj>"1997-01-01", ]

    return(ens_res)
}

calc_ensemble_results_NBH <- function(model_results) {
    # This function returns neighborhood level mean and standard deviations 
    # from an ensemble at a single timestep.
    # The first column of model_results dataframe should be the times
    # For each variable listed in "variable_names", there should be two columns,
    # one of means, named "variable_name.mean" and one of standard deviations,
    # named "variable_name.sd"
    var_names <- unique(gsub(".run[0-9]*$", "",
                    names(model_results)[2:ncol(model_results)]))
    var_names <- var_names[!(var_names %in% c("nid", "x", "y"))]

    # First calculate the mean and standard deviations for each set of runs
    ens_res <- data.frame(nid=model_results$nid, x=model_results$x, y=model_results$y)
    for (var_name in var_names) {
        var_cols <- grep(paste("^", var_name, ".", sep=""), names(model_results))
        var_mean <- apply(model_results[var_cols], 1, mean)
        var_sd <- apply(model_results[var_cols], 1, sd)
        ens_res <- cbind(ens_res, var_mean, var_sd)
        var_mean.name <- paste(var_name, ".mean", sep="")
        var_sd.name <- paste(var_name, ".sd", sep="")
        names(ens_res)[(length(ens_res)-1):length(ens_res)] <- c(var_mean.name, var_sd.name)
    }
    return(ens_res)
}