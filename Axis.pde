class Axis {
  String label, unit;
  Point p1, p2;
  float minValue, maxValue, axisSpacing, sortIndicatorSpacing;
  BoundingRect boundingRect;
  boolean descending;
  SortIndicator sortIndicator;
  
  Axis(String label, String unit, boolean selected, boolean descending, Point p1, Point p2, float minVal, float maxVal, Point[] bRectPoints) {
    this.label = label;
    this.unit = unit;
    this.p1 = p1;
    this.p2 = p2;
    this.minValue = minVal;
    this.maxValue = maxVal;
    this.descending = descending;
    axisSpacing = -30;
    sortIndicatorSpacing = axisSpacing - 20;
    createSortIndicator();
    setBoundingRect(bRectPoints[0], bRectPoints[1], selected, minVal, maxVal, descending);
  }
  
  void setBoundingRect(Point firstPoint, Point secondPoint, boolean selected, float minVal, float maxVal, boolean descending) {
    float w = 20;
    float h = secondPoint.y - firstPoint.y;
    Point pos = new Point(firstPoint.x - w/2, firstPoint.y);
    
    float upperVal;
    float lowerVal;

    if (descending) {
      upperVal = map(pos.y, p1.y, p2.y, maxVal, minVal);
      lowerVal = map(pos.y + h, p1.y, p2.y, maxVal, minVal);
    } else {
      upperVal = map(pos.y, p1.y, p2.y, minVal, maxVal);
      lowerVal = map(pos.y + h, p1.y, p2.y, minVal, maxVal);
    }
    
    this.boundingRect = new BoundingRect(pos, w, h, p1.y, p2.y, selected, upperVal, lowerVal, descending);
  }
  
  void createSortIndicator() {
    Point first, second, third;
    float sideLength = 15;
    if (descending) {
      first = new Point(p1.x - sideLength, p1.y + sortIndicatorSpacing - sideLength);
      second = new Point(p1.x + sideLength, p1.y + sortIndicatorSpacing - sideLength);
      third = new Point(p1.x, p1.y + sortIndicatorSpacing);
    } else {
      first = new Point(p1.x, p1.y + sortIndicatorSpacing - sideLength);
      second = new Point(p1.x - sideLength, p1.y + sortIndicatorSpacing);
      third = new Point(p1.x + sideLength, p1.y + sortIndicatorSpacing);
    }
    sortIndicator = new SortIndicator(first, second, third);
  }
  
  void drawAxis(PGraphics mainCanvas, PGraphics selectedCanvas) {
    mainCanvas.beginDraw();
    drawAxisTitle(mainCanvas);
    mainCanvas.endDraw();
    
    if (!boundingRect.isSelected()) {
      mainCanvas.beginDraw();
      drawBoundingRect(mainCanvas);
      mainCanvas.endDraw();
    } else {
      selectedCanvas.beginDraw();
      drawBoundingRect(selectedCanvas);
      selectedCanvas.endDraw();
    }
    
    mainCanvas.beginDraw();
    drawAxisLine(mainCanvas);
    drawSortIndicator(mainCanvas);
    mainCanvas.endDraw();
  }
  
  void drawBoundingRect(PGraphics canvas) {
    // draw bounding rect on new canvas
    boundingRect.drawBRect(canvas);
  }
  
  void drawAxisLine(PGraphics canvas) {
    canvas.stroke(0);
    canvas.strokeWeight(2);
    canvas.line(p1.x, p1.y, p2.x, p2.y);
  }
  
  void drawSortIndicator(PGraphics canvas) {
    sortIndicator.drawSelf(canvas);
  }
  
  void drawAxisTitle(PGraphics mainCanvas) {
    mainCanvas.textAlign(CENTER);
    mainCanvas.textSize(18);
    mainCanvas.fill(0);
    mainCanvas.text(label, p1.x, p1.y + axisSpacing);
  }
}