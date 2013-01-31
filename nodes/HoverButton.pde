class HoverButton { // Circular.
  
  int x;
  int y;
  int r;
  PImage icon;
  boolean show;
  boolean mouseOn;
  int a;
  
  public HoverButton(int x, int y, int r, PImage icon) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.icon = icon;
    this.show = false;
    this.mouseOn = false;
    this.a = 0;
  }
  
  public void setX(int x) {
    this.x = x;
  }
  
  public void setY(int y) {
    this.y = y;
  }
  
  public void show() {
    show = true;
  }
  
  public void hide() {
    show = false;
  }
  
  public boolean mouseOn() {
    return mouseOn;
  }
  
  public void mouseMoved(int relX, int relY, int prelX, int prelY) {
    if (show) {
      int dx = relX - x - r;
      int dy = relY - y - r;
      if (sqrt(dx * dx + dy * dy) <= r) {
        mouseOn = true;
      } else {
        mouseOn = false;
      }
    }
  }
  
  void draw(PGraphics g) {
    if (show) {
      if (a < 256) a += 15;
    } else {
      if (a >= 0) a -= 15;
    }
    if (a >= 0) {
      g.tint(255, a);
      g.image(icon, x, y);
      //int w = icon.width;
      //int h = icon.height;
      //g.blend(icon, 0, 0, w, h, x, y, w, h, ADD);
    }
  }
}
