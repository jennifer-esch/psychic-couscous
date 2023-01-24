library(tidyverse)

people_data <- read_csv('people_data.csv')

people_data_selected_columns <- people_data |>
  select('Name' = 'title',
         'Description' = 'http://purl.org/dc/elements/1.1/description',
         'Birth_date' = 'ontology/birthDate',
         'Death_date' = 'ontology/deathDate', 
         'Death_place' = 'ontology/deathPlace_label',
         'Death_cause' = 'ontology/deathCause_label'
         )

death_cause_mapping <- read_csv('mapping_death_causes.csv')

people_categorized <- left_join(people_data_selected_columns, 
                                death_cause_mapping, by="Death_cause")
