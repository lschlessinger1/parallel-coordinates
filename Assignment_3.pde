String path = "Iris.csv";
String labelName;
String[] featureNames, labels;
float[][] features;

PGraphics mainCanvas, selectedBRectCanvas, tooltipCanvas, selectedLines;

int defaultWidth = 1040;
int defaultHeight = 760;
int prevWidth = defaultWidth;
int prevHeight = defaultHeight;

Point startPoint;
int selectedDimension = 0;
Chart chart;
boolean selectingCurves = false;
boolean movingBRect = false;
int draggingBRectAxisNum = -1;

  // store copies
  boolean[] descendingDimensions;
  Point[][] bRectPoints;

ResponsiveButton chartTypeButton;
int defaultType = CurveType.LINEAR;

void setup() {
  size(1040, 760);
  //surface.setResizable(true);
  
  // load data
  loadStringsHelper();
  
  startPoint = new Point(-1, -1);
  createChart();
  createButtons();
}

void draw() {
  background(250);

  if (width != prevWidth || height != prevHeight) {
    // window has been resized
    prevWidth = width;
    prevHeight = height;
    bRectPoints = null;
    createChart();
    createButtons();
  }

  drawButtons();
  // draw axes, boundingRects, and curves on separate canvases
  chart.drawChart();
  
  //selectedBRectCanvas.clear();
  handleHovering();
}

void createChart() {
  mainCanvas = createGraphics(width, height);
  selectedBRectCanvas = createGraphics(width, height);
  tooltipCanvas = createGraphics(width, height);
  selectedLines = createGraphics(width, height);
 
  chart = new Chart(mainCanvas, selectedBRectCanvas, tooltipCanvas, selectedLines, labelName, featureNames, labels, features, selectedDimension, descendingDimensions, bRectPoints, defaultType);
}

void mousePressed() {
  // check if a bounding rect was pressed 
  // update the selected dimension if necessary
  // int selectedDimension = chart.selectedDimension;
  if (chartTypeButton.hovered()) {
    if (defaultType ==CurveType.LINEAR) {
       defaultType = CurveType.BEZIER;
    } else {
      defaultType = CurveType.LINEAR;
    }
    createChart();
    createButtons();
  }
  
  for (int i = 0; i < chart.axes.length; i++) {
    Axis axis = chart.axes[i];
    BoundingRect bRect = axis.boundingRect;
    SortIndicator indicator = axis.sortIndicator;
    if (bRect.hovered() && !movingBRect) {
      int newDim = i;
      //chart.changeSelectedDimension(newDim);
      selectedDimension = newDim;
      descendingDimensions = chart.getDescendingDimensions();
      bRectPoints = chart.getBRectPoints();
      createChart();
      return;
    } else if (indicator.hovered()) {
      chart.toggleDimensionOrder(i);
    }
  }
}

void mouseDragged() {
  // check for selected curves
  // save start and end dragged
  for (int i = 0; i < chart.axes.length; i++) {
    Axis axis = chart.axes[i];
    BoundingRect bRect = axis.boundingRect;
    if (bRect.hovered() && !movingBRect) {
      if (startPoint.x == -1 || startPoint.y == -1) {
        startPoint.x = mouseX;
        startPoint.y = mouseY;
        movingBRect = true;
      }
      draggingBRectAxisNum = i;
      break;
    } else if (bRect.curveAreaHovered()) {
      if (startPoint.x == -1 || startPoint.y == -1) {
        startPoint.x = mouseX;
        startPoint.y = mouseY;
        selectingCurves = true;
      }
      
      // update dimension if necessary
      int newDim = i;
      if (selectedDimension != newDim) {
        selectedDimension = newDim;
        //print(chart.topCanvas);
        //createChart();
      }
      
      //chart.updateSelection(startPoint);
    }
  }
  
  if (selectingCurves && !movingBRect) {
    // update bounding rects
    chart.updateSelection(startPoint);
  } else if (movingBRect && draggingBRectAxisNum != -1) {
    chart.moveBRect(startPoint, draggingBRectAxisNum);
  }
}

void mouseReleased() {
  startPoint.x = -1;
  startPoint.y = -1;
  selectingCurves = false;
  movingBRect = false;
  
}

void mouseMoved() {
  boolean anyIndicatorHovered = false;
  for (Axis axis: chart.axes) {
    BoundingRect bRect = axis.boundingRect;
    SortIndicator indicator = axis.sortIndicator;
    if (bRect.hovered()) {
      cursor(MOVE);
      return;
    } else if (bRect.curveAreaHovered()) {
      cursor(CROSS);
      return;
    }
    
    if (indicator.hovered()) {
      anyIndicatorHovered = true;
    }
  }
  
  if (anyIndicatorHovered) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }
}

void handleHovering() {
  chart.checkCurvesHovered();
}

void loadStringsHelper() {
  String[] lines = loadStrings(path);
  String[] firstLine = split(lines[0], ",");
  int n = lines.length - 1;
  int m = firstLine.length - 1;
  
  labelName = firstLine[0];
  featureNames = new String[m];

  // populate featureNames
  for (int i = 0; i < m; i++) {
    featureNames[i] = firstLine[i + 1];
  }
  
  labels = new String[n];
  features = new float[n][m];
  HashMap<Integer, ArrayList<String>> uniqueFeatures = getCategoricalFeatures();
  //int numUniqueFeatures = uniqueFeatures.keySet().size();
  for (int i = 1; i < n + 1; i++) {
    String[] row = split(lines[i], ",");
    labels[i - 1] = row[0];
    for (int j = 1; j < m + 1; j++) {
      // assume data are floats for now
      if (!isNaN(row[j])) {
        features[i - 1][j - 1] = float(row[j]);
      } else {
        ArrayList<String> featureValues = uniqueFeatures.get(j);
        int idx = 0;
        for (int k = 0; k < featureValues.size(); k++) {
          if (row[j].equals(featureValues.get(k)))
            idx = k;
        }
        features[i - 1][j - 1] = float(idx);
      }
      
    }
  }

}

public void createButtons() {
  float r = 0.1f;
  int yPad = 10;
  int xPad = 15;
  float x = width/2;
  float y = height * (1-r) - yPad;
  float w =  width * r + xPad;
  float h =  height * r;
  String label;
  if (defaultType == CurveType.LINEAR) {
    label = "Type: Bezier";
  } else {
    label = "Type: Linear";
  }
  chartTypeButton = new ResponsiveButton(x, y, w, h, label);
}

HashMap<Integer, ArrayList<String>> getCategoricalFeatures() {
  String[] lines = loadStrings(path);
  String[] firstLine = split(lines[0], ",");
  int n = lines.length - 1;
  int m = firstLine.length - 1;
  HashMap<Integer, ArrayList<String>> uniqueFeatures = new HashMap();
  
  for (int i = 1; i < n + 1; i++) {
    String[] row = split(lines[i], ",");
    labels[i - 1] = row[0];
    for (int j = 1; j < m + 1; j++) {
      // assume data are floats for now
      if (isNaN(row[j])) {
        ArrayList<String> arr;
        
        if (!uniqueFeatures.containsKey(j)) {
          arr = new ArrayList<String>();
        } else {
          arr = uniqueFeatures.get(j);
        }
        if (!arr.contains(row[j])) {
          arr.add(row[j]);
          uniqueFeatures.put(j, arr);
        }
      }
    }
  }
  return uniqueFeatures;
}

public void drawButtons() {
  chartTypeButton.drawButton();
}

boolean isNaN(String s) {
	return !s.matches(".*\\d+.*");
}