part of hexagone;

class Input {

  CanvasElement canvas;
  int mouseX, mouseY;
  bool mouseDown;

  Input(this.canvas) {
    mouseX = 0;
    mouseY = 0;
    canvas.onMouseMove.listen(onMouseMove);
    canvas.onMouseDown.listen(onMouseDown);
    canvas.onMouseUp.listen(onMouseUp);
  }

  void onMouseMove(MouseEvent event) {
    mouseX = event.page.x - canvas.documentOffset.x;
    mouseY = event.page.y - canvas.documentOffset.y;
  }

  void onMouseDown(MouseEvent event) {
    if (event.button == 0) {
      mouseDown = true;
    }
  }

  void onMouseUp(MouseEvent event) {
    if (event.button == 0) {
      mouseDown = false;
    }
  }

}