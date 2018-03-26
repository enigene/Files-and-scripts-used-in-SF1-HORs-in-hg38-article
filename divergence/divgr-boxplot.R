#!/usr/bin/env Rscript

library("ggplot2")
suppressPackageStartupMessages(library("data.table"))

dt <- read.delim("SF1-HOR-divergence-rate.tsv",
                 header = T, stringsAsFactors = T, strip.white = T, skipNul = T)

dt <- na.omit(melt(setDT(dt), id.var='HORname'))

# make new column with names truncated after dot
dt <- setDT(dt)[, HORNames:=sub("[.].+", "", HORname)]

maxlim <- max(as.numeric(dt$value))
minlim <- min(as.numeric(dt$value))

png(paste0("SF1-HOR-divergence-rate-boxplot.png"),
    res=300, width=2.5, height=3, units='in')

p <- ggplot(dt, aes(x = reorder(HORNames, value, function(x) -median(x)),
                    y = round(value, 2))) +
  geom_boxplot(varwidth = F, outlier.shape = 1, outlier.size = 0.5) +
  ylab("Divergence") +
  theme_classic() +
  scale_y_continuous(
    breaks = c(seq(0, floor(maxlim+1), by = .05)),
    limits=c(minlim, maxlim)) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(angle = 90, vjust=0.5, hjust = 1,
        color = "black"),
        axis.text.y = element_text(color = "black"))

plot(p)

# get values from geom_boxplot
gg <- ggplot_build(p)
# select columns
ggdata <- gg$data[[1]][, names(gg$data[[1]]) %in% c("ymin", "lower", "middle",
  "upper", "ymax", "notchupper", "notchlower", "ymin_final", "ymax_final")]
# add names from labes
setDT(ggdata)[, HORnames:=gg[["layout"]][["panel_ranges"]][[1]][["x.labels"]]]
# print
write.table(ggdata, "SF1-HOR-divergence-rate-ggdata.txt", sep = "\t", col.names = T,
  row.names = F)

invisible(dev.off())
