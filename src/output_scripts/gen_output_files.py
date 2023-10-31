import os 
import csv
import argparse 
import pandas as pd 

# TODO: Populate abundance columns
# TODO: Ensure count values are determined correctly 
# TODO: Rewrite to simplify (remove dictionary approach) 

def main():
        # sets up command line interface 

        parser = argparse.ArgumentParser(description='Generates the summary output files from the count matrix',
                                         usage='python %(prog)s [-h] count_matrix output_dir') 
        
        parser.add_argument('count_matrix', type=str, help='Path to the updated group-level count matrix') 
        parser.add_argument('output_dir', type=str, help='Path to the directory in which to generate the output files')  

        args = parser.parse_args()

        # reads the count matrix 

        count_matrix_df = pd.read_csv(args.count_matrix) 
        headers = count_matrix_df.columns[2:]

        sample_to_detected = {} 
        sample_to_counts = {} 
        sample_to_ra = {} 

        group_col = count_matrix_df['Group'].to_list()
        genome_col = count_matrix_df['Genome'].to_list()

        for header in headers:
                counts = count_matrix_df[header].to_list() 
                sample_to_counts[header] = counts

                detected_col = [] 

                for count in sample_to_counts[header]: 
                        if count == 0: 
                                detected_col.append('No')
                        else:
                                detected_col.append('Yes')

                sample_to_detected[header] = detected_col 

                ra_col = [] 

                for count in sample_to_counts[header]:  
                        ra_col.append(count / sum(sample_to_counts[header]))

                sample_to_ra[header] = ra_col 

                # populating output data frame 

                data_frame = [['Genome Name', 'ARG Group', 'Detected', 'Counts', 'Observed Relative Abundance']]

                for i in range(len(sample_to_counts[header])):
                        row = [genome_col[i], group_col[i], sample_to_detected[header][i], sample_to_counts[header][i], sample_to_ra[header][i]]
                        data_frame.append(row)

                # writing output files 

                with open(args.output_dir + f'{header}.tsv', 'w') as file: 
                        writer = csv.writer(file, delimiter='\t')
                        writer.writerows(data_frame)

main()
