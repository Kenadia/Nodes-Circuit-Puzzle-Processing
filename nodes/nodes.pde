import nodes_module.*;

// todo
// - allow notes that save to file
// - shows puzzle num and count
// bugs
// - trial map remains when puzzle is switched
// - grid and strip don't share same selectedID, markedID
// - error if hovering over blank space and press 'n'

import java.util.Scanner;
import java.io.File;

private final static int MAX_SOLUTIONS = 100;

ArrayList puzzles; // ArrayList of Puzzles.
ArrayList flags;
int selectedSolution; // Number of the currently displayed solution.
int solutionSelectedForID; // ID of the puzzle for which a solution was selected.

final String [] symbolList = {
  "x", "o", "t", "?"
}; // Except "/" ("box")
final HashMap symbolMap = new HashMap();

final color ink = #303030; // Dark gray for main color.

ThumbnailAbstract thumbs;
ThumbnailStrip thumbnailStrip;
ThumbnailGrid thumbnailGrid;
final int thumbnailY = 612; // Height of main display.
final int thumbnailH = 122 + 8; // Height of thumbnail display.

// Interface
boolean waitingForNumbers; // Waiting for numerical keyboard input from user.
int numberInput; // Last inputted number.
final int DOUBLE_CLICK_TIME = 20; // Max frames for a double-click;
int clickTime; // Time since last mouse click.
int clickX; // x of last mouse click.
int clickY; // y of last mouse click.
boolean shiftDown; // Shift key is down.
boolean altDown; // Alt/option key is down.

// Drawing
boolean mainDrawn;
PGraphics mainScreen;

boolean gridMode;
boolean solutionMode;
boolean trialMode;
char [] [] trialMap;
boolean editMode;

// Text
PFont displayFont;
PFont altFont;
PFont numFont;
final int SIDE_MARGIN = 6;

void setup() {
  size(396, 734, P2D);
  numFont = loadFont("AdobeArabic-Italic-160.vlw");
  puzzles = new ArrayList();
  flags = new ArrayList();
  // Have to set up symbol graphics first or the puzzles
  // will draw their images incorrectly on initialization.
  for (int a = 0; a < symbolList.length; a++) {
    symbolMap.put(symbolList[a], loadImage(symbolList[a] + "Image.png"));
  }
  PImage boxImage = createImage(1, 1, RGB);
  boxImage.loadPixels();
  boxImage.pixels[0] = ink;
  boxImage.updatePixels();
  symbolMap.put("box", boxImage);
  // Setup a Scanner with the input.
  Scanner sc = null;
  try {
    sc = new Scanner(createInput("data/input.txt"));
  } 
  catch (Exception e) {
  }
  if (sc == null) {
    println("Can't load input file.");
    return;
  }
  // Parse puzzles.
  while (sc.hasNext()) {
    String s = sc.nextLine();
    if (s.length() != 0 && s.charAt(0) != '-') {
      continue;
    }
    String border = s;
    int w = (s.indexOf(' ') > 0? s.indexOf(' ') : s.length()) - 2;
    if (w > 0) {
      ArrayList rows = new ArrayList();
      s = sc.nextLine();
      while (!s.equals (border)) {
        rows.add(s);
        s = sc.nextLine();
      }
      int h = rows.size();
      char [] [] map = new char [h] [w];
      for (int i = 0; i < h; i++) {
        String row = (String) rows.get(i);
        for (int j = 0; j < w; j++) {
          map[i][j] = row.charAt(j + 1);
        }
      }
      puzzles.add(new Puzzle(map, symbolMap));
      String flagLine = sc.nextLine();
      int flagValue;
      try {
        flagValue = Integer.parseInt(flagLine);
      } catch (NumberFormatException e) {
        flagValue = 0;
      }
      flags.add(flagValue);
    }
  }
  //
  selectedSolution = 0;
  solutionSelectedForID = 0;
  // Various display and interface variables.
  thumbnailStrip = new ThumbnailStrip(puzzles, flags, thumbnailH, width / 5);
  thumbnailGrid = new ThumbnailGrid(puzzles, flags, thumbnailH, width / 5);
  thumbs = thumbnailStrip;
  waitingForNumbers = false;
  numberInput = -1;
  clickTime = DOUBLE_CLICK_TIME + 1;
  clickX = -3;
  clickY = -3;
  mainDrawn = false;
  mainScreen = createGraphics(width, height, P2D);
  gridMode = false;
  solutionMode = false;
  trialMode = false;
  trialMap = null;
  editMode = false;
  displayFont = loadFont("HelveticaNeue-Medium-24.vlw");
  altFont = loadFont("Rockwell-Italic-100.vlw");
  //
  //export3by3();
}

