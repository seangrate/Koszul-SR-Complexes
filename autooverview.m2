autoOverview = method()
autoOverview (Ring,SimplicialComplex) := List => (R,K) -> (
    idealDataList = {};
    I = ideal K;
    Q = R/I;
    H = hilbertSeries I;
    num = numerator H;
    reg = regularity I;
    hS = for k from 0 to (reg-1) list hilbertFunction(k, I);
    sumhS = sum hS;
    mL = apply(1..reg, i -> sumhS % i);
    B = betti res I;
    hKT = hasKoszulTail B;
    iM = hasKoszulTail(B, Maximal=>true);
    if hKT then kt = koszulTails B else kt = null;
    idealDataList = append(idealDataList, {"original", num, hS, mL, B, "()", "false", "false", hKT, kt, iM})
)