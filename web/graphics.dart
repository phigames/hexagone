part of hexagone;

class Display {

  int width, height;
  CanvasElement canvas, buffer;
  CanvasRenderingContext2D canvasContext, bufferContext;

  Display(this.canvas) {
    width = canvas.width;
    height = canvas.height;
    buffer = new CanvasElement(width: width, height: height);
    canvasContext = canvas.context2D;
    bufferContext = buffer.context2D;
  }

  void clear() {
    bufferContext.clearRect(0, 0, width, height);
  }

  void render() {
    canvasContext.clearRect(0, 0, width, height);
    canvasContext.drawImage(buffer, 0, 0);
  }

}

abstract class Shape {

  bool contains(num x, num y);

  void draw(CanvasRenderingContext2D context);

}

class Hexagon extends Shape {

  num positionX, positionY;
  num size;
  List<Point<num>> pathPoints;
  Color fillColor;
  String fillColorString;
  Color strokeColor;
  String strokeColorString;
  num lineWidth;
  List<HexagonAnimation> animations;

  Hexagon(this.positionX, this.positionY, this.size, this.fillColor, this.strokeColor, this.lineWidth) {
    pathPoints = new List<Point<num>>();
    num a = PI / 3;
    num s = sin(a);
    num c = cos(a);
    pathPoints.add(new Point(0, -size));
    pathPoints.add(new Point(s * size, -c * size));
    pathPoints.add(new Point(s * size, c * size));
    pathPoints.add(new Point(0, size));
    pathPoints.add(new Point(-s * size, c * size));
    pathPoints.add(new Point(-s * size, -c * size));
    fillColorString = fillColor.hexString();
    strokeColorString = strokeColor.hexString();
    animations = new List<HexagonAnimation>();
  }

  void updateAnimations(num time) {
    for (int i = 0; i < animations.length; i++) {
      animations[i].update(time);
      if (animations[i].finished) {
        animations.removeAt(i);
        i--;
      }
    }
  }

  void updatePath() {
    num a = PI / 3;
    num s = sin(a);
    num c = cos(a);
    pathPoints[0] = new Point(0, -size);
    pathPoints[1] = new Point(s * size, -c * size);
    pathPoints[2] = new Point(s * size, c * size);
    pathPoints[3] = new Point(0, size);
    pathPoints[4] = new Point(-s * size, c * size);
    pathPoints[5] = new Point(-s * size, -c * size);
  }

  void updateFillColor() {
    fillColorString = fillColor.hexString();
  }

  void updateStrokeColor() {
    strokeColorString = strokeColor.hexString();
  }

  bool contains(num x, num y) {
    num angle = PI / 6;
    num cosAngle = cos(angle);
    num tanAngle = tan(angle);
    if (x < positionX - size * cosAngle || x > positionX + size * cosAngle ||                                                         // W/E boundaries
        y < -tanAngle * x + positionY - size + positionX * tanAngle || y > -tanAngle * x + positionY + size + positionX * tanAngle || // NW/SE boundaries
        y < tanAngle * x + positionY - size - positionX * tanAngle || y > tanAngle * x + positionY + size - positionX * tanAngle) {   // NE/SW boundaries
      return false;
    } else {
      return true;
    }
  }

  void draw(CanvasRenderingContext2D context) {
    context.beginPath();
    context.moveTo(positionX + pathPoints[0].x, positionY + pathPoints[0].y);
    for (int i = 1; i < pathPoints.length; i++) {
      context.lineTo(positionX + pathPoints[i].x, positionY + pathPoints[i].y);
    }
    context.closePath();
    if (fillColor != null) {
      context.fillStyle = fillColorString;
      context.fill();
    }
    if (strokeColor != null) {
      context.strokeStyle = strokeColorString;
      context.lineWidth = lineWidth;
      context.lineJoin = 'round';
      context.stroke();
    }
  }

}

class HexagonAnimation {

  Hexagon hexagon;
  num originalPositionX, targetPositionX;
  num originalPositionY, targetPositionY;
  num originalSize, targetSize;
  Color originalFillColor, targetFillColor;
  Color originalStrokeColor, targetStrokeColor;
  dynamic then;
  num duration;
  num delay;
  num timePassed;
  bool finished;

  HexagonAnimation(this.hexagon, this.duration, this.delay, {this.targetPositionX, this.targetPositionY, this.targetSize, this.targetFillColor, this.targetStrokeColor, this.then()}) {
    if (delay == 0) {
      if (targetSize != null) {
        originalSize = hexagon.size;
      }
      if (targetFillColor != null) {
        originalFillColor = hexagon.fillColor;
      }
      if (targetStrokeColor != null) {
        originalStrokeColor = hexagon.strokeColor;
      }
      if (targetPositionX != null) {
        originalPositionX = hexagon.positionX;
      }
      if (targetPositionY != null) {
        originalPositionY = hexagon.positionY;
      }
    }
    timePassed = 0;
    finished = false;
  }

  void update(num time) {
    if (delay > 0) {
      delay -= time;
      if (delay < 0) {
        delay = 0;
        if (targetSize != null) {
          originalSize = hexagon.size;
        }
        if (targetFillColor != null) {
          originalFillColor = hexagon.fillColor;
        }
        if (targetStrokeColor != null) {
          originalStrokeColor = hexagon.strokeColor;
        }
        if (targetPositionX != null) {
          originalPositionX = hexagon.positionX;
        }
        if (targetPositionY != null) {
          originalPositionY = hexagon.positionY;
        }
      }
    } else {
      timePassed += time;
      if (timePassed > duration) {
        timePassed = duration;
        finished = true;
        if (then != null) {
          then();
        }
      }
      num progress = timePassed / duration;
      if (targetSize != null) {
        hexagon.size = originalSize + (targetSize - originalSize) * progress;
        hexagon.updatePath();
      }
      if (targetFillColor != null) {
        hexagon.fillColor = originalFillColor + (targetFillColor - originalFillColor) * progress;
        hexagon.updateFillColor();
      }
      if (targetStrokeColor != null) {
        hexagon.strokeColor = originalStrokeColor + (targetStrokeColor - originalStrokeColor) * progress;
        hexagon.updateStrokeColor();
      }
      if (targetPositionX != null) {
        hexagon.positionX = originalPositionX + (targetPositionX - originalPositionX) * progress;
      }
      if (targetPositionY != null) {
        hexagon.positionY = originalPositionY + (targetPositionY - originalPositionY) * progress;
      }
    }
  }

}

class Color {

  num red, green, blue;

  Color(this.red, this.green, this.blue) {
    /*if (red < 0) red = 0;
    if (red > 255) red = 255;
    if (green < 0) green = 0;
    if (green > 255) green = 255;
    if (blue < 0) blue = 0;
    if (blue > 255) blue = 255;*/
  }

  operator +(Color other) {
    return new Color(red + other.red, green + other.green, blue + other.blue);
  }

  operator -(Color other) {
    return new Color(red - other.red, green - other.green, blue - other.blue);
  }

  operator *(num factor) {
    return new Color(red * factor, green * factor, blue * factor);
  }

  bool equals(Color other) {
    return (other.red - red).abs() < 0.5 && (other.green - green).abs() < 0.5 && (other.blue - blue).abs() < 0.5;
  }

  String hexString() {
    int rgb = (red.round() << 16) + (green.round() << 8) + blue.round();
    return '#' + (red.round() == 0 ? '00' : red.round() < 16 ? '0' : '') + rgb.toRadixString(16);
  }

  String toString() {
    return 'R: $red  G: $green  B: $blue';
  }

}