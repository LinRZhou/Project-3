library(tidyverse)
library(stringr)

args = commandArgs(trailingOnly = TRUE)

top_collab<-as.tibble(read.csv(args[1],stringsAsFactors = FALSE))

abstract_list<-as.tibble(read.csv(args[2],stringsAsFactors = FALSE,col.names = c("Collaborators","Abstract","Exists")))

#For each of the top collaborators, combine all the abstracts for that collaborator into one string

abstract_collate<-tibble("Collaborators"=character(),"Abstract"=character()) #Create an empty tibble to store the combined abstracts

for (i in 1:length(top_collab$Collaborators)){
  x<-filter(abstract_list, Collaborators==top_collab$Collaborators[i])
  combo=paste(unlist(x$Abstract),collapse = " ")
  collab=unique(x$Collaborators)
  abstract_collate[i,1]=collab
  abstract_collate[i,2]=combo
}

abstract_final<-abstract_collate%>%left_join(top_collab,by="Collaborators")

write.table(abstract_final,file="top_collab_abstract_data.csv", sep=",",row.names=F)