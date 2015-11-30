*set working directory
clear all

* preparo il file per salvare i risultati
use passaggiPrimoAnno/risultati20, replace
drop if id==0


* percentili della distribuzione dei salari
preserve

	replace wage=wage/1000
	collapse (p5) w5=wage (p25) w25=wage (p50) w50=wage (p75) w75=wage (p95) w95=wage, by(t)
	
	export excel using microsimulazione.xlsx, replace first(var) sheet("distribuzione salario")
	
	tsset t
	tsline w5 w25 w50 w75 w95, xtitle("") ytitle("Salario Base migliaia") xtick(0(5)40) ///
		title("Distribuzione del salario") ///
		legend(order(1 "5 pctile" 2 "25 pctile" 3 "MEDIANA" 4 "75 pctile" 5 "95 pctile") col(3))
	
	graph export percentili.pdf, replace


restore


* percentili della distribuzione degli anni per il passaggio di fascia
preserve 

	bys id fascia: gen nanni=_N
	collapse nanni ,by(id fascia)
	collapse (p5) w5=nanni (p25) w25=nanni (p50) w50=nanni (p75) w75=nanni (p95) w95=nanni, by(fascia)

	export excel using microsimulazione.xlsx, first(var) sheet("anni passaggio fascia ")


restore 

preserve 

	keep if t==40
	
	collapse (max) fascia ,by(id)
	gen one=1
	collapse (sum) one, by(fascia)
	gen id=1
	replace one=one/10
	reshape wide one, i(id) j(fascia)
	
	capture rename one0 fasciaC
	capture rename one1 fasciaD
	capture rename one2 fasciaE
	capture rename one3 fasciaF
	
	graph bar (sum) fascia*,  stack percent nolabel legend(row(1)) ///
		title("Termino la carriera in fascia")
	graph export termineCarriera.pdf, replace

	export excel using microsimulazione.xlsx, first(var) sheet("termino carriera in")


restore 
