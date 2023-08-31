set more off
clear all
est clear
set matsize 500

/***********************
RANDOMIZED INFERENCE

District Level Permutation
	
***********************/


********************************************************************************
*PRELIMINARY
********************************************************************************

	*set matrix with the p-values:
	mat P = J(5,6,.)

	*repetitions:
	local reps 500
	
	*dependent variable:
	global y_key "value_cons23 value_cons20_mo hh_wkly_earn hh_wkly_dys_wrk_casual"
	*also the daily wage (different dataset);


********************************************************************************
*PART 1: GENERATE THE TABLE WITH THE BASELINE ESTIMATES
********************************************************************************

use "$hhdata/HH_regression_data_prepped.dta", clear

********************************************************************************
*FIRST WE DEFINE THE CONTROL SET (WITH HH SIZE QUINTILES) AND THE VARIABLES OF INTEREST:

*global controls "i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_noSKS_rural_*_dumX6* i.GLP_2008_noSKS_rural_*_dumX6*"
*global pbo_controls "i.month i.round i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_noSKS_rural_*_dumX6"

*we first generate poverty according to the rural line:
	*( see PFriedrichSummer2015\Household\povertyhh.do, line 58)
	
	gen pov=.
	replace pov=1 if sector==1 & hh_pc_cons_m<plr
	replace pov=1 if sector==2 & hh_pc_cons_m<plu
	replace pov=0 if sector==1 & hh_pc_cons_m>=plr & plr!=.
	replace pov=0 if sector==2 & hh_pc_cons_m>=plu & plu!=.


*SETTING THE EXPOSURE VARIABLES:

*defining log-exposure:

gen     exp_ratio_noSKS_scl2_lnX64=0
replace exp_ratio_noSKS_scl2_lnX64= exp_ratio_noSKS_scl2_ln if round==64


gen exp_ratio_noSKS_scl2X64=0
replace exp_ratio_noSKS_scl2X64=exp_ratio_noSKS_scl2 if round==64

rename exp_rationoSKS_scl2_lnXpost exposure1

*defining binary meaasure of any exposure:

gen  exp_rationoSKS_scl2_dumX64=0
replace exp_rationoSKS_scl2_dumX64 = exp_ratio_noSKS_scl2_dum if round==64

*rename exp_rationoSKS_scl2_dumXpost exposure2

*creating non durable consumption::

	*by the sum of items:
	egen nondur_aux = rowtotal(value_cons17 value_cons18 value_cons19),missing
	replace nondur_aux = nondur_aux/12
	egen value_nondurables = rowtotal(value_cons16 nondur_aux),missing
	drop nondur_aux
	lab var value_nondurables "Nondurable Mthly Consumption"

	*by the difference between total consumption and durable cons:
	*cap gen value_nondurables = value_cons23 - value_cons20_mo
	
	*generate total consumption only when both components are non-missing:
	replace value_cons23 = . if value_nondurables==. | value_cons20_mo==.
	
	*similarly, we exclude poverty if missing the non-durable consumption data:
	replace pov = . if value_nondurables==. | value_cons20_mo==.	

*changing labels to match tables:
	
	*Labor (Table 5) variables:
	label var hh_dly_ws_cl_l_pam_np_1 "Casual Daily Wage: Ag" 
	label var hh_dly_ws_cl_l_pam_np_n1 "Casual Daily Wage: Non-Ag" 
	label var hh_wkly_dys_wrkd "HH Weekly Days Worked: Total"
	label var hh_wkly_dys_wrk_casual "HH Weekly Days Worked: Casual"
	label var hh_wkly_earn "HH Weekly Labor Earnings"
	label var hh_invol "Any HH Member Invol. Unemployment"
	label var hh_biz_nonag "Any non-Ag. Self Employment"

	*Consumption (Table 6) variables:
	label var value_cons23 "HH Monthly Consumption: Total"
	label var value_cons20_mo "HH Monthly Consumption: Durables"
	label var value_nondurables "HH Monthly Consumption: Nonurables"
	
	label var hh_wkly_earn "HH Weekly Labor Earnings"
	
	*exposure:
	label var exposure2 "Any Exposed Lender $\times$ Post"
	
	*Summary statistics variables:
	
	label var hh_size "HH size"
	
*run the model for all y in y_key
foreach y in $y_key {
areg `y' exposure2 i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum `y' if exposure2==0 & round==68 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'
}

********************************************************************************
*long format:
use "$hhdata/HH_regression_data2016_wage_long.dta", clear

*** To obtain hh_pc_cons_m_ea_66 ***
merge m:1 state_id district_id round using "$hhdata/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge
*** To obtain hh_pc_cons_m_ea_66 ***

