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

TUTORIAL: "Tap a lane to throw a bowling ball. Clear the puzzle by moving all pins off the map."


num_lanes_bounds = (3,3)
lane_length_bounds = (2,4)
num_turns_bounds = (2,4)

allow_diagonals = false
remove_pins_if_already_occupied = false

ball_too_weak_does_nothing = false
ball_matches_pincount_remove_all = false


## Easy

TUTORIAL: "If a pin hits another pin, both are removed."

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

TUTORIAL: "Bowling balls have a number. If the number of pins in a space matches the bowling ball, you have a perfect strike and all pins are removed!"

allow_diagonals = true
remove_pins_if_already_occupied = true

ball_too_weak_does_nothing = false
ball_matches_pincount_remove_all = true


## Hardest

TUTORIAL: "If the number of pins in a space is higher than the bowling ball number, it's too weak and does nothing."

ball_too_weak_does_nothing = true
ball_matches_pincount_remove_all = true

