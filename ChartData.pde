// a data point that is instantiated with a curve on a chart
class ChartData {
  DataPoint point;
  Curve curve;
  
  ChartData(DataPoint point, int selectedDimension, int n, int type, Axis[] axes, float[] minVals, float[] maxVals) {
    this.point = point;
    this.curve = createCurve(selectedDimension, n, type, point, axes, minVals, maxVals);
  }
  
  Curve createCurve(int selectedDimension, int n, int type, DataPoint point, Axis[] axes, float[] minVals, float[] maxVals) {
    // map color based on selectedDimension
    int d = selectedDimension;
    Axis axis = axes[d];
    float yOffset = 1 - norm(point.values[d], minVals[d], maxVals[d]);
    float y1 = axis.p1.y + yOffset * (axis.p2.y - axis.p1.y);
    float val = map(y1, axis.p1.y, axis.p2.y, 0, n);
    
    color primary = color(5, 143, 255);
    color secondary = color(255, 97, 5);
    float amt = val/n;
    color curveColor = lerpColor(primary, secondary, amt);
    Curve c = new Curve(type, curveColor, point, axes, minVals, maxVals);
    return c;
  }
  
  void drawData(PGraphics mainCanvas, PGraphics selectedCanvas, PGraphics selectedLines, BoundingRect selectedBoundingRect) {
    curve.drawCurve(mainCanvas, selectedCanvas, selectedLines, selectedBoundingRect);
  }
  
  String toString() {
    return "curve: " + curve + ", point: " + point;
  }
}