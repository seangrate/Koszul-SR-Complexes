TEST ///
    -- hessian
    R = QQ[x_1..x_3]
    S = QQ[X_1..X_3]
    f = x_1^2 + x_2*x_3

    -- hess(f) = -2
    assert(hessian f == (-2)_R)
    assert(hessian f == hessian(f, 1))
    assert(hessian f == hessian(f, S_*))
    
    -- hess^2(f) = 0
    assert(hessian(f, 2) == 0_R)
    assert(hessian(f, flatten entries basis(2, S)) == 0_R)

    -- FACT: Example 5.2 from Maeno-Watanabe [2009] has non-vanishing Hessian,
    --       but its 2nd Hessian vanishes.
    R = QQ[u,v,x,y,z]
    F = x^2*u^3 + x*y*u^2*v + y^2*u*v^2 + z^2*v^3
    assert(hessian F == 48*u^3*v^3 * (u^5*x^4 + 8*u^4*v*x^3*y + 16*u^3*v^2*x^2*y^2 + 19*u^2*v^3*x^2*z^2 + 9*u^2*v^3*x*y^3 + 13*u*v^4*x*y*z^2 + 2*u*v^4*y^4 + 4*v^5*y^2*z^2))
    assert(hessian(F, 2) == 0_R)

    -- FACT: Example 5.3 Maeno-Watanabe [2009] (who attribute it to Ikeda [1996])
    --       has non-vanishing Hessian.
    R = QQ[w,x,y,z]
    F = w^3*x*y + w*x^3*z + y^3*z^2
    assert(hessian F == 8*(3*w^7*x*y^4 + 8*w^6*x^6 - 27*w^5*x^3*y^3*z + 27*w^4*y^6*z^2 - 45*w^3*x^5*y^2*z^2 - 54*w^2*x^2*y^5*z^3 + 9*w*x^7*y*z^3 + 27*x^4*y^4*z^4))
///