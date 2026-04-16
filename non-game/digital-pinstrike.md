# Pinstrike!

A BOWLING puzzle game about _directions_ and _counting_.

Promising!

* The map is just a grid, separated into bowling lanes (vertical strips). I envision a really minimalist style, white, simple pins from that asset pack, not much else.
* Grid cells can have any number of **pins**, arranged on the 8 spots on the outside (never the center one, you'll see why).
* Each turn, you throw a ball into one lane. (On simplest mode, that's just _always the same ball_.)
* When you hit a square with pins ...
  * All pins on it _fly away_ in the direction from the center. (So a pin on the left will fly to the square on the left.)
  * If there's already a pin there, or it goes off the map, or it goes into a "DESTROYER TILE", it is **removed**.
    * If it moves into another pin, they BOTH disappear? That's easiest for generation algorithm too ...
  * (The ball STOPS? It does not continue on to anything that's behind it? PROBABLY BEST)
  * Now you must simply clear the whole field!
* EXPANSIONS:
  * Balls have _numbers_. If you hit a square with exactly that many, they all disappear. If you hit a square with _more_, it does nothing---an illegal move. You can only scatter squares with fewer pins than the ball number ( = strength/power/force/whatever)


# Difficulties

## Easiest

num_lanes_bounds = (3,3)
lane_length_bounds = (2,4)
num_turns_bounds = (2,4)

allow_diagonals = false
remove_pins_if_already_occupied = false

ball_too_weak_does_nothing = false
ball_matches_pincount_remove_all = false

@TODO: Maybe even limit number of pins on cells to 1 at most? So I can play a sound bite ("LEFT") depending on how each one scatters?
---> Nah, I probably want a system to support multi scattering anyway, so it would put them all in a list and play one by one.
---> Maybe the scattering animation can also be _one pin at a time_ for extra clarity?


## Easy

num_lanes_bounds = (3,4)
lane_length_bounds = (3,5)
num_turns_bounds = (3,6)

allow_diagonals = false
remove_pins_if_already_occupied = true

ball_too_weak_does_nothing = false
ball_matches_pincount_remove_all = false


## Medium

allow_diagonals = true
remove_pins_if_already_occupied = true

ball_too_weak_does_nothing = false
ball_matches_pincount_remove_all = false


## Hard

allow_diagonals = true
remove_pins_if_already_occupied = true

ball_too_weak_does_nothing = false
ball_matches_pincount_remove_all = true


## Hardest


ball_too_weak_does_nothing = true
ball_matches_pincount_remove_all = true

ball_keeps_going_after_hit = true?? (Or maybe it only keeps going if the ball was too weak for the first option?)





## To-Do

### Generation

@NOTE: Now it will never attract from BELOW, because it thinks cells behind it could never be reached. We can write a small little exception for this very specific case? Seems really hard actually ...

IMPROV: Generation -> defend against "nothing turns" on Easiest difficulty. (WHY DO THEY HAPPEN AT ALL? It's always lane 0 that's doubled up or something I believe ...) SOMETHING IS GOING WRONG HERE

### Visuals / Feedback

* Make ORDER of directions handled (when animating pins) CONSISTENT (start at right/top and go clockwise)
* During scatter of pin, play audio with name of direction (IF enabled in settings)
* Make scatter rotate the pin (somewhat randomly). Faster too?
* Only play appear/disappear tween of pins on `CommandRemove` and on level start/finish?


* Display all balls (numbers and order) -> which also displays current turn/turns left. (Though we can add a number for that if we want.)
