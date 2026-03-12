TEST ///
    -- hasKoszulTails
    -- This is a Betti table with a maximal (3,1)-Koszul tail and nothing else.
    B = new BettiTally from {(0,{0},0) => 1, 
                             (1,{2},2) => 3, (2,{3},3) => 3, (3,{4},4) => 1}

    assert(hasKoszulTail(3, 1, B))
    assert(hasKoszulTail(3, 1, B, Maximal=>true))
    assert(hasKoszulTail B)
    assert(hasKoszulTail(B, Maximal=>true))

    -- This is a Betti table with a non-maximal (3,1)-Koszul tail.
    B = new BettiTally from {(0,{0},0) => 1, 
                             (1,{2},2) => 3, (2,{3},3) => 3, (3,{4},4) => 1,
                             (1,{3},3) => 2, (2,{4},4) => 4, (3,{5},5) => 2, (4,{6},6) => 1}
    assert(hasKoszulTail(3, 1, B))
    assert(not hasKoszulTail(3, 1, B, Maximal=>true))
    assert(hasKoszulTail B)
    assert(not hasKoszulTail(B, Maximal=>true))
///

TEST ///
    -- koszulTails
    -- This is a Betti table with a maximal (3,1)-Koszul tail and nothing else.
    B = new BettiTally from {(0,{0},0) => 1, 
                             (1,{2},2) => 3, (2,{3},3) => 3, (3,{4},4) => 1}

    assert(koszulTails B == {(3, 1)})
    assert(koszulTails(B, Maximal=>true) == {(3, 1)})

    -- This is a Betti table with a non-maximal (3,1)-Koszul tail.
    B = new BettiTally from {(0,{0},0) => 1, 
                             (1,{2},2) => 3, (2,{3},3) => 3, (3,{4},4) => 1,
                             (1,{3},3) => 2, (2,{4},4) => 4, (3,{5},5) => 2, (4,{6},6) => 1}
    assert(koszulTails B == {(3, 1)})
    assert(koszulTails(B, Maximal=>true) == {})
///