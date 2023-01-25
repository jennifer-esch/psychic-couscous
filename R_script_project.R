library(tidyverse)

people_data <- read_csv('people_data.csv')

people_data_selected_columns <- people_data |>
  select('Name' = 'title',
         'Type' = 'type',
         'Birth_date' = 'ontology/birthDate',
         'Death_date' = 'ontology/deathDate',
         'Death_cause' = 'ontology/deathCause_label'
         )

death_cause_mapping <- read_csv('mapping_deaths.csv')

people_categorized <- left_join(people_data_selected_columns, 
                                death_cause_mapping, by="Death_cause")
