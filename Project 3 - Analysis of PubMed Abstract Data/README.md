"# project-3-LinRZhou 

Please run the following command in the VCL after the nextflow script has finished producing its final .csv file. This make take a few miniutes to load, so please be patient. The final .csv will be produced in the same directory as the main.nf, and the app.R should be in the directory with the them. 

docker run -d -p 3838:3838 -p 8787:8787 -e ADD=shiny -e PASSWORD=1234 -v $(pwd):/srv/shiny-server lzhou18/project3

" 
