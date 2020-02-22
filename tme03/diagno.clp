;;; IAMSI 2020 : séance TME 3
;;; famille.clp

; La règle qui permet de remplir la base de faits
; elle est facultative si on décide d'entrer les faits à la
; main dans CLIPS
(defrule my_init
	 (initial-fact)
=>
	(watch facts)
	(watch rules)

	(assert (tache_rouge bob))
	(assert (boutons_peu bob))
	(assert (sensation_froid bob))
	(assert (forte_fievre bob))
	(assert (yeux_douloureux bob))
	(assert (amygdales_rouge bob))
	(assert (peau_pele bob))
	(assert (peau_seche bob))
	(assert (exantheme bob))
	(assert (eruption_cutanee bob))
	(assert (rougeurs bob))	
	
)


(defrule eruption_cutanee
	 (or (boutons_peu ?patient)
	 (boutons_bcp ?patient))
=>
	(assert (eruption_cutanee ?patient))
)

(defrule exantheme
	 (or (eruption_cutanee ?patient )
	 (rougeurs ?patient))
=>
	(assert (exantheme ?patient))
)

(defrule etat_febrile
	 (or (forte_fievre ?patient)
	 (sensation_froid ?patient))
=>
	(assert (etat_febrile ?patient))
)

(defrule signe_suspect
	 (amygdales_rouge ?patient)
	 (tache_rouge ?patient)
	 (peau_pele ?patient)
=>
	(assert (signe_suspect ?patient))
)

(defrule signe_suspect
	 (amygdales_rouge ?patient)
	 (tache_rouge ?patient)
	 (peau_pele ?patient)
=>
	(assert (signe_suspect ?patient))
)

(defrule rougeole
	 (or (and (etat_febrile ?patient)
	 (yeux_douloureux ?patient)
	 (exantheme ?patient))
	 (and (signe_suspect ?patient)
	 (forte_fievre ?patient)))
	 
=>
	(assert (rougeole ?patient))
)

(defrule pas_rougeole
	 (peu_fievre ?patient)
	 (boutons_peu ?patient)
	 ?x <- (rougeole ?patient)
=>
	(retract ?x)
	(assert (rubeole ?patient))
	(assert (varicelle ?patient))
)

(defrule douleur
	 (yeux_douloureux ?patient)
	 (dos_douloureux ?patient)
	 
=>
	(assert (douleur ?patient))
)

(defrule grippe
	 (yeux_douloureux ?patient)
	 (etat_febrile ?patient)
	 
=>
	(assert (grippe ?patient))
)

(defrule varicelle
	 (fortes_demangeaisons ?patient)
	 (pustules ?patient)
	 
=>
	(assert (varicelle ?patient))
)

(defrule inflammation_ganglions
	 (amygdales_rouge ?patient)
	 
=>
	(assert (inflammation_ganglions ?patient))
)


(defrule rubeole
	 (peau_seche ?patient)
	 (inflammation_ganglions ?patient)
	 (not (pustule ?patient))
	 (not (sensation_froid ?patient))
	 
=>
	(assert (rubeole ?patient))
)

