# Data Quality Incident Report

**Team:**
**Date:**

Fill this in as you go, not on Thursday from memory.

---

## Summary

| Metric | Count |
| :--- | :--- |
| Rows in source files | 39,224,735 |
| Rows loaded to bronze | 39,224,735 |
| Rows surviving to silver | 23,445,146 |
| Rows dropped |  |
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

### Defect 3: Outlier trip distance

**What it is**
We had some trips with very high trip distances, indicating incorrect information.

**How we found it**
We used a SQL query to find trip distances greater than 200.

**Scale**

| | Count | Percent of total |
| :--- | :--- | :--- |
| Records affected | 1670 | |

**Which metrics it would distort, and in which direction**
Any distance related metrics could be distorted. It would distort towards higher distances. For example, average trip distance would be greater because there are many entries with very large trip distances.

**Our decision:** drop / correct / quarantine / keep with caveat
We dropped the rows.

**Why, and what we gave up**
We gave up 1670 rows of our data but were able to clean and make sure our data was accurate. We removed incorrect data that clearly indicated false information.
---

### Defect 4: Total amount does not equal sum of all fees

**What it is**
There were entries that had total amounts that didn't equal the sum of all the fees in that entry.

**How we found it**
We used a SQL query to find sum of all fees that don't equal total amount.

**Scale**

| | Count | Percent of total |
| :--- | :--- | :--- |
| Records affected | 13,338,842 | |

**Which metrics it would distort, and in which direction**
Any payment related metrics could be distorted. It could have distorted in any direction. 

**Our decision:** drop / correct / quarantine / keep with caveat
We dropped the rows.

**Why, and what we gave up**
We gave up 13,338,842 rows of our data but were able to clean and make sure our data was accurate. We removed incorrect data that clearly indicated false information.
---

### Defect 5: Passenger count is 0 or null

**What it is**
Rows existed where passenger count was 0 or null. This indicates these trips were false information.

**How we found it**
We used a SQL query to find passenger count values that were 0 or null.

**Scale**

| | Count | Percent of total |
| :--- | :--- | :--- |
| Records affected | 9,248,993 |  |

**Which metrics it would distort, and in which direction**
Any passenger related metrics could be distorted. It could have distorted in a lesser direction. For example, average passenger count can be skewed to be less. If we were to calculate payment per passenger based on the counts than that can be skewed higher as we would add payment amounts while not adding any passengers. This would also affect metrics regarding other columns as these entire rows should be considered invalid and we wouldn't want to keep invalid data.

**Our decision:** drop / correct / quarantine / keep with caveat
We dropped the rows.

**Why, and what we gave up**
We gave up 9,248,993 rows of our data but were able to clean and make sure our data was accurate. We removed incorrect data that clearly indicated false information.
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
Yes

**If yes, how did we handle it?**
We handle in the views that we will load to tableau. We have created the column total_revenue_before_tip to be used in some of our displays. This is important because it avoid creating incorrect comparison between total_revenue from trips that had cash tips and credit card tips.

**If we present a tipping chart, what does the slide say about this?**
We would show credit card tips only as that is the only data we have. This would not represent all tipping as cash tipping is very popular in nyc taxi trips but our lack of data limits our possible analysis.
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