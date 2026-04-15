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
  * (EASY MODE = Can reduce it to only the orthogonal directions, for example. Add diagonals only later.)
* EXPANSIONS:
  * Balls have _numbers_. If you hit a square with exactly that many, they all disappear. If you hit a square with _more_, it does nothing---an illegal move. You can only scatter squares with fewer pins than the ball number ( = strength/power/force/whatever)

GENERATION ALGORITHM: 

* We repeat the following random moves as often a we want/need.
  * Pick a random lane and square. 
  * Place _all_ possible pins there.
  * Now scatter them according to the puzzle rules.
  * Randomly decide to make them "disappear" by pretending there was a pin at the target location all along. (This pin CAN'T be earlier than the earliest "hit" on that lane, as it would've been hit on an earlier turn then.)
* As we do this, 
  * For each pin, track if it **influenced the puzzle** => At the end, we can just remove all pins (that weren't removed by the game's rules) that did nothing at all.
  * For each lane, check the earliest "hit" ---> later hits/pin placements can only be _behind_ that.


PERHAPS IT'S BETTER TO GO IN REVERSE! (A kind of "growths everywhere" algorithm.) Every step, we imagine "what changes do we need to make such that striking this space would _keep the state the same_?"

* The board starts empty -> the WIN state, completely cleared.
* Now repeat the following steps.
  * Pick a random lane. Pick a random square, or the first square with pins inside (if any).
  * If a side has _no pin_, and it would _scatter to the edge_, then you can place a pin there. (_Hitting this square will remove that pin._)
  * If a side has _no pin_, otherwise, you _can_ place a pin there _and_ on the opposite side. (Only possible if the other side does not have one yet. If not possible, just do nothing.)
  * If a side has _a pin_, and it would _scatter to the edge_, then you are simply NOT ALLOWED TO PICK THIS SQUARE. (_Hitting this square now would make that pin disappear, but it has to be there!_)
  * If a side has _a pin_, otherwise, you have to remove it by placing a pin on the opposite side. (Only possible if the other side does not have one yet.)




## To-Do

BUGFIX: My "strike_cell" system is bad. Instead, we should just loop through all cells and calculate the FIRST and LAST index of cells with pins each time. (Because cells can receive pins on OTHER TURNS/STEPS of the generation, not just when they're the current move.)

GEN IMPROVE: Prefer the ATTRACT growth options as they lead to harder/more interesting puzzles? -> They are basically NEVER happening right now, must be some bug with how I check neighbor pins?
===> DUH, of course it never happens, because this situation NEVER OCCURS. Pins are only added at edges or in doubles, so there is NEVER an opportunity to attract right now! **How to fix?**
  -> Could make these a type of pin that is allowed to stay on the field?
  -> NO we need smarter rules. The current rules simply make it impossible for a pawn to "travel around the map", because it can only flip-flop in direction-oppositeDirection.