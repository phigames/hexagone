part of hexagone;

class Level {

  static const int SIZE = 9;

  List<List<Tile>> tiles;
  Tile hoverTile;
  Tile selectedTile;
  List<Tile> deadTiles;

  Level.test() {
    tiles = new List<List<Tile>>();
    for (int i = 0; i < SIZE; i++) {
      tiles.add(new List<Tile>());
      for (int j = 0; j < SIZE; j++) {
        if (i < SIZE - j) {
          tiles[i].add(new Tile.simple(i, j, true));
        }
      }
    }
    deadTiles = new List<Tile>();
  }

  void swap(Tile tile) {
    int swapX = tile.x;
    int swapY = tile.y;
    tile.x = selectedTile.x;
    tile.y = selectedTile.y;
    tiles[tile.x][tile.y] = tile;
    selectedTile.x = swapX;
    selectedTile.y = swapY;
    tiles[selectedTile.x][selectedTile.y] = selectedTile;
    tile.animatePosition(0);
    selectedTile.animatePosition(0);
    selectedTile.deselect();
    selectedTile = null;
  }

  void remove(Tile tile, int recursion) {
    tile.kill(recursion);
    tiles[tile.x][tile.y] = null;
    deadTiles.add(tile);
    if (tile.x > 0) {
      if (tiles[tile.x - 1][tile.y] != null && tiles[tile.x - 1][tile.y].color == tile.color) {
        remove(tiles[tile.x - 1][tile.y], recursion + 1);
      }
      if (tiles[tile.x - 1][tile.y + 1] != null && tiles[tile.x - 1][tile.y + 1].color == tile.color) {
        remove(tiles[tile.x - 1][tile.y + 1], recursion + 1);
      }
    }
    if (tile.y > 0) {
      if (tiles[tile.x][tile.y - 1] != null && tiles[tile.x][tile.y - 1].color == tile.color) {
        remove(tiles[tile.x][tile.y - 1], recursion + 1);
      }
      if (tiles[tile.x + 1][tile.y - 1] != null && tiles[tile.x + 1][tile.y - 1].color == tile.color) {
        remove(tiles[tile.x + 1][tile.y - 1], recursion + 1);
      }
    }
    if (tile.x + tile.y < SIZE - 1) {
      if (tiles[tile.x + 1][tile.y]!= null && tiles[tile.x + 1][tile.y].color == tile.color) {
        remove(tiles[tile.x + 1][tile.y], recursion + 1);
      }
      if (tiles[tile.x][tile.y + 1] != null && tiles[tile.x][tile.y + 1].color == tile.color) {
        remove(tiles[tile.x][tile.y + 1], recursion + 1);
      }
    }
  }

  void fillGaps(int recursion) {
    bool recur = false;
    for (int j = SIZE - 1; j >= 0; j--) {
      for (int i = SIZE - j - 1; i >= 0; i--) {
        if (tiles[i][j] == null) {
          if (j > 0) {
            if (tiles[i][j - 1] == null) {
              recur = true;
            } else {
              tiles[i][j] = tiles[i][j - 1];
              tiles[i][j - 1] = null;
              tiles[i][j].x = i;
              tiles[i][j].y = j;
              tiles[i][j].animatePosition(recursion);
            }
          } else {
            tiles[i][j] = new Tile.simple(i, j);
          }
        }
      }
    }
    if (recur) {
      fillGaps(recursion + 1);
    }
  }

  void update(num time) {
    for (int i = 0; i < tiles.length; i++) {
      for (int j = 0; j < tiles[i].length; j++) {
        if (tiles[i][j] != null) {
          if (hoverTile != tiles[i][j]) {
            if (tiles[i][j].hexagon.contains(input.mouseX, input.mouseY)) {
              hoverTile = tiles[i][j];
              hoverTile.hover();
            }
          } else {
            if (!hoverTile.hexagon.contains(input.mouseX, input.mouseY)) {
              hoverTile.unhover();
              hoverTile = null;
            }
          }
          tiles[i][j].update(time);
        }
      }
    }
    if (input.mouseDown) {
      if (hoverTile != null) {
        if (selectedTile != null) {
          if (hoverTile == selectedTile) {
            remove(selectedTile, 0);
            fillGaps(1);
            hoverTile = null;
            selectedTile = null;
          } else if (hoverTile.nextTo(selectedTile)) {
            swap(hoverTile);
          }
        } else {
          selectedTile = hoverTile;
          selectedTile.select();
        }
      } else {
        if (selectedTile != null) {
          selectedTile.deselect();
        }
        selectedTile = null;
      }
      input.mouseDown = false;
    }
    for (int i = 0; i < deadTiles.length; i++) {
      deadTiles[i].update(time);
      if (deadTiles[i].decayed) {
        deadTiles.removeAt(i);
        i--;
      }
    }
  }

