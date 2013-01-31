class ThumbnailGrid extends ThumbnailAbstract {

  private int snap;
  private int thumbH;
  private static final int scrollH = 8;
  private PImage deleteIcon;
  private HoverButton [] deleteButtons;
  
  private PImage highlight;
  private PImage highlight2;

  public ThumbnailGrid(ArrayList puzzles, ArrayList flags, int h, int snap) {
    super(puzzles, flags, ceil(puzzles.size() / 6.0) * snap, height, width,
      new int [] {0, height - scrollH, width, scrollH});
    this.snap = snap;
    this.thumbH = h - scrollH;
    this.deleteIcon = loadImage("deleteIcon.png");
    this.deleteButtons = new HoverButton [36];
    for (int i = 0; i < 36; i++) {
      deleteButtons[i] = new HoverButton(0, 0, 4, deleteIcon);
    }
    this.highlight = createImage(snap, thumbH, RGB);
    this.highlight2 = createImage(snap, thumbH, RGB);
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
    // Set destination.
    int o = getOffset();
    int leftEdge = ((a / 6) * snap);
    if (o > leftEdge) setDestination(leftEdge);
    else if (o < leftEdge + snap - width + 1) {
      setDestination(leftEdge + snap - width + 1);
    }
  }

  public int getPuzzleIDAtXY(int x, int y) {
    if (y >= height - scrollH) return -1;
    int offset0 = getOffset() % snap;
    if ((x + offset0) % snap == 0) return -1;
    int col = (x + getOffset()) / snap;
    return col * 6 + y / thumbH;
  }

  @Override
  protected void puzzleCountChanged() {
    setWidth(ceil(getPuzzleCount() / 6.0) * snap);
    super.puzzleCountChanged();
  }
  
  @Override
  public int getSelectedID() {
    return selectedID;
  }
  
  @Override
  public void singleClicked(int relX, int relY) {
    super.singleClicked(relX, relY);
    int overPuzzle = thumbs.getPuzzleIDAtXY(mouseX, mouseY);
    if (overPuzzle >= 0 && overPuzzle < puzzles.size()) {
      if (overPuzzle == markedID) {
        unmark();
      } else {
        markPuzzle(overPuzzle);
        goToPuzzle(overPuzzle);
      }
    }
  }

  @Override
  public void mousePressed(int relX, int relY, int prelX, int prelY) {
    int i = 0;
    for (; i < 36; i++) {
      if (deleteButtons[i].mouseOn()) break;
    }
    if (i < 36) {
      int thumbnailStart = (getOffset() / snap) * 6;
      removePuzzle(thumbnailStart + i);
    }
    else {
      super.mousePressed(relX, relY, prelX, prelY);
    }
  }

  @Override
  public void mouseMoved(int relX, int relY, int prelX, int prelY) {
    selectedID = getPuzzleIDAtXY(mouseX, mouseY);
    int thumbnailStart = (getOffset() / snap) * 6;
    int showI = getPuzzleIDAtXY(relX, relY) - thumbnailStart;
    for (int i = 0; i < 36; i++) {
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
  }

  @Override
  public void draw(PGraphics g) {
    g.background(255);
    super.drawScrollBar(g);
    int thumbnailStart = (getOffset() / snap) * 6;
    int offset0 = getOffset() % snap;
    g.noStroke();
    for (int b = 0; b < 36; b++) {
      int puzzleID = b + thumbnailStart;
      //if (puzzleID == selected) g.noTint();
      if (puzzleID < 0) continue;
      if (puzzleID >= getPuzzleCount()) break;
      g.noTint();
      int x = (b / 6) * snap - offset0;
      int y = (b % 6) * thumbH;
      PGraphics g2 = getPuzzleThumbnail(b + thumbnailStart);
      g.image(g2, x, y);
      if (puzzleID == markedID) {
        g.blend(highlight2, 0, 0, snap, thumbH,
          x, y, snap, thumbH, DARKEST);
      } else if (puzzleID == selectedID) {
        g.blend(highlight, 0, 0, snap, thumbH,
          x, y, snap, thumbH, DARKEST);
      }
      deleteButtons[b].setX(x + 2);
      deleteButtons[b].setY(y + 2);
      deleteButtons[b].draw(g);
    }
    g.stroke(#777777);

    for (int b = 0; b < 6; b++) {
      int x = b * snap - offset0;
      g.line(x, 0, x, height - scrollH);
    }
    for (int b = 1; b < 8; b++) {
      int y = b * thumbH - 1;
      g.line(0, y, width, y);
    }
  }
}

