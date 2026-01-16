hasKoszulTail = method(
      Options => {
            Maximal => false
      }
)
hasKoszulTail BettiTally := Boolean => opts -> (bettiTable) -> (#(koszulTails(bettiTable, Maximal=>opts.Maximal)) > 0)
hasKoszulTail (ZZ, ZZ, BettiTally) := Boolean => opts -> (n, d, bettiTable) -> (
      -- Must have valid inputs.
      if n < 1 then error "n must be positive.";
      if d < 0 then error "d must be non-negative.";

      -- Check for the Koszul tail itself; early return if something does not match.
      -- Each index here is a tuple (i, multidegree, total_degree).
      -- Since things are standard-graded, these are tuples (i, {i+j}, i+j).
      koszulTailIndices := {(0, {0}, 0)} | (for i in 1..n list (i, {i+d}, i+d));
      for idx in koszulTailIndices do (
            if not bettiTable#?idx then return false;
            if bettiTable#idx != binomial(n, first idx) then return false;
      );

      -- Make sure there are no other nonzero entries in the top-left principal block.
      indicesToCheck := apply(toList(0..n)**toList(0..d), (i, j) -> (i, {i+j}, i+j));
      indicesToCheck = select(indicesToCheck, idx -> not isMember(idx, koszulTailIndices));
      for idx in indicesToCheck do (
            if bettiTable#?idx then return false;
      );

      -- Check if Koszul tail is *maximal*
      if opts.Maximal then (
            if pdim bettiTable != n then return false
      );
      true
)

koszulTails = method(
      Options => {
            Maximal => false
      }
)
koszulTails (BettiTally) := List => opts -> (bettiTable) -> (
      select(toList(1..pdim(bettiTable))**toList(0..regularity(bettiTable)), pair -> hasKoszulTail(first pair, last pair, bettiTable, Maximal=>opts.Maximal))
)