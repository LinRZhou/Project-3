library(tm)
library(wordcloud)
library(memoise)
library(shiny)
library(tidyverse)

#Credit for template goes to: https://shiny.rstudio.com/gallery/word-cloud.html


#Load data (a .csv file) produced from nextflow pipeline and arrange it so that it is descending by count

data_df=as.tibble(read.csv("top_collab_abstract_data.csv",stringsAsFactors = FALSE))

data_df<-data_df%>%
  arrange(desc(Count))


# The list of valid institutions
collaborators<-data_df$Collaborators[1:10]


# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(collaborator) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if (!(collaborator %in% collaborators))
    stop("Unrecognized Entry")
  
  selector<-as.character(collaborator)
  text <- data_df[data_df[,1]==collaborator,2]
  text <- gsub("[^a-zA-Z0-9]"," ", text)
  
  myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, content_transformer(tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  #Get rid of words that aren't very indicative of research topics, such as common vernacular or articles
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("SMART"), "the", "and", "but", "high", "low", "higher", 
                      "lower", "group", "months", "years", "reported","including",
                      "conclusion","conclusions", "data","based"))
  
  myDTM = TermDocumentMatrix(myCorpus,
                             control = list(minWordLength = 1))
  
  m = as.matrix(myDTM)
  
  sort(rowSums(m), decreasing = TRUE)
})



#Define UI for app that creates a word cloud from each top collaborator's abstracts and also creates a data table of the number of unique 
#abstracts from each top collaborator

ui<-fluidPage(
  # Application title
  titlePanel("Top US Collaborators with UNC and Their Research Topics"),
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      selectInput("selection", "Choose a Collaborator:",
                  choices = collaborators),
      actionButton("update", "Change"),
      hr(),
      sliderInput("freq",
                  "Minimum Occurrence Frequency:",
                  min = 3,  max = 20, value = 10),
      sliderInput("max",
                  "Maximum Number of Words:",
                  min = 1,  max = 50,  value = 25)
    ),
    
    # Show word cloud and top collaborators data table
    mainPanel(
      h3("Main Topics and Ideas", align="center"),
      plotOutput("plot",height=600,width=600),
      p("This word cloud displays up to the top 50 most-occurring words found in each group of abstracts from which at least one member of the selected
        institution was an author. For each institution, the top word was either 'cancer' or 'patients.' 'Patients' is a very generic word
        that could be used in any clinical trial or medically relevant research. `Cancer` is not only a very popular topic, it is also a very
        broad topic with many types. In addition, its heterogeneous nature and wide public impact also means that it can be related to most any
        topic in basic or applied research. When more words are revealed, we see more words relating to health and human disease, such as
        'risk', 'genes', 'chemotherapy', 'age', and 'clinical'."), 
      p("There are also some more specific results when we look at particular collaborators.
        For example, when we look at 'Baylor College of Medicine', we see many words relating to genetics, genomics, clinical genetics, and 
        sequencing. Baylor has one of the largest clinical genetics programs in the country, so it is not surprising that much of UNC's 
        collaborative research with Baylor relates to human and clinical genetics. When we look at the abstract words associated with
        'Brigham and Women's Hospital', we see many words that make sense for a hospital setting, such as 'surgery', 'indication', 'screening',
        or 'robotic.' Ultimately, our analysis suggests that the likely subject emphases of these collaborations are in the field of health
        and human disease. In particular, cancer (especially breast and prostate cancer), cancer biology and treatments, clinical trials, genetics,
        public health, and epidemiology are recurring topics."),
      h3("Top Collaborators, Ranked by Abstracts Shared", align="center"),
      dataTableOutput(outputId="CollaboratorTable"),
      p("Here, you can see the top 10 US institutions that collaborate with UNC, along with the number of unique abstracts on which someone
        from the institution was listed as an author. When the count of collaborators was compiled, several different associated institutions
        were combined into one, such as all institutions beginning with 'Duke University', including the medical school, were all counted
        as 'Duke University'. The method used to identify collaborating institutions and collect the abstracts filtered out all institutions
        found outside the US (including in Canada.) However, since we are only looking specifically for the top 10 collaborators, it is
        not unreasonable to expect them to be US-based."), 
      p("The list of top collaborators makes sense considering UNC's status as a top research university.
        Duke is one of our peer institutions and geographically close, while the NIH funds and collaborates with many entities 
        outside of its walls. The other institutions are also all top research or medical centers. Since all of these institutions 
        are associated with medical centers or schools, the list of top collaborators suggests that a lot of UNC's collaborative research
        is related to human health.")
    )
  )
)

#Define server logic required to create such figures

server<-function(input, output, session) {
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$update
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing abstracts...")
        getTermMatrix(input$selection)
      })
    })
  })
  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  output$plot <- renderPlot({
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(10,0.35),
                  min.freq = input$freq, max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
  })
  #Make a data table of top collaborators
  output$CollaboratorTable<-renderDataTable({
    data_df[,c(1,3)]
    })
}



shinyApp(ui = ui, server = server)