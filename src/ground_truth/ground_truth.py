import os 
import csv 
import argparse 

# python3 ground_truth.py ./../../data/filter/mock_genome_ARGs_filter.tsv ./../../data/

def main(): 
    # sets up the command-line interface 

    parser = argparse.ArgumentParser(description='Identifies ground truth genes from processed BLAST-aligned mock genome sequences',
                                     usage='python %(prog)s [-h] inp_data out_dir' )

    parser.add_argument('inp_data', type=str, help='Path to the filtered output database of blastn_filter.sh')
    parser.add_argument('out_dir', type=str, help='Directory in which to save the output files')

    args = parser.parse_args()   

    # reads in and processes the input data 

    with open(args.inp_data) as file: 
        reader = csv.reader(file, delimiter='\t')
        genomes = {} # raw read-out from input file 
        for row in reader: 
            genome = row[1]
            accession = row[2] 
            group = accession.split('|')[-1]

            if genome not in genomes: 
                genomes[genome] = {} # key is group, values is list of corresponding accessions  
            if group not in genomes[genome]: 
                genomes[genome][group] = [] 
            
            genomes[genome][group].append(accession) 

        filtered_genomes = {} # filtered for group-level uniqueness

        for genome in genomes:
            unique_groups = [] 
            for group in genomes[genome]:
                unique = True 
                for comp_genome in genomes: 
                    if genome != comp_genome: 
                        if group in genomes[comp_genome]:
                            unique = False 
                            # genomes[comp_genome].remove(group) 
                if unique: 
                    unique_groups.append(group) 

            filtered_genomes[genome] = {} 

            for group in unique_groups: 
                filtered_genomes[genome][group] = genomes[genome][group] 

    # defines names for the output files 

    ground_truth_out = os.path.join(args.out_dir, 'ground_truth_genes.txt') 
    group_genome_out = os.path.join(args.out_dir, 'group_to_genome.tsv')

    # writes the main output file 

    with open(ground_truth_out, 'w') as out_file: 
        for genome in filtered_genomes: 
            out_file.write(genome.strip() + '\n')
            for group in filtered_genomes[genome]:
                for accession in filtered_genomes[genome][group]:
                    out_file.write(accession.strip() + '\n')
            out_file.write('\n')

    # writes the secondary output file 

    with open(group_genome_out, 'w') as out_file: 
        out_writer = csv.writer(out_file, delimiter='\t')
        for genome in filtered_genomes: 
            for group in filtered_genomes[genome]: 
                row = [group.strip(), genome.strip()]
                out_writer.writerow(row) 

    """
    i = 0 
    for genome in filtered_genomes:
        for group in filtered_genomes[genome]:
            for accession in filtered_genomes[genome][group]:
                print(f'{genome}: {accession}') 
                i += 1 
    print(i)
    """

main() 