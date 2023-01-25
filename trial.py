#script by psychic couscous
#python code to filter data of people on Wikipedia by DBpedia
#data is filtered on death cause and type of person (activists, politicians, artists, businesspeople or other)

import json
import csv

#Function to filter every json file for death cause, and the description of the person 
#People can be categorized into activist, politician, artist, businessperson, or other
def filter_funct(people_file):
    people_filtered = []    #empty list for people that have a death cause listed
    occupation_filtered = []   #empty list for the occupation of people
    
    with open(people_file) as file:     #load the json file
        letter_people = json.load(file)
    
    for person in letter_people:        #loop to filter if death cause is listed and add to list
        if 'ontology/deathCause_label' in person:
            if isinstance(person['ontology/deathCause_label'], list):
                person['ontology/deathCause_label'] = person['ontology/deathCause_label'][0]
            people_filtered.append(person)

    for person in people_filtered:      #loop to filter for different occupations
        if 'http://purl.org/dc/elements/1.1/description' in person:
            if type(person['http://purl.org/dc/elements/1.1/description']) is list:     #filter if description is a list
                for description in person['http://purl.org/dc/elements/1.1/description']:   #filter for different descriptions of people
                    is_artist = False   #description used to filter for different types of artists
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

#Apply the filtering function for all files, A to Z
alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
occupation_death_data = []
for letter in alphabet:
    letter_filtered = filter_funct(f'People/{letter}_people.json')
    occupation_death_data.extend(letter_filtered)   #add each filtered list to this list

#Create JSON file with selected data
with open('people_data.json', 'w', encoding = 'utf-8') as file:
    json.dump(occupation_death_data, file, indent=2)

with open('people_data.json') as file:
    people_data_json = json.load(file)

#writing selected data to a csv file. Only name, description, birth date, death date, and death cause are saved
with open('people_data.csv', 'w', newline = '', encoding = 'utf-8') as csvfile:
    fieldnames = ['title','type','ontology/birthDate','ontology/deathDate','ontology/deathCause_label']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames, extrasaction= 'ignore')
    writer.writeheader()
    for person in people_data_json:
        writer.writerow(person)