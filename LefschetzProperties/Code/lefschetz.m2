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
        ShowProgress => true,
        LinearForm => null
    }
)
hasWLP Ideal := Boolean => opts -> (I) -> (
    R := ring I;
    
    tryIterator := iterator(1.. opts.MaxTries);
    tryIterator = if opts.ShowProgress then (
        progressBar(iterator(1..opts.MaxTries), Description=>"Checking WLP", TotalIterations=>opts.MaxTries)
    ) else tryIterator;
    for throwaway in tryIterator do (
        -- Find a general linear form.
        -- If supplied, use it; 
        -- otherwise, if I is a monomial ideal, the sum of variables suffices;
        -- otherwise, take a random linear form.
        L := if opts.LinearForm =!= null then (opts.LinearForm) 
             else (if isMonomialIdeal I then (sum R_*) 
                   else (random(R^{1}, R^1))
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
hasWLP RingElement := Boolean => opts -> (F) -> (
    -- This method is assuming F is the Macaulay dual generator of an Artinian
    -- Gorenstein algebra!)
    if F == 0_(ring F) then error "the input polynomial must be nonzero";
    if not isHomogeneous F then error(toString(F) | " must be a homogeneous polynomial");

    I := inverseSystem F;
    R := ring I;
    if not isArtinian I then error("the quotient ring " | toString(R) | "/" | toString(I) | " must be Artinian");

    hasWLP I
)
hasWLP QuotientRing := Boolean => opts -> (A) -> (hasWLP ideal presentation A)


hasSLP = method (
    Options => {
        MaxTries => 10,
        LinearForm => null,
    }
)
hasSLP RingElement := Boolean => opts -> (F) -> (
    -- This method is assuming F is the Macaulay dual generator of an Artinian
    -- Gorenstein algebra!)
    if F == 0_(ring F) then error "the input polynomial must be nonzero";
    if not isHomogeneous F then error(toString(F) | " must be a homogeneous polynomial");

    I := inverseSystem F;
    R := ring I;
    if not isArtinian I then error("the quotient ring " | toString(R) | "/" | toString(I) | " must be Artinian");

    tryNumber := 0;
    while tryNumber <= opts.MaxTries do (
        tryNumber += 1;

        -- Find a general linear form. Here, we are thinking of L as a sum
        -- of differential operators.
        -- If supplied, use it; 
        -- otherwise, if I is a monomial ideal, the sum of variables suffices;
        -- otherwise, take a random linear form.
        L := if opts.LinearForm =!= null then (opts.LinearForm) 
            else (if isMonomialIdeal I then (sum R_*) 
                else (random(R^{1}, R^1)
                )
            );
        
        -- Theorem 4 from Watanabe [2004]: "A remark on the Hessian of homogeneous polynomials"
        -- If F(coefficients L) != 0 and the higher Hessians do not vanish,
        -- then $A = Q / Ann_Q(F)$ has the SLP.
        coeffsL := transpose last coefficients L;
        if sub(F, coeffsL) == 0_R then return false;
        if any(1..(ceiling((socleDegree I) / 2)), d -> sub(hessian(F, d), coeffsL) == 0_R) then return false;
    );
    true
)
hasSLP Ideal := Boolean => opts -> (I) -> (
    
)
hasSLP QuotientRing := Boolean => opts -> (A) -> (hasSLP ideal presentation A)