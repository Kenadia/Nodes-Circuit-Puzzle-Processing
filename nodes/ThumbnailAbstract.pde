abstract class ThumbnailAbstract extends SlidingBar {
  
  private ArrayList puzzles;
  private int puzzleCount;
  private ArrayList flags;
  private final int [] flagColors = {#ff0000, #ff7700, #77ff00,
                                     #00ff00, #00ff77, #0077ff,
                                     #0000ff, #7700ff, #ff0077};
  protected int selectedID;
  protected int markedID;
  
  // flags must be an ArrayList of Integers with size puzzles.size().
  public ThumbnailAbstract(ArrayList puzzles, ArrayList flags,
      int w, int h, int displayW, int [] scrollBox) {
    super(w, h, displayW, scrollBox);
    this.puzzles = puzzles;
    this.flags = flags;
    this.puzzleCount = puzzles.size();
    this.selectedID = 0;
    this.markedID = -1;
  }
  
  @Override
  public void step() {
    if (puzzles.size() != puzzleCount) {
      puzzleCount = puzzles.size();
      puzzleCountChanged();
    }
    super.step();
  }
  
  protected void puzzleCountChanged() {
    // flags should be changed in removePuzzle() for the removal of a puzzle
    while (puzzles.size() > flags.size()) {
      flags.add(0);
    }
  }
  
  public int getSelectedID() {
    return selectedID;
  }
  
  public Puzzle getSelected() {
    int id = getSelectedID();
    if (id == -1) return null;
    return (Puzzle) puzzles.get(id);
  }
  
  public void flagPuzzle(int id, int flag) {
    int val = (Integer) flags.get(id);
    int newVal = 0;
    if (flag != 0) {
      int mask = 1 << (flag - 1);
      newVal = val ^ mask;
    }
    flags.remove(id);
    flags.add(id, newVal);
  }
  
  public void markPuzzle(int id) {
    markedID = id;
  }
  
  public void unmark() {
    markedID = -1;
  }
  
  public void swapPuzzle(int id) {
    if (markedID == -1) {
      markedID = id;
    } else {
      Puzzle p1 = (Puzzle) puzzles.get(markedID);
      Integer f1 = (Integer) flags.get(markedID);
      Puzzle p2 = (Puzzle) puzzles.get(id);
      Integer f2 = (Integer) flags.get(id);
      puzzles.remove(markedID);
      flags.remove(markedID);
      puzzles.add(markedID, p2);
      flags.add(markedID, f2);
      puzzles.remove(id);
      flags.remove(id);
      puzzles.add(id, p1);
      flags.add(id, f1);
      markedID = -1;
    }
  }
  
  public void insertPuzzle(int id) { // Inserts after marked.
    if (markedID != -1) {
      Puzzle p1 = (Puzzle) puzzles.remove(markedID);
      Integer f1 = (Integer) flags.remove(markedID);
      puzzles.add(markedID > id? id + 1 : id, p1);
      flags.add(markedID > id? id + 1 : id, f1);
      markedID = -1;
    }
  }
  
  protected void removePuzzle(int id) {
    puzzles.remove(id);
    flags.remove(id);
  }
  
  protected int getPuzzleCount() {
    return puzzleCount;
  }
  
  protected PGraphics getPuzzleThumbnail(int id) {
    PGraphics g = ((Puzzle) puzzles.get(id)).getThumbnail();
    PGraphics fullG = g;
    int f = (Integer) flags.get(id);
    if (f != 0) {
      int tw = g.width;
      int th = g.height;
      fullG = createGraphics(tw, th, P2D);
      fullG.beginDraw();
      fullG.noStroke();
      fullG.background(255);
      fullG.image(g, 0, 0);
      int flagNum = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          fullG.fill(flagColors[flagNum]);
          int x = tw - 11 + j * 4;
          int y = 3 + i * 4;
          int w = 1;
          int h = 1;
          if ((f & (1 << flagNum)) != 0) {
            x--;
            y--;
            w = 3;
            h = 3;
          }
          fullG.rect(x, y, w, h);
          flagNum++;
        }
      }
      fullG.endDraw();
    }
    return fullG;
  }
  
  public void singleClicked(int relX, int relY) {
  }
  
  public void doubleClicked(int relX, int relY) {
  }
  
  @Override
  public void keyPressed() {
    super.keyPressed();
    switch(key) {
      case 'i': // Insert puzzle after.
        thumbs.insertPuzzle(getSelectedID());
        break;
      case 'm': // Swap puzzle.
        thumbs.swapPuzzle(getSelectedID());
        break;
    }
  }
  
  abstract public void goToPuzzle(int a);
  abstract public int getPuzzleIDAtXY(int x, int y);
}
