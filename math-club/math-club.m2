-- STANLEY-REISNER RINGS
restart
needsPackage "SimplicialComplexes";

R = ZZ[x_1..x_6]
deltaFaces = {{1,2,5},{2,3,5},{3,4,5},{1,4,5},
              {1,2,6},{2,3,6},{3,4,6},{1,4,6}}
delta = simplicialComplex apply(deltaFaces, face -> product(face / (vertex -> x_vertex)))
I = ideal delta



-- ARTINIAN ALGEBRAS
restart
R = QQ[x,y,z]
I = ideal(x^2, y^2, z^3)
A = R/I

-- why do by hand what you can do by computer...?
ds = {"d"} | for i in 0..5 list i
mons = {"gens(A_d)"} | for i in 0..5 list netList(flatten entries basis(i, A), Boxes=>false)
dims = {"dim(A_d)"} | for i in 0..5 list hilbertFunction(i, A)
print netList({ds} | {mons} | {dims}, HorizontalSpace=>2, VerticalSpace=>1, Alignment=>Center)



-- FREE RESOLUTIONS AND BETTI NUMBERS
F = res I
F.dd
betti F



-- THE PROJECT
-- search through all simplicial complexes of on a fixed number of vertices
restart
needsPackage "SimplicialComplexes";

checkKoszulTail = method()
checkKoszulTail (ZZ, ZZ, BettiTally) := Boolean => (n, d, bettiTable) -> (
    -- checks if there is an (n,d)-Koszul tail in the betti table
      
    -- nonzero entries are correct
    upperLeft := try bettiTable#(0,{0},0) == 1 else false;
    tail := toList apply(1..n, i -> try bettiTable#(i,{i+d},i+d) == binomial(n,i) else false);
    checkNonzero := all(prepend(upperLeft, tail), i -> i == true);

    -- zero everywhere else
    -- if the sum of all entries is 2^d, then we are good;
    -- otherwise, there is a nonzero entry in a bad spot
    checkZeros := (sum(apply(toList(0..n)**toList(0..d), (i,j)-> try bettiTable#(i,{i+j},i+j) else 0)) == 2^n);
    checkNonzero and checkZeros
)
--tested, works, STG 5/16/2023
koszulTails = method()
koszulTails (BettiTally) := List => (bettiTable) -> (
    -- checks if there is any (n,d)-Koszul tail in the table
    for pair in toList(1..pdim(bettiTable))**toList(1..regularity(bettiTable)) list if checkKoszulTail(pair#0, pair#1, bettiTable) then pair else continue
)

R = (ZZ/32749)[x_1..x_5];
allPossibleFaces = drop(drop(subsets R_*, 1), -1);
numKoszulTails = 0;
while numKoszulTails == 0 do (
    delta = simplicialComplex(product \ randomSubset allPossibleFaces);
    I = ideal delta;
    -- if pdim comodule I != codim I then continue;
    maximalDegree = max(flatten \\ degree \ (I_*));
    J = ideal(R_* / (g -> g^maximalDegree));
    A = I + J;
    tails = koszulTails betti res A;
    if any(first \ tails, n -> n > 3) then numKoszulTails = #(koszulTails betti res A);
)
print delta