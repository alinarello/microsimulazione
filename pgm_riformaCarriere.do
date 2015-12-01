*! programma per la simulazione della riforma delle carriere
*! versione 0.1

program define riformaCarriere

	version 13.1
	
	syntax [anything] [, /// 
						livello_min_C(real 3)  ///
						livello_min_D(real 7)  ///
						livello_min_E(real 1)  ///
						anni_min_C(real 5)  ///
						anni_min_D(real 1) ///
						ppf_C(real .55) ///
						ppf_D(real .2) ///
						ppf_E(real .02) ///
						passaAlPrimo(real .2) ///
						passaAlSecondo(real 0.8) ///
						passaLivelloEF(real 0.55 ) ///
						max_livello_C(real 22) ///
						max_livello_D(real 20) ///
						max_livello_E(real 18) ///
						max_livello_F(real 11) ///
						c0_l1(real 40150) ///
						d0_l1(real 53360) ///
						e0_l1(real 81850) ///
						f0_l1(real 134760) ///
						deltaC(real 2190) ///
						deltaD(real 4070) ///
						deltaE(real 4070) ///
						deltaF(real 5180) ///
						indfunC(real 2000) ///
						indfunD(real 7000) ///
						indfunE(real 12500) ///
						indfunF(real 21000) ///
						indfunVariabile(real 1.0843) ///
						numeroReplication(real 100) ///
						vitaResidua(real 40) ///
						livelloIniziale(real 1) ///
						fasciaIniziale(real 0) ///
						nomeFile(string) ///
									]

