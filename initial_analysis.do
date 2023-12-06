clear
use "/Users/viniciusono/Downloads/TimeSeries_Final_Project -Vini/master_final.dta"
replace date_new = mofd(date_new)
format date_new %tm
tsset date_new

rename OilConsumptionDemandShocks OCDS
rename OilSupplyShocks OSS
rename OilInventoryDemandShocks OIDS

** generating price change for every index
gen lneem = ln(eem)
gen dlneem = d.lneem

gen lnvwo = ln(vwo)
gen dlnvwo = d.lnvwo

gen lnbova = ln(bova)
gen dlnbova = d.lnbova

eststo var1: var OSS OCDS OIDS dlnbova, lags(1) small
eststo var2:var OSS OCDS OIDS dlnbova, lags(1/2) small
eststo var3:var OSS OCDS OIDS dlnbova, lags(1/3) small
eststo var4:var OSS OCDS OIDS dlnbova, lags(1/4) small
estout var1 var2 var3 var4, stat(aic bic)

**Var 2 best fit using BIC, AIC
var OSS OCDS OIDS dlnbova, lags(2) small
vargranger


*** Unit roor test (Stationary)



** Cointegration and ECM (Appendix)
** rank>1 stationary linear relationships and reason to include (Largest trace statistic for rank>0)
** Long run relationsship
** Comparing trace statistic
vecrank OSS  OIDS OCDS dlnbova

*** MAIN SVAR
matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.)
svar  OSS  OIDS OCDS dlnbova,lags(1)  aeq(A) beq(B)



**** IRF
irf create BOVA, step(10) set(myirf_g) replace 
// irf graph oirf sirf , impulse(oil_supply oil_consumption_demand oil_inv_demand) response(dlnbova) 

svar  OSS  OIDS OCDS dlnvwo,lags(1)  aeq(A) beq(B)
irf create VWO, step(10) replace 
// irf graph oirf sirf, impulse(oil_supply oil_consumption_demand oil_inv_demand) response(dlnvwo)

svar   OSS  OIDS OCDS dlneem,lags(1)  aeq(A) beq(B)
irf create EEM, step(10) replace 
//irf graph oirf sirf, impulse(oil_supply oil_consumption_demand oil_inv_demand) response(dlneem)

//combining all IRFS
irf cgraph (BOVA OSS dlnbova oirf sirf)(BOVA OCDS dlnbova oirf sirf)(BOVA OIDS dlnbova oirf sirf)(VWO OSS dlnvwo oirf sirf)(VWO OCDS dlnvwo oirf sirf)(VWO OIDS dlnvwo oirf sirf)(EEM OSS dlneem oirf sirf)(EEM OCDS dlneem oirf sirf)(EEM OIDS dlneem oirf sirf),title("")



*we prefer higher lags for GARCH (make it more stationary). Keeps more information 

arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1,2) garch(2)

** Use TGARCH AND/OR EGARCH (predict variance)
** Volatily of down retruns contributes more for variance (Here we take it into account)
eststo arch1:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(1) tarch(1)
eststo arch2:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(1) tarch(1/2)
eststo arch3:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(1) tarch(1/3)

eststo arch4:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(2) tarch(1)
eststo arch5:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(2) tarch(1/2)
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(2) tarch(1/3)//convergence problem


eststo arch6:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(2) garch(1) tarch(1)
eststo arch7:arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(2) garch(1) tarch(1/2)
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(2) garch(1) tarch(1/3)//does not converge


//does not converge
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(2) garch(2) tarch(1)
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(2) garch(2) tarch(1/2)
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(2) garch(2) tarch(1/3)

//nothing converges
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(3) tarch(1)//does not conv
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(3) tarch(1/2)
arch  dlneem oil_supply  oil_inv_demand oil_consumption_demand ,arch(1) garch(3) tarch(1/3)

estout arch1 arch2 arch3 arch4 arch5 arch6 arch7 using example.tex, stat(aic bic)

**Best model arch 7 msallst bic and aic
**Best model



************************************************************************************************************************
  *ARCH Models                                                                                                         *
                                                                                                                       *
                                                                                                                       *
                                                                                                                       *
                                                                                                                       *
                                                                                                                       *
************************************************************************************************************************
eststo a: arch dlnbova OSS, arch(1) garch(1) tarch(1) nonrtolerance
eststo b:arch  dlnbova OIDS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance
eststo c:arch  dlnbova OCDS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance

eststo d:arch  dlnvwo OSS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance
eststo e:arch  dlnvwo OIDS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance
eststo f:arch  dlnvwo OCDS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance

eststo g:arch  dlneem OSS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance
eststo h:arch  dlneem OIDS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance
eststo i:arch  dlneem OCDS   ,arch(1) garch(1) tarch(1) tol(0.1) ltol(0.1) nonrtolerance


#delimit ;
esttab b c d e f g h i using Table2.tex, replace  label se star(* 0.10 ** 0.05 *** 0.01)  title(Summary Statistics) ;
#delimit cr




