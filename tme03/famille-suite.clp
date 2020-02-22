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

	(assert (pere claire jean))
	(assert (pere bob jean))
	(assert (pere yves bob))
	(assert (mere yves zoe))
	(assert (mere luc claire))
	(assert (mere alain claire))
)



; Grand-père par le père
(defrule grand_pere1
	 (pere ?enf ?papa)
	 (pere ?papa ?papa2papa)
=>
	(assert (grand_pere ?enf ?papa2papa))
)

; Grand-père par ma mère
(defrule grand_pere2
	 (mere ?enf ?maman)
	 (pere ?maman ?papa2maman)
=>
	(assert (grand_pere ?enf ?papa2maman))
)

; Parent : lien entre un enfant et son père ou sa mère
(defrule parent1
	 (pere ?enf ?papa)
=>
	(assert (parent ?enf ?papa))
)

(defrule parent2
	 (mere ?enf ?maman)
=>
	(assert (parent ?enf ?maman))
)

; Frère ou soeur
(defrule frere_et_soeur
	 (parent ?enf1 ?pereOuMere)
	 (parent ?enf2 ?pereOuMere)
	 (test (neq ?enf1 ?enf2))
=>
	(assert (frere_et_soeur ?enf1 ?enf2))
	(assert (frere_et_soeur ?enf2 ?enf1))
)


; L'enfant a pour oncle ou tante x
(defrule oncle_tante
	 (frere_et_soeur ?x ?geniteur)
	 (parent ?enf ?geniteur)
=>
	(assert (oncle_tante ?enf ?x))
)

; L'enfant enf1 et enf2 sont cousins ou cousines
(defrule cousin_cousine
	 (frere_et_soeur ?x ?geniteur)
	 (parent ?enf1 ?geniteur)
	 (parent ?enf2 ?x)
=>
	(assert (cousin_cousine ?enf1 ?enf2))
)


; ----- fin fichier famille.clp
