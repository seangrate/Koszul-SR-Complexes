isArtinian = method()
isArtinian Ideal := Boolean => (I) -> (isArtinian((ring I) / I))
isArtinian QuotientRing := Boolean => (S) -> (dim S == 0)


socleDegree = method()
socleDegree Ideal := ZZ => (I) -> (
    A := (ring I) / I;
    m := ideal vars A;
    j := 0;
    while m^j != 0 do j = j+1;
    j-1
)
socleDegree QuotientRing := ZZ => (A) -> (socleDegree ideal presentation A)


hasWLP = method(
    Options => {
        MaxTries => 10,
        LinearForm => null
    }
)
hasWLP Ideal := Boolean => opts -> (I) -> (
    R := ring I;
    tryNumber := 0;
    while tryNumber <= opts.MaxTries do (
        tryNumber += 1;

        -- Find a general linear form.
        -- If supplied, use it; 
        -- otherwise, if I is a monomial ideal, the sum of variables suffices;
        -- otherwise, take a random linear form.
        L := if opts.LinearForm =!= null then (opts.LinearForm) 
             else (if isMonomialIdeal I then (sum R_*) 
                   else (random(R^{1}, R^1)
                   )
             );
        
        -- Check if the Hilbert is as-expected.
        Acut := coker((gens I) | L);
        SD := socleDegree I;
        A := coker gens I;
        failsMaxRank := apply(SD+1, i -> hilbertFunction(i+1, Acut) > max({0, hilbertFunction(i+1, A) - hilbertFunction(i, A)}));
        failsMaxRank = not all(failsMaxRank, failureBool -> not failureBool);
        if not failsMaxRank then return true;
    );
    false
)
hasWLP QuotientRing := Boolean => opts -> (A) -> (hasWLP ideal presentation A)