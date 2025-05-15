#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#pagebreak()

= Installation and compilation of DUO

In this part, I am assuming that the reader has access to a linux terminal. If you are using windows, you can use #link("https://learn.microsoft.com/en-us/windows/wsl/install")[Windows Subsystem for Linux (WSL)].

This part is in majority based on DUO documentation: #link("https://duo.readthedocs.io/en/latest/index.html").

== Download DUO from github

An old but still working version is the `MOLPRO` branch: #link("https://github.com/Trovemaster/Duo/tree/MOLPRO"). In order to download this specific branch, the following command line can be used:

#align(center, `git clone -b MOLPRO https://github.com/Trovemaster/Duo.git .`)

If you want to have the last version of DUO (might not work ?), you can just type:
#align(center, `git clone https://github.com/Trovemaster/Duo.git .`)

== Download fortran compiler

Multiple free fortran compilers are available from internet. I am personally using `gfortran`. You may also need to install `gcc`, but it should be installed by default. Here is how to install them using `apt` package manager (for instance the default one in Ubuntu distribution):

#align(center, [`sudo apt-get install gfortran`\ `sudo apt-get install gcc`])

== Changing the Makefile

Makefile (`makefile`) is a file containing all the information about the files compilation. In order to start it and then compile the code, go to the main folder (where DUO files are) and type `make` in the terminal. If a `makefile` is found, it should start the compilation.
If it is not working, it can be that the default `makefile` is not well written for you compiler. If you install gfortran, then the default file is not the right one to use. In the folder `MAKEFILES` is the file `makefile_gfortran`: this is the one that needs to be used. Then you can use the following commands to properly compile duo, assuming you are in the main directory of DUO:
#align(center, [`cp MAKEFILES/makefile_gfortran makefile`\ `make`])

The default name for the DUO executable in the MOLPRO branch is `j-duo_0506.x`. You can change it directly in the `makefile` file, or using the `mv j-duo_0506.x new_name.x` command.

== Run your first simulation

The following command can be used to start a simulation. Note that the `<` and `>` characters are mandatory since they tell to the fortran program where to read and where to write.

#align(center, `./duo.x < input_file > output_file` )