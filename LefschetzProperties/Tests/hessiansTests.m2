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
///