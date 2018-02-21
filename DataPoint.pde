class DataPoint {
  String label;
  // assume values are floats for now
  float[] values;
 
  DataPoint(String labelName, float[] values) {
    this.label = labelName;
    this.values = values;
  }
 
}