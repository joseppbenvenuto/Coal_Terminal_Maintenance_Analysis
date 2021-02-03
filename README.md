# Coal_Terminal_Maintenance_Analysis

## Project Description

The analysis looked to analyze coal reclaimers' workloads in tonnes of coal moved during working hours to determine which reclaimers needed maintenance.

If anyone of the reclaimers averaged, over a seven-hour rolling window, 10% or higher below the nominal tonnes to be moved of 4,200, the reclaimer needed maintenance.

## Methods Used

1) Data exploration, cleaning, and descriptive statistical analysis.

## Results 

### RL1 Reclaimer

* The RL1 reclaimer needs maintenance due to the idle capacity exceeding the allowable threshold 28 times within September. 
* The RL1 recliamer's idle capacity peaked at 15.92%.

### RL2 Reclaimer

* The RL2 reclaimer does not need maintenance due to the idle capacity not exceeding the allowable threshold within September.
* The RL2 reclaimer's idle capacity peaked at 9.64% and may need maintenance sometime soon.

### SR1 Reclaimer

* The SR1 reclaimer needs maintenance due to idle capacity exceeding the allowable threshold 103 times within September.
* The SR1 reclaimer's idle capacity peaked at 100.00% due to a significant amount of missing date data.
* If missing data is excluded from the calculations because the reclaimer could have been parked or because the exact case for missing date data is currently unknown, the idle capacity only exceeds the allowable threshold 1 time and peaks at 10.34%. 

### SR4A Reclaimer

* The SR4A reclaimer needs maintenance due to idle capacity exceeding the allowable threshold 225 times within September.
* The SR4A reclaimer's idle capacity peaked at 100.00% due to a significant amount of missing date data.
* If missing data is excluded from the calculations because the reclaimer could have been parked or because the exact case for missing date data is currently unknown, the idle capacity only exceeds the allowable threshold 1 time and peaks at 10.31%. 

### SR6 Reclaimer

* The SR6 reclaimer needs maintenance due to idle capacity exceeding the allowable threshold 23 times within September.
* The SR6 reclaimer's idle capacity peaked at 13.04%.

### Dashboard 

![](ReadMe_Images/Dash.png)

## Technologies 

1) MySQL
2) MySQL Workbench
3) Microsoft Excel

## Directory Files

1) **Coal_Terminal_Maintenance.sql** - Analysis in MySQL.
2) **Coal_Terminal_Maintenance_Dashboard.xlsx** - Dashboard in Microsoft Excel.
3) **Cole_Data** - All project data.
