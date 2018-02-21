class Chart {
  String chartTitle;
  float margin, chartWidth, chartHeight, xShift, yShift;
  Axis[] axes;
  String[] featureNames;
  DataPoint[] points;
  ChartData[] chartData;
  PGraphics mainCanvas, topCanvas, tooltipCanvas, selectedLines;
  float[] minVals, maxVals;
  // by default select the first feature dimension
  int selectedDimension;
  int type;
  // for now, just save boolean array of orders for each dimension and all bounding rects
  boolean[] descendingDimensions;
  Point[][] bRectPoints;
  
  Chart(PGraphics mainCanvas, PGraphics selectedBRectCanvas, PGraphics tooltipCanvas, PGraphics selectedLines, String labelName, String[] featureNames, 
  String[] labels, float[][] features, int selectedDimension, boolean[] descendingDims, Point[][] bRectPositions, int defaultType) {
    // set chart title
    chartTitle = "Parallel Coordinates";
    // set chart width and chart height
    float usagePct = 0.75;
    chartWidth = usagePct * width;
    chartHeight = usagePct * height;
    
    // center shifts
    xShift = width / 2 - chartWidth / 2;
    yShift = height / 2 - chartHeight / 2;
    
    margin = 25;
    
    this.featureNames = featureNames;
    this.selectedDimension = selectedDimension;
    // create n datapoints
    points = createDataPoints(labels, features);
    
    // create axes
    // get min and max values for each feature
    minVals = getMinValues(features);
    maxVals = getMaxValues(features);
    this.mainCanvas = mainCanvas;
    this.topCanvas = selectedBRectCanvas;
    this.tooltipCanvas = tooltipCanvas;
    this.selectedLines = selectedLines;
    
    if (descendingDims != null) {
      descendingDimensions = descendingDims;
    } else {
      descendingDimensions = initDescendingDims(featureNames.length);
    }
    
    if (bRectPositions != null) { 
      bRectPoints = bRectPositions;// d x 2 array of points to keep track of bounding box
    } else {
      bRectPoints = initBRectPoints(featureNames.length);
    }
    
    createChartAxesAndData();
  }
  
  void createChartAxesAndData() {
    axes = createAxes(featureNames, minVals, maxVals, bRectPoints);
    
    // create chart data (using lines for now)
    type = defaultType;
    chartData = createChartData(points, type, axes, minVals, maxVals);

    selectCurves();
  }
  
  DataPoint[] createDataPoints(String[] labels, float[][] features) {
    int n = labels.length;
    DataPoint[] pts = new DataPoint[n];
    
    for (int i = 0; i < n; i++) {
      DataPoint point = new DataPoint(labels[i], features[i]);
      pts[i] = point;
    }
    
    return pts;
  }
  
  Axis[] createAxes(String[] featureNames, float[] minVals, float[] maxVals, Point[][] bRectPositions) {
    int m = featureNames.length;
    Axis[] axisArr = new Axis[m];
    
    for (int i = 0; i < m; i++) {
      float x  = calcAxisX(i, m);
      float y1 = calcTopAxisY();
      float y2 = calcBottomAxisY() ;
      
      Point p1 = new Point(x, y1);
      Point p2 = new Point(x, y2);
      
      String unit = "";
      boolean selected = selectedDimension == i;
      boolean descending = descendingDimensions[i];
      Axis axis = new Axis(featureNames[i], unit, selected, descending, p1, p2, minVals[i], maxVals[i], bRectPositions[i]);
      axisArr[i] = axis;
    }
    
    return axisArr;
  }
  
  float calcAxisX(int i, int m) {
    float spacing = chartWidth / float(m - 1);
    return spacing * i + xShift;
  }
  
  float calcTopAxisY() {
    return margin + yShift;
  }
  
  float calcBottomAxisY() {
    return -margin + chartHeight + yShift;
  }
  
  ChartData[] createChartData(DataPoint[] dataPoints, int type, Axis[] axisArr, float[] minVals, float[] maxVals) {
    int n = dataPoints.length;
    ChartData[] chartDataArr = new ChartData[n];
    
    for (int i = 0; i < n; i++) {
      chartDataArr[i] = new ChartData(dataPoints[i], selectedDimension, n, type, axisArr, minVals, maxVals);
    }
    
    return chartDataArr;
  }
  
  Point[][] initBRectPoints(int m) {
    Point[][] bRectPositions = new Point[m][2];
    for (int d = 0; d < m; d++) {
      float x  = calcAxisX(d, m);
      float y1 = calcTopAxisY();
      float y2 = calcBottomAxisY();
      Point p1 = new Point(x, y1);
      Point p2 = new Point(x, y2);
      bRectPositions[d][0] = p1;
      bRectPositions[d][1] = p2;
    }
    return bRectPositions;
  }
  
  boolean[] initDescendingDims(int m) {
    boolean[] desceningDimArr = new boolean[m];
    for (int i = 0; i < m; i++) {
      desceningDimArr[i] = true;
    }
    return desceningDimArr;
  }
  
  boolean[] getDescendingDimensions() {
    return descendingDimensions;
  }
  
  Point[][] getBRectPoints() {
    return bRectPoints;
  }
  
  void checkCurvesHovered() {
    tooltipCanvas.beginDraw();
    //tooltipCanvas.clear();
    tooltipCanvas.endDraw();
    ArrayList<Curve> curvesHovered = new ArrayList<Curve>(chartData.length);
    for (int i = 0; i < chartData.length; i++) {
      ChartData data = chartData[i];
      Curve curve = data.curve;      
      if (curve.isHovered()) {
        curvesHovered.add(curve);
        color hoverColor = color(255, 211, 0);
        curve.updateColor(hoverColor);
      } else {
        curve.resetColor();
      } 
    }
    
    showCurveTooltip(curvesHovered);
  }
  
  void changeSelectedDimension(int newDim) {
    // if the previously selected dimension is the same, do nothing
    if (newDim == selectedDimension) {
      return;
    }
    
    // otherwise, update the previous dimension selection
    axes = createAxes(featureNames, minVals, maxVals, bRectPoints);
    chartData = createChartData(points, type, axes, minVals, maxVals);
    
    BoundingRect prevSelectedRect = axes[selectedDimension].boundingRect;
    prevSelectedRect.setSelected(false);
    
    BoundingRect newlySelectedRect = axes[newDim].boundingRect;
    newlySelectedRect.setSelected(true);
    
    selectedDimension = newDim;
    
    selectCurves();
  }
  
  void updateSelection(Point startPoint) {
    // first update the bounding rect
    // (if need be, change selected bounding rect)
    Axis selectedAxis = axes[selectedDimension];
    //topCanvas.clear();
    boolean selected = true;
    boolean descending = selectedAxis.descending;
    
    // make sure start point is not less than axis point or greater than axis length
    float newYStart;
    if (startPoint.y < selectedAxis.p1.y) {
      newYStart = selectedAxis.p1.y;
    } else if (startPoint.y > selectedAxis.p2.y) {
      newYStart = selectedAxis.p2.y;
    } else {
      newYStart = startPoint.y;
    }
    
    // handle dimension drag up and down across start point
    float newHeight;
    if (mouseY < startPoint.y) {
      // change y position instead
      float y = mouseY;
      if (y < selectedAxis.p1.y) {
        y = selectedAxis.p1.y;
      }

      newYStart = y;
      newHeight = -y + startPoint.y;
    } else {
      float y = mouseY;
      if (mouseY > selectedAxis.p2.y) {
        y = selectedAxis.p2.y;
      }
      newHeight = y - startPoint.y;
    }
    
    float oldX = selectedAxis.p1.x;
    //selectedAxis.boundingRect.h = newHeight;
    Point p1 = new Point(oldX, newYStart);
    Point p2 = new Point(oldX, newYStart + newHeight);
    bRectPoints[selectedDimension][0] = p1;
    bRectPoints[selectedDimension][1] = p2;
    selectedAxis.setBoundingRect(p1, p2, selected, selectedAxis.minValue, selectedAxis.maxValue, descending);
    
    // select all curves having values between start point and current mouse position
    selectCurves();
  }
  
  float boundYStart(Axis selectedAxis) {
    float newYStart;
    if (startPoint.y < selectedAxis.p1.y) {
      newYStart = selectedAxis.p1.y;
    } else if (startPoint.y > selectedAxis.p2.y) {
      newYStart = selectedAxis.p2.y;
    } else {
      newYStart = startPoint.y;
    }
    return newYStart;
  }
  
  void moveBRect(Point startPoint, int draggingBRectAxisNum) {
    Axis selectedAxis = axes[draggingBRectAxisNum];
    topCanvas.beginDraw();
    //topCanvas.clear();
    topCanvas.endDraw();

    boolean selected = true;
    boolean descending = selectedAxis.descending;
    float oldX = selectedAxis.p1.x;
    float oldH = selectedAxis.boundingRect.h;
    float oldY = selectedAxis.boundingRect.pos.y;
    float shift = (mouseY - startPoint.y) > 0 ? 1 : -1;
    
    Point p1 = new Point(oldX, oldY + shift);
    Point p2 = new Point(oldX, oldY + oldH + shift);
    if (p1.y < selectedAxis.p1.y || p2.y > selectedAxis.p2.y) { 
      p1 = new Point(oldX, oldY);
      p2 = new Point(oldX, oldY + oldH );
    }
    bRectPoints[selectedDimension][0] = p1;
    bRectPoints[selectedDimension][1] = p2;
    selectedAxis.setBoundingRect(p1, p2, selected, selectedAxis.minValue, selectedAxis.maxValue, descending);
    selectCurves();
  }
  
  void toggleDimensionOrder(int dimension) {
    //mainCanvas.clear();
    //topCanvas.clear();
    descendingDimensions[dimension] = !descendingDimensions[dimension];
    axes = createAxes(featureNames, minVals, maxVals, bRectPoints);
    chartData = createChartData(points, type, axes, minVals, maxVals);
    selectCurves();
  }
  
  // selectCurves based on bounding rect
  void selectCurves() {
    for (ChartData data: chartData) {
      Curve curve = data.curve;
      boolean selected = true;
      // get the correct axis associated with the curve segment
      for (int d = 0; d < axes.length; d++) {
        Axis axis = axes[d];
        for (CurveSegment segment: curve.curves) {
          float epsilon = 0.01;
          Point p = segment.p1;
          if (d == axes.length - 1) {
            p = segment.p2;
          }
          if (abs(axis.p1.x - p.x) < epsilon) {
            BoundingRect bRect = axis.boundingRect;
            if (!isBetween(p.y, bRect.pos.y - epsilon, bRect.pos.y + bRect.h + epsilon)) {
              selected = false;
              
              break;
            }
          
          }
        }
      }
      if (curve.getSelected() != selected) {
        curve.setSelected(selected);
      }
    }
  }
  
  BoundingRect getSelectedBoundingRect() {
    Axis selectedAxis = axes[selectedDimension];
    return selectedAxis.boundingRect;
  }
  
  float[] getMinValues(float[][] features) {
    int n = features.length;
    int m = features[0].length;
    float[] minVals = new float[m];
    
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        if (i == 0) {
          minVals[j] = features[i][j];
        }
        float minVal = min(minVals[j], features[i][j]);
        minVals[j] = minVal;
      }
    }

    return minVals;
  }
  
  float[] getMaxValues(float[][] features) {
    int n = features.length;
    int m = features[0].length;
    float[] maxVals = new float[m];
    
    for (int i = 0; i < n; i++) {  
      for (int j = 0; j < m; j++) {
        if (i == 0) {
          maxVals[j] = features[i][j];
        }
        float maxVal = max(maxVals[j], features[i][j]);
        maxVals[j] = maxVal;
      }
    }

    return maxVals;
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
  
  void drawChart() {

    drawChartTitle();
    drawAxes(mainCanvas, topCanvas);
    drawChartData(mainCanvas, topCanvas);

    // always draw bounding rect last
    image(mainCanvas, 0, 0);
    image(topCanvas, 0, 0);
    image(selectedLines, 0, 0);
    image(tooltipCanvas, 0, 0);
  }
  
  void drawAxes(PGraphics mainCanvas, PGraphics topCanvas) {
    for (Axis axis: axes) {
      axis.drawAxis(mainCanvas, topCanvas);
    }
  }
  
  void drawChartData(PGraphics mainCanvas, PGraphics topCanvas) {
    selectCurves();
    for (ChartData chartDataPoint: chartData) {
      chartDataPoint.drawData(mainCanvas, topCanvas, selectedLines, getSelectedBoundingRect());
    }
  }
  
  void drawChartTitle() {
    float x = width/2;
    float pad = -50;
    float desiredY = max(5, yShift - 70);
    float y = min(desiredY, max(5, yShift + pad));
    mainCanvas.beginDraw(); 
    mainCanvas.textSize(28);
    mainCanvas.textAlign(CENTER);
    mainCanvas.text(chartTitle, x, y);
    mainCanvas.endDraw(); 
  }
  
  void showCurveTooltip(ArrayList<Curve> curvesHovered) {
    int numCurves = curvesHovered.size();
    if (numCurves < 1)
      return;
      
    String tooltipText = labelName + ": ";
    for (int i = 0; i < numCurves; i++) {
      if (numCurves > 3 && i == 3) {
        tooltipText += "...";
        break;
      }
      
      Curve curve = curvesHovered.get(i);
      String label = curve.dataPoint.label;
      tooltipText += label;
      if (i != numCurves - 1) {
        tooltipText += ", ";
      }

    }        
    //tooltipCanvas.beginDraw(); 
    fill(0);
    textSize(14);
    float pad = 5;
    text(tooltipText, mouseX, mouseY - pad);
   // tooltipCanvas.endDraw();
  }
}