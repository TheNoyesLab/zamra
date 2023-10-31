import os
import csv
import argparse

def main(): 
        # sets up command line interface

        parser = argparse.ArgumentParser(description='Modifies the output of amr_long_to_wide',
                                       usage='python %(prog)s [-h] original_matrix group_to_genome updated_matrix')

        parser.add_argument('original_matrix', type=str, help='Path to the original group-level count matrix')
        parser.add_argument('group_to_genome', type=str, help='Path to the ZAMRA group_to_genome.tsv file') # make optional?
        parser.add_argument('updated_matrix', type=str, help='Path at which to output the updated group-level count matrix')

        args = parser.parse_args()

        # loads original matrix

        data_frame = []

        with open(args.original_matrix) as file: 
                reader = csv.reader(file, delimiter=',')
                data_frame = list(reader)

        # loads group-to-genome

        group_to_genome = {}
        
        with open(args.group_to_genome) as file:
                reader = csv.reader(file, delimiter='\t')
                for row in reader:
                        group_to_genome[row[0]] = row[1]

        # modifies data frame 

        for i in range(len(data_frame)):
                row = data_frame[i]
                if i == 0:
                        row[0] = 'Group'
                        row.insert(1, 'Genome')
                        continue
                else:
                        row.insert(1, group_to_genome[row[0]])

                        for j in range(len(row)):
                                if j > 1: 
                                        row[j] = int(float(row[j])) 

        # writes the modified matrix

        with open(args.updated_matrix, 'w') as file:
                writer = csv.writer(file, delimiter=',')
                writer.writerows(data_frame)

main()

# TODO: change first column header to "Group" (from gene_accession) 
# TODO: add a "Genome" column using group_to_genome.tsv 
# TODO: cast all the values from floats to integers 
