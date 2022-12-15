******  Code for the manuscript:
******  Harmful Forms of Child Labour in India from a Time-Use
******  Jihye Kim and Wendy Olsen
******  Used Indian Time Use Survey (ITUS) microdata 2019 (NSS, 2020) Available at: https://mospi.gov.in/web/mospi/download-tables-data/-/reports/view/templateTwo/20702?q=TBDCAT. Accessed Sept. 15, 2022.


******  Data cleaning (Mind that it takes a long time to run) 
*** Allocate repository
clear
cd "C:\DIP Paper"
use "timeuse.dta", replace

*****************************************
*** Make conservative measurement data***
*****************************************

sort psid
by psid, sort: egen time_economic0=sum(time) if (activity_1digit==1|activity_1digit==2) & majoracitivity==1
by psid, sort: egen time_economic = max(time_economic0)
by psid, sort: egen time_unpaidservice0=sum(time) if (activity_1digit==3|activity_1digit==4|activity_1digit==5)  & majoracitivity==1
by psid, sort: egen time_unpaidservice = max(time_unpaidservice0) 
by psid, sort: egen time_anywork0=sum(time) if (activity_1digit==1|activity_1digit==2|activity_1digit==3|activity_1digit==4|activity_1digit==5)  & majoracitivity==1
by psid, sort: egen time_anywork= max(time_anywork0) 
by psid, sort: egen time_total0=sum(time)  if majoracitivity==1
by psid, sort: egen time_total= max(time_total0) 
replace time_economic=0 if time_economic==.
replace time_unpaidservice=0 if time_unpaidservice==.
replace time_anywork=0 if time_anywork==.
replace time_total=0 if time_total==.
drop time_economic0 time_unpaidservice0 time_anywork0 time_total0
save "timeuse_conservative_all.dta", replace

**************************************
*** Make extended measurement data****
**************************************
use "timeuse.dta", replace
sort psid

* the number of activities per slot (multilpleactivity yes=1 or no=2)
gen multiple0=1 if (multilpleactivity==1|multilpleactivity==.)
by psid time_from, sort: egen multiple = total(multiple0) 
replace multiple=1 if multiple==0

* Indicate type of activities (economic work, unpaid service work and any work)
gen economic0=1 if (activity_1digit==1|activity_1digit==2)
by psid time_from, sort: egen economic = max(economic0) 
gen unpaidservice0=1 if (activity_1digit==3|activity_1digit==4|activity_1digit==5)
by psid time_from, sort: egen unpaidservice = max(unpaidservice0) 
gen anywork0=1 if (activity_1digit==1|activity_1digit==2|activity_1digit==3|activity_1digit==4|activity_1digit==5)
by psid time_from, sort: egen anywork = max(anywork0) 

* Allocate the new amount of time working (time/num of activities; we need this variable to avoid duplicate counts)
gen time_new=time/multiple if anywork==1
gen time_new_adj = time_new

sort psid
by psid, sort: egen time_economic0=sum(time_new_adj) if economic==1
by psid, sort: egen time_economic = max(time_economic0)
by psid, sort: egen time_unpaidservice0=sum(time_new_adj) if unpaidservice==1
by psid, sort: egen time_unpaidservice = max(time_unpaidservice0) 
by psid, sort: egen time_anywork0=sum(time_new_adj) if anywork==1
by psid, sort: egen time_anywork= max(time_anywork0) 
by psid, sort: egen time_total0=sum(time_new_adj) 
by psid, sort: egen time_total= max(time_total0) 
replace time_economic=0 if time_economic==.
replace time_unpaidservice=0 if time_unpaidservice==.
replace time_anywork=0 if time_anywork==.
replace time_total=0 if time_total==.

save "timeuse_extended_all.dta", replace
use "timeuse_extended_all.dta", clear


*****************************************
*** Make literal measurement data*****
*****************************************
use "timeuse.dta", replace
sort psid

* the number of simultaneous activities per slot (simultaneousactivity yes=1 or no=2)
gen simultaneous0=1 if simultaneousactivity==1
by psid time_from, sort: egen simultaneous = total(simultaneous0) 

* the number of activities per slot (multilpleactivity yes=1 or no=2)
gen multiple0=1 if multilpleactivity==1
by psid time_from, sort: egen multiple = total(multiple0) 

* the number of activities per slot that are multiple but not simultaneous
gen notsimultaneous0=1 if multiple ==1 & simultaneous!=1
by  psid time_from, sort: egen no_activities = total(notsimultaneous0) 
replace  no_activities=1 if notsimultaneous==0

