All code by Ken Schiller.

An interface written in Processing for the viewing, organization, design, play-test, solving, and export of node/circuit puzzles.

Runs in Processing 1.5.1.
Requires 256MB of memory.

Controls
- Scrolling (in main or grid view)
  - click and drag:   scroll through puzzles
  - shift + left:     scroll left
  - shift + right:    scroll right
  - shift + up:       fast scroll left
  - shift + down:     fast scroll right
– Shared controls
  - m:                swap marked puzzle with selected puzzle
  - i:                insert marked puzzle after selected puzzle
  - n + two digits:   new puzzle with specified width and height
  - s:                save all changes
  - 1-9:              toggle flags on selected puzzle
  - 0:                clear all flags on selected puzzle
  - p:                print selected puzzle (and solution if in solution mode) to console
- Main view
  - tab:              switch to grid view
  - caps-lock:        toggle edit mode
  - space:            toggle trial (user solve) mode
  - return:           toggle solution display
  - double-click:     select puzzle
  - m:                mark puzzle
  - left/right:       select left/right puzzle
  - e                 export current puzzle as print-resolution tiff
- Grid view
  - tab:              switch to main view
  - hover:            select puzzle
  - click:            mark puzzle
