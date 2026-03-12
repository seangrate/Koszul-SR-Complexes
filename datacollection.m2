dataCollection = method()
dataCollection (Ring,SimplicialComplex) := List => (R,K) -> (
    idealDataList = {};
    I = ideal K;
    Q = R/I;
    for i from 2 to 5 do (
        J = I + (ideal vars R)^[i];
        A = R/J;
        pH = hilbertSeries J;
        pnum = numerator pH;
        reg = regularity J;
        phS = for k from 0 to (reg-1) list hilbertFunction(k, J);
        sumph = sum phS;
        pmL = apply(1..reg, j -> sumph % j);
        pB = betti res J;
        phWLP = hasWLP(A);
        phSLP = hasSLP(A);
        phKT = hasKoszulTail pB;
        piA = isArtinian (A);
        piM = hasKoszulTail(pB, Maximal=>true);
        if phKT then pkt = koszulTails pB else pkt = null;
        idealDataList = append(idealDataList, {i, pnum, phS, pmL, pB, piA, phWLP, phSLP, phKT, pkt, piM});
    );
    for i from 1 to 10 do (
        randomPowersList = for j from 0 to #gens R - 1 list (gens R)_j^(random(0, 4));
        for j from 0 to 8 do (
            randomPowersList = for k from 0 to #gens R - 1 list randomPowersList_k * (gens R)_k;
            randomPowers = ideal randomPowersList;
            J = I + randomPowers;
            A = R/J;
            rH = hilbertSeries J;
            rnum = numerator rH;
            reg = regularity J;
            rhS = for k from 0 to (reg-1) list hilbertFunction(k, J);
            sumrH = sum rhS;
            rmL = apply(1..reg, k -> sumrH % k);
            rB = betti res J;
            rhWLP = hasWLP(A);
            rhSLP = hasSLP(A);
            rhKT = hasKoszulTail rB;
            riA = isArtinian (A);
            riM = hasKoszulTail(rB, Maximal=>true);
            if rhKT then rkt = koszulTails rB else rkt = null;
            idealDataList = append(idealDataList, {"random" | toString(i) | " + " | toString(j) | " : " | toString(randomPowersList), rnum, rhS, rmL, rB, riA, rhWLP, rhSLP, rhKT, rkt, riM});
        );
    );  
    idealDataList
)