* Allocate the new amount of time (stint/num of activities if they are not simultaneous; two non-simultaneous activities will have 15 minutes, each; three non-simultaneous activities will have 10 minutes, each) 
gen time_new=time/no_activities
gen time_new_adj = time_new 

sort psid
by psid, sort: egen time_economic0=sum(time_new_adj) if (activity_1digit==1|activity_1digit==2)
by psid, sort: egen time_economic = max(time_economic0)
by psid, sort: egen time_unpaidservice0=sum(time_new_adj) if (activity_1digit==3|activity_1digit==4|activity_1digit==5)
by psid, sort: egen time_unpaidservice = max(time_unpaidservice0) 
by psid, sort: egen time_anywork0=sum(time_new_adj) if (activity_1digit==1|activity_1digit==2|activity_1digit==3|activity_1digit==4|activity_1digit==5) 
by psid, sort: egen time_anywork= max(time_anywork0) 
by psid, sort: egen time_total0=sum(time_new_adj) 
by psid, sort: egen time_total= max(time_total0) 
replace time_economic=0 if time_economic==.
replace time_unpaidservice=0 if time_unpaidservice==.
replace time_anywork=0 if time_anywork==.
replace time_total=0 if time_total==.

save "timeuse_literal_all_no24.dta", replace
use "timeuse_literal_all_no24.dta", clear


*****************************************
*** Merging the above three datasets*****
*****************************************
use "timeuse_literal_all_no24.dta", clear
sum time_economic time_unpaidservice time_anywork time_total
gen time_economic_literal=time_economic
gen time_unpaidservice_literal=time_unpaidservice
gen time_anywork_literal=time_anywork
gen time_total_literal=time_total
keep time_economic_literal time_unpaidservice_literal time_anywork_literal time_total_literal psid activity_id
save "ITUS literal.dta", replace

use "timeuse_extended_all.dta", clear
*sum time_economic time_unpaidservice time_anywork time_total
gen time_economic_extended=time_economic
gen time_unpaidservice_extended=time_unpaidservice
gen time_anywork_extended=time_anywork
gen time_total_extended=time_total
keep time_economic_extended time_unpaidservice_extended time_anywork_extended time_total_extended psid activity_id
save "ITUS extended.dta", replace

use "timeuse_conservative_all.dta", clear
merge 1:1 psid activity_id using "ITUS literal.dta"
drop _merge
merge 1:1 psid activity_id using "ITUS extended.dta"

*define child labour by conservative time
gen cl_con=1 if (time_economic*7)>38 & time_economic!=. & age>=12 & age<=17
replace cl_con=1 if (time_economic*7)>=1 &  time_economic!=. & age>=0 & age<=11
replace cl_con=1 if (time_unpaidservice*7)>=21 & time_unpaidservice!=. & age>=0 & age<=14
replace cl_con=1 if (nic_2008==5|nic_2008==41)
replace cl_con=0 if cl_con==.

*define child labour by literal time
gen cl_literal=1 if (time_economic_literal*7)>38 & time_economic_literal!=. & age>=12 & age<=17
replace cl_literal=1 if (time_economic_literal*7)>=1 &  time_economic_literal!=. & age>=0 & age<=11
replace cl_literal=1 if (time_unpaidservice_literal*7)>=21 & time_unpaidservice_literal!=. & age>=0 & age<=14
replace cl_literal=1 if (nic_2008==5|nic_2008==41)
replace cl_literal=0 if cl_literal==.

*define child labour by extended time
gen cl_extended=1 if (time_economic_extended*7)>38 & time_economic_extended!=. & age>=12 & age<=17
replace cl_extended=1 if (time_economic_extended*7)>=1 &  time_economic_extended!=. & age>=0 & age<=11
replace cl_extended=1 if (time_unpaidservice_extended*7)>=21 & time_unpaidservice_extended!=. & age>=0 & age<=14
replace cl_extended=1 if (nic_2008==5|nic_2008==41)
replace cl_extended=0 if cl_extended==.


