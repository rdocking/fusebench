#!/usr/bin/make -rRf

all: run_A34048

clean:
	rm -rf $(OUTPUT)

# Specify the bash shell
SHELL := /bin/bash -o pipefail

##============================================================================
## Targets to run the existing workflow from end to end
##============================================================================

# Set up directories here
FUSEBENCH = /home/projects/hackseq17_3/fusebench_master
DATA = /home/projects/hackseq17_3/datasets/
OUTPUT = /home/projects/hackseq17_3/pipeline_results

run_A34048: run_validator

# Convert raw output to BEDPE
$(OUTPUT):
	mkdir -p $@

# Copy in PAVfinder results
$(OUTPUT)/A34048.pavfinder.bedpe: $(DATA)/aml_cell_line_examples/pavfinder/A34048.events.bedpe $(OUTPUT)
	cat $< | sed s/#chrom/chrom/ > $@

# Convert DEfuse results
$(OUTPUT)/A34048.defuse.bedpe: $(DATA)/aml_cell_line_examples/defuse/A34048/results.classify.tsv $(OUTPUT)
	Rscript $(FUSEBENCH)parsers/defuse_to_bedpe_parser.R $< $@

# Convert ERICscript results
$(OUTPUT)/A34048.ericscript.bedpe: $(DATA)/aml_cell_line_examples/ericscript/A34048/MOLM13_A34048.results.filtered.tsv $(OUTPUT)
	python $(FUSEBENCH)parsers/ericscript_to_bedpe.py -i $< -o $@

# Convert fusioncatcher results
$(OUTPUT)/A34048.fusioncatcher.bedpe: $(DATA)/aml_cell_line_examples/fusioncatcher/A34048/final-list_candidate-fusion-genes.GRCh37.txt $(OUTPUT)
	python $(FUSEBENCH)parsers/fusioncatcher_to_bedpe.py -i $< -o $@

# Convert STARfusion results
# Also not working at present b/c of the Oncofuse annotations

# Run the validator on all the existing files
%.bedpe.validated: %.bedpe
	python $(FUSEBENCH)parsers/validate_bedpe.py -i $< > $@

run_validator: \
	$(OUTPUT)/A34048.fusioncatcher.bedpe.validated \
	$(OUTPUT)/A34048.ericscript.bedpe.validated \
	$(OUTPUT)/A34048.pavfinder.bedpe.validated \
	$(OUTPUT)/A34048.defuse.bedpe.validated
