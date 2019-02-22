library(tidyverse)
library(stringr)


args = commandArgs(trailingOnly = TRUE)

abstracts = as.tibble(read.csv(args[1],stringsAsFactors = FALSE,col.names = c("Collaborators","Abstract","Exists")))

collab_top_10<-abstracts%>%
  group_by(Collaborators)%>%
  summarise(Count=n())%>%
  top_n(10) #Top 10 collaborators in terms of author affiliations in abstracts

write.table(collab_top_10,file="top_10_collabs.csv", sep=",",row.names=F)