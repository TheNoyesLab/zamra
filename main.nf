params.coverage = 95

process MAKE_BLAST_DB {
	input:
	path meg_db 

	output: 
	path 'blast_db/'

	script:
	"""
	module load ncbi_blast+ 
	
	makeblastdb -in $meg_db -dbtype nucl -title megares_database_v3.00 -out blast_db/megares_database_v3.00 
	"""
}

process BLAST_ALIGN {
	input: 
	path blast_db 
	path mock_genome

	output:
	path '*.tsv'

	script: 
	"""
	mock_genome_name=\$(basename -a "$mock_genome" | sed s'/.fasta//')

	blastn -db $blast_db/megares_database_v3.00 -query "$mock_genome" -num_threads 32 -outfmt 6 -out "\$mock_genome_name".tsv  	
	"""		
}

process FILTER_BLAST {
	publishDir 'data'

	input: 
	path aligned_genomes

	output:
	path 'mock_genome_ARGs_filter.tsv'

	script:
	"""
	awk -F "\t" 'function basename(file){ sub(".*/", "", file); return file } { if(\$3 >= ${params.coverage} && \$2 !~ /M*RequiresSNPConfirmation/) print basename(FILENAME), "\t", \$1, "\t", \$2, "\t", \$3 >> "mock_genome_ARGs_filter.tsv"; else print \$0 >> "mock_genome_ARGs_did_not_filter.tsv"}' $aligned_genomes
	"""
}

process FIND_GROUND_TRUTH {
	publishDir 'data'

	input: 
	path filtered_genomes

	output:
	path 'ground_truth/'

	script:
	"""
	mkdir -p ground_truth/
	python3 $projectDir/src/ground_truth/ground_truth.py $filtered_genomes ground_truth/
	"""
} 

process GROUND_TRUTH_DB { 
	publishDir 'data/databases'

	input: 
	path ground_truth 
	path megares_db 

	output:
	path 'ground_truth_database.fasta'

	script:
	"""
	grep "^MEG" $ground_truth/ground_truth_genes.txt > ground_truth_accession.txt
	file=([0]="ground_truth_accession.txt" [1]=$megares_db)

	while IFS= read -r line; do
		grep "\$line" -A 1 "\${file[1]}" >> ground_truth_database.fasta

	done < "\${file[0]}"
	"""
}

process MINIMAP {
        input:
	path ground_truth_db
	path sample

	output:
	path '*.sam'

        script:
        """
	module load minimap2/2.26

	sample_name=\$(basename -a "$sample" | sed 's/sequel-demultiplex.//' | sed 's/.ccs.fastq.gz//')

	minimap2 -ax map-hifi $ground_truth_db "$sample" > "\$sample_name".sam
        """
}

process RESISTOME_ANALYZER {
	input: 
	path sample_sam
	val resistome_analyzer
	path ground_truth_db
	val annotations 

	output:
	path "*.group.tsv"

	script:
	"""
	sample_name=\$(basename -a "$sample_sam" | sed 's/.sam//')

	$resistome_analyzer -ref_fp $ground_truth_db -sam_fp "$sample_sam" -annot_fp $annotations -gene_fp "\$sample_name".AMR.gene.tsv -group_fp "\$sample_name".AMR.group.tsv -mech_fp "\$sample_name".AMR.mechanism.tsv -class_fp "\$sample_name".AMR.class.tsv -type_fp "\$sample_name".AMR.type.tsv -t 95
	"""	
}

process RA_FIX {
	input:
	path ra_group
	
	output:
	path "*.tsv"

	script:
	"""
	tr -d '\r' < $ra_group | tr -d ',' > \$(basename $ra_group)-fixed.tsv
	"""
} 

process AMR_LONG_TO_WIDE {
	input:
	path ra_groups
	path amr_long_to_wide

	output:
	path "original_group_count_matrix.csv"
	
	script:
	"""
	python3 $amr_long_to_wide -i $ra_groups -o original_group_count_matrix.csv
	"""
}

process FIX_COUNT_MATRIX {
        publishDir 'data'

        input: 
        path original_count_matrix 
        path ground_truth 
        path update_script

        output:
        path "final_count_matrix.csv"

        script:
        """
        python3 $update_script $original_count_matrix $ground_truth/group_to_genome.tsv final_count_matrix.csv
        """
}

process GENERATE_OUTPUTS {
        publishDir 'results'

        input:
        path final_count_matrix 
        path generate_script 

        output:
        path 'final_outputs/'

        script:
        """
        mkdir -p final_outputs
        python3 $generate_script $final_count_matrix final_outputs/
        """       
}

workflow {
	meg_ch = Channel.fromPath('data/databases/megares_database_v3.00.fasta')
	blast_db_ch = MAKE_BLAST_DB(meg_ch).first() 	

	mock_genomes_ch = Channel.fromPath('data/raw/D6331.refseq/genomes/*.fasta')
	aligned_ch = BLAST_ALIGN(blast_db_ch, mock_genomes_ch).collect()
	
	filter_ch = FILTER_BLAST(aligned_ch)

	ground_truth_ch = FIND_GROUND_TRUTH(filter_ch)

	megares_ch = Channel.fromPath('data/databases/megares_database_v3.00.fasta')
	ground_truth_db = GROUND_TRUTH_DB(ground_truth_ch, megares_ch).first()

        ccs_ch = Channel.fromPath('/scratch.global/fermx014/data/zamra/data/raw/ccs/fastq/*.fastq.gz') 
        minimap_ch = MINIMAP(ground_truth_db, ccs_ch)

        ra_path = Channel.value('/home/noyes046/shared/tools/pipeline.source/AMR++/3.0.6/src/AMRplusplus/bin/resistome')       
        annot_path = Channel.value('/home/noyes046/shared/tools/pipeline.source/AMR++/3.0.6/src/AMRplusplus/data/amr/megares_annotations_v3.00.csv') 
        ra_ch = RESISTOME_ANALYZER(minimap_ch, ra_path, ground_truth_db, annot_path)
        ra_fixed_ch = RA_FIX(ra_ch).collect()

        amr_l2w_path = Channel.fromPath('bin/amr_long_to_wide.py') 
        count_matrix_ch = AMR_LONG_TO_WIDE(ra_fixed_ch, amr_l2w_path)

        cm_script_path = Channel.fromPath('src/output_scripts/update_group_count_matrix.py')
        count_matrix_fixed_ch = FIX_COUNT_MATRIX(count_matrix_ch, ground_truth_ch, cm_script_path)      

        generate_script_path = Channel.fromPath('src/output_scripts/gen_output_files.py') 
        final_outputs_ch = GENERATE_OUTPUTS(count_matrix_fixed_ch, generate_script_path) 
}
