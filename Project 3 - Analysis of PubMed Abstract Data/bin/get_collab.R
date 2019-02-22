library(tidyverse)
library(stringr)


args = commandArgs(trailingOnly = TRUE)

full_file<-readLines(args[1])

institutions_match=as.tibble(read.csv(args[2],stringsAsFactors = FALSE))

abstracts_df<-tibble("Authors"=character(),"Abstract"=character()) #Create an empty tibble to store the author information and abstracts

for (j in 1:length(full_file)){
  if(substring(full_file[j],1,6)=="Author"){
    abstracts_df[1,1]=full_file[j]
    abstracts_df[1,2]=casefold(full_file[j+1]) #Make abstracts lower case
  }
}

#Split authors by (#) and then split that further by ","

collab_df<-tibble("Collaborators"=character(),"Abstract"=character()) #Create an empty tibble to store the split collaborator info

#This is to allow to to be extendable if we were to input multiple abstracts at once. This "loop" does not take extra computational time.
m=0
for (i in 1:nrow(abstracts_df)){
  Ident<-abstracts_df[i,1]
  author_split=strsplit(as.character(Ident),'\\(\\d+\\)')
  comma_split=strsplit(author_split[[1]],',')
  for (j in 1:length(unlist(comma_split))){
    collab_df[m+j,1]=unlist(comma_split)[j]
    collab_df[m+j,2]=abstracts_df[i,2]
  }
  m=m+length(unlist(comma_split))
}

#Trimming white spaces from institution names from abstracts

collab_df<-data.frame(lapply(collab_df,trimws),stringsAsFactors=FALSE)

#Hard-coding some names of institutions to match them to their central institution 
for (j in 1:nrow(collab_df)){
  if(substring(collab_df[j,1],1,15)=="Duke University"){
    collab_df[j,1]="Duke University"
  } else if (substring(collab_df[j,1],1,3)=="NIH"){
    collab_df[j,1]="National Institutes of Health"
  } else if (substring(collab_df[j,1],1,7)=="Harvard"){
    collab_df[j,1]="Harvard University"
  } else if (substring(collab_df[j,1],1,4)=="Yale"){
    collab_df[j,1]="Yale University"
  } else if (substring(collab_df[j,1],1,21)=="University of Chicago"){
    collab_df[j,1]="University of Chicago"
  } else if (substring(collab_df[j,1],1,21)=="Vanderbilt University"){
    collab_df[j,1]="Vanderbilt University"
  } else if (substring(collab_df[j,1],1,34)=="Washington University in St. Louis"){
    collab_df[j,1]="Washington University in St Louis"
  } else if (substring(collab_df[j,1],1,12)=="Case Western"){
    collab_df[j,1]="Case Western Reserve University"
  }
}
  
#Merge collaborators data with list of accredited institutions

collab_match<-collab_df%>%
  left_join(institutions_match,by=c("Collaborators"="ParentName"))%>%
  filter(Exist=="Yes")%>% #Get matches that matched the DAPIP database
  filter(Collaborators!="University of North Carolina at Chapel Hill")%>% #Filter out results from University of North Carolina at Chapel Hill
  unique() #Filter out duplicate abstracts/institution combinations
  


write.table(collab_match,file="collab_match.csv", sep=",",row.names=F,col.names=F)








