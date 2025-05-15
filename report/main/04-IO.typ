#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#pagebreak()

= DUO I/O
== Input file

Everything said here is based on personal experience with the software and on the documentation (available in the DUO folder as `manual.pdf` but a more recent version is available in the website: #link("https://duo.readthedocs.io/en/latest/index.html")). 

#infobox([In DUO files, the comments lines are surrounded by parenthesis, for instance:
#align(center,`(this is a comment)`)])

=== System defintion

The first lines of the input file will be the the definition of the system:

#sourcecode()[```rust
( === Global Setup === )
atoms Rb-87 Cs-133
nstates 3
jrot 0 - 5
(Symmetry is Cs(M) for heternuclear and C2v(M) for homonuclear)
symmetry Cs(M)
```]

- `atoms`: specifies the two atoms and isotopes
- `nstates`: number of potential energy curves (PEC) 
- `jrot`: specifies the set of total angular momentum quantum numbers to be computed. Can be integers, half-integers or range. _e.g_: `jrot 2.5, 0.5, 10.5 - 12.5,  20.5`. The first `J` in the `jrot` list will be used to define the reference zero-point-energy (ZPE) value for the run.
- `symmetry`: Optional keywork specifying the molecular permutation-inversion symmetry group

=== Definition of the grid

#sourcecode()[```rust
( === Grid definition === )
grid
npoints  800
range  2.5, 15.0
(units angstrom)
type 0
end
```]

- `grid` and `end`: keywords that specifies the beggining and the end of the grid definition section.
- `npoints`: number of grid points  
- `units`: optionnal here, default unit is `angstrom`. can be `bohr` 
- `range`: minimal and maximum internuclear distance for the calculation.
- `type`: can be 0, 1, 2, 3 or 4. `0` is default and correspond to a uniform distribution. For detail about the other type of grid definitions, see the documentation.

=== Vibrational basis set
#sourcecode()[```rust
VibrationalBasis
vmax 300 300 200 400
end
```]

where the `vmax` argument specifies the number of vibrational levels for each PEC included in the basis. If only one integer $n$ is provided, then it will compute for each PEC the lowest-energy $n$ vibrational levels.

=== Eigensolver

#sourcecode()[```rust
EigenSolver
nroots 100
ZPE 24.794637558396
end
```]

- `nroots`: number of energy levels of the coupled problem to be computed (for any of the specified values of jrot).
- `enermax`: to select the energy levels of the coupled problem to be computed
- `ZPE`: allows to explicitly input the zero-point energy (ZPE) of the molecule (in cm$""^(-1)$). This affects the value printed, as Duo always prints energy of rovibronic levels by subtracting the ZPE. Example:

#infobox([If both `nroots` and `enermax` are specified then only levels satisfying both criteria are selected. Note that the present `enermax` threshold is distinct from the VibrationalBasis input.])


=== Potential energy curves

The PEC can be implemented using built-in functions or by giving values on a grid. In both cases, the other keywords than `type` are the same. For a complete list of the built-in functions, please see the documentation and/or manual. I figured that some of the built-in functions are not specified in the documents. You can find them in the `functions.f90` file, defining all the functions.

- `poten`: number/ID of the PEC
- `lambda`: $Lambda$ quantum number
- `mult`: $2S+1$ value, spin multiplicity
- `symmetry`: $plus$ or $minus$, symmetry of the state. Only if $Lambda=0$
- `units`: units for length and energy
- `type`: built-in function (e.g `EMO`, see documentation) or `grid`
Below one example with `type EMO` and one with `type grid`. 
#sourcecode()[```rust
poten 1
  name "A1Sigma+"
  lambda 0
  mult 1
  symmetry +
  type EMO
  units angstrom cm-1
values
  Te 9994.328
  Re  5.12209398917506
  Ae 15383.992
  RREF  5.1
  PL  3
  PR 3
  NL 17
  NR 17
  a0 0.449325692555731
  a1 0.0322192612584081
  a2 0.00894469540557293
  ...
  a16 3.34614495243100
  a17 0.108832960764537
end
```]

#sourcecode()[```rust
poten 1
name "X1Sigma+"
symmetry +
lambda 0
mult  1
units cm-1
units angstroms
type grid
Interpolationtype Cubicsplines
values
2.800000 13071.271547
2.825814 12221.936011
2.851628 11434.746517
...
13.900000 3831.655762
end
```]

=== Couplings

Two examples will be given, one dipole and one spin-orbit coupling. More coupling are detailed in the documentation. Note that some optionnal keywords are not mentionned here but can be found in the documentation, such as `Interpolationtype`.

- `spin-orbit 1 2` or `dipole 1 2`: coupling between PEC 1 and PEC 2.
- `name`: name of the coupling -- only for prints.
- `lambda`, `spin`, `sigma`: $Lambda$, $S$ and $Sigma$ quantum number for both PEC. Other keywords exists, as `mult`... See documentation for more, depending on the systems.
- `units`: distance and energy units.
- `factor`: scaling factor (energy)
- `type`: build-in function or `grid`

Examples:

#sourcecode()[```rust
( 1. Spin-Orbit: A 1Sigma+ ~ b 3Pi_0 coupling --- V_A-b0 = -sqrt(2)*xi_Ab0 - Kruzins Table II [cite: 8] )
spin-orbit 1 2                 ( Couples state 1 and state 2 )
  name "<A|HSO|b0>"
  lambda 0 1
  spin   0 1
  sigma  0 -1
  units angstrom cm-1
  factor 1
  type HH
  values
    De 91.536963
    Aatom 184.6795
    re 5.529408
    a 1.820259
    b 0.455345
    c 0.487451
  end
```]

#sourcecode()[```rust

dipole 2 1
  name "1X <- 1A"
  units angstrom
  units debye
  lambda 0 0
  spin 0.0 0.0
  type grid
  values
    2.1 6.052659749799999
    2.2 8.8239254136
    2.3 9.770471623999999
    2.4 9.6825272124
    2.5 9.663718291999999
    2.6 9.7076904978
    2.7 9.789280544399999
    2.8 9.8952713526
  ...
end
```]

=== Computing spectra

#sourcecode()[```rs
intensity
 absorption
 Thresh-Einstein 1e-10
 temperature 1.0
 linelist name_of_file
 J, 0, 1
 freq-window -0.1, 22000.0
 energy low -0.1, 30.0, upper 8000.0 12000.0
end
```]

- `intensity`: keyword used for the transition section
- `absorption` or `emission`: speficies if it needs to compute absorption or emission
- `Thresh-Einstein`: threshold on the Einstein coefficients. Other thresholds exists, but I think this one is the most relevant (see documentation).
- `temperature`: for computing partition function, dummy variable in my case.
- `J`: specifies the $J$ levels that have to be taken into account in the computation of the transition. Uncorrelated to the `jrot` keyword at the beggining but takes the same kind of arguments.
- `freq-window`: frequency windows (in cm$""^(-1)$) for the transitions.
- `energy low ... high`: energy range of the lower state and the higher state. You can be restrictive in order to have fewer transitions to compute. They do not include the ZPE.
- `linelist`: filename prefix of the output file (`.trans` and `.states` file)

=== Writting the wavefunctions to the disk
In order to write the wavefunctions to the disk, the following code can be used. It will generate two files, one with the vibrational basis functions (values on a grid) and one with the expansion coefficients. `filename` is the prefix for the output checkpoint files.

#sourcecode()[```save
checkpoint
eigenfunc save
filename chk/file_name
end
```]
== Output file

=== .out file

This file contains almost every piece of information relevant to the simulation. Subsequent to the header, in which the author's information and the physical constants utilised by DUO are documented, the input file is printed. This can be advantageous because it ensures the availability of a secure copy of each input file utilised. Subsequently, a series of data pertaining to the atoms is enumerated, such as the atomic mass, the nuclear spin, and the reduced mass of the molecule. Subsequently, the grid and the PEC are printed. This process may be useful for performing a sanity check and plotting the PEC. addresses the coupling and dipoles in a similar manner. Subsequently, details pertaining to the contracted vibrational basis are displayed. While these may not be of particular pertinence in this context, they can be consulted to ascertain the overall functionality of the system.

The solutions to the coupled problem for each J will subsequently be printed, with the process commencing with the line entitled `Eigenvalues for J = 0.0`. The organisation of these elements will be by ($J,p$) blocks, where $p$ denotes the parity. The variable $i$ denotes the number of the state in this particular block. The term 'state' is employed to denote the ID of the `poten` object that possesses the highest coefficient in the expansion.
#sourcecode()[```
Eigenvalues for J =      0.0

       J      i        Energy/cm  State   v  lambda spin   sigma   omega  parity
       0.0    1       8724.961402   2     0   1     1.0    -1.0     0.0   +    ||b3pi0
       0.0    2       8774.806113   2     1   1     1.0    -1.0     0.0   +    ||b3pi0

```]

If the keyword `intensity` is used, then the transition informations will also be printed with this format:

#show raw.where(lang: "small_font"): set text(3.7pt)

#raw(lang: "small_font", block:true, "Linestrength S(f<-i) [Debye**2], Transition moments [Debye],Einstein coefficient A(if) [1/s],and Intensities [cm/mol]

    J Gamma <-  J  Gamma Typ       Ei     <-     Ef          nu_if        S(f<-i)          A(if)            I(f<-i)       State v lambda sigma  omega <-State v lambda sigma  omega 
  1.0  A\"    <- 0.0  A'    R    8749.7904 <-    24.7946   8724.9957     4.25724090E-01   2.95600291E+04   4.00321843E-16 (  3   0 -1     1.0     0.0 )<-(  1   0  0     0.0     0.0 )
  1.0  A\"    <- 0.0  A'    R    8760.6475 <-    24.7946   8735.8529     4.40336960E-06   3.06889506E-01   4.14578037E-21 (  3   0 -1     0.0    -1.0 )<-(  1   0  0     0.0     0.0 )
  1.0  A\"    <- 0.0  A'    R    8799.6350 <-    24.7946   8774.8404     2.80408206E-01   1.98056618E+04   2.65183064E-16 (  3   1 -1     1.0     0.0 )<-(  1   0  0     0.0     0.0 )")

=== .states and .trans files

The `.states` and `.states` files are generated if the keyword `intensity` is used. 

The `.states` file is a list of the states involed in the transitions, each state is described by the following line:

``` n  E        g J +/- e/f State  v |Λ| |Σ| |Ω|

1 24.794638 1 0 +   e X1Sigma+ 0  0   0   0

2 74.239245 1 0 +   e X1Sigma+ 1  0   0   0```

- n: State counting number.
- E: State energy in cm$""^(-1)$. 
- g: State degeneracy. 
- J: Total angular momentum. 
- +/-: Total parity. 
- e/f: Rotationless parity. 
- State: Electronic state label. 
- $v$: State vibrational quantum number. 
- Λ: Absolute value of Λ (projection of the electronic angular momentum). 
- Σ: Absolute value of Σ (projection of the electronic spin). 
- Ω: Absolute value of Ω = Λ + Σ (projection of the total angular momentum).
Example:

The `.trans` file is described the transitions:

```
        nf             ni  A_fi              v_fi
        1031            1  2.6862E+07        10478.783294
        1032            1  4.0242E+08        10490.670223
        1033            1  3.1481E+01        10511.503749
        1034            1  7.3507E+04        10513.099485
        1035            1  4.5985E+08        10539.090003

```

- nf : Upper state counting number.
- ni: Lower state counting number. 
- $A_"fi"$: Einstein-A coefficient in s$""^(-1)$. 
- $v_"fi"$: Transition wavenumber in cm$""^(-1)$.


=== .chk files

The checkpoints files are created if the keyword `checkpoint` is used. Two files are created: one describing the vibrational basis function with values on the grid, and one giving the expansion coefficients.


The `_vib.chk` file contains the vibrational part of the basis set in the grid representation, where the each basis function is given in a block. The first line specifies the sate (number, energy, electronic state and vibrational quantum number) followed by the grid values.
Example:

``` 499      13130.039181      2  97   A1Sigma+
 -0.195571629589E-19
 -0.417810529718E-19
 -0.105896656706E-18
 -0.718567118181E-18
...```

the `_vectors.chk` file contains the expansion coefficients of the eigenfunction in terms of the Duo vibrational basis set functions. The first eight lines describe the system. The line 9 is a header describing each column:
- `#`: counting number in the current (J, parity) block
- `J`, `p`: rotational quantum number, parity
- `Coeff`: coefficient $C_i^(J,p)$ of the expansion
- `St`, `vib`,`Lambda`, `Spin`, `Sigma`, `Omega`: quantum number of the current state of the vibrational basis
- `ivib`: unique basis set number, correspond at the first column in the `_vib.chk` file. It is a counting number including all electronic states.
\
Example:
``` Molecule = Rb-87           Cs-133         
 masses   =      86.909180531000    132.905451961000
 Nroots   =      300
 Nbasis   =      900
 Nestates =        3
 Npoints   =      800
 range   =      2.5000000    15.0000000
X1Sigma+, A1Sigma+, b3pi0,    <- States
      |   # |    J | p |           Coeff.   | St vib Lambda Spin     Sigma    Omega ivib|
         1      0.0  0   0.100000000000E+01   1   0   0      0.0      0.0      0.0    1
         1      0.0  0   0.000000000000E+00   1   1   0      0.0      0.0      0.0    2
         1      0.0  0   0.000000000000E+00   1   2   0      0.0      0.0      0.0    3
         1      0.0  0   0.000000000000E+00   1   3   0      0.0      0.0      0.0    4
         1      0.0  0   0.000000000000E+00   1   4   0      0.0      0.0      0.0    5```