*SETTING THE EXPOSURE VARIABLES:

*defining log-exposure:

gen     exp_ratio_noSKS_scl2_lnX64=0
replace exp_ratio_noSKS_scl2_lnX64= exp_ratio_noSKS_scl2_ln if round==64


gen exp_ratio_noSKS_scl2X64=0
replace exp_ratio_noSKS_scl2X64=exp_ratio_noSKS_scl2 if round==64

rename exp_rationoSKS_scl2_lnXpost exposure1

*defining binary meaasure of any exposure:

gen  exp_rationoSKS_scl2_dumX64=0
replace exp_rationoSKS_scl2_dumX64 = exp_ratio_noSKS_scl2_dum if round==64

*rename exp_rationoSKS_scl2_dumXpost exposure2

label var exposure1 "Log(Exposure Ratio) $\times$ Post 2010"
label var exposure2 "Any exposed lender $\times$ Post 2010"
label var dly_wage "Casual Daily Wage"



areg dly_wage exposure2 i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum dly_wage if exp_ratio_noSKS_scl2_dum==0 & round==68 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto dly_wage

areg dly_wage exposure2 i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum dly_wage if exp_ratio_noSKS_scl2_dum==0 & round==68 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto dly_wage



esttab value_cons23 value_cons20_mo hh_wkly_earn hh_wkly_dys_wrk_casual dly_wage using "$tables/RI_1.tex", b(3) noconstant noobs star(* 0.10 ** 0.05 *** 0.01) label mlabel(none) fragment booktabs keep(exposure2) nolines nomtitles nonumbers replace
esttab value_cons23 value_cons20_mo hh_wkly_earn hh_wkly_dys_wrk_casual dly_wage using "$tables/RI_3.tex", cells(none) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast label mlabel(none) fragment booktabs nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace

********************************************************************************
*PART 3: RANDOMIZATION INFERENCE
********************************************************************************

local pos=1