*****************************************
*** Make relevant variables**************
*****************************************
*Gen NEET variable
by psid, sort: egen schooling0=sum(time_7days)  if activity_1digit==6
by psid, sort: egen schooling= max(schooling0) 
gen nonschooling=1 if schooling==.
replace nonschooling=0 if nonschooling==.
gen neet_con=1 if (cl_con!=1 & nonschooling==1)
gen neet_literal=1 if (cl_literal!=1 & nonschooling==1)
replace neet_con=0 if usualstatus==91
replace neet_literal=0 if usualstatus==91
replace neet_con=0 if neet_con==.
replace neet_literal=0 if neet_literal==.
gen neet_extended=1 if (cl_extended!=1 & nonschooling==1)
replace neet_extended=0 if usualstatus==91
replace neet_extended=0 if neet_extended==.

*social group
gen socialgroup2=socialgroup
replace socialgroup2=4 if (socialgroup!=1 & socialgroup!=2) & religion==2 
recode socialgroup2 (9=0)

*type of work
*Type of work (BY USUAL STATUS) Type of work dominantly
*1) farming 
*2) household non-ag business 
*3) agricultural labour
*4) non-ag labour 
*5) domestic work
gen type=1  if (usualstatus==11|usualstatus==12|usualstatus==21) & (nic_2008==1)
replace type=2  if (usualstatus==11|usualstatus==12|usualstatus==21) & nic_2008!=. & type!=1
replace type=3  if (usualstatus==31|usualstatus==41|usualstatus==51) & (nic_2008==1)
replace type=4  if (usualstatus==31|usualstatus==41|usualstatus==51) & nic_2008!=. & type!=3
replace type=5  if (usualstatus==92|usualstatus==93)
replace type=0 if type==.

gen type2=1  if (nic_2008==1)
replace type2=2  if nic_2008!=. & type2!=1
replace type2=3  if (usualstatus==92|usualstatus==93)
replace type2=0 if type2==.

*land category
gen landcategory=land
recode landcategory (1/5=0) (6=1) (7/10=2)(11/12=3) (99=.)

*social class
gen class=.
replace class=0 if (usualstatu==41|usualstatu==51) & nic_2008!=1
replace class=1 if (usualstatu==41|usualstatu==51) & nic_2008==1
replace class=2 if (usualstatu==31)
replace class=3 if (usualstatu==11|usualstatu==12|usualstatu==21) & nic_2008!=1
replace class=4 if (usualstatu==11|usualstatu==12|usualstatu==21) & nic_2008==1 & landcategory==0
replace class=5 if (usualstatu==11|usualstatu==12|usualstatu==21) & nic_2008==1 & landcategory==1
replace class=6 if (usualstatu==11|usualstatu==12|usualstatu==21) & nic_2008==1 & landcategory==2
replace class=7 if (usualstatu==11|usualstatu==12|usualstatu==21) & nic_2008==1 & landcategory==3
replace class=8 if class==.

*household class by head status*
gen hhclass0=class if  relation_head==1
by hhid, sort: egen hhclass = max(hhclass0) 

*exploitation
gen exploitation=1 if time_anywork_extended>=10 & time_anywork!=.
replace exploitation=0 if exploitation==.

*****************************************
*** Labelling ***************************
*****************************************

label define payment 1	"	Unpaid	self development		" 2	"	Unpaid	care for children		" 3	"	Unpaid	production of other services		" 4	"	Unpaid	production of goods own consumption		" 5	"	Unpaid	voluntary	goods in households	" 6	"	Unpaid	voluntary	services in households	" 7	"	Unpaid	voluntary	goods in market and non-market unit	" 8	"	Unpaid	voluntary	services in market and non-market unit	" 9	"	Unpaid	trainee	goods	" 10	"	Unpaid	trainee	services	" 11	"	Unpaid	other	goods	"  12	"	Unpaid	other	services	" 13	"	Paid	self employment	goods	" 14	"	Paid	self employment	services	" 15	"	Paid	regular waged	goods	" 16	"	Paid	regular waged	services	" 17	"	Paid	casual labour	goods	" 18	"	Paid	casual labour	services	"
label value payment payment 

label define usualstatus 11 "own account worker hh enterprise" 12 "employer hhenterprise" 21 "unpaid family worker" 31 "regular paid worker" 41 "casual labourer public" 51 "casual labourer other" 81 "seeking work"  91 "attended education" 92 "domestic duties only" 93 "domestic duties and collection" 94 "rentiers pensioners" 95 "not able to work" 97 "others"
label value usualstatus usualstatus

label define socialgroup 1 "ST" 2 "SC" 3 "OBC" 4 "Muslim Non SC/ST" 0 "Others"
label value socialgroup2 socialgroup

