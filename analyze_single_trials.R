# Analyze single trial ERP data.
# Continuation of MATLAB stuff.
#
# Created...: ollie-d [20Apr23]
# Modified..: ollie-d [20Apr23]

# Install tidyverse if not already installed
#install.packages("tidyverse")

# Load tidyverse
library(tidyverse)

# Let's load in our .csv
dir <- 'C:/Users/H8801/Desktop/Kirby/'
fname <- 'single_trials.csv'
df <- read.csv(paste(dir, fname, sep=""), header=TRUE, sep=",")

# Let's compute some windowed means. First, let's define variables
windows_of_interest <- t(matrix(c(c(201, 300),
                                c(300, 400),
                                c(400, 500),
                                c(500, 601),
                                c(601, 701),
                                c(701, 798)), nrow=2, ncol=6))

# First let's convert our column names into numbers
cols <- colnames(df)[3:length(df)]
cols <- str_replace_all(cols, 'n', '-') # fixes negative values
cols <- str_replace_all(cols, 'X', '')  # fixes all other values
cols <- as.data.frame(cols)

# Now we can create a df that will contain our windowed means data
num_cols <- 2+dim(windows_of_interest)[1]
df_wm <- df[,1:num_cols]
df_wm[,3:num_cols] = 0 # erase single-time data
colnames(df_wm)[3] = "201_300"
colnames(df_wm)[4] = "300_400"
colnames(df_wm)[5] = "400_500"
colnames(df_wm)[6] = "500_601"
colnames(df_wm)[7] = "601_701"
colnames(df_wm)[8] = "701_798"

# And now we can populate df_wm
for (i in 1:dim(df)[1]) {
  for (w in 1:dim(windows_of_interest)[1]) {
    s = which(cols == windows_of_interest[w, 1]) + 2
    e = which(cols == windows_of_interest[w, 2]) + 2
    df_wm[i, w+2] = rowMeans(df[i, s:e])
  }
}

# Now we're ready for some statistics or something
Fz_b7_201_300 = df_wm[which((df_wm$channel_label == 'Fz') & (df_wm$bin_label == 7)), "201_300"]
