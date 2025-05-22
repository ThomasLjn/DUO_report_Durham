#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#import "@preview/physica:0.9.5": *
#pagebreak()

= Differential transition width $Gamma$

The objective of this section is to compute the differential transition width $Gamma$, defined in the direct imaging paper @guan_nondestructive_2020 with DUO software. With the particular choice of target excited states, $Gamma$ can be computed with <gamma1>, where $planck.reduce omega_("t"-"im")=E_"t"- E"im"$ where $E_"im"$ is the eigenenergy of the imaging state. $mu_n'$ is a vibrational matrix element that we will need to compute.

$ Gamma = 4/3 1/(4 pi epsilon_0 planck.reduce c ^3) (abs(c_0)^2/3 - abs(c_1)^2/6) w_("t"-"im")^3 abs(mu_n')^2 $ <gamma1>

Because our target vibrational states are coupled between $"A"^1Sigma^+$ and $"b"^3Pi_0$ states, then the wavefunction is given by @wf@guan_nondestructive_2020 where the index $n'$ labels eigenstates by order of their eigenenergies. DUO calculations can give access to the $f_("A", n') (R)$ and $f_("b", n') (R)$, using @eq:expansion.

$ ket(Psi_("t", n')) = 1/sqrt(4 pi)(f_("A", n')(R) ket("A"^1Sigma^+) + f_("b", n')(R) ket("b"^3Pi_0)) times ket(i_"Rb" m'_"Rb") ket(i_"Cs " m'_"Cs") $ <wf>

With this notations, the vibrational matrix element $mu_n'$ can be defined @guan_nondestructive_2020:
$ mu_n' = integral_0^infinity f_("A", n')(R) d_("A"<-"X")(R)phi_"perp"(R) R^2 dif R $ <mun>

Where $phi_"perp"$ is a state definde in the direct imaging paper as the initial state for the perpendicular dispersive imaging. It is defined as the energetically lowest $J = 1$ hyperfine state. In first approximation, that $phi_"perp"$ wavefunction will be the same as the $v=0, J=1$ state of the electronic ground state. As hyperfine interactions are very weak compared to the other interactions here, the effect on the wavefunction can be neglected.
== Computing the wavefunctions

Using the `checkpoint` keyword, the basis functions and the expansion coefficients can be written in a file. Because each coefficient is associated with a basis function of a specific electronic state, it is possible to compute only the wavefunction associated to the $"A"^1Sigma^+$ state for instance.

In DUO, the wavefunctions are normalized on a grid, with $r_i$ the points on the grid and $Delta r$ the grid step: 
$ sum_i abs(psi(r_i))^2 = Delta r $


In the direct imaging paper, it looks like (not directly mentionned) that the wavefunctions are normalized such that 

$ integral_0^infinity abs(psi(R))^2 R^2 dif R = 1 $

A first analysis can be to compute and write the wavefunctions (separated between the two coupled electronic states) in a separated file. Then, the wavefunctions can be plotted. @fig:wf shows the contributions of each excited electronic state to the global wavefunction. The quantity plot is the $f_("A",n')$ and $f_("b",n')$ defined in @wf. The right pannel shows the wavefunction of the electronic ground state ($nu=0, J=1$). Here, the wavefunctions are devided by $sqrt(Delta r)$ to account for normalization factor from the vibrational basis functions. One can also plot the basis wavefunctions and verify the normalization condition in DUO. 

#figure(image("../resources/fig/wf_sans.svg", width:120%), caption:[Wavefunction amplitude for $nu=4, J=0$ states of the excited complex, for both parities. The right pannel shows the wavefunction of the vibronic ground state for $J=1$, which will be used for $ket(phi_"perp")$.]) <fig:wf>


== Integral computation

In order to compute $mu_n'$, an integral has to be computed. In this analysis, the trapezoid rule (@trapz) has been used. With 900 grid points, it should be accurate enough but other more precise methods (as the Simpson method) can also be used.

The trapezoid method equation involved multiplying by the grid step $Delta r$. One can either devide the wavefunctions computed by DUO with $sqrt(Delta r)$ or devide the computed integral by $Delta r$ at the end. This is equivalent.

$ integral_(r_min)^(r_max) f(R)dif R tilde.eq sum_(i=1)^N (f(r_(i+1))-f(r_i))/(2 times Delta r_i) $ <trapz>

However, between the direct imaging papier @guan_nondestructive_2020 and DUO computation, the wavefunctions are not normalized the same way. To account for this difference, we integrand (@mun) has to be devided by $R^2$. So the correct matrix element to compute is:

$ mu_n'^"DUO"  = 1/(Delta r)integral_0^infinity f_("A", n')(R) d_("A"<-"X")(R)phi_"perp"(R) dif R $

The integrals has been computed for 100 eigenstates of the excited complex with $J=0$ and then written in a file. At each step a new file is written, this allows faster analysis and checkup of the code. $Gamma$ can be computed with these integrals, the result is shown in @Gamma. The highest value is 202~kHz, which is very close to the 201~kHz of the litterature @guan_nondestructive_2020.


#figure(image("../resources/fig/Gamma_sans.svg", width:75%), caption:[Differential transition linewidth of eigenstates of the $J'=0$ $"A"^1Sigma^+-"b"^3Pi_0$ complex of $""^87$Rb$""^133$Cs molecule.]) <Gamma>


The figure 8 from the direct imaging paper @guan_nondestructive_2020 can then be "reproduced", as shown in fig @3plots. A similar graphical chart as in the paper has been used for better comparison between both figures. The value of the relevant $gamma/Gamma$ points are 12 and 19 in the article. The results of DUO simulations gives 9 and 20, which is still close. The issue the probably in the lifetime computation, since it is the plot with the most differences.

#figure(image("../resources/fig/combined_spectroscopy.svg", width:90%), caption:[Lifetime (top panel), transition linewidth (middle panel) and ratio of both (bottom panel) of eigenstates of the $J'=0$ $"A"^1Sigma^+-"b"^3Pi_0$ complex of NaRb molecule. Left pannel: DUO simulations. Right pannel: direct imaging paper @guan_nondestructive_2020]) <3plots>

