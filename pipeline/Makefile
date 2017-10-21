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
FUSEBENCH = ~/fusebench/
DATA = ~/fusebench_scratch/datasets/
OUTPUT = ~/fusebench_scratch/results/

run_A34048: \
	$(OUTPUT)/A34048.pavfinder.bedpe \
	$(OUTPUT)/A34048.ericscript.bedpe \
	$(OUTPUT)/A34048.fusioncatcher.bedpe

	# $(OUTPUT)/A34048.defuse.bedpe \

# Convert raw output to BEDPE
$(OUTPUT):
	mkdir -p $@

# Copy in PAVfinder results
$(OUTPUT)/A34048.pavfinder.bedpe: $(DATA)/aml_cell_line_examples/pavfinder/A34048.events.bedpe $(OUTPUT)
	cp $< $@

# Convert DEfuse results
#$(OUTPUT)/A34048.defuse.bedpe: $(DATA)/aml_cell_line_examples/defuse/A34048/results.classify.tsv
#	Rscript $(FUSEBENCH)defuse_to_bedpe_parser.R $<

# Convert ERICscript results
$(OUTPUT)/A34048.ericscript.bedpe: $(DATA)/aml_cell_line_examples/ericscript/A34048/MOLM13_A34048.results.filtered.tsv
	python $(FUSEBENCH)ericscript_to_bedpe.py -i $< -o $@

# Convert fusioncatcher results
$(OUTPUT)/A34048.fusioncatcher.bedpe: $(DATA)/aml_cell_line_examples/fusioncatcher/A34048/final-list_candidate-fusion-genes.GRCh37.txt
	python $(FUSEBENCH)/fusioncatcher_to_bedpe.py -i $< -o $@

# Convert STARfusion results
# Also not working at present b/c of the Oncofuse annotations
