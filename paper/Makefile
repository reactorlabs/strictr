.PHONY: all clean clean-all

all: promises-are-meant-to-be-broken.pdf

promises-are-meant-to-be-broken.pdf: promises-are-meant-to-be-broken.tex references.bib
	latexmk -pdf $<

clean:
	latexmk -c
	rm -rf *.synctex.gz *.bbl 
	rm promises-are-meant-to-be-broken.pdf

clean-all:
	latexmk -C
