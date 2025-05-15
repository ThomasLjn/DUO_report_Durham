#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#pagebreak()

= Characterisation

== Impact of the number of grid points

While  performing simulations, a multitude of degrees of freedom can exert an influence on the precision of the calculation. It is imperative to verify that our computation has indeed reached convergence.

The initial evaluation focuses on the quantity of grid points. The initial 40 vibrational energy levels with $J=0$ of the $X^1Sigma$+ electronic state of the RbCs molecule were computed for varying numbers of grid points, whilst maintaining the same internuclear range. As demonstrated in @fig:econv, the energy displays exponential convergence with the number of grid points. It may be posited that, in accordance with this plot, utilising 300 grid points would be adequate. However, it is suggested that a more prudent approach would be to employ a point count of approximately 500 to 800, thereby ensuring convergence for higher vibrational levels. The choice between affordable precision and computation time is a constant compromise. In this instance the computational was sufficiently quick to permit utilisation of 800-1000 grid points without encountering any difficulties. It was ensured that a sufficient quantity of basis functions was employed in this instance to guarantee that this was not the limiting factor.
#figure(
  box(
    width: 100%,
    pad(left: 2em, right: -1em,
      image("../resources/fig/econv_sans.svg", width: 100%)
    )
  ),
  caption:[Vibrational energy levels ($J=0$) of the $X^1Sigma^+$ electronic state of the $""^87$Rb$""^133$Cs molecule, compared to the converged value for different numbers of grid points. The converged value is taken as the energy at 900 grid points. For this comparaison, $nu_"max"$=100. The inset shows the same study against the number of vibrational basis function. The data are for $nu=20, J=10$ of the electronic ground state and for 900 grid points.]
) <fig:econv>

== Impact of the size of the basis

The inset of @fig:econv shows how the energy of a rotationally excited state converge with the number of basis functions. It is recommended by the authors of the code to use a basis of size $1.25 times nu_max +2$ to compute rotationally excited states up to $nu_max$ @yurchenko_duo_2016. It is always better to have a bit more functions to ensure the convergence, if the computation is not too slow.

== Reproducing LEVEL16 results
With LEVEL16 code, the implementation of any form of coupling between states is impossible. The $"b"^3Pi_0$ and the $"A"^1Sigma^+$ states were pre-mixed in Python, using a 2 x 2 Hamiltonian. The off-diagonal terms of this Hamiltonian correspond to the spin-orbit coupling terms. Subsequently, the newly obtained eigenstates were employed as the input states for the simulations. With DUO, it is possible to input the uncoupled states and specify the coupling, which must result in greater accuracy and physical realism. Nevertheless, as a demonstration of the underlying principle, it is encouraging to observe that DUO and LEVEL16 produce consistent results when the same input is utilised. 

With the LEVEL16 code, it is impossible to put any coupling between states. I pre-mixed the $"b"^3Pi_0$ and the $"A"^1Sigma^+$ states in python (using a $2 times 2$ Hamiltonian, the off-diagonal terms are the spin-orbit coupling terms) and use the new eigenstates as input states. In DUO, one can input the uncoupled states and specify the coupling, which will be more accurate and physically correct. However, as a proof of principle, it is nice to see that DUO and LEVEL16 are giving the same results for the same input. 
As demonstrated by @fig:level16, the difference in the energies between the two codes is neglectable.




#figure(image("../resources/fig/compar_level_duo_sans.svg", width:80%), caption:[Comparison between energies computed with LEVEL16 or DUO for the J=0 states of the $"X"^1Sigma^+$ potentiel of RbCs molecule. The difference is shown in the same plot while the inset shows. In the DUO simulation, $nu_max=100$ and $n_"grid"=800$.]) <fig:level16>