quietly{									
	clear all
	set obs 1
	
	gen t=. 
	gen fascia=. 
	gen livello=. 
	gen wage=. 
	gen id=0

	save `nomeFile', replace
									
	forvalues id=1(1)`numeroReplication'{

		* genero dataset con numero di osservazioni (che corrispondono alla vita lavorativa residua)
		clear 
		set obs `vitaResidua'

		* creo variabili anni, fascia, livello e salario
		gen t=_n
		gen fascia=.
		gen livello=.
		gen wage=.

		* reinquadramento o combinazione fascia-livello iniziale di simulazione
		replace fascia=`fasciaIniziale' in 1
		replace livello=`livelloIniziale' in 1

		label define fascial 0 "C" 1 "D" 2 "E" 3 "F"
		label values fascia fascial 


		*------------------------------------------------------------------------------*
		** INIZIALIZZO CONTATORI PER I LOOP
		*------------------------------------------------------------------------------*
		* permanenza indica la permanenza nella fascia-Livello
		local permanenza=0
		local anni_in_fascia=0
		local livelli_in_fascia=0

		*------------------------------------------------------------------------------*
		** INIZIO MICROSIMULAZIONE
		*------------------------------------------------------------------------------*

		forvalues t=2(1)`vitaResidua' {
			* aumento di un anno la permanenza all'interno della fascia
			local ++permanenza
					
		*------------------------------------------------------------------------------*
		* PASSAGGI DI FASCIA 
		*------------------------------------------------------------------------------*
		 
			if fascia[`t'-1]==0 /*fascia C*/{
				if livello[`t'-1]>`livello_min_C' | `anni_in_fascia'>5 {
					if runiform()<`ppf_C' {
						replace fascia=fascia[_n-1]+1 in `t'
						
						/* per il calcolo della nuova fascia teniamo conto della distanza tra fasce e livelli */
						local livello_iniziale_in_D = ceil( ( ( ( `c0_l1' + ( livello[`t'-1] - 1 ) * `deltaC' ) + ( 2 * `deltaC' ) ) - `d0_l1' ) / `deltaD' ) + 1
						if `livello_iniziale_in_D' > 1 {
							replace livello=`livello_iniziale_in_D' in `t'
							}
						else {
							replace livello=1 in `t'
						}
							
						local permanenza=0
						local anni_in_fascia=0
						local livelli_in_fascia=0
						continue
						}
					}
				}
			else if fascia[`t'-1]==1 /*fascia D*/{
				if livello[`t'-1]>`livello_min_D' & `livelli_in_fascia'>=3{
					if runiform()<`ppf_D' {
						replace fascia=fascia[_n-1]+1 in `t'
						
						if livello[`t'-1]+2-7 >= 1 {
							replace livello=livello[_n-1]+2-7 in `t'
							}
						else {
							replace livello=1 in `t'
							}
						
						local permanenza=0
						local anni_in_fascia=0
						local livelli_in_fascia=0
						continue
						}	
					}
				}
			else if fascia[`t'-1]==2 /*fascia E*/ {
				if livello[`t'-1]>`livello_min_E' {
					if runiform()<`ppf_E' {
						replace fascia=fascia[_n-1]+1 in `t'
						
						
						/* per il calcolo della nuova fascia teniamo conto della distanza tra fasce e livelli */
						local livello_iniziale_in_F = ceil( ( ( ( `e0_l1' + (livello[`t'-1] - 1 ) * `deltaE' ) + ( 2 * `deltaE' ) ) - `f0_l1' ) / `deltaF' )+1
						if `livello_iniziale_in_F' > 1 {
							replace livello=`livello_iniziale_in_F' in `t'
							}
						else {
							replace livello=1 in `t'
						}
						
						
						local permanenza=0
						local anni_in_fascia=0
						local livelli_in_fascia=0
						continue
						}
					}
				}
			else  /*in fascia F ci rimango*/ {
				replace fascia=fascia[_n-1] in `t'
				local ++anni_in_fascia

				}

			/*per tutti quelli che non hanno avuto il passaggio di fascia*/
			
			if fascia[`t']==. {
				replace fascia=fascia[_n-1] in `t'
				local ++anni_in_fascia

				}

		*------------------------------------------------------------------------------*
		* PASSAGGI DI LIVELLO
		*------------------------------------------------------------------------------*
		* STEP 0 - VERIFICO CHE NON SIA STATO RAGGIUNTO IL LIVELLO MASSIMO NELLA FASCIA
			
			if fascia[`t']==0 & livello[`t'-1]==`max_livello_C' {
				replace livello=livello[_n-1] in `t'
				continue
				}
			else if fascia[`t']==1 & livello[`t'-1]==`max_livello_D' {
				replace livello=livello[_n-1] in `t'
				continue
				}
			else if fascia[`t']==2 & livello[`t'-1]==`max_livello_E' {
				replace livello=livello[_n-1] in `t'
				continue
				}
			else if fascia[`t']==3 & livello[`t'-1]==`max_livello_F' {
				replace livello=livello[_n-1] in `t'
				continue
				}
		
		* STEP 1 - SE NON HO RAGGIUNTO IL LIVELLO MASSIMO VALUTAZIONE PER PASSAGGIO DI LIVELLO
		
			/* per le fasce C e D le probabilità di passaggio variano al 1,2 o 3 anno */
			if fascia[`t']<2 {
				
				/*passaggi al primo anno*/
				
				if `permanenza'==1 {
						if runiform()<`passaAlPrimo' {
							replace livello=livello[_n-1]+1 in `t'
							local permanenza=0
							local ++livelli_in_fascia
							}
						else {
							replace livello=livello[_n-1] in `t'
						}
					}
					
				/*passaggi al secondo anno*/	
				
				else if `permanenza'==2 {
						if runiform()<`passaAlSecondo' {
							replace livello=livello[_n-1]+1 in `t'
							local permanenza=0
							local ++livelli_in_fascia
						}
						else {
							replace livello=livello[_n-1] in `t'
						}
					}
				
				/* passaggi al terzo anno*/
				
				else if `permanenza'==3{
					replace livello=livello[_n-1]+1 in `t'
					local permanenza=0
					local ++livelli_in_fascia
					}
			}
				
			/* per le fasce E e F ogni anno si ha la stessa prob di passare*/
			
			else 	{
				
				if runiform()<`passaLivelloEF' {
					replace livello=livello[_n-1]+1 in `t'
					local permanenza=0
					local ++livelli_in_fascia
				}
				else {
					replace livello=livello[_n-1] in `t'
				}
					
			}
			
			
			} /*loof forvalues*/
		 
		*------------------------------------------------------------------------------*
		* CALCOLIAMO IL SALARIO
		*------------------------------------------------------------------------------*	
		forvalues t=1(1)40 {
			if fascia[`t']==0 {
				replace wage= ( ( ( `c0_l1' + ( livello[`t'] - 1 ) * `deltaC' ) * 1.064 ) * `indfunVariabile' ) + `indfunC' in `t'
				}
			else if fascia[`t']==1 {
				replace wage= ( ( ( `d0_l1' + ( livello[`t'] - 1 ) * `deltaD' ) * 1.064 ) * `indfunVariabile' ) + `indfunD' in `t'
				}
			else if fascia[`t']==2 {
				replace wage= ( ( ( `e0_l1' + ( livello[`t'] - 1 ) * `deltaE' ) * 1.064 ) * `indfunVariabile' ) + `indfunE' in `t'
				}
			else {
				replace wage= ( ( ( `f0_l1' + ( livello[`t'] - 1 ) * `deltaF' ) * 1.064 ) * `indfunVariabile' ) + `indfunF' in `t'				
				}
		}
		
		*------------------------------------------------------------------------------*
		* salviamo i risultati
		*------------------------------------------------------------------------------*	

		gen id=`id'
		append using `nomeFile'
		save `nomeFile', replace

	}
}									
end
