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
///
