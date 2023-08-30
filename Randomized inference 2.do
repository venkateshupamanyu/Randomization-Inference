set more off
clear all
est clear
set matsize 500

/***********************
RANDOMIZED INFERENCE

MFI Level Permutation
	
***********************/

/*
*cd "/Users/eb2840/Dropbox (CBS)/AP Crisis Macro Impacts"
*cd "D:/Dropbox (CBS)/AP Crisis Macro Impacts"
*cd "C:\Users\cgk281\Dropbox (IndiaHIE)\AP Crisis Macro Impacts"
*cd "/Users/Sang/Dropbox/AP Crisis Macro Impacts"
cd  "C:\Users\barsa.DESKTOP-QFJ64VJ\Dropbox\AP Crisis Macro Impacts"

global datawork "Data/WorkingData/"
*global tables "Analysis/Tables/Selfgenerated Tables"
global tables "Analysis/Tables/June2017"
global outR "PFriedrichSummer2015/Robustness"
global outG "Analysis/Figures/Balance"
global hhdata "Analysis/Working Data"
global hh "Analysis/Tables/"
global paper "Analysis/Tables/Tables for paper/"
global writeup "Writeup/Tables for paper/"
global rainfall "Analysis/Rainfall"
global allenatkin "Analysis/Distance"
global party "Analysis/Political party data"
global crops "Analysis/crops2016/regression"
global nss70 "Data\NSS\Harvard Library 2016\Debt_Invest\Data Clean"
global randinf "Analysis/RI"
*/

********************************************************************************
*PRELIMINARY
********************************************************************************

	*set matrix with the p-values:
	mat P = J(5,6,.)

	*repetitions:
	local reps 500
	
	*dependent variable:
	global y_key "value_cons23 value_cons20_mo hh_wkly_earn hh_wkly_dys_wrk_casual"
	*also casual wages (long dataset)

	
********************************************************************************	
********************************************************************************
*PREPARE THE MFI DATA **********************************************************
********************************************************************************
********************************************************************************

*we first clean the data:
*this is the same as in 140118_mfi_clean_dist_names.do

use "Data/MFI Clean Data/MFI_Cleaned_SKS.dta", clear

* Replace State names to Lower-Case
replace state=lower(state) // State names to Lower-case
replace state=subinstr(state," ","",10) // remove " "
replace state=subinstr(state,".","",4)  // remove "."
replace state=subinstr(state,",","",4)  // remove ","
replace state=subinstr(state,"&","",4)  // remove "&"
replace state=subinstr(state,"(","",4)  // remove "("
replace state=subinstr(state,")","",4)  // remove ")"
replace state=subinstr(state,"*","",4)  // remove "*"

* Match: State Names
replace state="jammukashmir" if state=="jammukashmer"
replace state="karnataka" if state=="karnatak"
replace state="uttaranchal" if (state=="uttarakhand" | state=="uttrakhand" | state=="uttarkhand")
replace state="orissa" if state=="odisha"
replace state="pondicherry" if state=="puducherry"
replace state="gujarat" if state=="gujrat"
replace state="chhattisgarh" if (state=="chathisgarh" | state=="chattisgarh")
replace state="karnataka" if state=="karnatka"
replace state="maharashtra" if state=="maharastra"
replace state="haryana" if state=="hariyana"
replace state="chandigarh" if state=="chandigarhut"
replace state="delhi" if state=="newdelhi"
replace state="assam" if state=="asam"
 
* District names to lower case and remove characters
replace district=lower(district)
replace district=subinstr(district," ","",10)
replace district=subinstr(district,".","",4)
replace district=subinstr(district,"-","",4)
replace district=subinstr(district,",","",4)
replace district=subinstr(district,"&","",4)
replace district=subinstr(district,"(","",4)
replace district=subinstr(district,")","",4)
replace district=subinstr(district,"*","",4)
replace district=subinstr(district,"'","",4)

* Match: State Names (corrected)
replace state="uttarpradesh" if district=="bareilly" & state=="uttaranchal"
replace state="uttarpradesh" if district=="saharanpur" & state=="uttaranchal"
replace state="uttarpradesh" if district=="agra" & state=="rajasthan"
replace state="maharashtra" if district=="yavatmal" & state=="andhrapradesh"

