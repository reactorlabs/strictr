.PHONY: all clean clean-all

all: promises-are-meant-to-be-broken.pdf

promises-are-meant-to-be-broken.pdf: promises-are-meant-to-be-broken.tex
	latexmk -pdf $<

clean:
	latexmk -c
	rm -rf *.synctex.gz
	rm promises-are-meant-to-be-broken.pdf

clean-all:
	latexmk -C
