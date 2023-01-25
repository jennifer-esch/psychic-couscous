import json
import pandas as pd

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

    for person in people_filtered:      #loop to filter for politician or activist
        if 'http://purl.org/dc/elements/1.1/description' in person:
            if type(person['http://purl.org/dc/elements/1.1/description']) is list:     #filter if description is a list
                for description in person['http://purl.org/dc/elements/1.1/description']:
                    if 'politician' in description.lower():
                        person['type'] = 'Politician'
                        occupation_filtered.append(person)
                    elif 'activist' in description.lower():
                        person['type'] = 'Activist'
                        occupation_filtered.append(person)
                    elif 'artist' or 'musician' or 'author' or 'actor' or 'writer' in description.lower():
                        person['type'] = 'Artist'
                        occupation_filtered.append(person)
                    elif 'business' in description.lower():
                        person['type'] = 'Businessperson'
                        occupation_filtered.append(person)
                    elif 'scholar' or 'professor' or 'academic' in description.lower():
                        person['type'] = 'Scholar'
                        occupation_filtered.append(person)
                    else:
                        person['type'] = 'Other'

            else:       #filter if description is a string
                if 'politician' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Politician'
                    occupation_filtered.append(person)
                elif 'activist' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Activist'
                    occupation_filtered.append(person)
                elif 'scholar' or 'professor' or 'academic' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Scholar'
                    occupation_filtered.append(person)
                elif 'artist' or 'musician' or 'author' or 'actor' or 'writer' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Artist'
                    occupation_filtered.append(person)
                elif 'business' in person['http://purl.org/dc/elements/1.1/description'].lower():
                    person['type'] = 'Businessperson'
                    occupation_filtered.append(person)
                else:
                    person['type'] = 'Other'
    
    return occupation_filtered




#Apply the filtering on json file for every letter
A_people_filt = filter_funct('People/A_people.json')
B_people_filt = filter_funct('People/B_people.json')
C_people_filt = filter_funct('People/C_people.json')
D_people_filt = filter_funct('People/D_people.json')
E_people_filt = filter_funct('People/E_people.json')
F_people_filt = filter_funct('People/F_people.json')
G_people_filt = filter_funct('People/G_people.json')
H_people_filt = filter_funct('People/H_people.json')
I_people_filt = filter_funct('People/I_people.json')
J_people_filt = filter_funct('People/J_people.json')
K_people_filt = filter_funct('People/K_people.json')
L_people_filt = filter_funct('People/L_people.json')
M_people_filt = filter_funct('People/M_people.json')
N_people_filt = filter_funct('People/N_people.json')
O_people_filt = filter_funct('People/O_people.json')
P_people_filt = filter_funct('People/P_people.json')
Q_people_filt = filter_funct('People/Q_people.json')
R_people_filt = filter_funct('People/R_people.json')
S_people_filt = filter_funct('People/S_people.json')
T_people_filt = filter_funct('People/T_people.json')
U_people_filt = filter_funct('People/U_people.json')
V_people_filt = filter_funct('People/V_people.json')
W_people_filt = filter_funct('People/W_people.json')
X_people_filt = filter_funct('People/X_people.json')
Y_people_filt = filter_funct('People/Y_people.json')
Z_people_filt = filter_funct('People/Z_people.json')

#Merge all seperate lists into a single list
activist_politician_data = A_people_filt + B_people_filt + C_people_filt + D_people_filt + E_people_filt + F_people_filt + G_people_filt + H_people_filt + I_people_filt + J_people_filt + K_people_filt + L_people_filt + M_people_filt + N_people_filt + O_people_filt + P_people_filt + Q_people_filt + R_people_filt + S_people_filt + T_people_filt + U_people_filt + V_people_filt + W_people_filt + X_people_filt + Y_people_filt + Z_people_filt

#Create JSON file with selected data
with open('people_data.json', 'w', encoding='utf-8') as file:
    json.dump(activist_politician_data, file, indent=2)

with open('people_data.json') as file:
    people_data_json = json.load(file)

#Save output into a csv file
people_data = pd.read_json('people_data.json')
people_data.to_csv('people_data.csv')