** Clean data


**** BOVA
clear
import delimited "H:\TimeSeries_Final_Project\BOVA_Monthly.csv"
gen int date_new = date(date, "YMD")
format %td date_new

keep adjclose date_new
rename adjclose bova

save "H:\TimeSeries_Final_Project/BOVA.dta", replace


****VWO
clear
import delimited "H:\TimeSeries_Final_Project\VWO_Monthly.csv"
gen int date_new = date(date, "MDY")
format %td date_new

keep adjclose date_new
rename adjclose vwo

save "H:\TimeSeries_Final_Project/VWO_Monthly.dta", replace



****EEM
clear
import delimited "H:\TimeSeries_Final_Project\EEM_Monthly.csv"
gen int date_new = date(date, "YMD")
format %td date_new

keep adjclose date_new
rename adjclose eem

save "H:\TimeSeries_Final_Project/EEM_Monthly.dta", replace


clear
use  "H:\TimeSeries_Final_Project\oil_data.dta"
format %td A
rename A date_new

**Merge EEM on oil
merge 1:1 date_new using "H:\TimeSeries_Final_Project/EEM_Monthly.dta"
keep if _merge==3
drop _merge

**Merge VWO on oil
merge 1:1 date_new using "H:\TimeSeries_Final_Project/VWO_Monthly.dta"
keep if _merge==3
drop _merge

**Merge BOVA on oil
merge 1:1 date_new using "H:\TimeSeries_Final_Project/BOVA.dta"
keep if _merge==3
drop _merge


save "H:\TimeSeries_Final_Project/master_final.dta", replace