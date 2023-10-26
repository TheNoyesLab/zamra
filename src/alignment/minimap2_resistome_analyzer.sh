#!/bin/bash

module load minimap2/2.26
module load python 

mock_sample_fastq=(/scratch.global/fermx014/data/raw/zamra/ccs/*.ccs.fastq.gz)


for mock_sample in "${mock_sample_fastq[@]}"
do 
	mock_sample_name=$(basename -a "$mock_sample" | sed 's/sequel-demultiplex.//' | sed 's/.ccs.fastq.gz//')
	echo "$mock_sample_name"
	
	minimap2 -ax map-hifi ../../data/databases/ground_truth_database.fasta "$mock_sample"  > /scratch.global/fermx014/test_runs/"$mock_sample_name".sam
	
done


mock_sample_sam=(/scratch.global/fermx014/test_runs/*.sam)

for mock_sample in "${mock_sample_sam[@]}"
do 
	mock_sample_name=$(basename -a "$mock_sample" | sed 's/.sam//')
	echo "$mock_sample_name"

	/home/noyes046/shared/tools/pipeline.source/AMR++/3.0.6/src/AMRplusplus/bin/resistome -ref_fp ../../data/databases/ground_truth_database.fasta -sam_fp "$mock_sample" -annot_fp /home/noyes046/shared/tools/pipeline.source/AMR++/3.0.6/src/AMRplusplus/data/amr/megares_annotations_v3.00.csv -gene_fp /scratch.global/fermx014/test_runs/"$mock_sample_name".AMR.gene.tsv -group_fp /scratch.global/fermx014/test_runs/"$mock_sample_name".AMR.group.tsv -mech_fp /scratch.global/fermx014/test_runs/"$mock_sample_name".AMR.mechanism.tsv -class_fp /scratch.global/fermx014/test_runs/"$mock_sample_name".AMR.class.tsv -type_fp /scratch.global/fermx014/test_runs/"$mock_sample_name".AMR.type.tsv -t 95

done

# python ../../../../../AMR++/3.0.6/src/AMRplusplus/bin/amr_long_to_wide.py -i /scratch.global/fermx014/test_runs/*.tsv -o mock_sample_analytic_matrix.csv
