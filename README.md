# Lefschetz Properties for Simplicial Complexes

This is a repository for investigating Lefschetz properties of Artinian algebras coming from Stanley-Reisner rings.

- `ISMaRT/` contains working notes detailing the relevant background required for understanding the main problems at hand. The notes also contain some recent research related to the research questions we will be investigating.
- `math-club/` contains the presentation given at the Math Club meeting.
- As part of the codebase, a new *LefschetzProperties* package is supplied via `LefschetzProperties.m2` and its auxilliary directory `LefschetzProperties/`.
- Some additional Python code for working with simplicial complexes and for reading Betti tables from Macaulay2 are provided in the `simplicial.py` and `utils.py` files, respectively.

## Installation
To download the repository, run the following code sequentially in a terminal:
```
git clone git@github.com:seangrate/Koszul-SR-Complexes.git
cd Koszul-SR-Complexes/
git pull
git checkout ismart
```

## ISMaRT Notes
The working notes for the ISMaRT project can be found in the `ISMaRT/` directory.
At the moment, there are only some notes containing background and prerequisites for getting started with the project.
These are contained in `ISMaRT/preliminaries.pdf`, which has the following sections:
1. Crash Course in Ring Theory
    1. Fundamentals
    2. Geometric Intuition
    3. Dimension Theory
    4. Artinian Algebras
    5. Macaulay2 Code
2. Free Resolutions and Betti Numbers
    1. Fundamentals
    2. Exact Sequences
    3. Free Resolutions
    4. Betti Tables
    5. Macaulay2 Code
3. Lefschetz Properties
4. A Detour: Simplicial Complexes
    1. The Stanley-Reisner correspondence
    2. Combinatorial Commutative Algebra
    3. Macaulay2 Code
5. Putting It All Together
    1. The Project
    2. Literature for WLP of Monomial Ideals
        1. Migliore-Nagel-Schenck
        2. Mermin-Peeva-Stillman
        3. Dao-Nair
        4. Holleben
    3. Macaulay2 Code

## *LefschetzProperties* Package
The *LefschetzProperties* package includes methods for determining if a standard-graded Artinian algebra has the weak/strong Lefschetz property.

### Installation
This installation guide assumes there is a *locally* installed version of Macaulay2.
To install the package, open a Macaulay2 session at the top level of this directory by running `M2` in a terminal.
Then run `installPackage "LefschetzProperties"` in the Macaulay2 session.
Barring any errors during installation, to ensure everything installed correctly, it is suggested to run the unit tests and verify the documentation looks correct:
```
restart
needsPackage "LefschetzProperties"
elapsedTime check "LefschetzProperties"
viewHelp "LefschetzProperties"
```

### Features
1. Checking if an Artinian algebra has the weak Lefschetz property
    ```
    R = QQ[x, y, z]
    I = ideal(x^2, y^3, z^4)
    A = R / I
    hasWLP A
    ```
2. Checking if a Betti table has a (maximal) Koszul tail
    ```
    R = QQ[x, y, z, w]
    I = ideal(x*w, y*w, z*w)
    B = betti res I
    hasKoszulTail(B, Maximal=>true)
    ```
3. Complete documentation
    ```
    viewHelp "LefschetzProperties"
    ```

### Example
**Theorem** [Harima-Migliore-Nagel-Watanabe, 2003]: Let $R = \mathbb{K}[x,y,z]$ where $\text{char}(\mathbb{K}) = 0$.
Let $I = \langle f_1, f_2, f_3 \rangle$ be an Artinian complete intersection.
Then $R/I$ has the weak Lefschetz property.

We can test this theorem using the package (featuring `isArtinian` and `hasWLP`)!
```
R = QQ[x,y,z]

-- Get an *Artinian* complete intersection
degs = for d from 1 to 3 list random(2, 5);
I = ideal random(R^degs, R^1);
A = R / I;
while not isArtinian A do (
    degs = for d from 1 to 3 list random(2, 5);
    I = ideal random(R^degs, R^1);
    A = R / I;
)

hasWLP A
```