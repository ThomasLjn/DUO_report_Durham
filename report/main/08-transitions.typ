#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#import "@preview/physica:0.9.5": *
#pagebreak()

= Transitions
== Absorption and emissions

This section will concentrate on computing transitions from the state #ket($"X"^1Sigma^+, nu''=0, J=1$) to some excited states #ket($"A"^1Sigma^+ - "b"^3Pi_0, nu', J'=0$). The same method can be used to compute other transitions.  The simulations were conducted with the three states and the spin-orbit coupling. For each potential energy curve, the number of vibrational basis functions was 300. The grid was delineated from a minimum radius of 2.5 angstroms to a maximum radius of 15 angstroms and a total of 800 grid points. From the initial state, one of the most probable transition absorption is to the state #ket(($"A"^1Sigma^+ - "b"^3Pi_0, nu'=20, J'=0$)), with a transition energy of 10692.5409 $"cm"^(-1)$ (Top part of @abs_em). This excited state will mainly decay to the ground state ($J=1$), see the bottom part of the @abs_em.

== Lifetimes

@lifetime shows the lifetime of some excited eigenstates of the $"A"^1 Sigma^+-"b"^3Pi_0$ complex. This quantity is computed with 800 grid points and 400 basis functions for each potential energy curve. The lifetime is the sum of the decay Einstein coefficients, where $f$ is a $"X"^1Sigma^+$ rovibrational state:

$ gamma_i = sum_f A_(i,f) $

The figure shows some difference with the direct imaging paper figure @guan_nondestructive_2020 ( @3plots ). I tried to increase the number of grid points and the number functions in the vibrational basis but nothing changed. A first hypothesis was about the accuracy of the dipole moments/PEC but in fact it should not be caused by that since:
- They are the same that claimed by the paper
- The differential linewidth plot is very similar and is calculated from the wavefunctions and the transition dipole moment

The main differences are the states with "low" value of $gamma$ (around 2~MHz): they have an higher lifetime than in the direct imaging paper and also at high energy, the trend is not the same as in the paper.

#figure(image("../resources/fig/abs_em_sans.svg", width:130%), caption:[Einstein coefficients in MHz over the transition energy in $"cm"^(-1)$. The top of the plot is related to the emission spectra from the ground state to the excited complex. The bottom of the plot is related to the emission from the excited $nu'=20, J=0$ state to the electronic ground state. The states labels ($"A"^1Sigma^+$ and $"b"^3Pi_0$) are the output from DUO and related to the highest coefficient in the expansion (@eq:expansion).], placement:auto) <abs_em>


#figure(image("../resources/fig/lifetime_sans.svg"), caption:[Lifetime $gamma$ of eigenstates of the $J'=0$ $"A"^1 Sigma^+-"b"^3Pi_0$ complex of RbCs molecule. The reference in energy is the minimum of potential of the $"X"^1Sigma+$ potential energy curve. ], placement:auto) <lifetime>
