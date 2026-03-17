# NeuroAnalyzer Tests

## Running tests

From MATLAB, with the project root (NeuroAnalyzer folder) on the path:

```matlab
cd('/path/to/NeuroAnalyzer')
runtests('tests')
```

Or run a single test file:

```matlab
runtests('tests/ValidationTest')
runtests('tests/ProcessorTest')
runtests('tests/DataLoaderTest')
```

## Test files

- **ValidationTest** – `Validation.isValidLDFStruct`, `Validation.cropRange`
- **ProcessorTest** – `Processor.crop` (bounds, lengths, mismatched RawStim/RawLDF)
- **DataLoaderTest** – `DataLoader.load(..., 'FromStruct', d)` (no file dialog)

## Fixtures

- **fixtures/make_valid_ldf_fixture.m** – Script to generate `valid_ldf_export.mat` with minimal LDF export structure. Run once to create the file if needed for manual load tests.