void draw() {
  if (mainDrawn) { // Refreshes when a key is pressed or if goToPuzzle is called.
    image(mainScreen, 0, 0);
  }
  else if (!gridMode) /*(thumbs.getSelected() != null)*/{
    // If gridMode, selected may be null; else, selected is not null.
    Puzzle selected = thumbs.getSelected();
    if (solutionSelectedForID != thumbs.getSelectedID()) {
      selectedSolution = 0;
    }
    // Base.
    mainScreen.beginDraw();
    mainScreen.background(255);
    // Current puzzle.
    if (trialMode) {
      PGraphics trialImage = selected.generateImage(trialMap, Puzzle.ratio);
      selected.draw(mainScreen);
      mainScreen.tint(#cceeff);
      mainScreen.image(trialImage, 0, 0);
      mainScreen.noTint();
    }
    else if (solutionMode) {
      PGraphics solutionImage = selected.getSolutionImage(selectedSolution);
      if (solutionImage == null) { // No solution exists.
        selected.draw(mainScreen);
      } 
      else {
        mainScreen.image(solutionImage, 0, 0);
      }
    }
    else {
      selected.draw(mainScreen);
    }
    // Node connections.
    mainScreen.stroke(ink);
    if (trialMode) {
      char [] [] map = selected.getMap();
      int h = map.length;
      int w = map[0].length;
      char [] [] combinedMap = new char [h] [w];
      for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
          combinedMap[i][j] = map[i][j] == ' '? trialMap[i][j] : map[i][j];
        }
      }
      mainScreen.stroke(#0000ff);
      selected.drawNodeConnections(mainScreen, combinedMap);
      mainScreen.stroke(ink);
      selected.drawNodeConnections(mainScreen, selected.getMap());
    } else if (solutionMode) {
      mainScreen.fill(#FFB9B9);
      mainScreen.textFont(altFont, 60);
      mainScreen.textAlign(LEFT);
      mainScreen.text("solve ON", 16, thumbnailY + 4);
      char [] [] solutionMap = selected.getSolutionMap(selectedSolution);
      if (solutionMap != null) {
        selected.drawNodeConnections(mainScreen, solutionMap);
      } 
      else {
        selected.drawNodeConnections(mainScreen, selected.getMap());
      }
    } 
    else {
      selected.drawNodeConnections(mainScreen, selected.getMap());
    }
    // Upper bar with solutions info.
    mainScreen.noStroke();
    mainScreen.textFont(displayFont, 13);
    if (selected.isSolved()) {
      int solutionCount = selected.getSolutionCount();
      color textColor = #636363;
      String solutionsText = "Solution " + (selectedSolution + 1) + " of " +
        solutionCount + (selected.solutionOverflow()? "+." : ".");
      String difficultyText = "";
      if (solutionCount < 2) {
        mainScreen.fill(solutionCount == 0? #ff0000 : #00ff00);
        mainScreen.rect(0, 0, width, 20);
        textColor = #ffffff;
        if (solutionCount == 0) {
          solutionsText = "No solutions.";
        } 
        else {
          difficultyText = "Estimated difficulty: " + selected.getDifficulty() +
            " (depth " + selected.getDepth() + ")";
        }
      } 
      else if (solutionCount > MAX_SOLUTIONS) {
        mainScreen.fill(#FFC57E);
        mainScreen.rect(0, 0, width, 20);
      }
      mainScreen.fill(textColor);
      mainScreen.textAlign(LEFT);
      mainScreen.text(solutionsText, SIDE_MARGIN, 15);
      mainScreen.textAlign(RIGHT);
      mainScreen.text(difficultyText, width - SIDE_MARGIN, 15);
    }
    //
    mainScreen.endDraw();
    mainDrawn = true;
  }
  // Thumbnails.
  thumbs.step();
  PGraphics thumbStripG = createGraphics(width, gridMode? height : thumbnailH, P2D);
  thumbStripG.beginDraw();
  thumbs.draw(thumbStripG);
  thumbStripG.endDraw();
  image(thumbStripG, 0, gridMode? 0 : thumbnailY);
  //
  clickTime++;
}

void addBlankPuzzle(int w, int h) {
  char [] [] blankMap = blankMap(w, h);
  puzzles.add(new Puzzle(blankMap, symbolMap));
  flags.add(0);
  thumbs.goToPuzzle(puzzles.size() - 1);
}

void singleClicked() {
  thumbs.singleClicked(mouseX, mouseY - (gridMode? 0 : thumbnailY));
}

void doubleClicked() {
  mainDrawn = false;
  thumbs.doubleClicked(mouseX, mouseY - (gridMode? 0 : thumbnailY));
}

void mousePressed() {
  int relY = gridMode? mouseY : mouseY - thumbnailY;
  int prelY = gridMode? pmouseY : pmouseY - thumbnailY;
  thumbs.mousePressed(mouseX, relY, pmouseX, prelY);
  if (clickTime <= DOUBLE_CLICK_TIME) {
    if (abs(clickX - mouseX) <= 2 && abs(clickY - mouseY) <= 2) {
      doubleClicked();
    }
  }
  clickTime = 0;
  clickX = mouseX;
  clickY = mouseY;
}

void mouseReleased() {
  int relY = gridMode? mouseY : mouseY - thumbnailY;
  int prelY = gridMode? pmouseY : pmouseY - thumbnailY;
  if (clickX == mouseX && clickY == mouseY) {
    singleClicked();
  }
  thumbs.mouseReleased(mouseX, relY, pmouseX, prelY);
}

void mouseMoved() {
  int relY = gridMode? mouseY : mouseY - thumbnailY;
  int prelY = gridMode? pmouseY : pmouseY - thumbnailY;
  thumbs.mouseMoved(mouseX, relY, pmouseX, prelY);
}

void mouseDragged() {
  int relY = gridMode? mouseY : mouseY - thumbnailY;
  int prelY = gridMode? pmouseY : pmouseY - thumbnailY;
  thumbs.mouseDragged(mouseX, relY, pmouseX, prelY);
}

void keyPressed() {
  mainDrawn = false;
  int k = int(key) - 48;
  if (k >= 0 && k < 10) { // from 0 to 9
    if (waitingForNumbers) {
      if (numberInput == -1) numberInput = k;
      else {
        int a = numberInput;
        numberInput = -1;
        waitingForNumbers = false;
        addBlankPuzzle(a == 0? 10 : a, k == 0? 10 : k);
      }
    } else {
      int id = thumbs.getSelectedID();
      if(id != -1) {
        thumbs.flagPuzzle(id, k);
      }
    }
    return;
  }
  if (waitingForNumbers) return;
  //// Not number input or waiting for number input.
  Puzzle selected = thumbs.getSelected();
  // If gridMode, selected may be null; else, selected is not null.
  // If gridMode, selectedID may be -1; else, selectedID is a valid ID.
  // If gridMode, trialMode is false.
  switch (key) {
  case CODED:
    switch (keyCode) {
    case UP:
      if (!gridMode && !shiftDown && !altDown && selected.isSolved()) {
        solutionSelectedForID = thumbs.getSelectedID();
        if (++selectedSolution == selected.getSolutionCount()) {
          selectedSolution--;
        }
      }
      break;
    case DOWN:
      if (!gridMode && !shiftDown && !altDown && selected.isSolved()) {
        solutionSelectedForID = thumbs.getSelectedID();
        if (selectedSolution-- == 0) {
          selectedSolution++;
        }
      }
      break;
    case SHIFT:
      shiftDown = true;
      break;
    case ALT:
      altDown = true;
      break;
    case KeyEvent.VK_CAPS_LOCK:
      editMode = true;
      break;
    }
    break;
  case 'e': // Export current puzzle to tiff.
  case 'E':
    if (!gridMode) {
      int id = thumbs.getSelectedID();
      selected.getImage(1.0, id).save("puzzle " + id + ".tiff");
    }
    break;
  case 'n': // New puzzle.
  case 'N':
    waitingForNumbers = true;
    break;
  case 'p': // Print current puzzle or solution to console.
  case 'P':
    if (solutionMode && selected != null) {
      selected.printMap(selected.getSolutionMap(selectedSolution));
    } else {
      selected.printSelf();
    }
    break;
  case 's': // Save all puzzles to file.
  case 'S':
    savePuzzles();
    break;
  case TAB: // Toggle grid display.
    gridMode = !gridMode;
    if (gridMode) {
      thumbs = thumbnailGrid;
      trialMode = false;
    } else {
      int gridSelectedID = thumbs.getSelectedID();
      thumbs = thumbnailStrip;
      thumbs.goToPuzzle(gridSelectedID);
    }
    break;
  case ' ': // Toggle user solve mode.
    trialMode = !trialMode && !solutionMode && !gridMode;
    if (trialMode) {
      trialMap = blankMap(selected.getW(), selected.getH());
    }
    break;
  case RETURN: // Toggle solution display mode.
  case ENTER:
    if (!gridMode) {
      solutionMode = !solutionMode && !trialMode;
      if (solutionMode) {
        thumbs.goToPuzzle(thumbs.getSelectedID());
      }
    }
    break;
  case 'x':
  case 'X':
  case 'o':
  case 'O':
  case 't':
  case 'T':
  case '/':
    if (trialMode) selected.setSquare(trialMap, mouseX, mouseY, key);
    else if (editMode && !gridMode) selected.setSquare(mouseX, mouseY, key);
    selectedSolution = 0;
    break;
  case BACKSPACE:
    if (trialMode) selected.setSquare(trialMap, mouseX, mouseY, ' ');
    else if (editMode && !gridMode) selected.setSquare(mouseX, mouseY, ' ');
    selectedSolution = 0;
    break;
  case '.':
    if (editMode && !gridMode) {
      char c = selected.getSquare(mouseX, mouseY);
      if (c == '/') selected.setSquare(mouseX, mouseY, '_');
      else if (c == '_') selected.setSquare(mouseX, mouseY, '/');
    }
    break;
  }
  thumbs.keyPressed();
}

public void keyReleased() {
  switch (key) {
    case CODED:
      switch (keyCode) {
        case SHIFT:
          shiftDown = false;
          break;
        case ALT:
          altDown = false;
          break;
        case KeyEvent.VK_CAPS_LOCK:
          editMode = false;
          break;
      }
      break;
  }
  thumbs.keyReleased();
}

void savePuzzles() {
  ArrayList lines = new ArrayList();
  for (int a = 0; a < puzzles.size(); a++) {
    Puzzle puzzle = (Puzzle) puzzles.get(a);
    char [] [] map = puzzle.getMap();
    int w = puzzle.getW();
    int h = puzzle.getH();
    char [] s = new char[w + 2];
    for (int j = 0; j < w + 2; j++) {
      s[j] = '-';
    }
    lines.add(new String(s));
    for (int i = 0; i < h; i++) {
      char [] s2 = new char[w + 2];
      s2[0] = '|';
      for (int j = 0; j < w; j++) {
        s2[j + 1] = map[i][j];
      }
      s2[w + 1] = '|';
      lines.add(new String(s2));
    }
    s = new char[w + 2];
    for (int j = 0; j < w + 2; j++) {
      s[j] = '-';
    }
    lines.add(new String(s));
    lines.add(flags.get(a).toString());
    lines.add("");
  }
  String [] strings = new String[lines.size()];
  for (int i = 0; i < strings.length; i++) {
    strings[i] = (String) lines.get(i);
  }
  saveStrings("data/input.txt", strings);
  println("DATA SAVED");
}

void export3by3() {
  final float r = 1.0 / 3;
  final int fullWidth = Puzzle.fullWidth;
  final int fullHeight = Puzzle.fullHeight;
  for (int i = 8; i < puzzles.size();) {
    PGraphics page = createGraphics(fullWidth, fullHeight, P2D);
    page.beginDraw();
  
 page.background(255);
    int start = i;
    int end = i + 8;
    int x = 0;
    int y = 0;
    for (i = start; i <= end; i++) {
      if (i >= puzzles.size()) break;
      PGraphics g = ((Puzzle) puzzles.get(i)).getImage(r);
      page.image(g, x, y);
      x += fullWidth / 3;
      if (fullWidth - x < 3) {
        x = 0;
        y += fullHeight / 3;
      }
    }
    page.endDraw();
    page.save("puzzles" + start + "-" + end + ".tiff");
  }
}

public static char [] [] blankMap(int w, int h) {
  char [] [] blankMap = new char [h] [w];
  for (int i = 0; i < h; i++) {
    for (int j = 0; j < w; j++) {
      blankMap[i][j] = ' ';
    }
  }
  return blankMap;
}

