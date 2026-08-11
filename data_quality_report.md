# Data Quality Incident Report

**Team:**
**Date:**

Fill this in as you go, not on Thursday from memory.

---

## Summary

| Metric | Count |
| :--- | :--- |
| Rows in source files | 39,224,735 |
| Rows loaded to bronze | 23,445,146 |
| Rows surviving to silver |  |
| Rows dropped | |
| Percentage dropped | |

If rows in source and rows in bronze do not match, explain the gap before anything else. A load that silently dropped records is a more serious problem than dirty data, because you did not choose it.

---

## Defects found

Copy this block per defect. Aim for at least five, including at least one not named in `Data_Catalog.md`.

### Defect 1: Trips before and after our data timeline

**What it is**
We has some trips that apparently occurred years before when our data is from (2025-2026).

**How we found it**
We used a SQL query to find values that fell outside our timeline.

**Scale**

| | Count | Percent of total |
| :--- | :--- | :--- |
| Records affected | 7 | |

**Which metrics it would distort, and in which direction**
Any date related metrics could be distorted. It would distort towards the past.

**Our decision:** drop / correct / quarantine / keep with caveat
We dropped the rows.

**Why, and what we gave up**
We gave up 7 rows of our data but were able to clean and make sure our data was accurate. We removed what we perceived to be incorrect data due to an incorrect data that was far off of our timeline.

---
### Defect 2: Total amounts are less than initial fee ($3.00)

**What it is**
We has some trips that apparently occurred years before when our data is from (2025-2026).

**How we found it**
We used a SQL query to find values that fell outside our timeline.

**Scale**

| | Count | Percent of total |
| :--- | :--- | :--- |
| Records affected | 3621 | |

**Which metrics it would distort, and in which direction**
Any payment related metrics could be distorted. It would distort towards the less money. For example, average fare amount would be less because there are many entries with $0 total amount.

**Our decision:** drop / correct / quarantine / keep with caveat
We dropped the rows.

**Why, and what we gave up**
We gave up 3621 rows of our data but were able to clean and make sure our data was accurate. We removed incorrect data that didn't follow the initial charge of $3.00 according to nyc.gov.

---

## Defects we found but did not address

Being explicit about what you left alone, and why, is a strength. It shows you made a decision rather than missing it.

| Defect | Scale | Why we left it | How it limits our conclusions |
| :--- | :--- | :--- | :--- |
| Trips found slightly before Janurary and slightly after May.| 34 rows | We left it because we thought the data was not incorrect or an outlier. It stayed very close to our bounds and would not corrupt our finding or our specific business question. | It could possibly limit any analysis done strictly for January to May. |

---

## The cash tip question

Every team hits this, so answer it explicitly.

`tip_amount` is recorded for credit card transactions but not for cash, so cash tips appear as zero.

**Does any of our analysis involve tips?** yes / no

**If yes, how did we handle it?**

**If we present a tipping chart, what does the slide say about this?**

---

## What we would do with more time

The data quality work you would prioritize next, and why.

---

## Effect on our conclusions

The most important section. For each headline finding you present, state how the data quality issues could affect it.

| Our finding | Could a data quality issue explain it? | Why we are confident, or how confident we are |
| :--- | :--- | :--- |
| | | |

A finding you cannot defend here should not be a headline on Demo Day.