// The code below was revised based on Finn's button class posted on Piazza 1/19/18.
class ResponsiveButton {
  float x, y, w, h;
  int backgroundColor = color(92,184,92);
  int textColor = color(250);
  String btnText;
  
  ResponsiveButton(float x, float y, float w, float h, String btnText) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.btnText = btnText;
  }
  
  public void drawButton() {
    fill(backgroundColor);
    rect(x, y, w, h);
    
    fill(textColor);
    textSize(16);
    textAlign(CENTER);
    text(btnText, x + w/2, y + h/2);
  }
  
  public boolean hovered() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
}