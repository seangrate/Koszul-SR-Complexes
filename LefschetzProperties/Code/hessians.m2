hessian = method()
hessian (RingElement, List) := RingElement => (G, Bd) -> (
    R := ring G;
    S := ring first Bd;

    -- Verify the differential polynomials are homogeneous of degree d > 0, and live in the same ring.
    if not all(Bd, isHomogeneous) then error(toString(Bd) | " must all be homogeneous");
    if #(unique flatten apply(Bd, degree)) != 1 then error(toString(Bd) | " must all have the same (positive) degree");
    if first degree first Bd <= 0 then error(toString(Bd) | " must have positive degrees");
    if not all(Bd, f -> ring f === S) then error("the differential polynomials must all live in the same ring");

    -- Make sure the rings look like R = KK[x_1..x_n] and S = KK[X_1..X_n], with char(KK) = 0.
    if numgens R != numgens S then error("the number of variables in ring(" | toString(G) | ") = " | toString(ring G) | " is not equal to the number of variables of the differential polynomials (" | toString(numgens ring first Bd) | ")");
    if (coefficientRing R) =!= (coefficientRing S) then error("the polynomial rings of " | toString(G) | " and of the differential polynomials " | toString(Bd) | " do not have the same base field");
    if char(coefficientRing R) != 0 then error("The coefficient ring must have characteristic 0");

    subbedBd := (map(R, S, R_*)) \ Bd;
    matrixSize := #subbedBd;
    det matrix for i in 1..matrixSize list (
        for j in 1..matrixSize list (
            diff(subbedBd#(i-1), diff(subbedBd#(j-1), G))
        )
    )
)
hessian (RingElement, ZZ) := RingElement => (G, d) -> (
    if d <= 0 then error(toString(d) | " must be a positive integer");

    X := getSymbol "X";
    S := (coefficientRing ring G)[X_1..X_(numgens ring G)];
    hessian(G, flatten entries basis(d, S))
)
hessian RingElement := RingElement => (G) -> (hessian(G, 1))