TEST ///
    -- isArtinian
    R = QQ[x,y,z]
    I = ideal(x^2, y^3, z^4)
    A = R / I
    assert(isArtinian A)
///

TEST ///
    -- socleDegree
    R = QQ[x,y,z]
    I = ideal(x^2, y^3, z^4)
    assert(socleDegree I == 6)
///

TEST ///
    -- hasWLP
    -- FACT: Complete intersections have the WLP (actually, SLP).
    R = QQ[x,y,z]
    I = ideal(x^2, y^3, z^4)
    A = R / I
    assert(hasWLP A == true)

    -- FACT: The following algebra from Brenner-Kaid [2007] does not have the WLP.
    R = QQ[x,y,z]
    I = ideal(x^3, y^3, z^3, x*y*z)
    A = R / I
    assert(not hasWLP A)

    -- FACT: Example 5.2 from Maeno-Watanabe [2009] does not have the WLP.
    R = QQ[u,v,x,y,z]
    F = x^2*u^3 + x*y*u^2*v + y^2*u*v^2 + z^2*v^3
    assert(not hasWLP inverseSystem F)
///


TEST ///
    -- hasSLP
    -- FACT: Example 5.2 from Maeno-Watanabe [2009] does not have the WLP
    --       (since it does not have the WLP).
    R = QQ[u,v,x,y,z]
    F = x^2*u^3 + x*y*u^2*v + y^2*u*v^2 + z^2*v^3
    assert(not hasWLP inverseSystem F)

    -- FACT: Example 5.3 Maeno-Watanabe [2009] (who attribute it to Ikeda [1996])
    --       does not have the SLP.
    R = QQ[x,y,z,w]
    F = w^3*x*y + w*x^3*z + y^3*z^2
    assert(not hasSLP F)
///