(define (domain gridworld)
  (:requirements :strips)
  
  (:predicates
    (at ?x ?y)  ;; Robot is at (x, y)
    (goal ?x ?y) ;; Goal position
    (blocked ?x ?y) ;; Obstacle
    (adjacent ?x1 ?y1 ?x2 ?y2) ;; Movement possible
  )

  (:action move
    :parameters (?x1 ?y1 ?x2 ?y2)
    :precondition (and (at ?x1 ?y1) (adjacent ?x1 ?y1 ?x2 ?y2) (not (blocked ?x2 ?y2)))
    :effect (and (at ?x2 ?y2) (not (at ?x1 ?y1)))
  )
)
