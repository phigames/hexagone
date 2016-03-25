library hexagone;

import 'dart:html';
import 'dart:math';

part 'graphics.dart';
part 'input.dart';
part 'level.dart';

Display display;
Input input;
Random random;
Level level;
num timePassed;

void main() {
  CanvasElement canvas = querySelector('#canvas');
  display = new Display(canvas);
  input = new Input(canvas);
  random = new Random();
  level = new Level.test();
  requestFrame();
}

void frame(num time) {
  if (timePassed == null) {
    timePassed = time;
  } else {
    display.clear();
    level.update(time - timePassed);
    level.draw();
    display.render();
    timePassed = time;
  }
  requestFrame();
}

void requestFrame() {
  window.animationFrame.then(frame);
}