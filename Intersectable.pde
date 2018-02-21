interface Intersectable {
  boolean intersectsWithPoint(Point p);
  
  boolean selectedInsideRect();
  
  // TODO: add this to new interface
  
  void drawSelf(color c, PGraphics canvas);
}