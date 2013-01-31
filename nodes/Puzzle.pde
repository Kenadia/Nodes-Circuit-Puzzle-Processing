class Puzzle {

  final static float ratio = 72./300; // Screen to print ratio.
  final static float thumbnailRatio = ratio / 5; // Screen to thumbnail ratio.
  final static int fullWidth = 1650; // (8.5 * 300).
  final static int fullHeight = 2550; // Print height (11 * 300).
  private final static int MAX_SOLUTIONS = 100;

  private char [] [] map; // For map.
  private int w, h; // Grid dimensions.
  private int l, u; // x and y of top left corner in full res.
  private int s; // Size of a grid square in full res.
  private PGraphics image; // Graphics for computer res.
  private PGraphics thumb; // Graphics for thumbnail.
  private ArrayList solutionMaps; // ArrayList<char [] []>.
  private PGraphics [] solutionImages; // ArrayList<PGraphics>.
  // After running solve, solutionMaps will not be null
  // and solutionImages will not be null, though it may contain nulls.
  private boolean solutionOverflow;
  private int difficulty;
  private int depth;

  private final static color ink = #303030; // Dark gray for main color.
  private HashMap symbolMap;
  
  Puzzle(char [] [] map, HashMap symbolMap) {
    setMap(map);
    this.symbolMap = symbolMap;
    generateDisplay();
  }

  private void setMap(char [] [] map) {
    this.map = map;
    if (map == null) {
      w = h = l = u = s = 0;
    } 
    else {
      w = map[0].length;
      h = map.length;
      s = int(min(150, min(fullWidth * 3.0 / 4 / w, fullHeight * 3.0 / 4 / h)));
      l = (fullWidth - w * s) / 2;
      u = (fullHeight - h * s) / 2;
    }
    resetGraphics();
  }

  private void resetGraphics() {
    image = null;
    thumb = null;
    solutionMaps = null;
    solutionImages = null;
    difficulty = 0;
    depth = 0;
  }

  public char [] [] getMap() {
    return map;
  }

  public int getW() {
    return w;
  }

  public int getH() {
    return h;
  }

  public PGraphics getImage() {
    if (image == null) {
      generateDisplay();
    }
    return image;
  }
  
  public PGraphics getImage(float ratio) {
    return generateImage(map, ratio);
  }
  
  public PGraphics getImage(float ratio, int id) {
    return generateImage(map, ratio, id);
  }

  public PGraphics getThumbnail() {
    if (thumb == null) {
      generateDisplay();
    }
    return thumb;
  }

  public boolean isSolved() {
    return solutionMaps != null;
  }

  public int getSolutionCount() {
    if (solutionMaps == null) {
      solve();
    }
    return solutionMaps.size();
  }

  public boolean solutionOverflow() {
    return solutionOverflow;
  }

  public int getDifficulty() {
    return difficulty;
  }

  public int getDepth() {
    return depth;
  }

  public char [] [] getSolutionMap(int a) {
    if (a < 0 || a >= getSolutionCount()) {
      return null;
    }
    return (char [] []) solutionMaps.get(a);
  }

  public PGraphics getSolutionImage(int a) {
    if (a < 0 || a >= getSolutionCount()) {
      return null;
    }
    if (solutionImages[a] == null) {
      solutionImages[a] = generateImage((char [] []) solutionMaps.get(a), ratio);
    }
    return solutionImages[a];
  }

  private void solve() {
    Object [] returnObjects = NodesModule.solve(map);
    solutionMaps = (ArrayList) returnObjects[0];
    if (solutionMaps.size() > MAX_SOLUTIONS) {
      solutionOverflow = true;
      solutionMaps.subList(MAX_SOLUTIONS, solutionMaps.size()).clear();
    } 
    else {
      solutionOverflow = false;
    }
    difficulty = depth = 0;
    int solutionCount = solutionMaps.size();
    if (solutionCount == 1) {
      int [] dArray = (int []) returnObjects[1];
      if (dArray != null) {
        difficulty = dArray[0];
        depth = dArray[1];
      }
    }
    solutionImages = new PGraphics [solutionCount];
  }

  public char getSquare(int x, int y) {
    x /= ratio;
    y /= ratio;
    int c = x < l? -1 : (x - l) / s;
    int r = y < u? -1 : (y - u) / s;
    if (c >= 0 && c < w && r >= 0 && r < h) return map[r][c];
    else return '?';
  }

  public void setSquare(int x, int y, char ch) {
    x /= ratio;
    y /= ratio;
    int c = x < l? -1 : (x - l) / s;
    int r = y < u? -1 : (y - u) / s;
    if (c >= 0 && c < w && r >= 0 && r < h) {
      map[r][c] = ch;
      resetGraphics();
    }
  }
  
  public void setSquare(char [] [] m, int x, int y, char ch) {
    x /= ratio;
    y /= ratio;
    int c = x < l? -1 : (x - l) / s;
    int r = y < u? -1 : (y - u) / s;
    if (c >= 0 && c < w && r >= 0 && r < h) {
      m[r][c] = ch;
    }
  }

  public void draw(PGraphics g) {
    if (image == null) {
      generateDisplay();
    }
    g.image(image, 0, 0);
  }

  public void drawNodeConnections(PGraphics g, char [] [] m) {
    char lastChar;
    char foundChar;
    int lastI = -1;
    int lastJ = -1;
    //draw connecting lines horizontally
    for (int i = 0; i < h; i++) {
      lastChar = '0';
      for (int j = 0; j < w; j++) {
        foundChar = '0';
        char nextChar = m[i][j];
        if (nextChar == 'X' || nextChar == 'O' || nextChar == 'T' || nextChar == '∆' ||
          nextChar == 'x' || nextChar == 'o' || nextChar == 't') {
          foundChar = nextChar;
        }
        else if (nextChar == '/' || nextChar == '_') {
          lastChar = '0';
        }
        if (lastChar != '0') {
          if (foundChar == lastChar) {
            connectSquares(g, lastJ, lastI, j, i);
          }
        }
        if (foundChar != '0') {
          lastChar = foundChar;
          lastI = i;
          lastJ = j;
        }
      }
    }
    //draw connecting lines vertically
    for (int j = 0; j < w; j++) {
      lastChar = '0';
      for (int i = 0; i < h; i++) {
        foundChar = '0';
        char nextChar = m[i][j];
        if (nextChar == 'X' || nextChar == 'O' || nextChar == 'T' || nextChar == '∆' ||
          nextChar == 'x' || nextChar == 'o' || nextChar == 't') {
          foundChar = nextChar;
        }
        else if (nextChar == '/' || nextChar == '_') {
          lastChar = '0';
        }
        if (lastChar != '0') {
          if (foundChar == lastChar) {
            connectSquares(g, lastJ, lastI, j, i);
          }
        }
        if (foundChar != '0') {
          lastChar = foundChar;
          lastI = i;
          lastJ = j;
        }
      }
    }
  }

  private void connectSquares(PGraphics g, int c1, int r1, int c2, int r2) {
    int x1 = int((l + s * (c1 + 0.5)) * ratio);
    int y1 = int((u + s * (r1 + 0.5)) * ratio);
    int x2 = int((l + s * (c2 + 0.5)) * ratio);
    int y2 = int((u + s * (r2 + 0.5)) * ratio);
    g.line(x1, y1, x2, y2);
  }

  private void generateDisplay() {
    image = generateImage(map, ratio);
    thumb = generateImage(map, thumbnailRatio);
  }

  public PGraphics generateImage(char [] [] map, float ratio) {
    return generateImage(map, ratio, -1);
  }

  public PGraphics generateImage(char [] [] map, float ratio, int id) {
    PGraphics g = createGraphics(int(fullWidth * ratio), int(fullHeight * ratio), P2D);
    g.beginDraw();
    g.background(255, 0);
    /*if (id != -1) {
      g.fill(ink);
      if (ratio == 1.0) {
        g.textFont(numFont);
      } else {
        g.textFont(numFont, int(100 * ratio));
      }
      g.textAlign(CENTER);
      g.text(id, 1500 * ratio, fullHeight / 2 * ratio);
    }*/
    g.noFill();
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        int x = l + s * i;
        int y = u + s * j;
        drawChar(g, map[j][i], x, y, s, ratio);
        if (map[j][i] != '_') drawRect(g, x, y, s, s, ratio);
      }
    }
    g.endDraw();
    return g;
  }

  private void drawChar(PGraphics g, char c, int x, int y, int s, float r) {
    PImage i = getSymbolImage(c);
    if (i == null) return;
    g.image(i, x * r, y * r, s * r, s * r);
  }

  private void drawRect(PGraphics g, int x, int y, int w, int h, float r) {
    g.stroke(ink);
    g.rect(x * r, y * r, w * r, h * r);
    if (r == 1.0) {
      g.rect(x - 2, y - 2, w + 4, h + 4);
      g.rect(x - 1, y - 1, w + 2, h + 2);
      g.rect(x + 1, y + 1, w - 2, h - 2);
      g.rect(x + 2, y + 2, w - 4, h - 4);
    }
  }

  PImage getSymbolImage(char c) {
    switch(c) {
    case ' ':
    case '_':
    case ',':
    case '.':
    case '\'':
    case '^':
    case '*':
    case ';':
    case '\\':
    case '–':
    case '|':
    case '+':
      return null;
    case '∆':
      c = 'T';
    case 'X':
    case 'O':
    case 'T':
      c = char(int(c) + 32);
    case 'x':
    case 'o':
    case 't':
      return (PImage) symbolMap.get("" + c);
    case '/':
      return (PImage) symbolMap.get("box");
    default:
      return (PImage) symbolMap.get("?");
    }
  }

  public void printSelf() {
    for (int j = 0; j < w + 2; j++) {
      print('-');
    }
    println();
    for (int i = 0; i < h; i++) {
      char [] s2 = new char[w + 2];
      print('|');
      for (int j = 0; j < w; j++) {
        print(map[i][j]);
      }
      println('|');
    }
    for (int j = 0; j < w + 2; j++) {
      print('-');
    }
    println();
  }

  public void printMap(char [] [] m) {
    int w = m[0].length;
    int h = m.length;
    for (int j = 0; j < w + 2; j++) {
      print('-');
    }
    println();
    for (int i = 0; i < h; i++) {
      char [] s2 = new char[w + 2];
      print('|');
      for (int j = 0; j < w; j++) {
        print(m[i][j]);
      }
      println('|');
    }
    for (int j = 0; j < w + 2; j++) {
      print('-');
    }
    println();
  }
}

