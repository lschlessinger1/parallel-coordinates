class BoundingRect {
  Point pos;
  float w, h, minY, maxY, padding, upperValue, lowerValue;
  color backgroundColor;
  boolean selected, descending;

  BoundingRect(Point position, float w, float h, float minY, float maxY, boolean selected, float upperVal, float lowerVal, boolean descending) {
    this.pos = position;
    this.w = w;
    this.h = h;
    this.minY = minY;
    this.maxY = maxY;

    this.upperValue = upperVal;
    this.lowerValue = lowerVal;
    // for now just set some padding
    this.padding = 25;
    this.descending = descending;
    
    // for now set static background color to maroon
    this.selected = selected;
    setBGColor();
    
  }
  
  boolean isSelected() {
    return selected;
  }
  
  void setSelected(boolean val) {
    this.selected = val;
    setBGColor();
  }
  
  void setBGColor() {
    if (isSelected()) {
      // maroon for now
      this.backgroundColor = color(128,0,0);
    } else {
      this.backgroundColor = color(128,128,128);
    }
  }
  
  // is the bounding box hovered?
  boolean hovered() {
    return (mouseX >= this.pos.x && mouseX <= this.pos.x + this.w && mouseY >= this.pos.y && mouseY <= this.pos.y + this.h);
  }
  
  // is the bounding box + width + padding zone hovered?
  boolean curveAreaHovered() {
    boolean withinRightBound = mouseX > this.pos.x + this.w && mouseX <= this.pos.x + this.w + padding;
    boolean withinLeftBound = mouseX > this.pos.x - this.w - padding && mouseX <= this.pos.x;
    return ((withinRightBound || withinLeftBound) && !hovered());
  }
  
  // e.g. w + padding for selecting the lines
  Curve[] curvesHovered() {
    return null;
  }
  
  void drawBRect(PGraphics canvas) {
    // on new canvas
    noStroke();
    fill(250);
    // draw white padding around 
    //float pad  = 5;
    //canvas.rect(pos.x - pad, pos.y, w +2*pad, h);
    fill(backgroundColor);
    rect(pos.x, pos.y, w, h);
    drawLabels(canvas);
  }
  
  void drawLabels(PGraphics canvas) {
    stroke(0);
    fill(20, 20, 20);
    textAlign(CENTER);
    float padding = 12.5;
    textSize(14);
    if (descending) {
      text(upperValue, pos.x + w/2, pos.y - padding);
      text(lowerValue, pos.x + w/2, pos.y + h + padding);
    } else {
      text(upperValue, pos.x + w/2, pos.y - padding);
      text(lowerValue, pos.x + w/2, pos.y + h + padding);
    }
  }
  
  String toString() {
    return pos + ", w = " + w + ", h = " + h;
  }
}