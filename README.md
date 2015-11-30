# microsimulazione

descrizione dei files:
setWorkingDirectory.do
	Imposta la working directory in stata sulla mia public di osiride

pgm_sensitivityPrimoAnno.do
	Lancia in sequenza an_riformaCarriere.do e an_sensitivity_passaggiPrimoAnno.do per far girare la simulazione

an_riformaCarriere.do
	Produce la simulazione del percorso di carriera per un individuo che inizia in fascia C livello 1 e ha una vita residua di 40 anni. vengono fatte simulazioni per 1000 individui. Le probabilità di passaggio (fascia e/o livello) sono indipendenti tra individui e per gli individui nel tempo.
Il file produce diverse simulazioni per probabilità di passaggio di livello al primo anno che variano tra 0 e .3. questo per calcolare l’elasticità del salario a questo parametro.
Trovate i percorsi simulati per ciascuno di qeusti parametri nella cartella passaggiPrimoAnno salvati come risultatiX dove X è la percentuale. ogni file contiene le 1000 simulazioni

an_sensitivity_passaggiPrimoAnno.do
	Il dofiles carica i risultati delle simulazioni e calcola il salario di steady-state come la media pesata di ciascuna coorte. 
i pesi di ciascuna coorte sono calcolati assumendo che ogni anno il 2% della popolazione lasci la banca. date un occhiata e fatemi sapere cosa ne pensate. questo approccio permette di calcolare un salario medio dell’organizzazione e fare i confronti tra i diversi scenari (per esempio con probabilità passaggio al primo anno pari a 0 o pari a 20)

an_steadyState.do
	Questi file calcolano salario steady state come sopra e la distribuzione per fasce

an_figure_tabelle.do

	Crea un grafico con la distribuzione dei salari (diversi percentili) e salva i dati in un fogio excel.
