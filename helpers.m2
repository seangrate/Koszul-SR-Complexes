sunflowerHypergraphIdeal = method()
sunflowerHypergraphIdeal (ZZ, ZZ) := monomialIdeal => (n, k) -> (
    -* 
        n: ZZ
            Number of vertices.
        k: ZZ
            The hypergraph is k-uniform, i.e., all hyperedges have size k.
            When k=1, this is the standard star graph.
    *-
    hyperedges := unique apply(k+1..n, i -> toList(1..k) | {i});
    R := QQ[x_1..x_n];
    monomialIdeal(apply(hyperedges, edge -> product apply(edge, i -> x_i)))
)

isDoublyCM = method()
isDoublyCM SimplicialComplex := Boolean => (delta) -> (
    -*
        Requires the "SimplicialComplexes" package.
    *-
    I := ideal delta;
    R := ring I;
    if pdim comodule I != codim I then return false;
    -- Otherwise, delta is CM.
    -- Now check if delta - v is CM for all v in V(delta).
    for v in vertices delta do (
        I' := ideal inducedSubcomplex(delta, delete(v, R_*));
        if pdim comodule I' != codim I' then return false;
    );
    true
)
isDoublyCM Ideal := Boolean => (I) -> (isDoublyCM simplicialComplex I)