* Match: District Names
replace district="" if district==""
replace district="south" if state=="delhi" & district=="southdelhi"
replace district="southwest" if state=="delhi" & district=="southwestdelhi"
replace district="northwest" if state=="delhi" & district=="northwestdelhi"
replace district="bhopal" if district=="bhopalrural" & state=="madhyapradesh"
replace district="hoshangabad" if (district=="hosangabad" | district=="hosangbad") & (state=="madhyapradesh")
replace district="vidisha" if district=="vidhisa" & state=="madhyapradesh"
replace district="ahmadnagar" if district=="ahmednagar" & state=="maharashtra"
replace district="bid" if district=="beed" & state=="maharashtra"
replace district="khordha" if district=="bhubaneswar" & state=="orissa"
replace district="pondicherry" if district=="puducherry"
replace district="karaikal" if district=="karaikkal" & state=="pondicherry"
replace district="ludhiana" if district=="ludhiyana" & state=="punjab"
replace district="kancheepuram" if district=="kanchipuram" & state=="tamilnadu"
replace district="sivaganga" if district=="sivagangai" & state=="tamilnadu"
replace district="toothukudi" if district=="thoothukkudi" & state=="tamilnadu"
replace district="viluppuram" if district=="villupuram" & state=="tamilnadu"
replace district="agra" if district=="agara" & state=="uttarpradesh"
replace district="ambedkarnag" if district=="ambedkarnagar" & state=="uttarpradesh"
replace district="ballia" if district=="balia" & state=="uttarpradesh"
replace district="bulandshahr" if (district=="bulandshahar" | district=="bulandsahar") & state=="uttarpradesh"
replace district="gorakhpur" if (district=="gorakhapur" | district=="barhalganj") & state=="uttarpradesh"
replace district="moradabad" if district=="muradabad" & state=="uttarpradesh"
replace district="shahjahanpur" if district=="shahajahanpur" & state=="uttarpradesh"
replace district="saran" if district=="chapra" & state=="bihar"
replace district="vaishali" if district=="hazipur" & state=="bihar"
replace district="jphulenagar" if state=="uttarpradesh" & (district=="amroha" | district=="jpnagar" | district=="jpnagaramroha")
replace district="tiruvanamalai" if state=="tamilnadu" & district=="tiruvannamalai"
replace district="thiruvallur" if state=="tamilnadu" & district=="tiruvallur"
replace district="thiruvarur" if state=="tamilnadu" & district=="tiruvarur"
replace district="skabirnagar" if state=="uttarpradesh" & district=="santkabirnagar"
replace district="northeast" if state=="delhi" & district=="northeastdelhi"
replace district="north" if state=="delhi" & district=="northdelhi"
replace district="ghaziabad" if state=="uttarpradesh" & (district=="gaziabad" | district=="gazaibad")
replace district="narsimhapur" if state=="madhyapradesh" & district=="narsingpur"
replace district="baleshwar" if state=="orissa" & district=="balesore"
replace district="balangir" if state=="orissa" & district=="bolangir"
replace district="jajapur" if state=="orissa" & district=="jajpur"
replace district="khordha" if state=="orissa" & (district=="khurdha" | district=="khurda")
replace district="nabarangapur" if state=="orissa" & district=="nawrangpur"
replace district="sonapur" if state=="orissa" & district=="sonepur"
replace district="north24-parganas" if state=="westbengal" & district=="north24"
replace district="purbamidnapur" if district=="purbamedinipur" & state=="westbengal"
replace district="south24-parganas" if state=="westbengal" & (district=="south24" | district=="south24parganas")
replace district="hugli" if state=="westbengal" & district=="hoogly"
replace district="barddhaman" if state=="westbengal" & (district=="burwman" | district=="bardhaman" | district=="burdwan")
replace district="srnagarbhadoh" if state=="uttarpradesh" & (district=="bhadohi" | district=="bhodohi")
replace district="nainitalh" if state=="uttaranchal" & (district=="" | district=="")
replace district="pudukkottai" if state=="tamilnadu" & district=="pudukottai"
replace district="tiruvanamalai" if state=="tamilnadu" & district=="thiruvannamalai"
replace district="tiruchirappalli" if state=="tamilnadu" & district=="tiruchirapalli"
replace district="toothukudi" if state=="tamilnadu" & district=="tuticorin"
replace district="puruliya" if state=="westbengal" & district=="purulia"
replace district="bareilly" if state=="uttarpradesh" & district=="barelly"
replace district="saharanpur" if state=="uttarpradesh" & district=="saharnpur"
replace district="hardwar" if state=="uttaranchal" & district=="haridwar"
replace district="amravati" if state=="maharashtra" & district=="amaravathi"
replace district="buldana" if state=="maharashtra" & district=="buldhana"
replace district="gondiya" if state=="maharashtra" & district=="gondia"
replace district="jalgaon" if state=="maharashtra" & district=="jalgoan"
replace district="osmanabad" if state=="maharashtra" & district=="osamanabad"
replace district="sangli" if state=="maharashtra" & district=="sangali"
replace district="solapur" if state=="maharashtra" & district=="sholapur"
replace district="singhbhume" if state=="jharkhand" & district=="eastsinghbhum"
replace district="kodarma" if state=="jharkhand" & district=="koderma"
replace district="chhindwara" if state=="madhyapradesh" & district=="chhindawara"
replace district="dhaulpur" if state=="rajasthan" & district=="dholpur"
replace district="southnimachai" if state=="sikkim" & district=="southsikkim"
replace district="eastgangtok" if state=="sikkim" & district=="eastsikkim"
replace district="raipur" if state=="chhattisgarh" & district=="bhatapara"
replace district="rajnandgaon" if state=="chhattisgarh" & district=="rajnadgaon"
replace district="champarane" if state=="bihar" & district=="purvichamparan"
replace district="saran" if state=="bihar" & district=="sonepur"
replace district="katihar" if state=="bihar" & district=="kathihar"
replace district="anantapur" if state=="andhrapradesh" & district=="ananthapur"
replace district="cuddapah" if state=="andhrapradesh" & district=="kadapa"
replace district="chittoor" if state=="andhrapradesh" & district=="kuppam"
replace district="rangareddi" if state=="andhrapradesh" & district=="rangareddy"
replace district="kendujhar" if state=="orissa" & district=="keonjhar"
replace district="kandhamalphoolbani" if state=="orissa" & district=="kandhamal"
replace district="bangalore" if state=="karnataka" & district=="bangaloreurban"
replace district="nainitalh" if state=="uttaranchal" & (district=="nainital" | district=="nanital")
replace district="kolar" if state=="karnataka" & district=="chikkaballapura" | district=="chikkaballapur"
replace district="chikmagalur" if state=="karnataka" & district=="chikkamagalore"
replace district="davanagere" if state=="karnataka" & (district=="davangere" | district=="devaganere" | district=="devanagere")
replace district="bangalorerural" if state=="karnataka" & (district=="ramanagara" | district=="ramanagaram")
replace district="uttarakannada" if state=="karnataka" & district=="uttarkannada"
replace district="kanniyakumari" if state=="tamilnadu" & district=="kanyakumari"
replace district="thenilgiris" if state=="tamilnadu" & district=="nilgiris"
replace district="thiruvallur" if state=="tamilnadu" & district=="thiruvalluar"
replace district="tiruchirappalli" if state=="tamilnadu" & district=="trichy"
replace district="hazaribag" if state=="jharkhand" & district=="ramgarh"
replace district="dindigul" if state=="tamilnadu" & district=="dindugal"
replace district="anugul" if state=="orissa" & district=="angul"
replace district="puri" if state=="orissa" & district=="purid"
replace district="sambalpur" if state=="orissa" & district=="bhojpur"
replace district="baleshwar" if state=="orissa" & district=="baleswar"
replace district="kawardha" if state=="chhattisgarh" & district=="kabirdham"
replace district="kozhikode" if state=="kerala" & district=="kozhikkode"
replace district="kasaragod" if state=="kerala" & district=="kasargode"
replace district="thiruvananthapuram" if state=="kerala" & district=="trivandrum"
replace district="nashik" if state=="maharashtra" & district=="nasik"
replace district="thane" if state=="maharashtra" & district=="thaned"
replace district="kamrup" if state=="assam" &(district=="kamrupmetro" | district=="kamruprural")
replace district="kaimurbhabua" if state=="bihar" & district=="kaimur"
replace district="bharuch" if state=="gujarat" & district=="ankaleshwar"
replace district="vadodara" if state=="gujarat" & district=="baroda"
replace district="bharuch" if state=="gujarat" & district=="baruch"
replace district="sonipat" if state=="haryana" & district=="sonepat"
replace district="faridabad" if state=="haryana" & district=="palwal"
replace district="hisar" if state=="haryana" & district=="hissar"
replace district="ambala" if state=="haryana" & district=="amblacant"
replace district="belgaum" if state=="karnataka" & district=="belgam"
replace district="bagalkot" if state=="karnataka" & district=="bagalkote"
replace district="chamarajanagar" if state=="karnataka" & district=="chamarajanagara"
replace district="chitradurga" if state=="karnataka" & district=="chithradurga"
replace district="dharwad" if state=="karnataka" & district=="dharwar"
replace district="devanagere" if state=="karnataka" & district=="harihara"
replace district="koppal" if state=="karnataka" & district=="koppala"
replace district="bathinda" if state=="punjab" & district=="bhatinda"
replace district="ajmer" if state=="rajasthan" & district=="ajmeer"
replace district="jaipur" if state=="rajasthan" & (district=="bhahmpuri" | district=="brahmpuri")
replace district="ajmer" if state=="rajasthan" & district=="kishangarh"
replace district="sawaimadhopur" if state=="rajasthan" & district=="sawaimadhavpur"
replace district="ganganagar" if state=="rajasthan" & district=="sriganganagar"
replace district="north24-parganas" if state=="westbengal" & (district=="24parganasnorth" | district=="north24prgs")
replace district="south24-parganas" if state=="westbengal" & (district=="24parganassouth" | district=="south24prgs")
replace district="kochbihar" if state=="westbengal" & district=="coochbehar"
replace district="darjiling" if state=="westbengal" & district=="darjeeling"
replace district="purbamidnapur" if state=="westbengal" & (district=="eastmidnapur" | district=="midnaporeeast")
replace district="hugli" if state=="westbengal" & district=="hooghly"
replace district="maldah" if state=="westbengal" & district=="malda"
replace district="uttardinajpur" if state=="westbengal" & district=="northdinajpur"
replace district="paschimmidnapur" if state=="westbengal" & (district=="paschimmedinipur" | district=="westmidnapore")
replace district="dakshindinajpur" if state=="westbengal" & (district=="southdinajpur" | district=="southdenajpur")
replace district="alappuzha" if state=="kerala" & district=="allapuzha"
replace district="ernakulam" if state=="kerala" & district=="cochin"
replace district="chhindwara" if state=="madhyapradesh" & district=="chindwara"
replace district="hoshangabad" if state=="madhyapradesh" & district=="itarsi"
replace district="narsimhapur" if state=="madhyapradesh" & (district=="narsinghpur" | district=="narsingapur" | district=="narsinghpur" | district=="narshingpur")
replace district="katni" if state=="madhyapradesh" & district=="katani"
replace district="wnimar" if state=="madhyapradesh" & district=="khargone"
replace district="enimar" if state=="madhyapradesh" & district=="khandwa"
replace district="rewa" if (state=="madhyapradesh" | state=="uttarpradesh") & district=="reewa"
replace district="varanasi" if state=="uttarpradesh" & district=="varansi"
replace district="raebareli" if state=="uttarpradesh" & (district=="raibareilly" | district=="raibareliy")
replace district="jphulenagar" if state=="uttarpradesh" & district=="jyotibaphulenagar"
replace district="kanpurnagar" if state=="uttarpradesh" & district=="kanpur"
replace district="firozabad" if state=="uttarpradesh" & district=="ferozabad"
replace district="etah" if state=="uttarpradesh" & district=="etha"
replace district="bijnor" if state=="uttarpradesh" & district=="bijnour"
replace district="ghazipur" if state=="uttarpradesh" & district=="gazipur"
replace district="hathras" if state=="uttarpradesh" & district=="mahamayanagar"
replace district="dehradunh" if state=="uttaranchal" & (district=="dehradun" | district=="dehradoon")
replace district="hardwar" if state=="uttaranchal" & (district=="roorke" | district=="roorkee")
replace district="warangal" if state=="andhrapradesh" & district=="waragal"
replace district="basti" if state=="uttarpradesh" & district=="basticity"
replace district="budaun" if state=="uttarpradesh" & (district=="badaun" | district=="baduan")
replace district="moradabad" if state=="uttarpradesh" & district=="bhimnagar"
replace district="ghaziabad" if state=="uttarpradesh" & (district=="hapur" | district=="panchsheelnagar" | district=="garhmukteshwar")
replace district="muzaffarnagar" if state=="uttarpradesh" & district=="muzafernagar"
replace district="etah" if state=="uttarpradesh" & (district=="kashiramnagar" | district=="kasganj")
replace district="shimoga" if state=="karnataka" & district=="shivmoga"
replace district="gulbarga" if state=="karnataka" & district=="yadgir"
replace district="alappuzha" if state=="kerala" & district=="allepy"
replace district="gurdaspur" if state=="punjab" & district=="pathankot"
replace district="ramanathapuram" if state=="tamilnadu" & district=="ramnad"
replace district="thanjavur" if state=="tamilnadu" & district=="tanjore"
replace state="pondicherry" if state=="tamilnadu" & district=="pondichery"
replace district="tirunelveli" if state=="tamilnadu" & district=="thirunelveli"
replace district="coimbatore" if state=="tamilnadu" & (district=="thiruppur" | district=="tirupur" | district=="tiruppur")
replace district="pondicherry" if state=="pondicherry" & district=="pondichery"
replace district="kurukshetra" if state=="haryana" & district=="krukshetra"

