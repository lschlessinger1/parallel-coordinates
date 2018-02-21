class Curve {
  CurveSegment[] curves;
  color curveColor, hoveredColor, initialColor;
  boolean isSelected;
  DataPoint dataPoint;

  Curve(CurveType type, color curveColor, DataPoint point, Axis[] axes, float[] minVals, float[] maxVals) {
    this.initialColor = curveColor;
    this.curveColor = initialColor;
    this.dataPoint = point;
    this.curves = createCurveSegments(type, point, axes, minVals, maxVals);
  }
  
  boolean getSelected() {
    return this.isSelected;
  }
  
  void setSelected(boolean isSelected) {
    this.isSelected = isSelected;
    if (curves.length > 0) {
      for (CurveSegment segment: curves) {
        segment.setSelected(isSelected);
      }
    }
  }
  
  CurveSegment[] createCurveSegments(CurveType type, DataPoint point, Axis[] axes, float[] minVals, float[] maxVals) {
    int m = axes.length;
    CurveSegment[] segments = new CurveSegment[m - 1];
    
    switch(type) {
      case LINEAR:
        for (int d = 0; d < m - 1; d++) {
          Axis axis = axes[d];
          Axis nextAxis = axes[d + 1];
          
          float yOffset, x1, y1, nextYOffset, x2, y2;
          
          if (axis.descending) {
            // 1 - because range is max to min
            yOffset = 1 - norm(point.values[d], minVals[d], maxVals[d]);
            x1 = axis.p1.x;
            y1 = axis.p1.y + yOffset * (axis.p2.y - axis.p1.y);
          } else {
            yOffset = norm(point.values[d], minVals[d], maxVals[d]);
            x1 = axis.p1.x;
            y1 = axis.p1.y + yOffset * (axis.p2.y - axis.p1.y);
          }
          
          if (nextAxis.descending) {
            nextYOffset = 1 - norm(point.values[d + 1], minVals[d + 1], maxVals[d + 1]);
            x2 = nextAxis.p1.x;
            y2 = nextAxis.p1.y + nextYOffset * (nextAxis.p2.y - nextAxis.p1.y);
          } else {
            nextYOffset = norm(point.values[d + 1], minVals[d + 1], maxVals[d + 1]);
            x2 = nextAxis.p1.x;
            y2 = nextAxis.p1.y + nextYOffset * (nextAxis.p2.y - nextAxis.p1.y);
          }
          
          Point p1 = new Point(x1, y1);
          Point p2 = new Point(x2, y2);
          segments[d] = new Line(p1, p2);
        }

        break;
      
      case BEZIER:
        for (int d = 0; d < m - 1; d++) {
          Axis axis = axes[d];
          Axis nextAxis = axes[d + 1];
          
          float yOffset, x1, y1, nextYOffset, x2, y2;
          
          if (axis.descending) {
            // 1 - because range is max to min
            yOffset = 1 - norm(point.values[d], minVals[d], maxVals[d]);
            x1 = axis.p1.x;
            y1 = axis.p1.y + yOffset * (axis.p2.y - axis.p1.y);
          } else {
            yOffset = norm(point.values[d], minVals[d], maxVals[d]);
            x1 = axis.p1.x;
            y1 = axis.p1.y + yOffset * (axis.p2.y - axis.p1.y);
          }
          
          if (nextAxis.descending) {
            nextYOffset = 1 - norm(point.values[d + 1], minVals[d + 1], maxVals[d + 1]);
            x2 = nextAxis.p1.x;
            y2 = nextAxis.p1.y + nextYOffset * (nextAxis.p2.y - nextAxis.p1.y);
          } else {
            nextYOffset = norm(point.values[d + 1], minVals[d + 1], maxVals[d + 1]);
            x2 = nextAxis.p1.x;
            y2 = nextAxis.p1.y + nextYOffset * (nextAxis.p2.y - nextAxis.p1.y);
          }
          
          Point p1 = new Point(x1, y1);

          float xStep = abs(x2 - x1) / (3.0);

          Point p3 = new Point(x1 + xStep, y1);
          Point p4 = new Point(x1 + xStep * 2, y2);
          Point p2 = new Point(x2, y2);
          segments[d] = new BezierCurve(p1, p2, p3, p4);
        }
        break;
        
      default:
        break;
    }
    
    return segments;
  }
  
  float[] normalizeArray(float[] a) {
    float[] arr = new float[a.length];
    for (int i =0; i < a.length; i++) {
      arr[i] = norm(a[i], min(a), max(a));
    }
    return arr;
  }
  
  float getSumOfArray(float[] a) {
    float sum = 0;
    for (int i =0; i < a.length; i++) {
      sum += a[i];
    }
    return sum;
  }
  
  boolean isHovered() {
    // check if any curve segment is hovered
    Point mousePos = new Point(mouseX, mouseY);
    for (CurveSegment segment: curves) {
      if (segment.intersectsWithPoint(mousePos)) {
        return true;
      }
    }
    
    return false;
  }
  
  void updateColor(color newColor) {
    this.curveColor = newColor;
  }
  
  void resetColor() {
    this.curveColor = initialColor;
  }
  
  void drawCurve(PGraphics mainCanvas, PGraphics selectedCanvas, PGraphics selectedLines, BoundingRect selectedBoundingRect) {
    // if all curve segments are bounded, then it is selected
    for (CurveSegment curveSegment: curves) {
      // if bounding rect selected, draw curveSegment on selected canvas
      //if (!curveSegment.isBounded(selectedBoundingRect)) {
      if (!getSelected()) {
        mainCanvas.beginDraw(); 
        curveSegment.drawSelf(curveColor, mainCanvas);
        mainCanvas.endDraw();
      } else if (isHovered())  {
        selectedLines.beginDraw(); 
        curveSegment.drawSelf(curveColor, selectedLines);
        selectedLines.endDraw();
      } else {
        selectedCanvas.beginDraw();
        curveSegment.drawSelf(curveColor, selectedCanvas);
        selectedCanvas.endDraw();
      }
    }
  }
}