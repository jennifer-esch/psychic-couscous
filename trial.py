import json
import csv

#Function to filter every json file for death cause, and whether the person is a politician or activist
def filter_funct(people_file):
    people_filtered = []    #empty list for people that have a death cause listed
    occupation_filtered = []   #empty list for people that are either activist or politician
    with open(people_file) as file:     #load the json file
        letter_people = json.load(file)
    for person in letter_people:        #loop to filter if death cause is listed
        if 'ontology/deathCause_label' in person:
            if isinstance(person['ontology/deathCause_label'], list):
                person['ontology/deathCause_label'] = person['ontology/deathCause_label'][0]
            people_filtered.append(person)

    for person in people_filtered:      #loop to filter for different occupations
        if 'http://purl.org/dc/elements/1.1/description' in person:
            if type(person['http://purl.org/dc/elements/1.1/description']) is list:     #filter if description is a list
                for description in person['http://purl.org/dc/elements/1.1/description']:
                    is_artist = False
                    for artist_label in ['artist', 'musician', 'author', 'actor', 'actress', 'writer', 'singer', 'painter', 'dancer']:
                        if artist_label in description.lower():
                            is_artist = True
                    if 'politician' in description.lower():
                        person['type'] = 'Politician'
                        occupation_filtered.append(person)
                    elif 'activist' in description.lower():
                        person['type'] = 'Activist'
                        occupation_filtered.append(person)
                    elif is_artist:
                        person['type'] = 'Artist'
                        occupation_filtered.append(person)
                    elif 'business' in description.lower():
                        person['type'] = 'Businessperson'
                        occupation_filtered.append(person)
                    else:
                        person['type'] = 'Other'
                        occupation_filtered.append(person)

            else:       #filter if description is a string
                is_artist = False
                for artist_label in ['artist', 'musician', 'author', 'actor', 'actress', 'writer', 'singer', 'painter', 'dancer']:
                    if artist_label in person['http://purl.org/dc/elements/1.1/description'].lower():
                        is_artist = True
                
                if 'politician' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Politician'
                    occupation_filtered.append(person)
                elif 'activist' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Activist'
                    occupation_filtered.append(person)
                elif is_artist:
                    person['type'] = 'Artist'
                    occupation_filtered.append(person)
                elif 'business' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Businessperson'
                    occupation_filtered.append(person)
                else:
                    person['type'] = 'Other'
                    occupation_filtered.append(person)
                
                

    return occupation_filtered

#Apply the filtering on json file for every letter in the alphabet
alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
occupation_death_data = []
for letter in alphabet:
    letter_filtered = filter_funct(f'People/{letter}_people.json')
    occupation_death_data.extend(letter_filtered)

#Create JSON file with selected data
with open('people_data.json', 'w', encoding = 'utf-8') as file:
    json.dump(occupation_death_data, file, indent=2)

with open('people_data.json') as file:
    people_data_json = json.load(file)

with open('people_data.csv', 'w', newline = '', encoding = 'utf-8') as csvfile:
    fieldnames = ['title','type','ontology/birthDate','ontology/deathDate','ontology/deathCause_label']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames, extrasaction= 'ignore')
    writer.writeheader()
    for person in people_data_json:
        writer.writerow(person)
        

#file.write('Name,Type,Birth_date,Death_date,Death_cause\n')

#Save output into a csv file
#people_data = pd.read_json('people_data.json')
#people_data.to_csv('people_data.csv')