* Fixes for SKS
replace district="aurangabad" if district=="aurangabadofbihar"
replace district="bhojpur" if district=="arrah" & MFI=="Saija"
replace district="vaishali" if district=="hajipur" & MFI=="Saija"
replace district="lakshadweephisarai" if district=="lakhisarai" & state=="bihar"
replace district="champarane" if district=="purbachamparan" & state=="bihar"
replace district="champaranw" if district=="pashchimchamparan"  & state=="bihar"
replace district=subinstr(district,"ofchhattisgarh","",1)
replace district="ahmedabad" if district=="ahmadabad" & state=="gujarat"
replace district=subinstr(district,"ofgujarat","",1)
replace district="dohad" if district=="dahod"
replace district="panchmahals" if district=="panchmahal"
replace district="pakaur" if district=="pakur" & state=="jharkhand"
replace district="singhbhume" if district=="purbasinghbhum"
replace district="singhbhumw" if district=="pashchimsinghbhum"
replace district="chamarajanagar" if district=="chamrajnagar"
replace district="davanagere" if district=="devanagere"
replace district="dakshinakannada" if district=="dakshinkannad"
replace district="uttarakannada" if district=="uttarkannand"
replace district="palakshadweepkad" if district=="palakkad"
replace district="pathanamthitta" if district=="pattanamtitta"
replace district="enimar" if district=="eastnimar"
replace district="wnimar" if district=="westnimar"
replace district=subinstr(district,"ofmaharashtra","",1)
replace district="bargarh" if district=="baragarh"
replace district="baudh" if district=="boudh"
replace district="nabarangapur" if district=="nabarangpur"
replace district="nainitalh" if district=="haldwani"
replace district="garhwal" if district=="paurigarhwal"
replace district="hoshangabad" if district=="hosangbad" & state=="uttarpradesh"
replace state="madhyapradesh" if district=="hoshangabad" & state=="uttarpradesh"
replace district="birbhum" if district=="bhirbhum"
replace district="howrah" if district=="haora"
replace district=subinstr(district, "-", "", 1)
replace state="madhyapradesh" if state=="uttarpradesh" & district=="rewa"
replace district="kheri" if district=="lakhimpurkheri"
replace district="srnagarbhadoh" if district=="santravidasnagar"
replace district="visakhapatnam" if district=="vishakhapatnam" & state=="andhrapradesh"
replace district="debagarh" if district=="deogarh"
replace district="jagatsinghapur" if district=="jagatsinghpur"
replace district="purbamidnapur" if district=="midnapore" & branch=="Panskura"
replace district="purbamidnapur" if district=="midnapore" & branch==" Panskura"
replace district="paschimmidnapur" if district=="midnapore" & branch=="Midnapore"
replace district="paschimmidnapur" if district=="midnapore" & branch==" Midnapore"
replace district="paschimmidnapur" if district=="midnapore" & branch=="Kharagpur"
replace district="paschimmidnapur" if district=="midnapore" & branch==" Kharagpur"
replace district="purbamidnapur" if district=="midnapore" & branch=="Mecheda"
replace district="purbamidnapur" if district=="midnapore" & branch==" Mecheda"
replace district="purbamidnapur" if district=="midnapore" & branch=="Mechada"
replace district="purbamidnapur" if district=="midnapore" & branch==" Mechada"
replace district="purbamidnapur" if district=="midnapore" & branch=="Mechada Bazar"
replace district="purbamidnapur" if district=="midnapore" & branch==" Mechada Bazar"

