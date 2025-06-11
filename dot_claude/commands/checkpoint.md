Create a recoverable checkpoint commit.

Follow these steps:

1. Make sure any code quality tools are passing, eg clippy and tests for rust,
   credo and exunit for elixir.
2. Analyse uncommitted changes in the local working tree.
3. Update the current plan/project file with the current progress status.
4. Remove any temporary working files that are not meant to be part of the
   ongoing project.
5. Create a work-in-progress commit using the conventional commit syntax to make
   sure our changes aren't lost. NO CLAUDE ATTRIBUTIONS!
6. Ask Barnabas if he wants to continue on to the next item in the plan
