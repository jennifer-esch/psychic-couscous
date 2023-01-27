#MET2J final project on death rates among activists and politicians
#Group name: psychic couscous

library(tidyverse)
library('dplyr')

#Read data filtered data file containing data for all people that have death cause listed
people_data <- read_csv('people_data.csv')

#Select columns that will be used
people_data_selected_columns <- people_data |>
  select('Name' = 'title',
         'Type' = 'type',
         'Death_date' = 'ontology/deathDate',
         'Death_cause' = 'ontology/deathCause_label'
         )

#Add file with categories for type of death (natural, violent, suicide)
death_cause_mapping <- read_csv('mapping_deaths.csv')

#Join two files and create new column with categorized death cause
people_categorized <- left_join(people_data_selected_columns, 
                                death_cause_mapping, by='Death_cause')

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
barplot_deaths_per_occupation <- ggplot(data = pct) +
  aes(fill=category, y=percentage, x=Type) +
  labs(x='Occupation', y='Deaths in percentages') +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(fill='Death Cause') +
  theme_light() +
  theme(text = element_text(size=20)) +
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c('#56B4E9', '#E69F00', '#C0392B'))
ggsave('barplot_deaths_per_occupation.pdf', width= 10, height=5)

#barplot with grouped bars per occupation without natural death
pct_without_natural <- pct[!(pct$category=='Natural'),]
barplot_pct_without_natural <- ggplot(data = pct_without_natural) +
  aes(fill=category, y=percentage, x=Type) +
  labs(x='Occupation', y='Deaths in percentages') +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(fill='Death Cause') +
  theme_light() +
  theme(text = element_text(size=15)) +
  geom_bar(position='dodge', stat='identity') +
  scale_fill_manual(values=c('#E69F00', '#C0392B'))
ggsave('barplot_pct_without_natural.pdf', width= 10, height=5)

#make year integer
people_categorized$year <-as.integer(format(people_categorized$Death_date, '%Y'))

data_with_year <- people_categorized |>
  select(year, Type, category) |>
  #make 2 categories for occupation: activists, politicians and other
  mutate('occupation'=
           ifelse((Type=='Activist'| Type=='Politician'),
         'civic',
         'other'))|>
  group_by(year, occupation, category) |>
  #get total numbers of deaths by year and occupation
  summarize(Count=n()) |>
  filter(!is.na(year)) |>
  subset(year> 1600) |>
  pivot_wider(names_from = category,
              values_from = Count) 

data_with_year[is.na(data_with_year)] <- 0
#get percentages for different types of death
data_with_year <- data_with_year |>
  mutate(total=sum(natural + suicide + violent)) |>
  summarise(Natural=(natural/total) * 100, 
            Violent=(violent/total) * 100, 
            Suicide=(suicide/total) * 100) |>
  subset(year> 1850)

#make years into groups per 50 years
data_decade <- data_with_year |>
  mutate(
    decade = floor(year / 50) * 50
  ) |>
  group_by(decade, occupation) |>
  pivot_longer(cols=c(Natural, Violent, Suicide), 
               names_to = 'category', 
               values_to = 'percentage') |>
  group_by(decade, occupation,category) |>
  summarise(percentage = mean(percentage))

#keep only activists and politicians and remove natural deaths
data_decade_civic <- data_decade |>
  subset(occupation == 'civic') |>
  subset (category != 'Natural')

#keep other occupations and remove natural deaths for plotting
data_decade_other<- data_decade |>
  subset(occupation=='other') |>
  subset (category != 'Natural')

#plotting bar graph for civic group per 50 years
barplot_trend_civic <- ggplot(data = data_decade_civic) +
  aes(x=decade, y=percentage, fill=category) +
  labs(x='Year', y='Deaths in percentages') +
  scale_y_continuous(labels = scales::percent_format(scale = 1), lim=c(0,40)) +
  theme_light() +
  theme(text = element_text(size=20)) +
  geom_bar(position='dodge', stat='identity') +
  scale_fill_manual(values=c('#E69F00', '#C0392B'))
ggsave('barplot_trend_civic.pdf', width= 7, height=4)

#plotting bar graph for other group per 50 years
barplot_trend_other <- ggplot(data = data_decade_other) +
  aes(x=decade, y=percentage, fill=category) +
  labs(x='Year', y='Deaths in percentages') +
  scale_y_continuous(labels = scales::percent_format(scale = 1), lim=c(0,40)) +
  theme_light() +
  theme(text = element_text(size=20)) +
  geom_bar(position='dodge', stat='identity') +
  scale_fill_manual(values=c('#E69F00', '#C0392B'))
ggsave('barplot_trend_other.pdf', width= 7, height=4)
