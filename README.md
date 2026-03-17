# NeuroAnalyzer

Neuronal Data Analyzer toolbox (NMD Lab) for LDF (Laser Doppler Flowmetry) and electrophysiology (LFP, MUA) processing and signal characterization.

## Quick start

1. **Add to path** (one time): In MATLAB, run
   ```matlab
   addpath('path/to/NeuroAnalyzer');
   savepath;   % optional: save for future sessions
   ```
2. **Launch**: From the Command Window, type
   ```matlab
   NeuroAnalyzer
   ```

You can also use **Current Folder** to navigate to the NeuroAnalyzer folder and run `NeuroAnalyzer` from there.

## Structure

- **NeuroAnalyzer.m** – Entry point; run this to open the app.
- **Main.m** – Main launcher (in `core/`); typically invoked by `NeuroAnalyzer`.
- **apps/** – Application windows (Extract LDF, Signal Characterization, Help, etc.).
- **core/** – Core logic (theme, project paths, data loading, validation, processing).
- **docs/** – Help images and documentation.
- **Utilities/** – Third-party utilities (e.g. TDT SDK).

## Requirements

- MATLAB R2018b or later (R2021a+ recommended for Help hyperlinks).
- For TDT data: place or link the TDT MATLAB SDK under `Utilities/` as used by the toolbox.

## Author

© Copyrights by Alejandro Suarez, Ph.D.  
[GitHub](https://github.com/alesuarez92)
