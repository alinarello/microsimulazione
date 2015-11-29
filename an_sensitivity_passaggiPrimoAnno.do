*set working directory
clear all
set more off

cd D:\Dati\Profili\e192470\Documents\DASBI\microsimulazione\


forvalues x=0(1)30 {

* preparo il file per salvare i risultati
	use passaggiPrimoAnno\risultati`x', replace
	drop if id==0

	* calcoliamo il salario medio dell'organizzazione
	* media pesata tenendo conto della distribuzione per t
	* e assumendo un separation rate peri al 2%


	keep id wage t
	collapse wage ,by(t)
		
	** CALCOLIAMO I PESI 
	*local separationRate=.02
	gen temp=(1-.02)^(t-1)
	su temp
	gen peso=temp/r(sum)
	drop temp
	
	gen tildeWage=wage*peso
	collapse (sum) tildeWage
	gen passaAlPrimo=`x'
	
	if `x'==0 {
		save wage_passaAlPrimoAnno, replace
		} 
	else {
		append using wage_passaAlPrimoAnno
		save wage_passaAlPrimoAnno, replace
		}

	}
	
/* calcoliamo la distribuzione delle persone per fasce */

forvalues x=0(1)30 {	
* calcoliamo la distribuzione delle persone per fasce
	use passaggiPrimoAnno\risultati`x', replace
	drop if id==0
	
	collapse (count) persone_in_=livello, by(t fascia)
	reshape wide persone_in_, i(t) j(fascia)
	
	forvalues xx=0(1)3 {
		replace persone_in_`xx'=0 if persone_in_`xx'==.
		}
	
	forvalues xx=0(1)3 {
		replace persone_in_`xx'=persone_in_`xx'/1000
		}
	
	** CALCOLIAMO I PESI 
	*local separationRate=.02
	gen temp=(1-.02)^(t-1)
	su temp
	gen peso=temp/r(sum)
	drop temp
	
	gen fascia_C=peso*persone_in_0
	gen fascia_D=peso*persone_in_1
	gen fascia_E=peso*persone_in_2
	gen fascia_F=peso*persone_in_3
	
	collapse (sum) fascia_C fascia_D fascia_E fascia_F 

	gen passaAlPrimo=`x'
	
	if `x'==0 {
		save fasce_passaAlPrimoAnno, replace
		} 
	else {
		append using fasce_passaAlPrimoAnno
		save fasce_passaAlPrimoAnno, replace
		}
}	

