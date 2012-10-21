###
@depend circle.js
###

###

This file implements a Solution to the 'Frühsport' challange of the BWINF 2012.

**Author:** *Karolin Varner*
**Date:**   *9.10.2012*

TODO: Check if optimizations using more expansion points would be efficient
TODO: Save snake margins
TODO: Use 2D map for optimization?
TODO: Use a sane datastructure for snake (linked list)
TODO: Error handling & Sanity Checks
TODO: Move code into SNAKE object
TODO: Better Way to detect straitr snake
###

###!
Frühsport Snake Solver by Karolin Varner
###

###################################
# CONSTANTS

NORT  = 0
EAST  = 1
SOUTH = 2
WEST  = 3


MoveR = [
    [ 0,  1, true],
    [ 1,  0, true]
    [ 0, -1, true]
    [-1,  0, true]
]

Xcor = 0
Ycor = 1
StrechD = 2

TAIL=1
HEAD=1

###################################
# Snake Loading

###
 Load snake from Text File:

 Args:
    string T - The text to parse
 Return:
    A list of snake segments
###
parse_snake = (T) ->
    # Remove empty lines
    lns = filter (T.split '\n'), (l) -> 
        !(/\s/.test 'l')
    # Parse single instructions
    lns = map lns, (l) ->
        x = y = 0
        str = /#/.test l

        if /W|Y/.test l
            y++
        else if /S/.test l
            y--
        else if /W|X/.test l
            x++
        else
            x--

        if /-/.test l
            x*=-1
            y*=-1

        return [x,y,str]
    # Convert relative to absolute pos
    reduce lns, [[0,0,false]], (ols, l) ->
        lst = last ols
        ols.concat [
            l[Xcor]+lst[Xcor],
            l[Ycor]+lst[Ycor],
            l[StretchD]]



###
Searches for a Segment that can serve as a starting point:
* It must be at the border of the snake
* it must not be the last or the second to the last elem.
Args:
    (list) S - A Snake
Returns:
    1. The index of a stretchable segment.
    2. The direction to strecht to
###
find_strechpos = (S) ->
    # Compute the bounds of the snake
    B = reduce S, {}, (I, e) ->
        NORTH: max e[Ycor], I[NORTH]
        EAST:  max e[Xcor], I[EAST]
        SOUTH: min e[Ycor], I[SOUTH]
        WEST:  min e[Xcor], I[WEST]
   
    for m, i in S 
        if m[Xcor] >= B[EAST]
            return [i, EAST]
        if m[Xcor] <= B[WEST]
            return [i, WEST]
        if m[Ycor] >= B[NORTH]
            eturn [i, NORTH]
        if m[Ycor] <= B[SOUTH]
            return [i, SOUTH]

    return null

###
Strech the specified segment.

Args:
    S - The Snake !! Is modified !!
    seg - The segment to strech
    dir - The Dir to strech do (NORTH or SOUTH or ...)
Sideeffekts:
    S is modified directly
Returns:
    The segment that is the 'extruded result' of the stretch.
###
__stretch = (S, seg, dir) ->
    S[i][StretchD] = true
    S.splice seg, 0,
        combine S[seg], MoveR[dir], sum # MovR contains the relative movement
        combine S[seg], MoveR[dir], sum # => Sum applys it for each elem
                                        # StrechD is also set (+1), because
    return seg+1                        # x>0 == true
stretch = __stretch

###
Move the 'tension' in the specified segment.
AUtomatically reduces Snake length if the head or
the tip of the tail is reached.

Args:
    S   - The Snake
    seg - The direction (one of TAIL or HEAD)
Return:
    If the snake was shortnend
###
__move_tension = (S, seg, dir) ->
    S[seg][StretchD]     = false
    S[seg+dir][StretchD] = true

    if (head S)[StretchD]
        S.splice 0,1
        return true
    else if (tail S)[StretchD]
        do S.pop
        return true

    false
move_tension = __move_tension

###
Check if a snake is straight

Args:
    S - The Snake
    i - (Default: First)The beginning index for checking straightness
    k - (Default: ilen S) The end index (exclusively)
Return:
    If the Snake is straight
###
is_straight = (S, i=0, k=(len S) -1) ->
    r_ = relate S[i...k], (a, b) ->
        a[Xcor] 
    r_ = map r_, (x) ->
        if x[Xcor] ==  0 && x[Ycor] ==  1
            NORTH
        else if x[Xcor] ==  0 && x[Ycor] == -1
            SOUTH
        else if x[Xcor] == -1 && x[Ycor] ==  0
            WEST
        else if x[Xcor] ==  1 && x[Ycor] ==  0
            EAST
    eq r_
        
###
Actual algorythim...
###
unfold_snake = (S) ->
    # Find expansion place
    [stretch_str, dir] = find_stretchpos

    # Execute one dir after oneother;
    # Faster for very high or low expansion point
    map [TAIL, HEAD], (ex_dir) ->
        r_straight = do ->
            if ex_dir == TAIL
                is_straight S, str
            else
                is_straight S, 0, str+1

        unless r_straigt
            for seg,i in S when (i <= str)
                if seg[StretchD]
                    move_tension S, i, ex_dir
            str = stretch S, str, stretch_dir
