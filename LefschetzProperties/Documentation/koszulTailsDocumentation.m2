doc ///
  Key
    hasKoszulTail
    (hasKoszulTail, BettiTally)
    (hasKoszulTail, ZZ, ZZ, BettiTally)
    Maximal
    [hasKoszulTail, Maximal]
  Headline
    checks if a BettiTally has a Koszul tail
  Usage
    hasKoszulTail B
  Inputs
    B:BettiTally
  Outputs
    :Boolean
  Description
    Text
      See Definition 1 of Grate-Schenck [2024] for the definition of an 
      $(n,d)$-Koszul tail. The following example has a $(3,1)$-Koszul tail, 
      which can be checked with {\tt hasKoszulTail(n, d, B)}. To check for the 
      presence of \emph{some} Koszul tail, {\tt hasKoszulTail B} is available.
    Example
      B = new BettiTally from new BettiTally from {(0,{0},0) => 1, (1,{2},2) => 3, (2,{3},3) => 3, (3,{4},4) => 1}
      hasKoszulTail(3, 1, B)
      hasKoszulTail B
    Text
      Moreover, we can check if the tail is maximal with the {\tt Maximal}
      optional argument.
    Example
      hasKoszulTail(B, Maximal=>true)
  SeeAlso
    koszulTails
///

doc ///
  Key
    koszulTails
    (koszulTails, BettiTally)
    [koszulTails, Maximal]
  Headline
    finds all of the Koszul tails of a BettiTally
  Usage
    koszulTails B
  Inputs
    B:BettiTally
  Outputs
    :List
  Description
    Text
      See Definition 1 of Grate-Schenck [2024] for the definition of an 
      $(n,d)$-Koszul tail. This method returns a list of all of the pairs 
      $(n,d)$ such that the supplied Betti table has an $(n,d)$-Koszul tail.
    Example
      B = new BettiTally from new BettiTally from {(0,{0},0) => 1, (1,{2},2) => 3, (2,{3},3) => 3, (3,{4},4) => 1}
      koszulTails B
    Text
      Moreover, if the {\tt Maximal} optional argument is supplied, only the
      list of pairs $(n,d)$ corresponding to present maximal $(n,d)$-Koszul 
      tails will be returned.
    Example
      koszulTails(B, Maximal=>true)
  SeeAlso
    hasKoszulTail
///