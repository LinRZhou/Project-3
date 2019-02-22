library(tidyverse)
library(stringr)



args = commandArgs(trailingOnly = TRUE)

institutions_df=as.tibble(read.csv(args[1],stringsAsFactors = FALSE))

#We will use the "ParentName" column since the names here are more likely to fit an actual institution name. If the "ParentName" column does not
#have an existing value, we will copy over the value from "LocationName".

for(i in 1:nrow(institutions_df)){
  if(institutions_df[i,4]=="-"){
    institutions_df[i,4]=institutions_df[i,3]
  } else {
    institutions_df[i,4]=institutions_df[i,4]
  }
}

#Make a unique list of accredited US institutions for matching and add an "Exist" variable to track real institutions when merging

institutions_match<-institutions_df[,4]%>%mutate(Exist="Yes")%>%unique()

#Write out a .csv file with the institution names
write.csv(institutions_match,file="institutions_match.csv",row.names=F)