  void draw() {
    for (int i = 0; i < tiles.length; i++) {
      for (int j = 0; j < tiles[i].length; j++) {
        if (tiles[i][j] != null) {
          tiles[i][j].draw();
        }
      }
    }
    for (int i = 0; i < deadTiles.length; i++) {
      deadTiles[i].draw();
    }
  }

}

class Tile {

  static final List<Color> COLORS_MAIN =           [ new Color(0xF0, 0x40, 0x00), new Color(0xF0, 0xF0, 0x00), new Color(0x00, 0xF0, 0x00),
                                                     new Color(0x00, 0xF0, 0xF0), new Color(0x00, 0x40, 0xF0), new Color(0xF0, 0x00, 0xF0) ];
  static final List<Color> COLORS_MAIN_HIGHLIGHT = [ new Color(0xFF, 0x80, 0x40), new Color(0xFF, 0xFF, 0x40), new Color(0x40, 0xFF, 0x40),
                                                     new Color(0x40, 0xFF, 0xFF), new Color(0x40, 0x80, 0xFF), new Color(0xFF, 0x40, 0xFF) ];
  static final List<Color> COLORS_OUTLINE =        [ new Color(0xB4, 0x30, 0x00), new Color(0xB4, 0xB4, 0x00), new Color(0x00, 0xB4, 0x00),
                                                     new Color(0x00, 0xB4, 0xB4), new Color(0x00, 0x30, 0xB4), new Color(0xB4, 0x00, 0xB4) ];

  int x, y;
  int color;
  Hexagon hexagon;
  bool decayed;

  Tile.simple(this.x, this.y, [bool randomDelay = false]) {
    color = random.nextInt(6);
    num angle = PI / 3;
    num sinAngle = sin(angle);
    num cosAngle = cos(angle);
    hexagon = new Hexagon(x * sinAngle * 58 + y * sinAngle * 29 + sinAngle * 29, y * (29 + cosAngle * 29) + 29, 0, COLORS_MAIN[color], COLORS_OUTLINE[color], 3);
    if (randomDelay) {
      hexagon.animations.add(new HexagonAnimation(hexagon, 300, random.nextDouble() * 500, targetSize: 25));
    } else {
      hexagon.animations.add(new HexagonAnimation(hexagon, 300, 0, targetSize: 25));
    }
  }

  bool nextTo(Tile other) {
    return (other.x == x - 1 && (other.y == y || other.y == y + 1)) ||
           (other.x == x && (other.y == y - 1 || other.y == y + 1)) ||
           (other.x == x + 1 && (other.y == y - 1 || other.y == y));
  }

  void hover() {
    hexagon.animations.add(new HexagonAnimation(hexagon, 100, 0, targetFillColor: COLORS_MAIN_HIGHLIGHT[color]));
  }

  void unhover() {
    hexagon.animations.add(new HexagonAnimation(hexagon, 100, 0, targetFillColor: COLORS_MAIN[color]));
  }

  void select() {
    hexagon.animations.add(new HexagonAnimation(hexagon, 100, 0, targetSize: 20));
  }

  void deselect() {
    hexagon.animations.add(new HexagonAnimation(hexagon, 100, 0, targetSize: 25));
  }

  void kill(int delayFactor) {
    hexagon.animations.add(new HexagonAnimation(hexagon, 150, delayFactor * 75, targetSize: 0, then: () => decayed = true));
  }

  void animatePosition(int delayFactor) {
    num angle = PI / 3;
    num sinAngle = sin(angle);
    num cosAngle = cos(angle);
    hexagon.animations.add(new HexagonAnimation(hexagon, 150, delayFactor * 150, targetPositionX: x * sinAngle * 58 + y * sinAngle * 29 + sinAngle * 29, targetPositionY: y * (29 + cosAngle * 29) + 29));
  }

  void update(num time) {
    hexagon.updateAnimations(time);
  }

  void draw() {
    hexagon.draw(display.bufferContext);
  }

}