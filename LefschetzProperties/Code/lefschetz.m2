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

hasWLPOptimized = method(
    Options => {
        LinearForm => null
    }
)

hasWLPOptimized Ideal := Boolean => opts -> (I) -> (
    R := ring I;
    -- 1. Determine the Linear Form L
    L := if opts.LinearForm =!= null then (opts.LinearForm) 
         else (if isMonomialIdeal I then (sum R_*) 
               else (random(R^{1}, R^1)));

    -- 2. Compute the Hilbert Function of the original Algebra A
    -- We need the basis of the quotient ring to build the matrices
    -- 'basis' is generally fast for monomial ideals/simplicial complexes
    A := R/I;
    
    -- We only need to check up to the top degree
    maxDeg := regularity I;
    
    -- 3. Iterate through degrees
    -- We check the map: A_d --(*L)--> A_{d+1}
    scan(0..maxDeg-1, d -> (
        -- Get basis for source and target degrees
        basisSource := basis(d, A);
        basisTarget := basis(d+1, A);
        
        lenSource := numgens source basisSource;
        lenTarget := numgens source basisTarget;
        
        -- If either vector space is 0, the map is trivially surjective/injective
        if lenSource == 0 or lenTarget == 0 then continue;

        -- Construct the multiplication map matrix
        -- This represents "multiplication by L" in the basis of A
        -- The map goes from A_d to A_{d+1}
        multMap := map(A, A, L);
        matrixAtDegree := multMap_{d}; -- Induced map on graded components
        
        -- 4. The Rank Check
        -- WLP holds if the rank is maximal (equal to min(source, target))
        r := rank matrixAtDegree;
        expectedRank := min(lenSource, lenTarget);
        
        if r < expectedRank then (
            -- We found a failure! Return false immediately.
            return false;
        )
    ));
    
    -- If we survived all degrees, WLP holds.
    true
)

hasWLPOptimized QuotientRing := Boolean => opts -> (A) -> (
    hasWLPOptimized(ideal A, opts)
)

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