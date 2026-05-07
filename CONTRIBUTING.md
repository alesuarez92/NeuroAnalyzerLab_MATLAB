# Contributing to NeuroAnalyzerLab_MATLAB

Thanks for your interest. This is an early-stage research toolbox
(currently v0.1.0) and contributions that flow back to the canonical
repo are welcome.

## How to use it

Please install the project from a release ZIP (see the
[README](README.md#install)) rather than maintaining a long-running fork.
The license ([LICENSE.txt](LICENSE.txt)) does not allow republishing the
code under a different name. If you need a change, the right path is to
file an issue or open a PR back here.

## Reporting bugs

Open an [issue](https://github.com/alesuarez92/NeuroAnalyzerLab_MATLAB/issues)
with:

- The version (shown in every app's footer next to the copyright, or check
  `core/UITheme.version`).
- MATLAB version (`ver`).
- A minimal example that reproduces the problem (which app, which inputs,
  what you expected, what you got).
- Any error text from the MATLAB Command Window.

## Suggesting features

Open an issue with the use case before sending code. A short description
of the experimental workflow and the analysis you wish the tool did is
the most useful starting point — it lets us pick a design that fits the
rest of the toolbox instead of bolting on a one-off function.

## Submitting a pull request

1. Fork **only as a working copy** to develop your change. Don't publish
   it as a separate project.
2. Branch from `main`. Use a short descriptive name
   (`fix/extract-ldf-crash`, `feature/spike-clustering-export`).
3. Match the existing code style: classdef-per-app, `core/` for shared
   utilities, UI through `UITheme`. Don't introduce a different layout
   pattern in a single window.
4. Add or update tests under `tests/` when the change is testable
   (validation, processing, signal features). Run `run_tests` locally.
5. Update [CHANGELOG.md](CHANGELOG.md) under the `[Unreleased]` section
   (Added / Changed / Fixed).
6. Open the PR against `main`. Keep the PR scoped — one logical change
   per PR makes review tractable.

Please do not include AI-generated co-author trailers in commits.

## Versioning and releases

The project follows [SemVer](https://semver.org/) (MAJOR.MINOR.PATCH).
The version constant lives in `core/UITheme.version` and is the single
source of truth — every app's footer reads from it.

- `PATCH` — bug fixes, no behavior change for existing data.
- `MINOR` — new analysis, new app, or new option that's backwards
  compatible.
- `MAJOR` — incompatible change to the data formats consumed/produced
  by an app, or removal of a public-facing feature.

Releases are git tags (`v0.1.0`, ...) with a corresponding entry in
[CHANGELOG.md](CHANGELOG.md).

## Questions

For anything that's not a bug or a concrete proposal, open a
[discussion](https://github.com/alesuarez92/NeuroAnalyzerLab_MATLAB/discussions)
or email the author (see the GitHub profile linked in the README).
