# A Structured Expert Judgment Study on the Quantum Computing Boom

*Forecasting the next major technology wave*

**Author:** Bruno Fernandez Carballo
**Instructor:** G. F. Nane
**Course:** Decision Theory and Expert Judgment — TU Delft
**Date:** June 2026

---

## About the project

This repository contains a **Structured Expert Judgment (SEJ)** study on
the future of quantum computing, carried out with the
[**Classical Model**](https://en.wikipedia.org/wiki/Expert_elicitation#Cooke's_Classical_Model)
of Roger Cooke.

Quantum computing is frequently described as the next major technology
revolution, but the **timing** and **magnitude** of this potential
"quantum boom" remain highly uncertain. Because there is almost no
historical data to build a purely data-driven model, the problem is
precisely the setting for which SEJ was designed.

A panel of **eight experts** provided the 5 %, 50 % and 95 % quantiles
for **14 calibration questions** (with known answers) and **5 questions
of interest** about the future of the field. To test whether the
background of the assessors changes the conclusions, the panel is
analysed in three configurations:

| Configuration        | Composition                                  |
| -------------------- | -------------------------------------------- |
| **Full panel**       | all 8 experts                                |
| **Quantum panel**    | 4 experts with a quantum-physics background  |
| **Investment panel** | 4 experts with an investment / PE background |

### Headline results

- In all three configurations the **performance-weighted decision maker
  (PWDM)** outperforms the equal-weight one on the combined
  calibration × information score.
- The strongest DM overall is the one built from the full panel
  (calibration **0.399**, information **1.37**), which concentrates its
  weight on the only two well-calibrated assessors — one from each
  background group.
- The aggregate forecast projects that the global quantum-computing
  market will exceed **USD 50 billion around 2039** (90 % interval
  2032 – 2050), and that the first cryptographically relevant break of
  **RSA-2048 will happen around 2049** (90 % interval 2035 – 2067).
- The two background groups disagree on the timing of the so-called
  "Q-day", which may indicate a degree of overconfidence among domain
  experts.

All the details, tables, figures and discussion are in the full report:
[`report/Report_DT_EJ.pdf`](report/Report_DT_EJ.pdf).

---

## Repository layout

```
.
├── report/
│   └── Report_DT_EJ.pdf          Full report (PDF, 19 pages)
│
├── R code for CM/                R implementation of the Classical Model
│   ├── R code/
│   │   ├── Classical Model main.R    Main script to run
│   │   ├── calibrationScore.R        Calibration score C(e)
│   │   ├── informationScore.R        Information score I(e)
│   │   ├── constructDM.R             Decision-maker construction
│   │   ├── globalWeights_opt.R       Global weights, optimised alpha
│   │   ├── globalWeights_alpha.R     Global weights with fixed alpha
│   │   ├── itemWeights.R             Item weights (alpha = 0)
│   │   ├── itemWeights_opt.R         Item weights, optimised alpha
│   │   └── itemWeights_alpha.R       Item weights with fixed alpha
│   │
│   └── Expert data/              Sample data (input format)
│       ├── Exp1.csv … Exp5.csv       Quantiles per expert
│       └── realizations.csv          True values of the seeds
│
├── .gitignore
└── README.md
```

> **Note on the data.** The `Exp*.csv` and `realizations.csv` files
> included here are the **sample data** distributed alongside the course
> implementation (based on the AEX index). They exist to illustrate the
> input format of the code and to provide a runnable example, but they
> are **not the responses of the expert panel** used in the report;
> those responses are kept confidential as established by the
> elicitation protocol (Section 3.1 of the report).

---

## The Classical Model in two lines

Each expert *e* receives a weight proportional to

$$w_e \;\propto\; C(e)\cdot I(e)\cdot \mathbf{1}_{\{C(e)\ge\alpha\}}$$

where

- **C(e)** is the *calibration score*: the p-value of the χ²ₙ₋₁ test
  that compares the empirical distribution of the realisations over the
  inter-quantile bins against the theoretical vector
  (0.05, 0.45, 0.45, 0.05).
- **I(e)** is the *information score*: the Kullback-Leibler divergence
  of the expert's density with respect to a uniform (or log-uniform)
  background measure on the intrinsic range with overshoot k = 0.1.
- **α** is an optional threshold that zeroes the weight of any expert
  whose calibration falls below the cut-off.

The *Performance Weights Decision Maker* (PWDM) aggregates the
individual densities with these weights and produces the group's
5 / 50 / 95 % quantiles. See Sections 2.1 – 2.4 of the report for the
full derivation.

---

## How to reproduce the results

### Requirements

- **R** ≥ 4.0
- No external packages required. Everything is implemented in `base` R.
  (Optionally, `rstudioapi` for auto-detection of the working directory
  inside RStudio.)

### Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/brunoffernandez/structured-expert-judgment-on-the-quantum-computing-boom-.git
   cd structured-expert-judgment-on-the-quantum-computing-boom-/"R code for CM"
   ```

2. Open `R code/Classical Model main.R` in RStudio (or R). The script
   tries to locate the `R code for CM` folder as the working directory
   automatically. If you launch it from the command line, make sure
   `getwd()` returns that folder.

3. Run the whole script. The console will print:

   - Calibration and information scores per expert.
   - Weights and solutions (5 / 50 / 95 %) for the following decision
     makers:
     - **EWDM** — Equal Weights DM
     - **PWDM** — Performance Weights DM (α = 0)
     - **PWDM opt** — global, optimised α
     - **PWDM α = 0.05**
     - **IWDM opt** — item weights, optimised α
   - Combined calibration-information score for PWDM and EWDM (the
     direct comparison reported in Section 4.3 of the report).

To reproduce the sub-panel analysis from the report
(quantum vs. investment), it is enough to run the script three times
changing the selection of `Exp*.csv` files present in `Expert data/`
(or adjusting `csvFiles` in the main script).

---

## Quick reference to the study questions

**Calibration questions (14).** They cover, on purpose, the three
phases of a technology wave:

- *Market / historical boom.* NASDAQ at the dot-com peak (Q1), NASDAQ
  decline 2000-2002 (Q2).
- *Adoption.* Internet users in 2000 (Q3), ChatGPT adoption speed (Q4),
  AI-related publications in 2023 (Q5), organisations using AI in 2024
  (Q14).
- *Investment and research.* AI patents 2023 (Q6), private investment
  in GenAI 2024 (Q7), operational quantum computers in 2025 (Q8),
  `quant-ph` submissions in 2023 (Q9), quantum patents 2024 (Q10), VC
  in quantum 2024 (Q11), private quantum investment in 9M 2025 (Q12),
  McKinsey's 2030 projection (Q13).

**Questions of interest (5).**

1. Year the global quantum-computing market first exceeds USD 50 billion
   in annual revenue.
2. Papers per year submitted to `quant-ph` by 2035.
3. Number of operational quantum computers worldwide in 2035.
4. Year a quantum computer first breaks RSA-2048 in < 24 h (*Q-day*).
5. Percentage of Fortune 500 companies reporting operational use of
   quantum by 2035.

The rationale, seeds and per-expert qualitative comments are in
Section 3 of the report.

---

## Credits

- **Classical Model (theory):** Roger M. Cooke (TU Delft).
- **R implementation:** T. Nane and T. Dong, distributed for the
  *Decision Theory and Expert Judgment* course at TU Delft. This
  repository uses it **as-is**; the only self-authored change is the
  data-reading step, where the script was adapted to read the survey
  exports of the online questionnaire (normalising decimal commas to
  points and checking that the three quantiles of every assessment are
  strictly increasing).
- **Study, elicitation, analysis and report:** Bruno Fernandez Carballo
  (author of the project).

---

## License

Academic content. The R code retains the original authorship of its
authors; the report and the documentation of this repository are shared
for educational purposes and reproducibility.
