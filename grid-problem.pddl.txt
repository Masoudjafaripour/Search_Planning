(define (problem move-agent)
  (:domain gridworld)
  (:objects 0 1 2 3 4) ;; Grid coordinates
  
  (:init
    (at 0 0) ;; Start position
    (goal 4 4) ;; Goal position
    (blocked 2 2) (blocked 3 3) ;; Obstacles

    ;; Define adjacency for movement
    (adjacent 0 0 0 1) (adjacent 0 1 0 2) (adjacent 0 2 0 3) (adjacent 0 3 0 4)
    (adjacent 0 0 1 0) (adjacent 1 0 2 0) (adjacent 2 0 3 0) (adjacent 3 0 4 0)
    (adjacent 1 1 1 2) (adjacent 1 2 1 3) (adjacent 1 3 1 4)
    (adjacent 2 1 2 3) (adjacent 2 3 2 4)
    (adjacent 3 1 3 2) (adjacent 3 2 3 4)
    (adjacent 4 1 4 2) (adjacent 4 2 4 3) (adjacent 4 3 4 4)
  )

  (:goal (at 4 4))
)
