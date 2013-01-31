class ThumbnailStrip extends ThumbnailAbstract {

  private int snap;
  private static final int scrollH = 8;
  private PImage deleteIcon;
  private HoverButton [] deleteButtons;
  
  private PImage highlight;
  private PImage highlight2;

  public ThumbnailStrip(ArrayList puzzles, ArrayList flags, int h, int snap) {
    super(puzzles, flags, puzzles.size() * snap, h, width, new int [] {0, 0, width, scrollH});
    setLim(getLim() + 2 * snap);
    this.snap = snap;
    this.deleteIcon = loadImage("deleteIcon.png");
    this.deleteButtons = new HoverButton [6];
    for (int i = 0; i < 6; i++) {
      deleteButtons[i] = new HoverButton(0, scrollH + 2, 4, deleteIcon);
    }
    this.highlight = createImage(snap, h - scrollH, RGB);
    this.highlight2 = createImage(snap, h - scrollH, RGB);
    highlight.loadPixels();
    highlight2.loadPixels();
    for (int i = 0; i < highlight.pixels.length; i++) {
      highlight.pixels[i] = #ffffbb;
      highlight2.pixels[i] = #ffbbbb;
    }
    highlight.updatePixels();
    highlight2.updatePixels();
  }
  
  @Override
  public void goToPuzzle(int a) {
    selectedID = a;
    // Set destination.
    int dest;
    if (a < 2) dest = 0;
    //else if (destination > puzzles.size() - 3) dest = puzzles.size() - 3;
    else dest = a - 2;
    setDestination(dest * snap);
  }

  public int getPuzzleIDAtXY(int x, int y) {
    if (y < scrollH) return -1;
    int offset0 = getOffset() % snap;
    if ((x + offset0) % snap == 0) return -1;
    return (x + getOffset()) / snap;
  }
  
  @Override
  protected void puzzleCountChanged() {
    setWidth(getPuzzleCount() * snap);
    setLim(getLim() + 2 * snap);
    super.puzzleCountChanged();
  }
  
  @Override
  public int getSelectedID() {
    return selectedID;
  }
  
  @Override
  public void doubleClicked(int relX, int relY) {
    int overPuzzle = getPuzzleIDAtXY(mouseX, relY);
    if (overPuzzle >= 0 && overPuzzle < puzzles.size()) goToPuzzle(overPuzzle);
  }

  @Override
  public void mousePressed(int relX, int relY, int prelX, int prelY) {
    int i = 0;
    for (; i < 6; i++) {
      if (deleteButtons[i].mouseOn()) break;
    }
    if (i < 6) {
      int thumbnailStart = getOffset() / snap;
      removePuzzle(thumbnailStart + i);
    }
    else {
      super.mousePressed(relX, relY, prelX, prelY);
    }
  }

  @Override
  public void mouseMoved(int relX, int relY, int prelX, int prelY) {
    int thumbnailStart = getOffset() / snap;
    int showI = getPuzzleIDAtXY(relX, relY) - thumbnailStart;
    for (int i = 0; i < 6; i++) {
      deleteButtons[i].mouseMoved(relX, relY, prelX, prelY);
      if (i == showI) {
        deleteButtons[i].show();
      } 
      else {
        deleteButtons[i].hide();
      }
    }
  }
  
  @Override
  public void keyPressed() {
    super.keyPressed();
    if (!(this.shiftDown || this.altDown) && key == CODED) {
      if (keyCode == LEFT && selectedID != 0) {
        goToPuzzle(--selectedID);
      } else if (keyCode == RIGHT && selectedID != puzzles.size() - 1) {
        goToPuzzle(++selectedID);
      }
    }
  }

  @Override
  public void draw(PGraphics g) {
    g.background(255);
    super.drawScrollBar(g);
    int thumbnailStart = getOffset() / snap;
    int offset0 = getOffset() % snap;
    g.noStroke();
    for (int b = 0; b < 6; b++) {
      int puzzleID = b + thumbnailStart;
      g.noTint();
      //if (puzzleID == selectedID) g.noTint();
      if (puzzleID < 0) continue;
      if (puzzleID >= getPuzzleCount()) break;
      int x = b * snap - offset0;
      PGraphics g2 = getPuzzleThumbnail(b + thumbnailStart);
      g.image(g2, x, scrollH);
      if (puzzleID == markedID) {
        g.blend(highlight2, 0, 0, snap, getH() - scrollH,
          x, scrollH, snap, getH() - scrollH, DARKEST);
      } else if (puzzleID == selectedID) {
        g.blend(highlight, 0, 0, snap, getH() - scrollH,
          x, scrollH, snap, getH() - scrollH, DARKEST);
      }
      deleteButtons[b].setX(x + 2);
      deleteButtons[b].draw(g);
    }
    g.stroke(#777777);
    g.line(0, scrollH, width, scrollH);
    //g.line(0, h - 1, w, h - 1);
    for (int b = 0; b < 6; b++) {
      int x = b * snap - offset0;
      g.line(x, scrollH, x, getH());
    }
  }
}

