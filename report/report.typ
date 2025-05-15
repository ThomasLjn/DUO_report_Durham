#set text(font: "Fira Sans")

#import "@preview/hei-synd-report:0.1.1": *
#set text(font: "Fira Sans")

#import "/metadata.typ": *
#import "/tail/bibliography.typ": *
#import "/tail/glossary.typ": *



// #show:make-glossary
// #register-glossary(entry-list)

//-------------------------------------
// Template config
//
#show: report.with(
  option: option,
  doc: doc,
  date: date,
  tableof: tableof,
)


//-------------------------------------
// Content
//

#set text(font: "Fira Sans")

#show math.equation: set text(font: "Fira Math")

#outline()

#include "/main/01-intro.typ"
#include "main/02-theory.typ"
#include "/main/03-install.typ"
#include "/main/04-IO.typ"
#include "/main/05-PEC.typ"

#include "/main/06-charac.typ"
#include "/main/07-mixings.typ"
#include "/main/08-transitions.typ"
#include "main/09-linewidth.typ"
#include "main/10-narb.typ"
// #include "/main/03-design.typ"
// #include "/main/04-implementation.typ"
// #include "/main/05-validation.typ"
// #include "/main/06-conclusion.typ"

// #heading(numbering:none, outlined: false)[] <sec:end>

//-------------------------------------
// Glossary
//
// #make_glossary(gloss:gloss, title:i18n("gloss-title"))

//-------------------------------------
// Bibliography
//
#make_bibliography(bib:bib, title:i18n("bib-title"))

//-------------------------------------
// Appendix
//
// #if appendix == true {[
//   #pagebreak()
//   #counter(heading).update(0)
//   #set heading(numbering:"A")
//   // = #i18n("appendix-title") <sec:appendix>
//   #include "tail/a-appendix.typ"
// ]}