label define activity 110	"	Employment in corporations		" 121	"	Informal goods	Growing of crops	" 122	"	Informal goods	Raising animals	" 123	"	Informal goods	Forestry and logging	" 124	"	Informal goods	Fishing	" 125	"	Informal goods	Aquaculture	" 126	"	Informal goods	Mining and quarrying	" 127	"	Informal goods	Making and processing goods	" 128	"	Informal goods	Construction	" 129	"	Informal goods	Others	" 131	"	Informal services	Vending and trading	" 132	"	Informal services	Paid repair	" 133	"	Informal services	Paid business	" 134	"	Informal services	Transporting goods	" 135	"	Informal services	Paid personal care	" 136	"	Informal services	Paid domestic services	" 139	"	Informal services	Others	" 141	"	Employment related	Ancillary activities	" 142	"	Employment related	Breaks during working time	" 150	"	Employment related	Training and studies	" 160	"	Seeking employment		" 170	"	Setting up a business		" 181	"	Employment related	Travel	" 182	"	Employment related	Commuting	" 211	"	Own use production goods	Growing crops	" 212	"	Own use production goods	Farming of animals	" 213	"	Own use production goods	Hunting	" 214	"	Own use production goods	Forestry	" 215	"	Own use production goods	Gathering wild products	" 216	"	Own use production goods	Fishing	" 217	"	Own use production goods	Aquaculture	" 218	"	Own use production goods	Mining and quarrying	" 221	"	Own use processing goods	food products, beverages, tobacco	" 222	"	Own use processing goods	textiles, wearing apparel, leather	" 223	"	Own use processing goods	wood and bark products	" 224	"	Own use processing goods	bricks, concrete slabs	" 225	"	Own use processing goods	herbal and medicinal preparations	" 226	"	Own use processing goods	herbal and medicinal preparations	" 227	"	Own use processing goods	others	" 229	"	Own use processing goods	Acquiring supplies and disposing of products	" 230	"	Own use 	Construction activities	" 241	"	Own use 	Gathering firewood	" 242	"	Own use 	Fetching water	" 250	"	Own use	travelling	" 311	"	Unpaid domestic services	Preparing meals	" 312	"	Unpaid domestic services	Serving meals	" 313	"	Unpaid domestic services	Cleaning up	" 314	"	Unpaid domestic services	Storing, arranging	" 319	"	Unpaid domestic services	other food work	" 321	"	Unpaid domestic services	Indoor cleaning	" 322	"	Unpaid domestic services	Outdoor cleaning	" 323	"	Unpaid domestic services	Recycling	" 324	"	Unpaid domestic services	plants, hedges, garden	" 325	"	Unpaid domestic services	furnace, boiler, fireplace	" 329	"	Unpaid domestic services	other dwelling	" 331	"	Unpaid domestic services	maintenance	" 332	"	Unpaid domestic services	equipment	" 333	"	Unpaid domestic services	vehicle maintenance	" 339	"	Unpaid domestic services	other decoration	" 341	"	Unpaid domestic services	washing	" 342	"	Unpaid domestic services	Drying	" 343	"	Unpaid domestic services	Ironing	" 344	"	Unpaid domestic services	Mending	" 349	"	Unpaid domestic services	other textile care	" 359	"	Unpaid domestic services	other household management	" 361	"	Unpaid domestic services	pet care	" 362	"	Unpaid domestic services	veterinary care	" 369	"	Unpaid domestic services	other pet	" 371	"	Unpaid domestic services	Shopping	" 380	"	Unpaid domestic services	Travelling	" 390	"	Unpaid domestic services	Others	"
destring activity_code, replace
label value activity_code activity

label define type 1 "Farming" 2 "Hh non-ag business" 3 "Ag labourer" 4 "Non-ag labourer"  5 "Hh worker" 0 "Others"
label value type type

label define land 0 "<1hec" 1 "1-2hec" 2 "2-6hec" 3 "6+hec"
label value landcategory landcategory

label define class 1 "Ag labourers" 0 "Non-ag labourers" 2 "Waged workers" 3 "Family business" 4 "Marginal farmers" 5 "Small farmers" ///
6 "Middle farmers" 7 "Large farmers"  8 "Others"
label value class class
label value hhclass class

label define sector 1 "Rural" 2 "Urban"
destring sector, replace
label value sector sector



*****************************************
*** Save the data************************
*****************************************
save "ITUS all.dta", replace

*make child only data
keep if age>=5 & age<=17
save "ITUS children.dta", replace
export delimited using "ITUS children.csv", replace
