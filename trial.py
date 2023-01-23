import json

#with open('filtered_people\A_people.txt') as file:
#    A_people_txt = file.read()

with open('People/A_people.json') as file:
        A_people = json.load(file)
A_people_filtered = [
        person for person in A_people
        if person.get('ontology/deathCause_label') is not None
]

people_filtered = []
monarch_filtered = []


def filterdeathCause(people_file):
    with open(people_file) as file:
        letter_people = json.load(file)
    for person in letter_people:
        if 'ontology/deathCause_label' in person:
            people_filtered.append(person)
            for person in people_filtered:
                if 'ontology/monarch_label' not in person:
                    people_filtered.remove(person)
    return people_filtered

A_people_filt = filterdeathCause('People/A_people.json')
print(len(A_people_filt))
#person.get('http://dbpedia.org/ontology/Politician'))