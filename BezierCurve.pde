class BezierCurve extends CurveSegment {
  Point p3, p4;
  
  BezierCurve(Point p1, Point p2, Point p3, Point p4) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
    this.p4 = p4;
  }
  
  // source: https://en.wikipedia.org/wiki/B%C3%A9zier_curve#Cubic_B%C3%A9zier_curves
  // B(t) = (1 - t)^3 P_0 + 3(1 - t)^2 t P_1 + 3 (1 - t)t^2 P_2 + t^3 P_3, 0 <= t <= 1
  boolean intersectsWithPoint(Point p) {
    //TODO
    float t = norm(p.x, p1.x, p2.x);
    float y = pow((1-t),3) * p1.y + 3*pow((1-t), 2) * t * p3.x + 3 * (1-t)* pow(t,2) * p4.x + pow(t,3) * p2.x;
    float epsilon = 2.5;

    boolean isOnCurve = abs(p.y - y) < epsilon;
    return isOnCurve && isBetween(p.x, p1.x - epsilon, p2.x + epsilon) && isBetween(p.y, p1.y - epsilon, p2.y + epsilon);
  }
  
  boolean selectedInsideRect() {
    return false;
  }
  
  void drawSelf(color c, PGraphics canvas) {
    // TODO: add color
    canvas.noFill();
    canvas.strokeWeight(2);
    if (getSelected()) {
      canvas.stroke(c);
    } else {
      canvas.stroke(unselectedColor);
    }
    
    canvas.bezier(p1.x, p1.y,p3.x, p3.y, p4.x, p4.y, p2.x, p2.y);
  }
  
  String toString() {
    return p1 + ", " + p3 + ", " + p4 + ", " + p2;
  }
}