doc ///
  Key
    isArtinian
    (isArtinian, Ideal)
    (isArtinian, QuotientRing)
  Headline
    checks if an algebra is Artinian
  Usage
    isArtinian I
    isArtinian A
  Inputs
    I:Ideal
    A:QuotientRing
  Outputs
    :Boolean
  Description
    Text
      A standard-graded $\mathbb{K}$-algebra $A$ is \emph{Artinian} if it is a 
      finite-dimensional $\mathbb{K}$-vector space. An equivalent
      definition is that $A$ is Artinian if its Krull dimension is $0$.
    Example
      R = QQ[x,y,z]
      I = ideal(x^2, y^3, z^4)
      A = R / I
      isArtinian A
///


doc ///
  Key
    socleDegree
    (socleDegree, Ideal)
    (socleDegree, QuotientRing)
  Headline
    computes the socle degree
  Usage
    socleDegree I
  Inputs
    I:Ideal
    A:QuotientRing
  Outputs
    :ZZ
  Description
    Text
      The \emph{socle degree} of an Artinian algebra is maximum degree of the 
      (minimal) generator(s) of the socle $(0 \colon \mathfrak{m})$.
    Example
      R = QQ[x,y,z]
      I = ideal(x^2, y^3, z^4)
      A = R / I
      socleDegree I
///


doc ///
  Key
    hasWLP
    (hasWLP, Ideal)
    (hasWLP, RingElement)
    (hasWLP, QuotientRing)
    [hasWLP, MaxTries]
    [hasWLP, LinearForm]
  Headline
    checks the weak Lefschetz property
  Usage
    hasWLP I
    hasWLP F
    hasWLP A
  Inputs
    I:Ideal
    F:RingElement
    A:QuotientRing
  Outputs
    :Boolean
  Description
    Text
      An Artinian algebra $A$ has the \emph{weak Lefschetz property} (\emph{WLP}) 
      if there exists a general linear form $\ell \in A_1$ such that 
      $\cdot \ell \colon A_d \to A_{d+1}$ has full rank for all $d \geq 0$.
      Since $\ell$ is a \emph{general} linear form, this method either finds
      such a linear form, or it checks a number of random linear forms to perform
      a probabilistic check of \emph{not} having the WLP.
    Example
      R = QQ[x,y,z]
      I = ideal(x^2, y^3, z^4)
      A = R / I
      hasWLP A
    Text
      If $\cdot \ell$ is not full rank, {\tt MaxTries} (default value is $10$)
      may be passed as an optional argument to specify how many linear forms to 
      sample and check for the WLP. If one is found, then {\tt true} is returned;
      otherwise, {\tt false} is returned.
    Example
      -- From Brenner-Kaid [2007]
      R = QQ[x,y,z]
      I = ideal(x^3, y^3, z^3, x*y*z)
      A = R / I
      hasWLP A
    Text
      When a {\tt RingElement} is passed as the argument, this is taken to be
      \emph{the} Macaulay dual generator used to produce an Artinian Gorenstein
      algebra, i.e., $A = S / \text{Ann}_S(F)$. The WLP is then checked on that
      algebra.
    Example
      R = QQ[u,v,x,y,z]
      F = x^2*u^3 + x*y*u^2*v + y^2*u*v^2 + z^2*v^3
      hasWLP F
    Text
      One may also pass use the {\tt LinearForm} optional argument to test the
      WLP with a specific linear form.
  Caveat
    If {\tt true} is returned, the Artinian algebra is guaranteed to have the 
    WLP. On the other hand, if {\tt false} is returned, this is a 
    \emph{probabilistic} check for the WLP.
  SeeAlso
    hasSLP
///


doc ///
  Key
    hasSLP
    (hasSLP, RingElement)
    -- (hasSLP, Ideal)
    -- (hasSLP, QuotientRing)
    [hasSLP, MaxTries]
    [hasSLP, LinearForm]
  Headline
    checks the strong Lefschetz property
  Usage
    hasSLP F
    hasSLP I
    hasSLP A
  Inputs
    F:RingElement
    I:Ideal
    A:QuotientRing
  Outputs
    :Boolean
  Description
    Text
      An Artinian algebra $A$ has the \emph{strong Lefschetz property} 
      (\emph{WLP}) if there exists a general linear form $\ell \in A_1$ such 
      that $\cdot \ell^k \colon A_d \to A_{d+k}$ has full rank for all 
      $d \geq 0$ and $k \geq 0$.

      When a {\tt RingElement} is passed, this must be a homogeneous polynomial
      of degree $d$. It is interpretated as \emph{the} Macaulay dual generator
      of an Artinian Gorenstein algebra, i.e., $A = S / \text{Ann}_S(F)$.
    Example
      R = QQ[x,y,z,w]
      F = w^3*x*y + w*x^3*z + y^3*z^2
      hasSLP F
    Text
      If $\cdot \ell$ is not full rank, {\tt MaxTries} (default value is $10$)
      may be passed as an optional argument to specify how many linear forms to 
      sample and check for the SLP. If one is found, then {\tt true} is returned;
      otherwise, {\tt false} is returned.

      One may also pass use the {\tt LinearForm} optional argument to test the
      SLP with a specific linear form.
  Caveat
    If {\tt true} is returned, the Artinian algebra is guaranteed to have the 
    SLP. On the other hand, if {\tt false} is returned, this is a 
    \emph{probabilistic} check for the SLP.
  SeeAlso
    hasWLP
///


-- doc ///
--   Key
--     MaxTries
--   Headline
--     The maximum number of attempts to check for a Lefschetz element
--   SeeAlso
--     [MaxTries, hasWLP]
--     [MaxTries, hasSLP]
-- ///


-- doc ///
--   Key
--     LinearForm
--   Headline
--     A linear form to use as a candidate Lefschetz element
--   SeeAlso
--     [LinearForm, hasWLP]
--     [LinearForm, hasSLP]
-- ///