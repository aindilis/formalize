(add the ability to manually resolve entities by asking the user)

(work on the context - i.e. read more linguistics stuff)

(
 (when we are trying to understand text, if we can't figure it
  out exactly, such as with our entity resolution, we can add
  formulas to the system as follows

  (implies
   ("is same entity"
    (text-entity (text-id 235325) (entity-id 1))
    (termios-entity 235325)
    )
   (function-of (text-entity (text-id 235325) (entity-id 1)))
   )

  That way, when the "thinker" system is trying to understand
  stuff, it can reason with the suppositions.  
  )
 )
