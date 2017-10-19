# fusebench

Fusebench is a workbench for aggregation and interpretation of RNA-Seq gene fusions. This project was initiated as a [HackSeq 2017](http://www.hackseq.com/) project, with development planned to begin during the Hackathon October 20-22, 2017.

## Initial Description

Many cancers are defined by the presence of recurrent, subtype-defining gene fusions. While there is an abundance of informatics tools for detection of gene fusions from RNA-Seq data, these tools show little predictive overlap. Further, while annotation databases for gene fusions exist, it remains difficult to automatically annotate newly-detected gene fusions against these resources. The aim of this project is to (1) Develop methods for aggregating and comparing the results of different fusion detection tools against each other, (2) Visualizing those results in terms of fused protein domains, read evidence, and annotation status, and (3) Automatically annotating fusions for presence in selected online databases. These methods will be incorporated into a new R package and made available to the community. This project will facilitate the development of improved methods for understanding the diversity and recurrence of gene fusions, and help facilitate the clinical translation of RNA-Seq based fusion detection.

## Longer Description of Current Challenges

One of the goals of this project is to assist bioinformaticians and clinical scientists in interpreting the results of fusion detection tools in personalized medicine contexts. In the single-patient setting, the main goals are to _filter_ the results of the particular analytic pipeline for high-confidence results, and then to _annotate_ those events with event- and disease-specific information, in order to _interpret_ the relevance of that event to a particular patients disease.

As described above, this is often difficult for RNA-Seq gene fusions, for reasons including:

1. Different fusion tools often produce contradictory results from the same data sets
2. Different fusion tools use different result file formats, making comparisons between tools difficult
3. Useful annotation information for interpreting the likely functional effect of fusions (e.g., fused protein domains) is often not included
4. Additional intra-sample features (e.g., relative expression of fusion partners) is often not included
5. The process of looking up similar fusion events in online databases is often manual
6. Other external data sources (e.g., fusion junction recurrence) are also difficult to link in
7. Visualization of supporting evidence is also often difficult

## What We're Thinking of Building

### Features

A tool that is capable of:

- Importing results from different fusion callers tools (or can convert the results of a set of tools into a common format)
    - Initial idea: have team members write simple parsers to convert tool output formats to a common standard (most likely [BEDPE](http://bedtools.readthedocs.io/en/latest/content/general-usage.html))
- From the common file format, aggregating results from different tools into a consensus set
    - Initial idea: require some level of minimum overlap between features
    - Handling duplicate or 'synonym' calls might be difficult here
- Augmenting the consensus set with additional information from the RNA-Seq data set or existing tools
    - Initial idea: add gene expression data for candidate fusion partners
    - Initial idea: use Oncofuse?
- Importing information from existing databases
    - Initial idea: start from dump of CIViC, filtered for fusions
    - Initial idea: use ReCount to provide view of how common the fusion junction is in different data sets
- Review interface
    - Some kind of dashboard or web view for 'reviewers' to view evidence associated with particular fusions
- Visualization
    - TBD

### Implementation

- Currently, this repository is set up as an R package. The initial idea was to implement most of the components principally in 'tidyverse'-style R, but this is not a hard requirement (it might not make sense for some parts)

### Initial Data Sets

- Synthetic test set containing 9 known fusions (from FusionCatcher)
- Re-called data from publicly available data sets with known positives
- TBC - AML cell line RNA-Seq data

## Component and Similar Projects

### Recent Review Papers

- Comprehensive evaluation of fusion transcript detection algorithms and a meta-caller to combine top performing methods in paired-end RNA-seq data - [PMID: 26582927](https://www.ncbi.nlm.nih.gov/pubmed/26582927)
- Comparative assessment of methods for the fusion transcripts detection from RNA-Seq data. - [PMID: 26862001](https://www.ncbi.nlm.nih.gov/pubmed/26862001)

### Fusion Callers

Selected tools include:

- trans-ABySS
- deFuse
- FusionCatcher
- EricScript
- pizzly
- Bellerophontes
- InFusion
- JAFFA
- FusionMap
- PRADA
- SOAPfuse 
- STAR-FUSION

### Visualization

- [IGV](http://software.broadinstitute.org/software/igv/)
- [Ribbon](http://genomeribbon.com/)
- Packages like chimeraviz also have visualizations
- Packages like [circlize](https://github.com/jokergoo/circlize) are adaptable for this (as well as other Bioconductor packages)

### Annotation

- Computational inference:
    - [OncoFuse](https://github.com/mikessh/oncofuse)
        - 'Oncofuse is a framework designed to estimate the oncogenic potential of de-novo discovered gene fusions. It uses several hallmark features and employs a bayesian classifier to provide the probability of a given gene fusion being a driver mutation.'
        - [PMID: 23956304](https://www.ncbi.nlm.nih.gov/pubmed/23956304)
- Databases: 
    - [CIViC](https://civic.genome.wustl.edu/home)
    - [Database of Genomic Variants](http://dgv.tcag.ca/dgv/app/home)
    - [Atlas of Genetics and Cytogenetics in Oncology and Haematology](http://atlasgeneticsoncology.org/)
    - [Tumor Fusion Gene Data Portal](http://54.84.12.177/PanCanFusV2/)
    - [Recount](https://www.biorxiv.org/content/early/2016/08/08/068478)
        - Note that this is actually an interface for downloading fusion junctions from many SRA studies

### Aggregation

- MetaSV
    - [Bioinformatics Article](https://academic.oup.com/bioinformatics/article-lookup/doi/10.1093/bioinformatics/btv204)
    - Mainly focused on large-scale structural variants, from tools like Pindel, BreakDancer, CNVnator, BreakSeq2
- [confFuse](https://www.frontiersin.org/articles/10.3389/fgene.2017.00137/full) 
    - [GitHub link](https://github.com/Zhiqin-HUANG/confFuse)
    - [Frontiers in Genetics Article](https://www.frontiersin.org/articles/10.3389/fgene.2017.00137/full)
- [chimeraviz](https://github.com/stianlagstad/chimeraviz)
    - [Bioinformatics Application Note](https://academic.oup.com/bioinformatics/article/33/18/2954/3835381/chimeraviz-a-tool-for-visualizing-chimeric-RNA)
    - [BioConductor](https://bioconductor.org/packages/release/bioc/html/chimeraviz.html)
    - `chimeraviz` is able to import fusion results from 'nine different fusion-finder tools: deFuse, EricScript, InFusion, JAFFA, FusionCatcher, FusionMap, PRADA, SOAPfuse and STAR-FUSION'
    - These are imported as R S4 objects. There are then a selection of functions for visualizing and comparing events (from what I can tell the comparison is mostly done at the coordinate level) 
- MAVIS - BCGSC unpublished tool along similar lines