* Gabriel Tourek fixes
replace district="sultanpur" if district=="chhatrapatisahujimaharajnagar" & state=="uttarpradesh" //"ch..." split from sultanpur and raebareli districts in 2010

* Cleaning unnecessary observations e.g. total, mple (FIXME)
drop if strpos(district, "educational")!=0
drop if strpos(district, "total")!=0
drop if strpos(state, "tobeclo")!=0
drop if strpos(district,"purchased")!=0
drop if strpos(district, "loanstoeducational")!=0

* Add securitization variable

g secure = 0

replace secure = 1 if MFI == "Arohan" | MFI == "Asirvad" | MFI == "Chaitanya" | MFI == "GV" | MFI == "GrameenKoota" | MFI == "MPower" | MFI == "Satin" | MFI ==  "SURYODAY" | MFI == "SVCL" | MFI == "Sonata" | MFI == "Swadhaar" | MFI == "Ujjivan" | MFI == "Utkarash"

	* Drop obs that won't match
	drop if state=="westbengal" & district=="westbengal"
	
	* Replace all Delhi districts as one
	
	/* NOTE: Combining all Delhi districts into one - the difference in exposure between the districts as listed is stark
	for the different MFI's: it is either ~28% in the "delhi" district or =0% in the other regions, the average is ~16%
	when combining the two sets - combine for now and revisit*/
	
	replace district="delhi" if state=="delhi"

