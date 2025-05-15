#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#pagebreak()

= Mixing coefficients

In the RbCs molecule, the $"A"^1Sigma$ and $"b"^3Pi_0$ states are coupled by spin-orbit interactions. The potential energy curves and the spin-orbit functions utilised in this study were derived from Ref. @kruzins_extended_2014. The computed rovibrational states are found to exhibit a mixture, rather than a pure attribution to any single state. In the DUO system, the utilisation of the 'checkpoint' keyword allows for the storage of expansion coefficients in a file. The proportion $alpha$ of $"A"^1Sigma$ or $"b"^3Pi_0$ of one particular state $lambda$ can then be computed from the @eq:expansion, where the electronic state is denoted $Lambda$.
The following equation is to be solved: $alpha_lambda^Lambda = sum_n (C^J, tau)² delta_"state", Lambda$.

It is evident that, in the case of the simulation being populated with only these two electronic states, the calculation of a single $alpha_lambda$ is sufficient, since $alpha_lambda^("A"^1Sigma⁺) = 1-alpha_lambda^("b"^3Pi_0)$.


Table I from the supplementary data of Ref @kruzins_extended_2014 gives some experimental energies and computed mixing coefficients (see @list:table1). The main goal of this part is to see wheter it is possible to reproduce these data using DUO calculations. For these calculations, I only included the spin-orbit coupling, the $"A"^1Sigma^+$ and the $"b"^3Pi_0$ states. Other couplings could be added to have more precision if needed.


#figure(sourcecode()[```
=================================================================
N   i   J   Eexpt   Ecalc   Del   A%   b0%   b1%   b2%
=================================================================
1   0   139   10928.612   10928.614   -0.002   73   26.9   0.1   0
2   0   141   10935.797   10935.802   -0.005   73.5 26.4   0.1   0
3   0   142   10939.419   10939.429   -0.01    73.7 26.2   0.1   0
4   0   143   10943.074   10943.078   -0.004   73.9 26     0.1   0
5   0   148   10961.676   10961.679   -0.003   73.7 26     0.3   0
6   0   149   10965.471   10965.477   -0.006   73.3 26.3   0.4   0
7   0   150   10969.302   10969.306   -0.003   72.7 26.8   0.5   0
8   0   151   10973.163   10973.169   -0.006   71.8 27.5   0.7   0
9   0   125   10607.937   10607.936    0.001   50   50       0   0
```], caption:[Extract of TableI.txt, $N$ is the line number, i refers to the isotope and $J$ is the rotational quantum number. Del is the difference between their simulation and experimental energies @kruzins_extended_2014.]) <list:table1>

The isotope of interest is $""^87"Rb"^133"Cs"$. Subsequently, it is imperative to implement a preliminary filtration process on the designated file, with the  condition of `i=1`. In consideration of the symmetry of the the $"A"^1Sigma$ state, a comparison is to be made exclusively with those states that exhibit $(-1)^J$ parity. Conversely, states with the opposite parity will not be mixed and will be 100% $"b"^3Pi_0$ states.

Following the computation of rovibrational states with DUO, for J ranging from 0 to 10 and from 70 to 80, a comparison can be made by searching for the state with the correct parity and $J$ value that has the closest energy to $"E"_"exp"$ from Table I. Subsequently, all the pertinent information can be written in file (cf. @list:diff ). In order to facilitate the analysis, it is first possible to retrieve all the state information from the `.out` file, and then write them in a separate file (cf. @list:out). The same process can be repeated for the mixing coefficient (cf @list:chk). The process of opening large files can be time-consuming; therefore, it is advisable to undertake the preliminary step of formatting the file in order to reduce the time taken.

The resultant extract of the formatted file, which was produced by the analysis code, can be found in @list:out, @list:chk and @list:diff. @Amixing provides a comprehensive overview of the differences between the Table I@kruzins_extended_2014 and the calculations from DUO.  The magnitude of the energy difference is consistently less than $1~"cm"^(-1)$, and in the majority of cases, it is less than $0.1~"cm"^(-1)$. The points that exhibit the optimal match in terms of mixing coefficients are those that demonstrate the closest proximity in energy to the experimental values. The figure is indicative of a trend, with the points exhibiting the highest differences in mixing coefficients being those with the highest vibrational quantum number $nu$ and the highest energy difference with the litterature.

#figure(sourcecode()[```
   J       i(#)         E state  v lambda spin  sigma  omega parity
   0.0      1    8724.9614   2   0   1   1.0  -1.0   0.0 +
   0.0      2    8774.8061   2   1   1   1.0  -1.0   0.0 +
   0.0      3    8824.5188   2   2   1   1.0  -1.0   0.0 +
   0.0      4    8874.0994   2   3   1   1.0  -1.0   0.0 +
```], caption:[Example of formatted `.out` file]) <list:out>

#figure(sourcecode()[```
# Root  J Par SumCoeffSq(St=1) SumCoeffSq(St=2)
    1   0.0 0   0.00489879   0.99510121
    2   0.0 0   0.00518921   0.99481079
    3   0.0 0   0.00551109   0.99448891
    4   0.0 0   0.00586926   0.99413074
    5   0.0 0   0.00000000   0.00000000
    6   0.0 0   0.00626953   0.99373047
```], caption:[Example of formatted `.chk` file]) <list:chk>

#figure(sourcecode()[```
   I p   J  v        Eexpt        Eduo    diff A_duo  b0_duo A_paper b0_paper
---- - --- ------------ ----------- ------- ------ ------ ------- --------
 114 -  71  12   10477.0490  10476.8858  -0.16  60.18  39.82  65.60  34.30
 114 +  72  11   10478.9660  10478.8331  -0.13  62.71  37.29  67.00  32.90
 114 -  73  11   10480.9040  10480.7928  -0.11  64.85  35.15  68.30  31.60
 114 +  74  11   10482.8620  10482.7666  -0.10  66.66  33.34  69.30  30.60
 114 -  75  11   10484.8390  10484.7562  -0.08  68.15  31.85  70.30  29.60
 114 +  76  11   10486.8340  10486.7630  -0.07  69.38  30.62  71.10  28.80
 114 -  77  11   10488.8510  10488.7885  -0.06  70.39  29.61  71.70  28.20
 105 -  71   7   10374.3460  10374.3173  -0.03  70.94  29.06  71.30  28.70
 105 +  72   7   10376.2450  10376.2158  -0.03  71.37  28.63  71.70  28.30
 105 -  73   7   10378.1660  10378.1377  -0.03  71.76  28.24  72.00  28.00
 105 +  74   7   10380.1080  10380.0832  -0.02  72.10  27.90  72.30  27.60

```], caption:[Example of computed difference output file]) <list:diff>



#figure(image("../resources/fig/Acoeff_sans.svg"), caption:[Comparison between the $"A"^1Sigma^+$ mixing coefficient given in Table I @kruzins_extended_2014 and the ones computed with DUO. The size of the circle are related to the absolute difference in cm$""^(-1)$ between the experimental energy of Table I and the computed energy in DUO. The color is related to the vibrational quantum number of each computed state.], placement: auto, gap:-3em) <Amixing>