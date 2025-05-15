#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#import "@preview/physica:0.9.5": *

#pagebreak()

= Introduction

// #option-style(type:option.type)[
//   This chapter provides an overview of the project, including its background, motivation, and objectives. It should clearly state the problem being addressed and why it is relevant.

//   Key elements:
//   - *Introduce the goal* – What do you want to achieve with the project?
//   - *Provide context* – Why is this project relevant? What problem does it solve?
//   - *Define the scope* – What are the boundaries and limitations of your project?
//   - *Outline the structure* – How is this report organized?

//   Always place yourself in the point of view of the reader. For who is the report intended? What do they need to know to understand the project? Create and follow a red thread that guides the reader through the report.
// ]

This report provides an overview of the methods and the results about the simulations I have done with the DUO software during my internship (February -- July 2025) in the RbCs team of the #link("cornishlabs.uk")[Cornish Labs]. #link("https://duo.readthedocs.io/en/latest/duo.html")[DUO] is a computer program for computing rotational and rovibrational spectra of diatomic molecules @yurchenko_duo_2016. In the present work, I aimed to reproduce simulations about direct imaging of diatomic molecules @guan_nondestructive_2020. DUO can solve the Schrödinger equation for multiple coupled electronic states (open-shell diatomic, excited states with spin-orbit coupling...). Transition dipole moment can also be added to compute absorption/emission spectra. DUO also has the capacity of fitting experimental data to models, however this will not be studied here. In order to analyse the data, I used some fortran code besides python codes. Fortran is way faster than python for some purpose, but I everything could be done in python (for a longer running time).

After reviewing briefly the method of resolutions in DUO, a tutorial describing the input file for a basis input file will be given and then a brief overview of the informations given in the output files. Then, the results of the simulations will be presented.

Some of the output files (which contains the input file) and fortran codes are available at: #link("https://github.com/ThomasLjn/DUO_report_Durham")
