
/* TO DO LIST
	
	3) PENSARE COME INTRODURRE SIMULAZINE PER REINQUADRAMENTO

*/


*set working directory
clear all
set more off
capture log close


* loop che va variare la probialità di passaggio al primo anno 
* vedi riga 87 definizione della variabile

forvalues x=0(1)30 {
	
	* genero dataset per salvare i risultati della simulazione
	* li salvo in una cartella passaggiPrimoAnno
	clear all
	set obs 1
	
	gen t=. 
	gen fascia=. 
	gen livello=. 
	gen wage=. 
	gen id=0

	capture confirmdir passaggiPrimoAnno
	if `r(confirmdir)'==170 {
		mkdir passaggiPrimoAnno
		save passaggiPrimoAnno/risultati`x', replace
		}
	else {
		save passaggiPrimoAnno/risultati`x', replace
	}
	
	
	* numero di repliche della simulazione per ciascuna probabilità di passaggio
	* al primo anno - per ora rimaniamo a 1000
	
	forvalues id=1(1)1000{

		* genero dataset con numero di osservazioni (che corrispondono alla vita lavorativa residua)
		clear all
		set obs 40

		* creo variabili anni, fascia, livello e salario
		gen t=_n
		gen fascia=.
		gen livello=.
		gen wage=.

		* reinquadramento o combinazione fascia-livello iniziale di simulazione
		replace fascia=0 in 1
		replace livello=1 in 1

		label define fascial 0 "C" 1 "D" 2 "E" 3 "F"
		label values fascia fascial 

		*------------------------------------------------------------------------------*
		** DEFINIZIONE VARIABILI - PASSAGGI DI FASCIA - 
		*------------------------------------------------------------------------------*
		* definizione eligible per passaggi di fascia
		** in termini di livello
		local livello_min_C=3
		local livello_min_D=7
		local livello_min_E=1

		local anni_min_C=5
		local anni_min_D=1

		* definizione probabilità passaggio di fascia
		/* su un centinaio di partecipanti ne passano una sessantina*/
		local ppf_C=.55
		/* su 150 partecipanti 30 voti utili */
		local ppf_D=.2
		/* qui ???? */
		local ppf_E=.02

		*------------------------------------------------------------------------------*
		** DEFINIZIONE VARIABILI - PASSAGGI DI LIVELLO -
		*------------------------------------------------------------------------------*
		* probabilita passaggio di livello per fasce C e D
		local passaAlPrimo=`x'/100
		local passaAlSecondo=0.8

		* probabilita passaggio di livello per fasce E e F
		local passaLivelloEF=0.55 

		*------------------------------------------------------------------------------*
		** DEFINIZIONE VARIABILI - NUMERO LIVELLI MAX PER FASCIA
		*------------------------------------------------------------------------------*
		
		local max_livello_C=22
		local max_livello_D=20
		local max_livello_E=18
		local max_livello_F=11
		
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

		forvalues t=2(1)40 {
			* aumento di un anno la permanenza all'interno della fascia
			local ++permanenza
					
		*------------------------------------------------------------------------------*
		* PASSAGGI DI FASCIA 
		*------------------------------------------------------------------------------*
		 
			if fascia[`t'-1]==0 /*fascia C*/{
				if livello[`t'-1]>`livello_min_C' | `anni_in_fascia'>5 {
					if runiform()<`ppf_C' {
						replace fascia=fascia[_n-1]+1 in `t'
						
						/* per il calcolo della nuova fascia teniamo conto della distanza
						tra fasce e livelli */
						
						*          - stipendio + 2 livelli aggiuntivi ---  base D - deltaD     
						if ceil((((40150+(livello[`t'-1]-1)*2190)+(2*2190))-53360)/4070)+1 > 1 {
							replace livello=ceil((((40150+(livello[`t'-1]-1)*2190)+(2*2190))-53360)/4070)+1 in `t'
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
						
						
						/* per il calcolo della nuova fascia teniamo conto della distanza
						tra fasce e livelli */
						
						*          - stipendio + 2 livelli aggiuntivi ---  base D - deltaD     
						if ceil((((81850+(livello[`t'-1]-1)*4070)+(2*4070))-134760)/5180)+1 > 1 {
							replace livello=ceil((((81850+(livello[`t'-1]-1)*4070)+(2*4070))-134760)/5180)+1 in `t'
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
				/* calcolo stipendio base */
				replace wage=40150+(livello[`t']-1)*2190 in `t'
				/* aggiungo indennità residenza parte percentuale */
				replace wage=wage[`t']*1.064 in `t'
				/* aggiungo indennità di funzione */
				replace wage=wage[`t']*1.0843+2000 in `t'
				}
			else if fascia[`t']==1 {
				replace wage=53360+(livello[`t']-1)*4070 in `t'
				/* aggiungo indennità residenza parte percentuale */
				replace wage=wage[`t']*1.064 in `t'
				/* aggiungo indennità di funzione */
				replace wage=wage[`t']*1.0843+7000 in `t'
				}
			else if fascia[`t']==2 {
				replace wage=81850+(livello[`t']-1)*4070 in `t'
				/* aggiungo indennità residenza parte percentuale */
				replace wage=wage[`t']*1.064 in `t'
				/* aggiungo indennità di funzione */
				replace wage=wage[`t']*1.0843+12500 in `t'
				}
			else {
				replace wage=134760+(livello[`t']-1)*5180 in `t'
				/* aggiungo indennità residenza parte percentuale */
				replace wage=wage[`t']*1.064 in `t'
				/* aggiungo indennità di funzione */
				replace wage=wage[`t']*1.0843+21000 in `t'
				}
		}

		*------------------------------------------------------------------------------*
		* salviamo i risultati
		*------------------------------------------------------------------------------*	

		gen id=`id'
		append using passaggiPrimoAnno/risultati`x'
		save passaggiPrimoAnno/risultati`x', replace

	}
}