*we drop SKS (as in the other results of the paper):
drop if MFI=="SKS"	
	
*now we collapse at the district-time-MFI level:
format GLP %20.4f
sort Year Month MFI state district branch
collapse (sum) GLP AC LA PAR* Total (mean) secure, by(state district Year Month MFI)


********************************************************************************
*check the number of exposed/unexposed MFIs:
********************************************************************************

preserve

* Total_PF: total portfolio loan by MFI by particular Year & month
	bys Year Month MFI: egen Total_PF = sum (GLP)
	format Total_PF %20.4f
	
	*exclude MFIs w/ no data for Sept. 2010:
	gen GLP_0910 = GLP if Year==2010 & Month==1
	bysort MFI: egen Total_PF_0910 = sum (GLP_0910)
	drop if Total_PF_0910==0

* AP_PF: Portfolio loan invested by MFI in AP state by Year & Month
	* if state=="andhrapradesh"
	bys Year Month MFI: egen AP_PF = sum (GLP) if state=="andhrapradesh"
	format AP_PF %20.4f

	replace AP_PF=0 if AP_PF>=.
	
* APtemp = AP_PF with missing values replaced by "0"
	rename AP_PF APtemp

* AP_PF: maximum investment made by an MFI in Andhra Pradesh by Year & Month
	bys Year Month MFI: egen AP_PF = max (APtemp) 

