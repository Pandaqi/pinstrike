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

### PuzzleFramework

Move my improvement with `visualizer` attached to PuzzleCommands by default back to general system.


### Generation

THINK ABOUT IF I REALLY DON'T WANT TO MAKE "MORE" OUT OF THIS. Whether numbers are introduced too late, perhaps. (+SHOULD we include 0??)

**@IDEA:** Show numbers _on squares_. If you get _that many pins_ there, they are removed!

* GENERATION = GrowthOption = Pick a number, place that many pins on the cell.
* The only requirement now is that this cell is CHANGED at some point (something must _cause_ it to become that number and then remove everything)


### Visuals / Feedback

PINS:

* Make outline of pins dynamic so I can make it always the same size (regardless of camera zoom in/out)?
* Setting to allow random visual differentiation? (Just re-tinting pins randomly.)
* Setting for "simultaneous scatter"? Or "instant scatter"?

MENU/BACKGROUND: What to do for this?

OTHER:

* Create a variation for when `remove_pins_if_already_occupied` is false? In that case, it just does not move it/does not ALLOW it, or only removes the initial one?
* Particles, SoundFX, feedback (especially on PERFECT HITS or BALL TOO WEAK)
* During scatter of pin, play audio with name of direction (IF enabled in settings)
* HOVER effect over lane you've currently selected for rolling


### Future To-Do / Deluxe Version

@NOTE: Now I do something funky with adding appear/disappear tweens on pins manually in the right places. I _should_ have just made a `CommandPinAdd` and `CommandPinRemove` and let _those_ handle both the logic and tweens ... 

@NOTE: Now it will never attract from BELOW, because it thinks cells behind it could never be reached. We can write a small little exception for this very specific case? Seems really hard actually ... **forget about this for now**




* Do "cascading scattering" ---> hitting an existing pin just makes _that_ pin scatter away too, and this sequence of events continues until nothing is hit anymore. (Often with the final scatter sending it off the edge.)
  * HOW would you generate this, though?
  * GROWTH OPTION: Create an entire _line_ of pins, all in the same direction, until the edge. (Instead of just double pins.) => NO THIS ISN'T ENOUGH. Because the original pin that started the cascade will still remain on that first square.
* Allow ball to keep rolling after hit? Or maybe it only keeps going if the ball was too weak for the first option?
* We might create _colored_ pins, which can only be hit by _balls_ of the same color. 
* We might create different _types_ of pins. Some that can _only_ be removed at the edge, some that move in _reverse_ direction, etcetera.
