-----------------------
-- Hollow octahedron --
-----------------------
restart
load "./LefschetzProperties.m2"

-- Let's look at the hollow octahedron.
R = QQ[x_1..x_6]
delta = simplicialComplex {x_1*x_2*x_5, x_2*x_3*x_5, x_3*x_4*x_5, x_1*x_4*x_5,
                           x_1*x_2*x_6, x_2*x_3*x_6, x_3*x_4*x_6, x_1*x_4*x_6}
I = ideal delta                 -- The Stanley-Reisner ideal
hilbertSeries(I, Reduce=>true)  -- This is Theorem 4.17
betti res I                     -- Its Betti table

-- Let's look at certain Artinian "reductions"
-- Example: adding in squares of the variables
squares = (ideal vars R)^[2]    -- This is the "standard" one (x_i^2 : 1 <= i <= n)
J = I + squares
hilbertSeries(J, Reduce=>true)  -- This is Proposition 5.13
fVector delta                   -- This is
B2 = betti res J                -- The resolution changes quite a bit!

-- Example: adding in cubes of the variables
cubes = (ideal vars R)^[3]
J = I + cubes
hilbertSeries(J, Reduce=>true)
B3 = betti res J

-- Example: adding in x_i^4 of the variables
fours = (ideal vars R)^[4]
J = I + fours
hilbertSeries(J, Reduce=>true)
B4 = betti res J

-- Let's compare the Betti tables
netList({{squares, cubes, fours}, {B2, B3, B4}}, HorizontalSpace=>1, VerticalSpace=>1)


-- Or if we were really crazy, we could reduce by non-pure powers
randomPowers = ideal for gen in R_* list gen^(random(2, 5))
J = I + randomPowers
hilbertSeries(J, Reduce=>true)
betti res J



----------------------------------------------
-- Stephen's example: Sunflower hypergraphs --
----------------------------------------------
restart
needsPackage \ {"Graphs", "SimplicialComplexes"}
load "./LefschetzProperties.m2"
load "./helpers.m2"

n = 7; k = 2;
I = sunflowerHypergraphIdeal(n, k)
J = monomialIdeal((ring I)_* / (g -> g^(k+2)));
A = I+J;
B = betti res A     -- This has has a non-maximal (5,2)-Koszul tail, but it is *almost* maximal
hasKoszulTail B
koszulTails B
hasKoszulTail(B, Maximal=>true)