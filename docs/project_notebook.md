# Zamra Project Notebook
=======================

Entry
-----
********************************************************************************
**Date:** <br>
**User:** <br>
**Job:** <br>

### Description

### MSI
#### Resources
**Cluster:** <br>
**Node:** <br>
**Tmux:** <br>
**Job type:** <br>

#### Data
**Raw:** <br>
**Interim:** <br>
**Clean:** <br>
**Source:** <br>
**Install:** <br>
**s3:** <br>

### Workflow
#### Goal(s)
-
#### Design(s)
-
#### Command(s)

```

```

#### Observation(s)
**Issue:**

**Error:**

**Debug:**

**Outcome:**


********************************************************************************

## Entry
Date: 2023-07-24
User: fermx014
Subject: Zamra Git repository 

## Description

Today the Zamra project was initialized a git repository! The projects file and directory structure was discussed with fermx014 and singe259. Furthermore the `.gitignore` file for which files and sub-directories to be untracked. A quick breakdown of the the simple bash shell script to align our mock genomes to megares and then filter out hits where the percent identity was greater than equal to 90 AND did not have the RequiresSNPConfrimation string in the gene annotation header. 

## MSI 
### Locations
Source code: 
`/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra`
`/home/noyes046/shared/projects/zamra`


### Resources
Job: Noyes Lab compute node
Cluster: Agate
Node: `acl97`
tmux: zamra


## Workflow
### Goal
Set up zamra git and GitHub repository on MSI 

### Approach
- Set up project directory and file structure
- Create .gitignore file
- Push up git repo to The Noyes Lab Organization GitHub page
- Add singe259 to collorate on repo
- Download shared/projects
- Dev time!
 
### Commands
`module load git`

### Obeservations


### Issues
There were no issues for this particulary entry. Woohoo! 


## Entry
Date: 2023-07-24
User: fermx014
Subject: Blasting mock genomes and filtering

## Entry 
Date: 2023-07-29
User: singe259
Subject: Identifying unique groups for mock genomes 

## Description 

Started the script `ground_truth.py` to isolate the ARG groups that are unique across the mock genomes. The results are not yet broken down into accessions nor saved into an output file. 

## Entry
Date: 2023-08-03
User: singe259
Subject: Generating output for ground truth genes of mock genomes

## Description

Generated the output file 'ground_truth_genes.txt' from 'ground_truth.py', containing the accessions of the ground truth genes for each mock genome.

Entry
-----
********************************************************************************
**Date:** 2023-08-11 <br>
**User:** fermx014 <br>
**Job:** Extracting ground truth accession from MEGARes <br>

### Description
With the ground truth accessions filtered from the mock genomes we will now extract theses accession from MEGARes to create our ground truth database. The database will be our refereance database for the minimap2.

### MSI
#### Resources
**Cluster:** Agate <br>
**Node:** acl97 <br>
**Tmux:** zamra <br>
**Job type:** Interactive <br>

#### Data
**Raw:** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/data/raw`<br>
**Interim:** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/data/interim` <br>
**Clean:** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/data` <br>
**Source:** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/src` <br>

### Workflow
#### Goal(s)
- Extract ground truth accessions MEGARes

#### Design(s)
- Grab lines starting with MEG redirect into new file
- Grab accession and sequence and append into new file
#### Command(s)

```
cd /home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/src

grep "^MEG" ../../data/ground_truth_genes.txt > ../../data/ground_truth_accession.txt

vim ground_truth_database.sh
chmod ug+x ground_truth_database.sh
./ground_truth_database.sh

```

#### Observation(s)
**Outcome:**

The ground truth accessions were extracted from the file `ground_truth_genes.txt` using grep and redirected into a new file called `ground_truth_accession.txt`. Next a simple bash script `ground_truth_database.sh` was written to read in each accession from `ground_truth_accession.txt` and extract this accession header and is corresponding seqeunce. Each extraction was appended to create the new ground truth database: `ground_truth_database.fasta`


********************************************************************************

Entry
-----
********************************************************************************
**Date:** 2023-08-11 <br>
**User:** fermx014 <br>
**Job:** Copying raw data of that have mock community <br>

### Description
Copying over raw mock sample data ccs/clr from Noyes_Project_026 to scratch to test minimap2 workflow

### MSI
#### Resources
**Cluster:** Agate <br>
**Node:** acl97 <br>
**Tmux:** zamra <br>
**Job type:** Interactive <br>

#### Data
**Raw:** `/scratch.global/fermx014/data/raw/zamra/{ccs,clr}` <br>
**Source:** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/src` <br>

### Workflow
#### Goal(s)
- Copying raw mock samples from Noyes_Project_026 dataset

#### Design(s)
- Create directory on scratch
- Navigate to directory
- Find mock samples with pattern and cp to current location
- Do this for both ccs and clr reads

#### Command(s)

```
cd /scratch.global/fermx014/data

mkdir -p raw/zamra/{ccs,clr}

cd raw/zamra/ccs
find /home/noyes046/data_release/umgc/sequel/Noyes_Project_026 -name "*MO*ccs.fastq.gz" -exec cp '{}' . ';'

cd ../clr
find /home/noyes046/data_release/umgc/sequel/Noyes_Project_026 -name "*MO*.fastq.gz" -exec cp '{}' . ';'
ls *.ccs*
rm *.ccs*

```

#### Observation(s)

**Outcome:**

Raw mock samples ready to be tested with minimap2 and resistome analyzer!

********************************************************************************

Entry
-----
********************************************************************************
**Date:** 2023-08-14 <br>
**User:** fermx014 <br>
**Job:** minimap2 workflow tests <br>

### Description

### MSI
#### Resources
**Cluster:** Agate <br>
**Node:** acl97 <br>
**Tmux:** zamra <br>
**Job type:** Interactive <br>

#### Data
**Raw:** `/scratch.global/fermx014/data/raw/zamra/{ccs,clr}` <br>
**Database** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/data/databases` <br>
**Source:** `/home/noyes046/shared/tools/pipeline.source/Zamra/1.0.0/zamra/src` <br>
**Interim:** ` `  <br>
**Clean:** ` ` <br>

### Workflow
#### Goal(s)
- Test minimap2 with raw mock sample data and ground truth database

#### Design(s)
- Load minimap2 software
- Execute minimap2 command with single sample

#### Command(s)

```
 minimap2 -ax map-hifi ../../data/databases/ground_truth_database.fasta /scratch.global/fermx014/data/raw/zamra/ccs/sequel-demultiplex.MOV2AA.ccs.fastq.gz > /scratch.global/fermx014/data/aln.sam

#### Observation(s)
**Issue:**

**Error:**

**Debug:**

**Outcome:**


********************************************************************************

## Entry
Date: 2023-08-29
User: singe259
Subject: Interactively generated a group-level count matrix

## Description

Generated `group_count_matrix.tsv` in the testing directory using `cr_removal.sh` to fix the carriage return issue in the ResistomeAnalyzer output. 


## Entry 
Date: 2023-09-01
User: singe259
Subject: Modified the formatting of the group-level count matrix

## Description 

Wrote the script `update_count_matrix.py` in the testing directory to modify the output of `cr_removal.sh` (`original_count_matrix.csv`) into 
`final_count_matrix.csv`, the main change being the inclusion of the `Genome` column.


## Entry
Date: 2023-09-05
User: singe259
Subject: Started script to generate the final output file 

## Description 

Began the script `gen_output_file.py` in the testing directory to combine the group-to-genome file and the modified count matrix into `final_output.tsv`, 
combining the results of the two files.   
