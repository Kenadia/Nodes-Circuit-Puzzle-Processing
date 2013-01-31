abstract class SlidingBar {

  private final int MAX_SHIFT = 40; // Max shift speed.
  // Only reaches about 28 because of friction.
  private final int MAX_FLING = 25; // Max fling speed.
  private int w;
  private int h;
  private int displayW;
  private int offset;
  private int lim;
  private float v;
  private float inertia;
  //private boolean springBack;
  private float force;

  private int destination;
  private boolean goingRight;
  private boolean decelerating;
  private int elapsed;
  private int halfway;

  private int ppmouseX;
  private boolean mouseDown;

  private int [] scrollBox;
  private boolean mouseDownOnScrollBar;
  private boolean mouseDownInArea;
  
  // Keys.
  protected boolean shiftDown;
  protected boolean altDown;
  protected boolean leftShiftDown; // Left is down after being pressed with shift.
  protected boolean rightShiftDown; // Right is down after being pressed with shift.
  protected boolean upShiftDown; // Up is down after being pressed with shift.
  protected boolean downShiftDown; // Down is down after being pressed with shift.

  public SlidingBar(int w, int h, int displayW, int [] scrollBox) {
    this.w = w;
    this.h = h;
    this.displayW = displayW;
    this.offset = 0;
    this.lim = max(w - displayW + 1, 0);
    this.v = 0.0;
    this.inertia = 0.95;
    //this.springBack = false;
    this.force = 0.0;
    this.destination = -1;
    this.goingRight = false;
    this.decelerating = false;
    this.elapsed = 0;
    this.halfway = -1;
    this.ppmouseX = mouseX;
    this.mouseDown = false;
    this.scrollBox = scrollBox;
    this.mouseDownOnScrollBar = false;
    this.mouseDownInArea = false;
  }

  protected int getW() {
    return w;
  }

  protected int getH() {
    return h;
  }

  protected int getOffset() {
    return offset;
  }

  protected int getLim() {
    return lim;
  }

  protected void setLim(int lim) {
    this.lim = lim;
  }

  protected void setWidth(int w) {
    this.w = w;
    this.lim = max(w - displayW + 1, 0);
  }

  private void start() {
    offset = 0;
  }

  private void end() {
    offset = lim;
  }

  private void startMovingLeft(float accel) {
    if (/*!springBack && */offset != 0) {
      this.force = -accel;
      destination = -1;
    }
  }

  private void startMovingRight(float accel) {
    if (/*!springBack && */offset != lim) {
      this.force = accel;
      destination = -1;
    }
  }

  private void stopMoving() {
    force = 0;
  }

  protected void setDestination(int dest) {
    if (dest == offset) return; 
    int prevDest = destination;
    destination = dest;
    // If already moving in the same direction, don't have to stop,
    // just adjust halway point. Won't work if already past
    // halway point.
    if (prevDest != -1 && !decelerating) {
      int d = dest - offset;
      boolean goingRightNew = d > 0;
      if (goingRightNew == goingRight) {
        int startPoint = halfway * 2 - prevDest;
        halfway = (dest + startPoint) / 2;
        return;
      }
    }
    elapsed = 0;
    v = 0.0;
  }

  private int offsetCapped() {
    if (offset < 0) return 0;
    else if (offset > lim) return lim;
    return offset;
  }

  public void step() {
    // Arrows + shift movement.
    if (downShiftDown == upShiftDown) {
      if (leftShiftDown == rightShiftDown) {
        stopMoving();
      } 
      else {
        if (leftShiftDown) {
          startMovingLeft(0.4);
        } else {
          startMovingRight(0.4);
        }
      }
    } else {
      if (upShiftDown) {
        startMovingLeft(1.25);
      } else {
        startMovingRight(1.25);
      }
    }
    /*if (springBack) {
     destV = 0;
     }*/
    if (force != 0) {
      v += force;
    }
    if (destination == -1) {
      elapsed = 0;
      if (mouseDown) {
        force = 0.0;
        // Slide after mouse is released, unless dragged past edge.
        int dx = (ppmouseX - mouseX) / 2;
        if (offset < 0 || offset > lim) v = 0;
        else v = abs(dx) > MAX_FLING? (dx > 0? MAX_FLING : -MAX_FLING) : 
        dx;
        //
      }
      else {
        offset += int(v < 0? v - 0.5 : v + 0.5);
        if (force == 0 && v < 0.1 && v > -1) v = 0;
        else v *= inertia;
        if (offset < 0 || offset > lim) {
          offset = offsetCapped();
          v = 0;
        }
        /*if (offset < 0 || offset > lim) {
         destination = offset < 0 ? 0 : lim;
         destV = 0;
         springBack = true;
         }*/
      }
    } 
    else {
      force = 0.0;
      //offset = destination;
      //destination = -1;
      if (elapsed == 0) { // Begin journey.
        int d = destination - offset;
        goingRight = d > 0;
        decelerating = false;
        halfway = offset + d / 2;
      }
      v += goingRight ^ decelerating? 1 : -1;
      if (goingRight) {
        if (offset >= destination) {
          offset = destination;
        } 
        else if (offset > halfway) {
          decelerating = true;
        }
      } 
      else {
        if (offset <= destination) {
          offset = destination;
        } 
        else if (offset < halfway) {
          decelerating = true;
        }
      }
      if (offset != destination) {
        offset += int(v < 0? v - 0.5 : v + 0.5);
      } 
      else { // Reached destination.
        destination = -1;
        v = 0;
        //springBack = false;
      }
      elapsed++;
    }
    ppmouseX = pmouseX;
  }

  public void mousePressed(int relX, int relY, int prelX, int prelY) {
    mouseDownOnScrollBar = false;
    mouseDownInArea = false;
    if (relY < 0) return;
    else if (relY >= scrollBox[1] && relY < scrollBox[1] + scrollBox[3]) {
      int barWidth = scrollBox[2] * displayW / this.w;
      int barX = scrollBox[0] + offset * (scrollBox[2] - barWidth) / lim;
      if (prelX >= barX && prelX < barX + barWidth) {
        mouseDownOnScrollBar = true;
      }
    }
    else if (relX + offset >= 0 && relX + offset < w) {
      mouseDown = true;
      mouseDownInArea = true;
      /*if (!springBack)*/ destination = -1;
    }
  }

  public void mouseReleased(int relX, int relY, int prelX, int prelY) {
    mouseDown = false;
  }

  public void mouseMoved(int relX, int relY, int prelX, int prelY) {
  }

  public void mouseDragged(int relX, int relY, int prelX, int prelY) {
    if (mouseDownOnScrollBar) {
      int dx = relX - prelX;
      float r = float(this.w) / displayW;
      offset += r * dx;
      offset = offsetCapped();
    } 
    else if (mouseDownInArea) {
      // Without the !springBack there was an error
      // where if you dragged while it was springing back
      // it would miss its destination and decelerate infinitely.
      if (/*!springBack && */prelX + offset >= 0 && prelX + offset < w) {
        int dx = prelX - relX;
        offset += dx;
      }
      // Don't allow dragging beyond range.
      if (offset < 0) offset = 0;
      else if (offset >= lim) offset = lim;
    }
  }
  
  public void keyPressed() {
    if (key == CODED) {
      switch (keyCode) {
        case LEFT:
          if (altDown) {
            start();
          } else if (shiftDown) {
            leftShiftDown = true;
          }
          break;
        case RIGHT:
          if (altDown) {
            end();
          } else if (shiftDown) {
            rightShiftDown = true;
          }
          break;
        case UP:
          if (shiftDown) {
            upShiftDown = true;
          }
          break;
        case DOWN:
          if (shiftDown) {
            downShiftDown = true;
          }
          break;
        case SHIFT:
          shiftDown = true;
          break;
        case ALT:
          altDown = true;
          break;
      }
    }
  }
  
  public void keyReleased() {
    switch (key) {
      case CODED:
        switch (keyCode) {
          case LEFT:
            leftShiftDown = false;
            break;
          case RIGHT:
            rightShiftDown = false;
            break;
          case UP:
            upShiftDown = false;
            break;
          case DOWN:
            downShiftDown = false;
            break;
          case SHIFT:
            shiftDown = false;
            break;
          case ALT:
            altDown = false;
            break;
        }
        break;
    }
  }

  public abstract void draw(PGraphics g);

  public void drawScrollBar(PGraphics g) {
    g.stroke(#909090);
    g.noFill();
    int barW = scrollBox[2] * displayW / this.w;
    int barX = offset * (scrollBox[2] - barW) / lim + scrollBox[0];
    g.rect(barX + 2, scrollBox[1] + 2, barW - 5, scrollBox[3] - 5);
  }
}

