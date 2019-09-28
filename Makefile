DOCS      := $(shell find */*.md)
DOC_OBJS  := ${DOCS:.md=.html}
DOC_NOEXT := ${DOCS:%.md=%}
DATE      := $(shell date)

default: help

all: help debug index.html ## Builds index of entire folder

docs: ${DOC_OBJS} ## Builds the entire folder

help: ## Prints usage instructions
	@echo "usage: make [target] [<optional argument>=<value> ...]"
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\t%-30s%s\n", $$1, $$2}'
	@echo "optional arguments:"
	@echo "NAME -- name of module"
	@echo "CATEGORY -- category of module"
	@echo "AUTHOR -- author of module"

debug: ## Prints debug information
	@echo "DOCS: ${DOCS}"
	@echo "DOC_OBJS: ${DOC_OBJS}"
	@echo "DOC_NOEXT: ${DOC_NOEXT}"
	@echo "DATE: ${DATE}"

%.html: %.md
	@echo "Compiling $@..."
	@pandoc -o $@ $<
	@echo "Done."

index.html: README.MD ${DOCS}
	@echo "Compiling $@..."
	@rm $@ -f
	@cat README.MD >> index.md
	@echo '\n\n***\n\n' >> index.md
	@echo "## Index\n\n" >> index.md
	@for i in ${DOC_NOEXT}; do echo "$$i" | awk 'BEGIN { FS="/" } { printf "[%s](#%s%s)\n\n", $$i, tolower($$1), tolower($$2) }' >> index.md; done
	@echo "\n\n***\n\n" >> index.md;
	@for i in ${DOCS}; do cat "$$i" >> index.md; echo "\n\n***\n\n" >> index.md; done
	@pandoc -o $@ index.md
	@rm index.md
	@echo "Done."

define TEMPLATE_TEXT
## ${CATEGORY}/${NAME}

MODULE: ${CATEGORY}/${NAME}

CREATED: ${AUTHOR} (${DATE})

ADDS:

  - 

CARD TEXT:

[Back to index](#Index)
endef
export TEMPLATE_TEXT

template: ## Creates a template using optional arg NAME
ifndef NAME
	@echo "Requires parameter NAME"
endif
ifndef CATEGORY
	@echo "Requires parameter CATEGORY"
endif
ifndef AUTHOR
	@echo "Requires parameter AUTHOR"
endif
ifdef NAME
ifdef CATEGORY
ifdef AUTHOR
	mkdir -pv ${CATEGORY};
	@if [ -f ${CATEGORY}/${NAME}.md ]; then echo "${NAME}.md already exists!"; else \
		echo "$$TEMPLATE_TEXT" > ${CATEGORY}/${NAME}.md;                  \
		echo "Created ${CATEGORY}/${NAME}.md";                            \
	fi
endif
endif
endif