foreach y in $y_key {

di "Dependent Variable: `y'"

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801	

use "$hhdata/HH_regression_data_prepped.dta", clear

********************************************************************************
*FIRST WE DEFINE THE CONTROL SET (WITH HH SIZE QUINTILES) AND THE VARIABLES OF INTEREST:

*global controls "i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_noSKS_rural_*_dumX6* i.GLP_2008_noSKS_rural_*_dumX6*"
*global pbo_controls "i.month i.round i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_noSKS_rural_*_dumX6"

*we first generate poverty according to the rural line:
	*( see PFriedrichSummer2015\Household\povertyhh.do, line 58)
	
	gen pov=.
	replace pov=1 if sector==1 & hh_pc_cons_m<plr
	replace pov=1 if sector==2 & hh_pc_cons_m<plu
	replace pov=0 if sector==1 & hh_pc_cons_m>=plr & plr!=.
	replace pov=0 if sector==2 & hh_pc_cons_m>=plu & plu!=.

*main dependent variables:
global y_key "value_cons23 value_cons20_mo hh_wkly_earn hh_wkly_dys_wrkd hh_wkly_dys_wrk_casual hh_dly_ws_cl_l_pam_np_1 hh_dly_ws_cl_l_pam_np_n1"

*SETTING THE EXPOSURE VARIABLES:

*defining log-exposure:

gen     exp_ratio_noSKS_scl2_lnX64=0
replace exp_ratio_noSKS_scl2_lnX64= exp_ratio_noSKS_scl2_ln if round==64


gen exp_ratio_noSKS_scl2X64=0
replace exp_ratio_noSKS_scl2X64=exp_ratio_noSKS_scl2 if round==64

rename exp_rationoSKS_scl2_lnXpost exposure1

*defining binary meaasure of any exposure:

gen  exp_rationoSKS_scl2_dumX64=0
replace exp_rationoSKS_scl2_dumX64 = exp_ratio_noSKS_scl2_dum if round==64

*rename exp_rationoSKS_scl2_dumXpost exposure2

*creating non durable consumption::

	*by the sum of items:
	egen nondur_aux = rowtotal(value_cons17 value_cons18 value_cons19),missing
	replace nondur_aux = nondur_aux/12
	egen value_nondurables = rowtotal(value_cons16 nondur_aux),missing
	drop nondur_aux
	lab var value_nondurables "Nondurable Mthly Consumption"

	*by the difference between total consumption and durable cons:
	*cap gen value_nondurables = value_cons23 - value_cons20_mo
	
	*generate total consumption only when both components are non-missing:
	replace value_cons23 = . if value_nondurables==. | value_cons20_mo==.
	
	*similarly, we exclude poverty if missing the non-durable consumption data:
	replace pov = . if value_nondurables==. | value_cons20_mo==.	

*changing labels to match tables:
	
	*Labor (Table 5) variables:
	label var hh_dly_ws_cl_l_pam_np_1 "Casual Daily Wage: Ag" 
	label var hh_dly_ws_cl_l_pam_np_n1 "Casual Daily Wage: Non-Ag" 
	label var hh_wkly_dys_wrkd "HH Weekly Days Worked: Total"
	label var hh_wkly_dys_wrk_casual "HH Weekly Days Worked: Casual"
	label var hh_wkly_earn "HH Weekly Labor Earnings"
	label var hh_invol "Any HH Member Invol. Unemployment"
	label var hh_biz_nonag "Any non-Ag. Self Employment"

	*Consumption (Table 6) variables:
	label var value_cons23 "HH Monthly Consumption: Total"
	label var value_cons20_mo "HH Monthly Consumption: Durables"
	label var value_nondurables "HH Monthly Consumption: Nonurables"
	
	label var hh_wkly_earn "HH Weekly Labor Earnings"
	
	*Summary statistics variables:
	
	label var hh_size "HH size"
	

	
********************************************************************************
*define the matrix:
mat B = J(`reps',2,.)

*first, we run the basic model:

areg `y' exposure2 i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)

mat b = e(b)
mat B[1,1]=b[1,1]
mat P[1,`pos']=b[1,1]

est clear

********************************************************************************
*now we must start the loop:
sort state_dist

*we generate a variable that contains the share each district was selected as "treated":
gen selected_treat = 0

forvalues iter=1/`reps' {

	****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers:
	gen random = runiform()
	replace random=. if state_dist[_n-1]==state_dist
	gen exposure2_`iter'_aux = 0 if random!=.
	
	*for the choice of the treatment we take the 132 lowest randoms from 355
	egen random_rank = rank(random)
	replace exposure2_`iter'_aux = 1 if random_rank<=132 & random!=.
	*tab exposure2_`iter'
	bysort state_dist: egen exposure2_`iter' = mean(exposure2_`iter'_aux)
	replace exposure2_`iter' = 0 if round!=68
	drop exposure2_`iter'_aux random random_rank
	
	*update the selected variable:
	replace selected_treat = selected_treat + exposure2_`iter'/`reps'
	
	****************************************************************************
	*ESTIMATING THE MODEL AND SAVING THE COEFFICIENT
	
	areg `y' exposure2_`iter' i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear
	
	drop exposure2_`iter'
	
}

	
*check the randomization by the LLN:
sum selected_treat

*mat li B

*now we set the dataset as the matrix of simulated coefficients:
clear 
svmat B

rename B1 coef
rename B2 dist

*now we generate the p-value:
egen aux = mean(coef)

gen x = 0
replace x =1 if dist <= aux

egen rank = sum(x)
gen pct = rank/`reps'

gen pval = 2*(1 - pct) if pct>0.5
replace pval = 2*pct if pct<=0.5
	
drop pct

*storing the p-value and other information on the matrix P:
sum pval
mat P[5,`pos']=r(mean)

sum dist
mat P[2,`pos']=r(mean)
mat P[3,`pos']=r(sd)

sum rank
mat P[4,`pos']=r(mean)
	

*and changig the position pos:
local pos=1+`pos'
di `pos'

}

********************************************************************************
*now for the daily wage:

*local reps 500
*local pos=1

di "Dependent Variable: dly_wage"

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801	

use "$hhdata/HH_regression_data2016_wage_long.dta", clear

*** To obtain hh_pc_cons_m_ea_66 ***
merge m:1 state_id district_id round using "$hhdata/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge
*** To obtain hh_pc_cons_m_ea_66 ***

*SETTING THE EXPOSURE VARIABLES:

*defining log-exposure:

gen     exp_ratio_noSKS_scl2_lnX64=0
replace exp_ratio_noSKS_scl2_lnX64= exp_ratio_noSKS_scl2_ln if round==64


gen exp_ratio_noSKS_scl2X64=0
replace exp_ratio_noSKS_scl2X64=exp_ratio_noSKS_scl2 if round==64

rename exp_rationoSKS_scl2_lnXpost exposure1

*defining binary meaasure of any exposure:

gen  exp_rationoSKS_scl2_dumX64=0
replace exp_rationoSKS_scl2_dumX64 = exp_ratio_noSKS_scl2_dum if round==64

*rename exp_rationoSKS_scl2_dumXpost exposure2

label var exposure1 "Log(Exposure Ratio) $\times$ Post 2010"
label var exposure2 "Any exposed lender $\times$ Post 2010"
label var dly_wage "Casual Daily Wage"	

	
********************************************************************************
*define the matrix:
mat B = J(`reps',2,.)

*first, we run the basic model:

areg dly_wage exposure2 i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)

mat b = e(b)
mat B[1,1]=b[1,1]
mat P[1,`pos']=b[1,1]

est clear

********************************************************************************
*now we must start the loop:
sort state_dist

*we generate a variable that contains the share each district was selected as "treated":
gen selected_treat = 0

forvalues iter=1/`reps' {

	****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers:
	gen random = runiform()
	replace random=. if state_dist[_n-1]==state_dist
	gen exposure2_`iter'_aux = 0 if random!=.
	
	*for the choice of the treatment we take the 132 lowest randoms from 355
	egen random_rank = rank(random)
	replace exposure2_`iter'_aux = 1 if random_rank<=132 & random!=.
	*tab exposure2_`iter'
	bysort state_dist: egen exposure2_`iter' = mean(exposure2_`iter'_aux)
	replace exposure2_`iter' = 0 if round!=68
	drop exposure2_`iter'_aux random random_rank
	
	*update the selected variable:
	replace selected_treat = selected_treat + exposure2_`iter'/`reps'
	
	****************************************************************************
	*ESTIMATING THE MODEL AND SAVING THE COEFFICIENT
	
	areg dly_wage exposure2_`iter' i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear
	
	drop exposure2_`iter'
	
}

	
*check the randomization by the LLN:
sum selected_treat

********************************************************************************
*now for the non-agricultural daily wage:

*local reps 500
*local pos=1

di "Dependent Variable: dly_wage"

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801	

use "$hhdata/HH_regression_data2016_wage_long.dta", clear

*** To obtain hh_pc_cons_m_ea_66 ***
merge m:1 state_id district_id round using "$hhdata/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge
*** To obtain hh_pc_cons_m_ea_66 ***

*SETTING THE EXPOSURE VARIABLES:

*defining log-exposure:

gen     exp_ratio_noSKS_scl2_lnX64=0
replace exp_ratio_noSKS_scl2_lnX64= exp_ratio_noSKS_scl2_ln if round==64


gen exp_ratio_noSKS_scl2X64=0
replace exp_ratio_noSKS_scl2X64=exp_ratio_noSKS_scl2 if round==64

rename exp_rationoSKS_scl2_lnXpost exposure1

*defining binary meaasure of any exposure:

gen  exp_rationoSKS_scl2_dumX64=0
replace exp_rationoSKS_scl2_dumX64 = exp_ratio_noSKS_scl2_dum if round==64

*rename exp_rationoSKS_scl2_dumXpost exposure2

label var exposure1 "Log(Exposure Ratio) $\times$ Post 2010"
label var exposure2 "Any exposed lender $\times$ Post 2010"
label var dly_wage "Casual Daily Wage"	

	
********************************************************************************
*define the matrix:
mat B = J(`reps',2,.)

*first, we run the basic model:

areg dly_wage exposure2 i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)

mat b = e(b)
mat B[1,1]=b[1,1]
mat P[1,`pos']=b[1,1]

est clear

********************************************************************************
*now we must start the loop:
sort state_dist

*we generate a variable that contains the share each district was selected as "treated":
gen selected_treat = 0

forvalues iter=1/`reps' {

	****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers:
	gen random = runiform()
	replace random=. if state_dist[_n-1]==state_dist
	gen exposure2_`iter'_aux = 0 if random!=.
	
	*for the choice of the treatment we take the 132 lowest randoms from 355
	egen random_rank = rank(random)
	replace exposure2_`iter'_aux = 1 if random_rank<=132 & random!=.
	*tab exposure2_`iter'
	bysort state_dist: egen exposure2_`iter' = mean(exposure2_`iter'_aux)
	replace exposure2_`iter' = 0 if round!=68
	drop exposure2_`iter'_aux random random_rank
	
	*update the selected variable:
	replace selected_treat = selected_treat + exposure2_`iter'/`reps'
	
	****************************************************************************
	*ESTIMATING THE MODEL AND SAVING THE COEFFICIENT
	
	areg dly_wage exposure2_`iter' i.round i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist) vce(cluster state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear
	
	drop exposure2_`iter'
	
}

	
*check the randomization by the LLN:
sum selected_treat

*mat li B

*now we set the dataset as the matrix of simulated coefficients:
clear 
svmat B

rename B1 coef
rename B2 dist

*now we generate the p-value:
egen aux = mean(coef)

gen x = 0
replace x =1 if dist <= aux

egen rank = sum(x)
gen pct = rank/`reps'

gen pval = 2*(1 - pct) if pct>0.5
replace pval = 2*pct if pct<=0.5
	
drop pct

*storing the p-value and other information on the matrix P:
sum pval
mat P[5,`pos']=r(mean)

sum dist
mat P[2,`pos']=r(mean)
mat P[3,`pos']=r(sd)

sum rank
mat P[4,`pos']=r(mean)
	

*and changig the position pos:
local pos=1+`pos'
di `pos'

********************************************************************************
********************************************************************************
*now for the non-agricultural daily wage:

*local reps 500
*local pos=1

di "Dependent Variable: non-ag dly_wage"

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801	

use "$hhdata/HH_regression_data2016_wage_long.dta", clear

*** To obtain hh_pc_cons_m_ea_66 ***
merge m:1 state_id district_id round using "$hhdata/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge
*** To obtain hh_pc_cons_m_ea_66 ***

*SETTING THE EXPOSURE VARIABLES:

*defining log-exposure:

gen     exp_ratio_noSKS_scl2_lnX64=0
replace exp_ratio_noSKS_scl2_lnX64= exp_ratio_noSKS_scl2_ln if round==64


gen exp_ratio_noSKS_scl2X64=0
replace exp_ratio_noSKS_scl2X64=exp_ratio_noSKS_scl2 if round==64

rename exp_rationoSKS_scl2_lnXpost exposure1

*defining binary meaasure of any exposure:

gen  exp_rationoSKS_scl2_dumX64=0
replace exp_rationoSKS_scl2_dumX64 = exp_ratio_noSKS_scl2_dum if round==64

*rename exp_rationoSKS_scl2_dumXpost exposure2

label var exposure1 "Log(Exposure Ratio) $\times$ Post 2010"
label var exposure2 "Any exposed lender $\times$ Post 2010"
label var dly_wage "Casual Daily Wage"	

	
********************************************************************************
*define the matrix:
mat B = J(`reps',2,.)

*first, we run the basic model:

areg dly_wage exposure2 i.labor_type_id#i.round $controls_new if labor_type_id==2 | labor_type_id==4 [pweight=weight], absorb(state_dist) vce(cluster state_dist)

mat b = e(b)
mat B[1,1]=b[1,1]
mat P[1,`pos']=b[1,1]

est clear

********************************************************************************
*now we must start the loop:
sort state_dist

*we generate a variable that contains the share each district was selected as "treated":
gen selected_treat = 0

forvalues iter=1/`reps' {

	****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers:
	gen random = runiform()
	replace random=. if state_dist[_n-1]==state_dist
	gen exposure2_`iter'_aux = 0 if random!=.
	
	*for the choice of the treatment we take the 132 lowest randoms from 355
	egen random_rank = rank(random)
	replace exposure2_`iter'_aux = 1 if random_rank<=132 & random!=.
	*tab exposure2_`iter'
	bysort state_dist: egen exposure2_`iter' = mean(exposure2_`iter'_aux)
	replace exposure2_`iter' = 0 if round!=68
	drop exposure2_`iter'_aux random random_rank
	
	*update the selected variable:
	replace selected_treat = selected_treat + exposure2_`iter'/`reps'
	
	****************************************************************************
	*ESTIMATING THE MODEL AND SAVING THE COEFFICIENT
	
	areg dly_wage exposure2_`iter' i.labor_type_id#i.round $controls_new if labor_type_id==2 | labor_type_id==4 [pweight=weight], absorb(state_dist) vce(cluster state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear
	
	drop exposure2_`iter'
	
}

*check the randomization by the LLN:
sum selected_treat

*mat li B

*now we set the dataset as the matrix of simulated coefficients:
clear 
svmat B

rename B1 coef
rename B2 dist

*now we generate the p-value:
egen aux = mean(coef)

gen x = 0
replace x =1 if dist <= aux

egen rank = sum(x)
gen pct = rank/`reps'

gen pval = 2*(1 - pct) if pct>0.5
replace pval = 2*pct if pct<=0.5
	
drop pct

*storing the p-value and other information on the matrix P:
sum pval
mat P[5,`pos']=r(mean)

sum dist
mat P[2,`pos']=r(mean)
mat P[3,`pos']=r(sd)

sum rank
mat P[4,`pos']=r(mean)
	

*and changig the position pos:
local pos=1+`pos'
di `pos'


outtable using "$tables/RI1.tex", mat(P) replace 
