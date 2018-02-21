class Line extends CurveSegment {
  
  Line(Point p1, Point p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
  
  boolean intersectsWithPoint(Point p) {
    float m = getSlope();
    float b = p1.y - m * p1.x;
    float y = m * p.x + b;
    
    float epsilon = 2.5;
    boolean isOnLine = abs(p.y - y) < epsilon;
    return isOnLine && isBetween(p.x, p1.x - epsilon, p2.x + epsilon) && isBetween(p.y, p1.y - epsilon, p2.y + epsilon);
  }
  
  boolean selectedInsideRect() {
    return false;
  }
  
  void drawSelf(color c, PGraphics canvas) {
    // TODO: add color
    strokeWeight(2);
    if (getSelected()) {
      stroke(c);
    } else {
      stroke(unselectedColor);
    }
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  float getSlope() {
    return (p2.y - p1.y) / (p2.x - p1.x);
  }
  
  String toString() {
    return p1 + ", " + p2;
  }
}