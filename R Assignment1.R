#First, required package needs to be installed
install.packages("tidyverse")
install.packages('vegan')
install.packages('maps')

#Then packages are passed through the library function so we can use them
library("tidyverse")
library('vegan')
library('maps')

#I set working directory 
setwd("C:/Users/Simon/My Drive/Fall 2023/BINF6210/Assignment 1")

#Specimen data retrieval
# Anseriformes also known as waterfowl contain public data on BOLD.Public data as of 2023/09/22 consists of 2,371 published records forming 88 BINS, with specimens from 43 countries. These records include 2,213 species names, representing 133 species.  
#Below is the path used access data from BOLD
#http://www.boldsystems.org/index.php/API_Public/specimen?taxon=Anseriformes&format=tsv
#BOLD specimen data is retrieved using read_tsv, from the BOLD website. . 
birdBOLD <- read_tsv( file = "http://www.boldsystems.org/index.php/API_Public/specimen?taxon=Anseriformes&format=tsv")
birdBOLD <- read_tsv(file = 'Anseriformes_BOLD_data.tsv' )

#I then used write_tsv() to write the birdBOLD dataframe to a delimited file named "Anseriformes_BOLD_data.tsv
write_tsv(birdBOLD, "Anseriformes_BOLD_data.tsv")

#general information was gathered using names(), summary(), and length() to have an idea of what is contained in the data
names(birdBOLD)
summary(birdBOLD)
length(birdBOLD)

#Generating an exploratory map of the Anseriformes BINs with lat and lon values in Canada and Argentina

#Using tidyverse format, I start with birdBOLD dataframe, filter for only rows where the country category is 'Canada' and 'Argentina', and filter to remove any NA values from the lat and lon categories. 
NAbirdBOLD <- birdBOLD %>%
  filter(country %in% c('Canada','Argentina')) %>%
  filter(!is.na(lat)) %>%
  filter(!is.na(lon))

#Fetch world map

world <- map_data('world')

#use ggplot to map fetched world map, and plot coordinates from Canada and Argentina on top 

ggplot() + 
  geom_map( 
    data = world, 
    map = world,
    aes( x = long, y = lat, map_id = region),
    color = 'black', 
    fill = 'lightgray', 
    size = 0.1) + 
  geom_point(
    data = NAbirdBOLD,
    aes(x = lon, y = lat),
    color = 'red',
    size = 0.1) +
  labs(title = 'Exploratory map of Anseriforms BOLD specimens in Canada and Argentina', x = 'longitude', y = 'latitude') +
  theme(plot.title = element_text(hjust = 0.5))


#Built a rarefaction curve of all Anseriformes(waterfowl) specimens in Canada with lat and lon data to determine species richness

#dataframe CanadabirdBIN is made by filtering out only specimens from Canada with a non-NA bin_uri from birdBOLD dataframe

CanadabirdBIN <- birdBOLD %>%
  filter(country == 'Canada') %>%
  filter(!is.na(bin_uri))

#dataframe dfCOUNT.by.BIN is made to group dataframe rows by bin_uri, and to count how many times each bin_uri appears

dfCount.by.BIN <- CanadabirdBIN %>%
  group_by(bin_uri) %>%
  count(bin_uri)


#pivot_wider() is used to turn data into a community object fit for use in tidyverse package, the new columns are named after bin_uri values, and the data in the body of the new datatframe is n: the counts in the dfCount.by.BIN dataframe

dfBINs.spread <- pivot_wider( data = dfCount.by.BIN, names_from = bin_uri, values_from = n)

#rarefaction curve is made where x is the sample size, and the y axis is the BIN richness

rarefactioncurvebird <- rarecurve( x = dfBINs.spread, step = 1,  xlab = 'Sample size', ylab = "BIN richness", col = 'Black', main = 'Rarefaction curve of BINs of Anseriformes found in Canada', lwd = 2 )

#Built a rarefaction curve of all Anseriformes(waterfowl) specimens in Argentina with lat and lon data to determine species richness

#dataframe ArgbirdBIN is made by filtering out only specimens from Argentina with a non-NA bin_uri from birdBOLD dataframe

ArgbirdBIN <- birdBOLD %>%
  filter(country == 'Argentina') %>%
  filter(!is.na(bin_uri))

#dataframe ArgdfCOUNT.by.BIN is made to group dataframe rows by bin_uri, and to count how many times each bin_uri appears

ArgdfCount.by.BIN <- ArgbirdBIN %>%
  group_by(bin_uri) %>%
  count(bin_uri)

#pivot_wider() is used to turn data into a community object fit for use in tidyverse package, the new columns are named after bin_uri values, and the data in the body of the new datatframe is n: the counts in the ArgdfCount.by.BIN dataframe

ArgdfBINs.spread <- pivot_wider( data = ArgdfCount.by.BIN, names_from = bin_uri, values_from = n)

#rarefaction curve is made where x is the sample size, and the y axis is the BIN richness

Argrarefactioncurvebird <- rarecurve( x = ArgdfBINs.spread, step = 1,  xlab = 'Sample size', ylab = "BIN richness", col = 'Black', main = 'Rarefaction curve of BINs of Anseriformes found in Argentina', lwd = 2 )


#Acknowledgements
#For making a world map with ggplot2 in R: https://datavizpyr.com/how-to-make-world-map-with-ggplot2-in-r/
#To format data for vegan and to make a rarefaction curve, code was adapted by the BINF6210 R script #6. 
#For centering plot titles: https://stackoverflow.com/questions/40675778/center-plot-title-in-ggplot2