* FracAP: maximum investment by MFI in AP divided by total investment by Year & Month
	gen FracAP = AP_PF/Total_PF

* exp_frac and exp: in Sep 2010, maximum investment by MFI in AP, both as fraction and total
	gen exp_frac_aux = FracAP if (Month==1 & Year==2010)
	gen exp_aux = AP_PF if (Month==1 & Year==2010)

* FracAPPre: maximum value of APPretemp by MFI level
	bysort MFI: egen exp= max (exp_aux)
	bysort MFI: egen exp_frac = max (exp_frac_aux)

* in Muthoot and Satin file, manage for missing values
	replace exp=0 if exp>=. & MFI=="Muthoot"
	replace exp=0 if exp>=. & MFI=="Satin"
	replace exp_frac=0 if exp_frac>=. & MFI=="Muthoot"
	replace exp_frac=0 if exp_frac>=. & MFI=="Satin"

*collapsing:
	collapse (max) exp exp_frac (sum) GLP, by (Year Month MFI state district)
	*collapse (mean) exp exp_frac GLP, by (Year MFI state district)
	
	tab MFI if GLP!=. & Year==2010 & Month==1
	
	*the values in 2010 refer to the pre-crisis period (that is, I use September for pre-crisis level)
	drop if Month==0 & Year==2010
	drop Month
	tab state
	
	
