# Snakemake workflow

This workflow performs a differential gene expression analysis with STAR and Deseq2.

## Install packages

Snakemake and Snakedeploy are best installed via the Mamba package manager (a drop-in replacement for conda). If you have neither Conda nor Mamba, it can be installed via Mambaforge.

Given that Mamba is installed, run

```bash
mamba create -c conda-forge -c bioconda --name snakemake snakemake snakedeploy entrez-direct
```
to install both the required packages in an isolated environment. For all following commands ensure that this environment is activated.

```bash
conda activate snakemake
```

## Deploy workflow

Given that Snakemake and Snakedeploy are installed and available, the workflow can be deployed as follows.

First, create an appropriate project working directory on your system and enter it:

```bash
mkdir -p path/to/project-workdir
cd path/to/project-workdir
```

Second, run

```bash
snakedeploy deploy-workflow https://github.com/eikontx/rna-seq . --tag {current_tag}
```

Snakedeploy will create two folders workflow and config. The former contains the deployment of the chosen workflow as a Snakemake module, the latter contains configuration files which will be modified in the next step in order to configure the workflow to your needs. Later, when executing the workflow, Snakemake will automatically find the main Snakefile in the workflow subfolder.

## Configure workflow

To configure this workflow, modify `config/config.yaml` according to your needs, following the explanations provided in the file.

### `DESeq2` differential expression analysis configuration

To successfully run the differential expression analysis, you will need to tell DESeq2 which sample annotations to use (annotations are columns in the `samples.tsv` file described below). This is done in the `config.yaml` file with the entries under `diffexp:`.

### Sample and unit setup

The sample and unit setup is specified via tab-separated tabular files (.tsv). Missing values can be specified by empty columns or by writing NA.

#### sample sheet

The default sample sheet is `config/samples.tsv` (as configured in `config/config.yaml`). Each sample refers to an actual physical sample, and replicates (both biological and technical) may be specified as separate samples. For each sample, you will always have to specify a sample_name. In addition, all `variables_of_interest` and `batch_effects` specified in the `config/config.yaml` under the `diffexp:` entry, will have to have corresponding columns in the `config/samples.tsv`. The sample sheet can contain any number of additional columns. 

#### unit sheet

The default unit sheet is `config/units.tsv` (as configured in `config/config.yaml`). For each sample, add one or more sequencing units (for example if you have several runs or lanes per sample).

#### `.fastq` file source

For each unit, you will have to define a source for your `.fastq` files. This can be done via the columns fq1, fq2 and sra, with either of:

1. A single `.fastq` file for single-end reads (fq1 column only; fq2 and sra columns present, but empty). The entry can be any path on your system, but we suggest something like a `raw/` data directory within your analysis directory.
2. Two `.fastq` files for paired-end reads (columns fq1 and fq2; column sra present, but empty). As for the fq1 column, the fq2 column can also point to anywhere on your system.
3. A sequence read archive (SRA) accession number (sra column only; fq1 and fq2 columns present, but empty). The workflow will automatically download the corresponding `.fastq` data. The accession numbers usually start with SRR or ERR and you can find accession numbers for studies of interest with the [SRA Run Selector](https://trace.ncbi.nlm.nih.gov/Traces/study).

#### adapter trimming

If you set `trimming: activate:` in the `config/config.yaml` to `True`, you will have to provide at least one `cutadapt` adapter argument for each unit in the `adapters` column of the `units.tsv` file. You will need to find out the adapters used in the sequencing protocol that generated a unit: from your sequencing provider, or for published data from the study's metadata (or its authors). Then, enter the adapter sequences into the `adapters` column of that unit, preceded by the [correct `cutadapt` adapter argument](https://cutadapt.readthedocs.io/en/stable/guide.html#adapter-types).

#### strandedness of library preparation protocol

To get the correct `geneCounts` from `STAR` output, you can provide information on the strandedness of the library preparation protocol used for a unit. `STAR` can produce counts for unstranded (`none` - this is the default), forward oriented (`yes`) and reverse oriented (`reverse`) protocols. Enter the respective value into a `strandedness` column in the `units.tsv` file.

## Run workflow

Given that the workflow has been properly deployed and configured, it can be executed as follows.

To run the workflow while deploying any necessary software via conda (using the Mamba package manager by default), run Snakemake with:

```bash
snakemake --cores all --use-conda
```

### Cluster execution 

In order to run the workflow on the SLURM cluster, you will first need to install the Snakemake SLURM plugin on your conda environment:

```bash
pip install snakemake-executor-plugin-slurm
```

To run the workflow on the cluster, run Snakemake with the `--executor slurm` option:

```bash
snakemake --cores all --use-conda --jobs 15 --executor slurm --default-resources slurm_partition=compute cpus_per_task=4
```

For more information on the different configuration options, see the [SLURM plugin documantation](https://snakemake.github.io/snakemake-plugin-catalog/plugins/executor/slurm.html).


## Generate report

After finalizing your data analysis, you can automatically generate an interactive visual HTML report for inspection of results together with parameters and code inside of the browser via

```bash
snakemake --report report.zip
```