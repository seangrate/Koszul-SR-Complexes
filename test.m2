dataCollection = method()
dataCollection (Ring,SimplicialComplex) := List => (R,K) -> (
    idealDataList = {}
    I = ideal K
    Q = R/I
    hS = hilbertSeries(I, Reduce=>true)
    B = betti res I
    hWLPO = hasWLPOptimized(Q)
    hWLP = hasWLP(Q)
    hSLP = hasSLP(Q)
    hKT = hasKoszulTail B
    iA = isArtinian Q
    iM = hasKoszulTail(B, Maximal=>true)
    if hKT then kt = koszulTails B else kt = null
    idealDataList = append(idealDataList, {{"original"}, hS, B, iA, hWLP, hSLP, hKT, iM, kt});
    for i from 2 to 5 do (
        J = I + (ideal vars R)^i;
        A = R/J;
        ph = hilbertSeries(J, Reduce=>true);
        pB = betti res J;
        phWLP = hasWLP(A);
        phSLP = hasSLP(A);
        phKT = hasKoszulTail pB;
        piA = isArtinian (A);
        piM = hasKoszulTail(pB, Maximal=>true);
        if phKT then pkt = koszulTails pB else pkt = null;
        idealDataList = append(idealDataList, {{i}, ph, pB, piA, phWLP, phSLP, phKT, pkt, piM});
    );
    for i from 1..10 do (
        randomPowers = ideal for gen in R_* list gen^(random(2, 5))
        J = I + randomPowers
        A = R/J
        rh = hilbertSeries(J, Reduce=>true)
        rB = betti res J
        rhWLP = hasWLP(A)
        rhSLP = hasSLP(A)
        rhKT = hasKoszulTail rB
        riA = isArtinian (A)
        riM = hasKoszulTail(B, Maximal=>true)
        if rhKT then rkt = koszulTails rB else rkt = null
        idealDataList = append(idealDataList, {{"random"}, rh, rB, riA, rhWLP, rhSLP, rhKT, riM, rkt});
    )
    return {idealDataList};
)