gen exp_dum=0
replace exp_dum=1 if exp>0
tab exp_dum
collapse (mean) exp_dum, by(MFI)
tab exp_dum

/* 4 out of 23 exposed MFIs (total of 175560 permutations)
    exp_dum |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         19       81.82       81.82
          1 |          4       18.18      100.00
------------+-----------------------------------
      Total |         22      100.00

*/


restore


********************************************************************************
*Generate dummy for the presence of each MFI:
********************************************************************************

*exclude MFIs w/ no data for Sept. 2010:
gen GLP_0910 = GLP if Year==2010 & Month==1
bysort MFI: egen Total_PF_0910 = sum (GLP_0910)
drop if Total_PF_0910==0


egen mfi_id = group(MFI)
sum mfi_id

*generate a variable if the MFI was present in the eve of the crisis (Sept-2010) at the district:

forvalues m=1/23 {

gen mfi_pres_`m' = 0
replace mfi_pres_`m' = 1 if GLP!=. & GLP>0 & Month==1 & Year==2010 & mfi_id==`m'

}

collapse (sum) mfi_pres_*, by(state district)
sum if state!="andhrapradesh"

rename state state_name
rename district district_name

*save for later use:
save "$randinf/mfi_pres_district.dta", replace

merge 1:m state_name district_name using "$hhdata/HH_regression_data_prepped.dta"
drop if _m==1
	*now we replace the presence by zero for the other districts (so the sample is the same):
	forvalues m=1/22 {
	replace mfi_pres_`m' = 0 if _m==2
	}
	drop _m
	
********************************************************************************
*PREPARE DATASET AT THE HH LEVEL
********************************************************************************

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

********************************************************************************
*RANDOMIZATION INFERENCE - VARIABLES AT THE HH LEVEL
********************************************************************************	
	
*start count of regressions:
local c=1


foreach y in $y_key {
*foreach y in value_cons23 {

di "Dependent Variable: `y'"

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801
	
	*define the matrix to store the distribution:
	mat B = J(`reps',2,.)

*run the baseline result:
areg `y' exposure2 i.round $controls_new [pweight=weight], absorb(state_dist)
*save the coefficients:
mat b = e(b)
mat P[1,`c']=b[1,1]
mat B[1,1]=b[1,1]

********************************************************************************
*now we must start the loop:
sort state_dist

forvalues iter=1/`reps' {

****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers, for each MFI:
	forvalues m=1/23 {
	gen aux_`m' = runiform()
	egen random`m' = max(aux_`m')
	drop aux_`m'
	}
	
	*generate the rannk of the MFI:
	rowranks random1-random23, gen(rank1-rank23)
	drop random*
	
	*now we assign treatment status to the highest four ranks:
	forvalues m=1/23 {
	gen exp_mfi_`m' = 0
	replace exp_mfi_`m' = 1 if rank`m'<=4
	}
	drop rank*
	
	*now we generate the exposure at the district level:
	gen exp_dist_`iter' = 0
	forvalues m=1/23 {
	replace exp_dist_`iter' = 1 if mfi_pres_`m'==1 & exp_mfi_`m' == 1 & round==68
	}

	*and then we estimate the model:
	areg `y' exp_dist_`iter' i.round $controls_new [pweight=weight], absorb(state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear

	drop exp_dist_`iter' exp_mfi_*

}

*now we set the dataset as the matrix of simulated coefficients:
preserve
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
mat P[5,`c']=r(mean)

sum dist
mat P[2,`c']=r(mean)
mat P[3,`c']=r(sd)

sum rank
mat P[4,`c']=r(mean)



*increase the regression count:
restore
local c=`c'+1
}
	
********************************************************************************/
*now we do the same for the casual wage (which uses the long file):
********************************************************************************

clear
use "$hhdata/HH_regression_data2016_wage_long.dta"
drop _m

merge m:1 state_name district_name using "$randinf/mfi_pres_district.dta"
drop _m

*** To obtain hh_pc_cons_m_ea_66 ***
merge m:1 state_id district_id round using "$hhdata/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge
*** To obtain hh_pc_cons_m_ea_66 ***

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801	

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

	*define the matrix to store the distribution:
	mat B = J(`reps',2,.)

*run the baseline result:
areg dly_wage exposure2 i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist)
*save the coefficients:
mat b = e(b)
mat P[1,`c']=b[1,1]
mat B[1,1]=b[1,1]

********************************************************************************
*now we must start the loop:
sort state_dist

forvalues iter=1/`reps' {

****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers, for each MFI:
	forvalues m=1/23 {
	gen aux_`m' = runiform()
	egen random`m' = max(aux_`m')
	drop aux_`m'
	}
	
	*generate the rannk of the MFI:
	rowranks random1-random23, gen(rank1-rank23)
	drop random*
	
	*now we assign treatment status to the highest four ranks:
	forvalues m=1/23 {
	gen exp_mfi_`m' = 0
	replace exp_mfi_`m' = 1 if rank`m'<=4
	}
	drop rank*
	
	*now we generate the exposure at the district level:
	gen exp_dist_`iter' = 0
	forvalues m=1/23 {
	replace exp_dist_`iter' = 1 if mfi_pres_`m'==1 & exp_mfi_`m' == 1 & round==68
	}

	*and then we estimate the model:
	areg dly_wage exp_dist_`iter' i.labor_type_id#i.round $controls_new [pweight=weight], absorb(state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear

	drop exp_dist_`iter' exp_mfi_*

}

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
mat P[5,`c']=r(mean)

sum dist
mat P[2,`c']=r(mean)
mat P[3,`c']=r(sd)

sum rank
mat P[4,`c']=r(mean)

local c = `c'+1

********************************************************************************/
*now we do the same for the casual non-agricultural wage (which uses the long file):
********************************************************************************

clear
use "$hhdata/HH_regression_data2016_wage_long.dta"
drop _m

merge m:1 state_name district_name using "$randinf/mfi_pres_district.dta"

*** To obtain hh_pc_cons_m_ea_66 ***
merge m:1 state_id district_id round using "$hhdata/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge
*** To obtain hh_pc_cons_m_ea_66 ***

	*seed (so same sample of treatments for every dependent variable):
	set seed 48146801	

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

	*define the matrix to store the distribution:
	mat B = J(`reps',2,.)

*run the baseline result:
areg dly_wage exposure2 i.labor_type_id#i.round $controls_new if labor_type_id==2 | labor_type_id==4 [pweight=weight], absorb(state_dist)
*save the coefficients:
mat b = e(b)
mat P[1,`c']=b[1,1]
mat B[1,1]=b[1,1]

********************************************************************************
*now we must start the loop:
sort state_dist

forvalues iter=1/`reps' {

****************************************************************************
	*GENERATING THE "TREATMENTS"
	
	*first we must generate the random numbers, for each MFI:
	forvalues m=1/23 {
	gen aux_`m' = runiform()
	egen random`m' = max(aux_`m')
	drop aux_`m'
	}
	
	*generate the rannk of the MFI:
	rowranks random1-random23, gen(rank1-rank23)
	drop random*
	
	*now we assign treatment status to the highest four ranks:
	forvalues m=1/23 {
	gen exp_mfi_`m' = 0
	replace exp_mfi_`m' = 1 if rank`m'<=4
	}
	drop rank*
	
	*now we generate the exposure at the district level:
	gen exp_dist_`iter' = 0
	forvalues m=1/23 {
	replace exp_dist_`iter' = 1 if mfi_pres_`m'==1 & exp_mfi_`m' == 1 & round==68
	}

	*and then we estimate the model:
	areg dly_wage exp_dist_`iter' i.labor_type_id#i.round $controls_new if labor_type_id==2 | labor_type_id==4 [pweight=weight], absorb(state_dist)

	mat b_`iter' = e(b)
	mat B[`iter',2]=b_`iter'[1,1]
	
	est clear

	drop exp_dist_`iter' exp_mfi_*

}

*now we set the dataset as the matrix of simulated coefficients:
preserve
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
mat P[5,`c']=r(mean)

sum dist
mat P[2,`c']=r(mean)
mat P[3,`c']=r(sd)

sum rank
mat P[4,`c']=r(mean)


********************************************************************************
*writing result:

outtable using "$tables/RI2.tex", mat(P) replace 
