library(tidyverse)
library('dplyr')


people_data <- read_csv('people_data.csv')

people_data_selected_columns <- people_data |>
  select('Name' = 'title',
         'Type' = 'type',
         'Birth_date' = 'ontology/birthDate',
         'Death_date' = 'ontology/deathDate', 
         'Death_place' = 'ontology/deathPlace_label',
         'Death_cause' = 'ontology/deathCause_label'
         )

death_cause_mapping <- read_csv('mapping_death_causes.csv')

people_categorized <- left_join(people_data_selected_columns, 
                                death_cause_mapping, by="Death_cause")


#death count per occupation and death cause
type_category_count <- people_categorized |>
  group_by(Type, category) |>
  summarize(Count=n()) |>
  pivot_wider(names_from = category,
              values_from = Count) |>
  mutate(total=sum(natural + suicide + violent))

#converting to percentages from counts (per occupation and death cause)
pct <- type_category_count |>
  summarise(Natural=(natural/total)*100, 
            Violent=(violent/total)*100, 
            Suicide=(suicide/total)*100) |> 
  pivot_longer(cols= !Type, 
               names_to = 'category', 
               values_to = 'percentage')

#barplot with stacked bars per occupation
pct_barplot_1 <- ggplot(data = pct) +
  aes(fill=category, y=percentage, x=Type) +
  xlab('Occupation') +
  ylab('Deaths in Percentage') +
  labs(fill='Death Cause') +
  labs(title= 'Percentage of deaths by occupation and death cause type') +
  theme_light() +
  geom_bar(position="stack", stat="identity") +
  cat = factor(c('Natural', 'Suicide', 'Violent'), 
               levels = c('Natural', 'Violent', 'Suicide')) +
  scale_fill_manual(values=c("#56B4E9", "#E69F00", "#C0392B"))

#barplot with grouped bars per occupation
pct_barplot_2 <- ggplot(data = pct) +
  aes(fill=category, y=percentage, x=Type) +
  xlab('Occupation') +
  ylab('Deaths in percentage') +
  labs(fill='Death Cause') +
  labs(title= 'Percentage of deaths by occupation and death cause type') +
  theme_light() +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_manual(values=c("#56B4E9", "#E69F00", "#C0392B"))
  ##56B4E9
print(pct_barplot_1)
print(pct_barplot_2)
