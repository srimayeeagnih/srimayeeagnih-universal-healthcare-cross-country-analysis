# Universal Health Care in Developed vs Developing Countries: A Broad Cross-Country Analysis

**Course:** ECON 498 H — Concordia University
**Author:** Srimayee Agnihotram
**Date:** April 2025

---

## Research Question

> How do different financing mechanisms of Universal Health Coverage (UHC) affect household-level affordability in developed vs. developing countries?

## Abstract

The Universal Healthcare Coverage (UHC) policy is a tool aimed to achieve the 3rd Sustainable Development Goal (SDG 3), yet progress has stagnated since 2015. This study conducts a comparative cross-country analysis of 73 countries from 2000 to 2022, examining how two major public financing mechanisms — social health insurance (SHI) contributions and tax-based health expenditure — affect a constructed household financial cost burden metric. The model includes foreign aid, year, and regional fixed effects to account for domestic capacity and geographic heterogeneity in UHC implementation.

## Methodology

- **Model:** Ordinary Least Squares (OLS) panel regression (three specifications)
- **Sample:** 73 countries, 2000–2022
- **Dependent variable:** Financial cost burden (constructed from WHO indicators)
- **Treatment variables:** Social Health Insurance (SHI) as % of CHE; Tax-based health expenditure
- **Controls:** External health aid, regional fixed effects, year fixed effects
- **Robustness check:** Lagged cost burden models to test for reverse causality

## Key Findings

- A 1 SD increase in SHI contributions leads to a ~1.5 SD increase in cost burden in **developed** countries vs. ~0.17 SD in **developing** countries
- Tax-based expenditure has a larger average effect on cost burden in **developing** countries
- The interaction between SHI and tax-based funding is **negative in developed countries** (complementary effect), but **positive in developing countries** (possible fragmentation/administrative barriers)
- Lagged models confirm reverse causality: higher past cost burden predicts greater SHI contributions, especially in developed economies

## Data Sources

All data is publicly available:

1. **WHO Global Health Expenditure Database** — Current Health Expenditure (CHE) per capita, Out-of-Pocket Expenditure, Voluntary Health Insurance
   → [apps.who.int/nha/database](https://apps.who.int/nha/database)

2. **World Bank World Development Indicators** — Government tax revenue, other revenue, general government health expenditure, total population
   → [data.worldbank.org](https://data.worldbank.org)

## Repository Structure

```
├── FinalPaper.pdf                        # Final paper
├── FinalManuscript_30434.pdf             # Submitted manuscript
├── Empirical-Analysis-Revised.R          # Main regression analysis
├── Tax-Variable-Revised.R                # Tax variable construction
├── Visualization.R                       # Plots and figures
├── SFA-Analysis.R                        # Supplementary analysis
├── NHA indicators.xlsx                   # Raw NHA indicators
├── *.rds                                 # Processed R data files
├── *.png                                 # Output figures
├── literature/                           # Consulted papers
└── README.md
```

## How to Reproduce

1. Clone the repo and open in RStudio
2. Download raw data from WHO and World Bank (links above) and place in the working directory
3. Run scripts in order:
   ```
   Tax-Variable-Revised.R       # Construct tax variable
   Empirical-Analysis-Revised.R # Run main regressions
   Visualization.R              # Generate figures
   ```

## Citation

Agnihotram, S. (2025). *Universal Health Care in Developed vs Developing Countries: A Broad Cross-Country Analysis*. ECON 498 H, Concordia University.
