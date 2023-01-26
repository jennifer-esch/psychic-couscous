library(tidyverse)
library('dplyr')

people_data <- read_csv('people_data.csv')

people_data_selected_columns <- people_data |>
  select('Name' = 'title',
         'Type' = 'type',
         'Birth_date' = 'ontology/birthDate',
         'Death_date' = 'ontology/deathDate',
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
  theme_light() +
  geom_bar(position="stack", stat="identity") +
  scale_fill_manual(values=c("#56B4E9", "#E69F00", "#C0392B"))


#barplot with grouped bars per occupation without natural death
pct_without_natural <- pct[!(pct$category=='Natural'),]
pct_barplot_without_natural <- ggplot(data = pct_without_natural) +
  aes(fill=category, y=percentage, x=Type) +
  xlab('Occupation') +
  ylab('Deaths in percentage') +
  labs(fill='Death Cause') +
  theme_light() +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_manual(values=c("#E69F00", "#C0392B"))

#lineplot for violence
people_categorized$year <-as.integer(format(people_categorized$Death_date, "%Y"))
data_with_year <- people_categorized |>
  select(year, Type, category) |>
  mutate("occupation"=
           ifelse((Type=='Activist'| Type=='Politician'),
         "civic",
         "other"))|>
  group_by(year, occupation, category) |>
  summarize(Count=n()) |>
  filter(!is.na(year)) |>
  subset(year> 1600) |>
  pivot_wider(names_from = category,
              values_from = Count) #|>
data_with_year[is.na(data_with_year)] <- 0
data_with_year <- data_with_year |>
  mutate(total=sum(natural + suicide + violent)) |>
  summarise(Natural=(natural/total)*100, 
            Violent=(violent/total)*100, 
            Suicide=(suicide/total)*100) |>
  subset(year> 1850)

data_decade <- data_with_year |>
  mutate(
    decade = floor(year / 10) * 10
  ) |>
  group_by(decade, occupation) |>
  pivot_longer(cols=c(Natural, Violent, Suicide), 
               names_to = 'category', 
               values_to = 'percentage') |>
  group_by(decade, occupation,category) |>
  summarise(percentage = mean(percentage))

data_decade_civic <- data_decade |>
  subset(occupation == 'civic') |>
  subset (category != 'Natural')

data_decade_other<- data_decade |>
  subset(occupation=='other') |>
  subset (category != 'Natural')

lineplot_civic <- ggplot(data = data_decade_civic) +
  aes(x=decade, y=percentage, color=category) +
  #xlab("") +
  #ylab("Percentage of violent death within year") +
  theme_light() +
  geom_smooth(aes(fill = category)) +
  scale_fill_manual(values=c("#E69F00", "#C0392B")) +
  scale_color_manual(values=c("#E69F00", "#C0392B"))

lineplot_other <- ggplot(data = data_decade_other) +
  aes(x=decade, y=percentage, color=category) +
  #xlab("") +
  #ylab("Percentage of violent death within year") +
  theme_light() +
  geom_smooth(aes(fill = category)) +
  scale_fill_manual(values=c("#E69F00", "#C0392B")) +
  scale_color_manual(values=c("#E69F00", "#C0392B"))

#lineplot_pct <- ggplot(data = data_decade_civic) +
#  aes(x=decade, y=percentage, fill=occupation) +
#  xlab("Year of violent death") +
#  ylab("Percentage of violent death within year") +
#  theme_light() +
#  geom_bar(position='stack', stat='identity')


print(lineplot_civic)
print(lineplot_other)
#print(pct_barplot_1)
#print(pct_barplot_without_natural)

