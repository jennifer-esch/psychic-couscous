library(tidyverse)

people_data <- read_csv('psychic-couscous/people_data.csv')

people_data_selected_columns <- people_data |>
  select('Name' = 'title',
         'Nationality' = 'ontology/nationality_label',
         'Description' = 'http://purl.org/dc/elements/1.1/description',
         'Birth date' = 'ontology/birthDate',
         'Death date' = 'ontology/deathDate', 
         'Death place' = 'ontology/deathPlace_label',
         'Death cause' = 'ontology/deathCause_label'
         )