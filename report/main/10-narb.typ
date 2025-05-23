#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#import "@preview/physica:0.9.5": *
#pagebreak()

= Results on NaRb

Using the exact same methods and protocoles and using the PEC, dipole moment and spin-orbit coupling mentionned in the direct imaging paper @guan_nondestructive_2020, the following figures are showing the lifetime, differential transition width and the ratios as before but for the NaRb molecule. We can see that as for RbCs molecule, the differential transition width is in very good agreement with the paper. However, the lifetime is of the good order of magnitude but not accurate enough to have the right ratios.

#figure(image("../resources/fig/NaRb_PEC_coupling_sans.svg"), caption:[*A*: Potential energy curves of the relevant electronic states of NaRb molecule. *B* Transition dipole moment between $"X"^1Sigma^+$ and $"A"^1Sigma^+$ states. *C*: Spin-orbit coupling between $"A"^1Sigma^+$ and $"b"^3Pi^0$ states.])

#figure(image("../resources/fig/NaRb_lifetime_sans.svg"), caption:[Lifetime $gamma$ of eigenstates of the $J'=0$ $"A"^1 Sigma^+-"b"^3Pi_0$ complex of NaRb molecule. The reference in energy is the minimum of potential of the $"X"^1Sigma+$ potential energy curve. ])

#figure(image("../resources/fig/NaRb_Gamma_sans.svg"), caption: [Differential transition linewidth of eigenstates of the $J'=0$ $"A"^1Sigma^+-"b"^3Pi^0$ complex of NaRb molecule])

#figure(image("../resources/fig/NaRb_combined_spectroscopy.svg") , caption:[Lifetime (top panel), transition linewidth (middle panel) and ratio of both (bottom panel) of eigenstates of the $J'=0$ $"A"^1Sigma^+-"b"^3Pi_0$ complex of NaRb molecule. Left pannel: DUO simulations. Right pannel: direct imaging paper @guan_nondestructive_2020])