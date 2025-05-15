#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#import "@preview/physica:0.9.5": *

#pagebreak()

= Theoretical background

== Methods of resolutions
The methods used in DUO are well described in @yurchenko_duo_2016, I will simply do a summary of the main ideas of the section 2 of this paper.

The non relativistic Hamiltonian of a diatomic molecule can be writte as:
$ hat(H)_"tot" = hat(H)_"e" + hat(H)_mu + hat(H)_"vib" + hat(H)_"rot" +  $

Where $hat(H)_"e"$ is the electronic Hamiltonian, with ${xi_i}_i$ the set of electronic coordinates, $r$ is the internuclear distance and $V$ the Coulomb electrostatic interactions between all particles: 
$ hat(H)_"e" = -planck.reduce^2/(2m_e) sum_(i=1)^N_e nabla_i^2 + V(r, xi_i) $ 

$hat(H)_mu$ is the mass-polarization term, where $m_N$ is the total nuclear mass. 

$ hat(H)_mu = -planck.reduce/(2m_N) sum_(i=1)^N_e sum_(j=1)^N_e nabla_i dot nabla_j $

$hat(H)_"vib"$ is the vibrational kinetic energy operator, with $mu$ the reduced mass of the molecule.
$ hat(H)_"vib" = -planck.reduce^2/(2 mu) (dif r)/(dif r^2) $

$hat(H)_"rot"$ is the rotational Hamiltonian and can be expression in terms of the body-fixed rotational angular momentum operator $hat(bold("R"))=hat(bold("J"))-hat(bold("L"))-hat(bold("S"))$ where $hat(bold("L"))$ is the total angular momentum, $hat(bold("J"))$ the electron orbital angular momentum and $hat(bold("S"))$ the spin angular momentum. With $hat(bold(K))$ an angular momentum, we can define the ladder operators: $hat(K)_(plus.minus) = hat(K)_x plus.minus hat(K)_y$. We can then express the rotational Hamiltonian:
$ hat(H)_"rot" &= planck.reduce^2/(2 mu r^2)hat(bold("R"))^2 \ &= planck.reduce^2/(2 mu r^2) [(hat(J)^2 - hat(J)_z^2)+(hat(L)^2 - hat(L)_z^2)+(hat(S)^2 - hat(S)_z^2) \ &+ (hat(J)_+ hat(S)_- + hat(J)_- hat(S)_+) - (hat(J)_+ hat(L)_- + hat(J)_- hat(L)_+) +(hat(S)_+ hat(L)_- + hat(S)_- hat(L)_+) ] $

The input of DUO is the electronic potential. It is assumed that the electronic problem has already been solved. The subsequent objective is to resolve the vibrational problem, which is known as the uncoupled problem. The construction of a basis of vibrational functions is a prerequisite for the expansion of rovibrational wavefunctions. In this basis of functions, the complete rovibronic Hamiltonian is solved (coupled problem). In the case of the addition of certain couplings, these are included in the full Hamiltonian. In conclusion, the wavefunction of each rovibrational state is expressed as an expansion in the basis set of function labelled by $ket(n) = ket(#text([state, $J$, $Omega$, $Lambda$, $S$, $Sigma$, $v$]))$, with $tau$ the parity ($plus.minus$), $lambda$ a counting index:
$ Phi_lambda^(J, tau) = sum_n C_(lambda, n)^(J, tau) ket(n) $ <eq:expansion>

In the general case, the only goof quantum numbers ($i.e.$ labels associated with the eigenvalues of symmetry operators) are the total angular momentum value $J$ and the parity $tau$. Other numbers are estimated by DUO by looking at the highest coefficient in this expansion.

