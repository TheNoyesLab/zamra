#!/bin/bash 

module load ncbi_blast+

makeblastdb -in ../../data/databases/megares_database_v3.00.fasta -dbtype nucl -title megares_database_v3.00 -out ../../data/databases/megares_database_v3.00 -logfile ../../logs/makeblastdb.log

mkdir -p ../../data/{interim_blast,filter_blast_95}

mock_genome_fasta=(../../data/raw/D6331.refseq/genomes/*.fasta)

for mock_genome in "${mock_genome_fasta[@]}"
do 
	mock_genome_name=$(basename -a "$mock_genome" | sed s'/.fasta//')
	echo "$mock_genome_name is on blast!"
	
	blastn -db ../../data/databases/megares_database_v3.00 -query "$mock_genome" -num_threads $1 -outfmt $2 -out ../../data/interim_blast/"$mock_genome_name".tsv &> ../../logs/"$mock_genome_name".log
done

awk -F "\t" 'function basename(file){ sub(".*/", "", file); return file } { if($3 >= 95 && $2 !~ /M*RequiresSNPConfirmation/) print basename(FILENAME), "\t", $1, "\t", $2, "\t", $3 >> "../../data/filter_blast_95/mock_genome_ARGs_filter.tsv"; else print $0 >> "../../data/filter_blast_95/mock_genome_ARGs_did_not_filter.tsv"}' ../../data/interim_blast/*.tsv

awk -F "\t" 'function basename(file){ sub(".*/", "", file); return file } { if($3 >= 90 && $2 !~ /M*RequiresSNPConfirmation/) print basename(FILENAME), "\t", $1, "\t", $2, "\t", $3 >> "../../data/filter_blast_95/mock_genome_ARGs_filter.tsv"}' ../../data/interim_blast/Veillonella_rogosae.tsv


