EXT       := html
DOCS      := $(find *.md)
DOC_OBJS  := ${DOCS:.md=.${EXT}}
DOC_NOEXT := ${DOCS:%.md=%}
DATE      := $(shell date)

default: help

all: index ## Builds index of entire folder

help: ## Prints usage instructions
	@echo "usage: make [target] [<optional argument>=<value> ...]"
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\t%-30s%s\n", $$1, $$2}'
	@echo "optional arguments:"
	@echo "EXT -- extension of file"
	@echo "NAME -- name of module"
	@echo "CATEGORY -- category of module"
	@echo "AUTHOR -- author of module"

%.${EXT}: %.md
	@echo "Compiling $@..."
	@pandoc -o $@ $<
	@echo "Done."

index.html: ${DOC_OBJS}
	@echo "Compiling $@..."
	@rm $@ -f
	@echo "# Index" > ${@:.html=.md}
	@for i in ${DOC_NOEXT}; do printf '- [%s](%s)' $i "$i.html\n" >> ${@:.html=.md}; done
	@pandoc -o $@ ${@:.html=.md}
	@rm ${@:.html=.md}
	@echo "Done."

define TEMPLATE_TEXT
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

