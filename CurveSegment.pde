// The sub-curve between 2 axes
abstract class CurveSegment implements Intersectable {
  Point p1, p2;
  color unselectedColor = color(233, 233, 233); // light gray 
  boolean selected;
  
  CurveSegment() {}
  
  void setSelected(boolean selected) {
    this.selected = selected;
  }
  
  boolean getSelected() {
    return this.selected;
  }
  
  // helpers
  boolean isBounded(BoundingRect bRect) {
    boolean selected = bRect.isSelected();
    float eps = 0.1;
    boolean selectedLeftPoint = isBetween(p1.x, bRect.pos.x - eps, bRect.pos.x  + bRect.w + eps) && isBetween(p1.y, bRect.pos.y -eps, bRect.pos.y  + bRect.h + eps);
    boolean selectedRightPoint = isBetween(p2.x, bRect.pos.x - eps, bRect.pos.x  + bRect.w + eps) && isBetween(p2.y, bRect.pos.y- eps, bRect.pos.y  + bRect.h + eps);
    return selected && (selectedLeftPoint || selectedRightPoint) ;
  }
  
  boolean isBetween(float val, float range1, float range2) {
    float largeNum = range1;
    float smallNum = range2;
    if (smallNum > largeNum) {
        largeNum = range2;
        smallNum = range1;
    }

    if ((val < largeNum) && (val > smallNum)) {
        return true;
    }
    
    return false;
  }
}