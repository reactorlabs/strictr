(TeX-add-style-hook
 "acmart-sigplanproc-template"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("acmart" "sigplan" "10pt")))
   (TeX-run-style-hooks
    "latex2e"
    "acmart"
    "acmart10"
    "booktabs"
    "subcaption"))
 :latex)

