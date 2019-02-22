#!/usr/bin/env nextflow


DAPIP=file('data/InstitutionCampus.csv')

process institution_match {
  container 'rocker/tidyverse:3.5'
  publishDir 'data', mode: 'copy'
  
  input:
  
  file DAPIP
  
  output:
  
  file '*.csv' into institution_match
  
  script:
  
  """
	
	Rscript $baseDir/bin/institution_list.R $DAPIP 

	"""

}

params.file_dir='data/*.txt'


abstract_input = Channel.fromPath(params.file_dir)
combo_channel = abstract_input.combine(institution_match)

process get_collaborators {
  container 'rocker/tidyverse:3.5'
  
  input:
  
  file a from combo_channel
  
  output:
  
  file '*.csv' into out_collaborators
  
  script:
  
  """
	
	Rscript $baseDir/bin/get_collab.R $a

	"""

}


process get_top_10 {
  container 'rocker/tidyverse:3.5'
  
  input:
  
  file i from out_collaborators.collectFile(name: "matched_abstracts.csv", newLine:true)
  
  output:
  
  file 'top_10_collabs.csv' into out_top10
  
  file 'matched_abstracts.csv' into matched_abstracts
  
  script:
  
  """
  Rscript $baseDir/bin/get_top_collabs.R $i
  
  """
}

process group_abstracts {
  container 'rocker/tidyverse:3.5'
  publishDir '.', mode: 'copy'
  
  input:
  
  file k from out_top10
  file j from matched_abstracts
  
  output:
  
  file 'top_collab_abstract_data.csv' into collab_abstract
  
  script:
  
  """
  Rscript $baseDir/bin/grouped_abstracts.R $k $j
  
  """
}

