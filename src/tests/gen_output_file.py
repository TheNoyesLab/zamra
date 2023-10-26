import os 
import csv 
import argparse

# TODO: Add ArgParse interface 
# TODO: Populate abundance columns

def main():
        count_matrix = './data/final_count_matrix.csv'
        group_to_genome = '/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/data/clean_ground_truth/group_to_genome.tsv'

        output_file = './data/final_output.tsv'

        # loads the count matrix 

        group_to_count = {}

        with open(count_matrix) as file:
                next(file)
                reader = csv.reader(file, delimiter=',')
                for row in reader:
                        group = row[0]
                        counts = [eval(i) for i in row[2:]]
                        group_to_count[group] = sum(counts)

        # loads the group-to-genome file 

        data_frame = [['Genome Name', 'ARG Group', 'Detected', 'Counts', 'Observed Relative Abundance',
                        'Theoretical Relative Abundance']] 

        with open(group_to_genome) as file:
                reader = csv.reader(file, delimiter='\t')
                for row in reader: 
                        group, genome = row[0], row[1]
                        if group in group_to_count: 
                                data_frame.append([genome, group, 'Yes', group_to_count[group]])
                        else:
                                data_frame.append([genome, group, 'No', 0])

        # writes the final output file 

        with open(output_file, 'w') as file:
                writer = csv.writer(file, delimiter='\t')
                writer.writerows(data_frame)


main()

# TODO: accuracy testing
