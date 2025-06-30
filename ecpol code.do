clear all

// creates log file 
cap log close
log using ecpolcode.log, replace
//find my folder 
cd "/Users/masha/Downloads"
//open dataset 
use "ALL_alldata_monthly.dta", clear

* Step 1: Define post-treatment period (after July 2018)
gen postt = (ym >= tm(2018m7))

* Step 2: Define treatment group (China + Tariff Affected) => already in the data as "tariff" tariff: =1 if hs_tariff=1 and china==1
gen treatment = (tariff == 1)


* Step 3: Define control group (Non-China or China not affected by tariff)
* Here, we compare China with tariffs vs China without tariffs
gen control_group = (china == 0 & hs_tariff == 0)

* Step 4: Create the interaction term for DiD (China + Tariff Affected × Post-Treatment)
gen did_interaction = treatment * postt


* Step 5: Take the natural log of the price variable (to capture relative changes)
gen ln_price = ln(price)  

* Step 6: Run the Difference-in-Differences regression with log(price) as the outcome
regress ln_price postt treatment ym did_interaction wave i.coicop, robust


* Plot the trends for the treatment and control groups
twoway (line ln_price ym if treatment == 1, lcolor(blue) lwidth(medium)) ///
       (line ln_price ym if control_group == 1, lcolor(red) lwidth(medium)), ///
       legend(label(1 "Treatment (Chinese goods affected by  Tariffs)") ///
              label(2 "Control (Non-Chinese goods and Chinese goods not affected by tariffs)")) ///
       xtitle("Time (Year-Month)") ///
       ytitle("Average Price") ///
       title("Difference-in-Differences Plot: Price Changes Over Time") ///
       ylabel(, angle(0))


	   // cleaning if needed
	drop price_before_tariff
drop price_after_tariff
drop group 
drop treatment_group
drop hs6_tariff_ever
drop did_interaction
drop control_group
drop treatment
drop postt   
