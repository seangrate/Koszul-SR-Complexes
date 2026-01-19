newPackage (
    "LefschetzProperties",
    AuxiliaryFiles => true,
    Version => "1.0", 
    Date => "January 15, 2026",
    Keywords => {"Commutative Algebra"},
    Authors => {
        {Name => "Sean Grate", 
         Email => "sgrate@iastate.edu", 
         HomePage => "https://seangrate.com/"}
    },
    Headline => "functions for working with Lefschetz properties",
    PackageExports => {
        "SimplicialComplexes"
    }
)

export {
    -- types
    -- "YoungDiagram",
    -- Lefschetz methods
    "isArtinian",
    "hasWLP",
    "socleDegree",
    -- Koszul tail methods
    "hasKoszulTail",
    "koszulTails",
    -- Hessians
    "hessian",
    -- optional arguments and symbols
    "MaxTries",
    "LinearForm",
    "Maximal"
}

-----------------------------------------------------------------------------
-- **CODE** --
-----------------------------------------------------------------------------
load "./LefschetzProperties/Code/lefschetz.m2"
load "./LefschetzProperties/Code/koszulTails.m2"
load "./LefschetzProperties/Code/hessians.m2"

-----------------------------------------------------------------------------
-- **DOCUMENTATION** --
-----------------------------------------------------------------------------
beginDocumentation()
load "./LefschetzProperties/Documentation/packageDocumentation.m2"
load "./LefschetzProperties/Documentation/lefschetzDocumentation.m2"
load "./LefschetzProperties/Documentation/koszulTailsDocumentation.m2"
load "./LefschetzProperties/Documentation/hessiansDocumentation.m2"

-----------------------------------------------------------------------------
-- **TESTS** --
-----------------------------------------------------------------------------
load "./LefschetzProperties/Tests/lefschetzTests.m2"
load "./LefschetzProperties/Tests/koszulTailsTests.m2"
load "./LefschetzProperties/Tests/hessiansTests.m2"
end

-----------------------------------------------------------------------------
--Development Section
-----------------------------------------------------------------------------
restart
uninstallPackage "LefschetzProperties"
restart
installPackage "LefschetzProperties"
restart
needsPackage "LefschetzProperties"
elapsedTime check "LefschetzProperties"
viewHelp "LefschetzProperties"
