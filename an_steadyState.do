*set working directory
cd D:\Dati\Profili\e192470\Documents\DASBI\microsimulazione

* preparo il file per salvare i risultati
* qui si deve scegliere che file usare data la probabilita' passaggio primo anno

use risultati, replace
drop if id==0


* calcoliamo il salario medio dell'organizzazione
* media pesata tenendo conto della distribuzione per t
* e assumendo un separation rate peri al 2%
preserve
quietly{
	keep id wage t
	collapse wage ,by(t)
		
	** CALCOLIAMO I PESI 
	*local separationRate=.02
	gen temp=(1-.02)^(t-1)
	su temp
	gen peso=temp/r(sum)
	drop temp
	
	gen tildeWage=wage*peso
	su tildeWage
	}
	di   "il salario  medio dell'organizzazione euro " %6.0f r(sum)
restore	
	

* calcoliamo la distribuzione delle persone per fasce
preserve
	collapse (count) persone_in_=livello, by(t fascia)
	reshape wide persone_in_, i(t) j(fascia)
	
	forvalues x=0(1)3 {
		replace persone_in_`x'=0 if persone_in_`x'==.
		}
	
	forvalues x=0(1)3 {
		replace persone_in_`x'=persone_in_`x'/1000
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

restore
