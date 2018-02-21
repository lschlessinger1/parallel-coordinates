class SortIndicator {
  Point p1, p2, p3;
  color defaultColor = color(0,0,0);
  
  SortIndicator(Point p1, Point p2, Point p3) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }
  
  boolean hovered() {
    Point mousePos = new Point(mouseX, mouseY);
    float a1 =  triangleArea(mousePos, p2, p3);
    float a2 =  triangleArea(p1, mousePos, p3);
    float a3 =  triangleArea(p1, p2, mousePos);
    float totalMouseArea  = a1 + a2 + a3;
    float indicatorArea = triangleArea(p1, p2, p3);
    float epsilon = 0.25;
    return abs(indicatorArea - totalMouseArea) < epsilon;
  }
  
  void drawSelf(PGraphics canvas) {
    canvas.fill(defaultColor);
    canvas.triangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
  }
  
  float triangleArea(Point a, Point b, Point c) {
    return 0.5 * abs(a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y));
  }
  String toString() {
    return p1 + ", " + p2 + ", " + p3;
  }
}