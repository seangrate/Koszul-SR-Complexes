doc /// 
  Key
    "LefschetzProperties"
  Headline
    a package providing methods for checking Lefschetz properties
  Description
    Text
      This package provides methods to check if Artinian algebras have Lefschetz 
      properties. An overview of the package can be found in the 
      @TO "All Things Lefschetz Guide"@.
///

doc ///
  Key
    "All Things Lefschetz Guide"
  Headline
    a detailed overview of Lefschetz properties in Macaulay2
  Description
    Text
      This page gives an overview of the methods used to check Lefschetz
      properties of Artinian algebras. This package assumes that $R$ is
      a standard-graded $\mathbb{K}$-algebra ($\mathbb{K}$ is a field),
      and $S = R/I$ is a quotient by a homogeneous ideal $I \subseteq R$.

      The sections of the overview are, in order:

      {\bf Artinian algebras.} @BR{}@
      {\bf Lefschetz properties.} @BR{}@
      {\bf Known results.} @BR{}@

      Links to individual documentation pages for the functions 
      described in this article are collected in an alphabetized list 
      at the very end of the page.


      {\bf Artinian algebras.}

      There are many equivalent definitions of \emph{Artinian}, but one is that
      $S$ is an Artinian algebra if it is a finite-dimensional 
      $\mathbb{K}$-vector space. One can check if $S$ is Artinian with the 
      {\tt isArtinian} method:

    Example
      R = QQ[x,y,z]
      I = ideal(x^2, y^3, z^4)
      S = R / I
      isArtinian S

    --
    Text

     {\bf Lefschetz properties.}

      An Artinian algebra $A = R/I$ is said to have the 
      \emph{weak Lefschetz property} (\emph{WLP}) if there exists a general 
      linear form $\ell \in A_1$ such that $\cdot \ell \colon A_d \to A_{d+1}$
      is full rank for all $d \geq 0$, i.e., if $\cdot \ell$ is either injective
      or sujective in each degree.

      Since $\ell$ is a \emph{general} linear form, to show that $A$ has the 
      WLP, it suffices to find such an $\ell$. This can be checked with the
      {\tt hasWLP} method:
    
    Example
      R = QQ[x,y,z]
      I = ideal(x^2, y^3, z^4)
      A = R / I
      hasWLP A
    
    Text
      On the other hand, if {\tt false} is returned, this is the result of a
      \emph{probabilistic} check by testing with a number of random linear forms.
      Importantly, this does not guarantee that $A$ has the WLP.

    Example
      -- From Brenner-Kaid [2007]
      R = QQ[x,y,z]
      I = ideal(x^3, y^3, z^3, x*y*z)
      A = R / I
      hasWLP A

    --
    Text

      {\bf Known results.}

      There are many results for determining if certain Artinian algebras have
      the WLP.

  SeeAlso
    (hasWLP, Ideal)
///