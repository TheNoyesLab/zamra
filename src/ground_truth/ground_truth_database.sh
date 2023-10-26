#!/bin/bash

grep "^MEG" ../../data/clean_ground_truth/ground_truth_genes.txt > ../../data/clean_ground_truth/ground_truth_accession.txt
file=([0]="../../data/clean_ground_truth/ground_truth_accession.txt" [1]="../../data/databases/megares_database_v3.00.fasta")

while IFS= read -r line; do
	#printf '%s\n' "$line"
	grep "$line" -A 1 "${file[1]}" >> ../../data/databases/ground_truth_database.fasta
		
	
done < "${file[0]}"

 
