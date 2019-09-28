DOCS      := $(shell find *.md)
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

index.html: docs
	@echo "Compiling $@..."
	@rm $@ -f
	@echo "# Index" > ${@:.html=.md}
	@for i in ${DOC_NOEXT}; do printf '+ [%s](%s)\n\n' "$$i" "$$i.html" >> ${@:.html=.md}; done
	@pandoc -o $@ ${@:.html=.md}
	@rm ${@:.html=.md}
	@echo "Done."

define TEMPLATE_TEXT
[Back to index](index.html)

MODULE: ${CATEGORY}/${NAME}

CREATED: ${AUTHOR} (${DATE})

***

ADDS:

  - 

CARD TEXT:

```md

```
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
	@if [ -f ${NAME}.md ]; then echo "${NAME}.md already exists!"; else \
		echo "$$TEMPLATE_TEXT" > ${NAME}.md;                              \
		echo "Created ${NAME}.md";                                        \
	fi
endif
endif
endif

