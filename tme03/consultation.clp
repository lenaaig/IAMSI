;;; IAMSI 2020 : séance TME 3
;;; medical.clp

(defmodule MAIN (export ?ALL))

;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction MAIN::ask-question (?question ?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) then (bind ?answer (lowcase ?answer))))
   ?answer)

;;*****************
;;* INITIAL STATE *
;;*****************

(deftemplate MAIN::attribute
   (slot name)
   (slot value)
   (slot certainty (default 100.0)))

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus QUESTIONS CHOOSE-QUALITIES WINES PRINT-RESULTS))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))
  
;;******************
;;* QUESTION RULES *
;;******************

(defmodule QUESTIONS (import MAIN ?ALL) (export ?ALL))

(deftemplate QUESTIONS::question
   (slot attribute (default ?NONE))
   (slot the-question (default ?NONE))
   (multislot valid-answers (default ?NONE))
   (slot already-asked (default FALSE))
   (multislot precursors (default ?DERIVE)))
   
(defrule QUESTIONS::ask-a-question
   ?f <- (question (already-asked FALSE)
                   (precursors)
                   (the-question ?the-question)
                   (attribute ?the-attribute)
                   (valid-answers $?valid-answers))
   =>
   (modify ?f (already-asked TRUE))
   (assert (attribute (name ?the-attribute)
                      (value (ask-question ?the-question ?valid-answers)))))

(defrule QUESTIONS::precursor-is-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is ?value $?rest))
         (attribute (name ?name) (value ?value))
   =>
   (if (eq (nth 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-is-not-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is-not ?value $?rest))
         (attribute (name ?name) (value ~?value))
   =>
   (if (eq (nth 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

;;*******************
;;* MEDICAL QUESTIONS *
;;*******************

(defmodule MEDICAL-QUESTIONS (import QUESTIONS ?ALL))

(deffacts MEDICAL-QUESTIONS::question-attributes
 (question (attribute rougeurs)
            (the-question "Avez vous des rougeurs? ")
            (valid-answers oui non nsp))
	
  (question (attribute eruption-cutanee)
  	    (precursors rougeurs is non)
            (the-question "Avez vous peu ou beaucoup de boutons ? ")
            (valid-answers peu beaucoup nsp))
           
  (question (attribute fievre)
  	    (the-question "Avez vous de la fièvre")
  	    (valid-answers peu forte nsp))
            
  (question (attribute froid)
  	    (the-question "Avez vous une sensation de froid")
  	    (valid-answers oui non nsp))            

  (question (attribute amygdales)
   	    (the-question "Avez vous les amygdales rouges ?"
            (valid-answers oui non nsp))
            
  (question (attribute tache-rouge)
   	    (the-question "Avez vous des tâches rouges ?"
            (valid-answers oui non nsp))
            
  (question (attribute peau-pele)
   	    (the-question "Avez vous la peau qui pêle ?"
            (valid-answers oui non nsp))
            
  (question (attribute yeux-douloureux)
   	    (the-question "Avez vous les yeux douloureux ?"
            (valid-answers oui non nsp))
            
  (question (attribute dos-douloureux)
   	    (the-question "Avez vous le dos douloureux ?"
            (valid-answers oui non nsp))      
 
  (question (attribute dos-douloureux)
   	    (the-question "Avez vous le dos douloureux ?"
            (valid-answers oui non nsp))
            
  (question (attribute demangeaisons)
   	    (the-question "Avez vous des fortes demangeaisons ?"
            (valid-answers oui non nsp))

  (question (attribute pustules)
  	    (precursors demangeaisons is oui)
   	    (the-question "Avez vous des pustules ?"
            (valid-answers oui non nsp))
            
  (question (attribute ganglions)
   	    (the-question "Avez vous une inflammation des ganglions ?"
            (valid-answers oui non nsp))      

  (question (attribute peau-seche)
   	    (the-question "Avez vous la peau seche ?"
            (valid-answers oui non nsp))   
            
  (question (attribute ganglions)
   	    (the-question "Avez vous une inflammation des ganglions ?"
            (valid-answers oui non nsp))                       
)      

;;******************
;; The RULES module
;;******************

(defmodule RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate RULES::rule
  (slot certainty (default 100.0))
  (multislot if)
  (multislot then))

(defrule RULES::throw-away-ands-in-antecedent
  ?f <- (rule (if and $?rest))
  =>
  (modify ?f (if ?rest)))

(defrule RULES::throw-away-ands-in-consequent
  ?f <- (rule (then and $?rest))
  =>
  (modify ?f (then ?rest)))

(defrule RULES::remove-is-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is ?value $?rest))
  (attribute (name ?attribute) 
             (value ?value) 
             (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::remove-is-not-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is-not ?value $?rest))
  (attribute (name ?attribute) (value ~?value) (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::perform-rule-consequent-with-certainty
  ?f <- (rule (certainty ?c1) 
              (if) 
              (then ?attribute is ?value with certainty ?c2 $?rest))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) 
                     (value ?value)
                     (certainty (/ (* ?c1 ?c2) 100)))))

(defrule RULES::perform-rule-consequent-without-certainty
  ?f <- (rule (certainty ?c1)
              (if)
              (then ?attribute is ?value $?rest))
  (test (or (eq (length$ ?rest) 0)
            (neq (nth 1 ?rest) with)))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) (value ?value) (certainty ?c1))))

;;*******************************
;;* CHOOSE DIAGNO RULES *
;;*******************************

(defmodule CHOOSE-DIAGNO (import RULES ?ALL)
                            (import QUESTIONS ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-DIAGNO::startit => (focus RULES)) 
            
          
                                          
(deffacts medical-rules

  (rule (if rougeurs is oui or eruption-cutanee is oui)
        (then diagno is exanthème))
  (rule (if fievre is oui or froid)
        (then diagno is etat febrile))        
  (rule (if amygdales is oui and tache-rouge is oui and peau-pele is oui)
        (then diagno is signe suspect)) 
  (rule	(if yeux-douloureux is oui or dos-douloureux is oui)
  	(then diago is douleur))
  (rule (if rougeurs is oui or eruption-cutanee is oui)
        (then diagno is exanthème))
            
)            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
; ----- fin fichier medical.clp
