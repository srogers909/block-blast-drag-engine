
/// Represents a coordinate in the grid system.
class GridCoordinate {
  final int row;
  final int col;

  const GridCoordinate(this.row, this.col);

  @override
  String toString() => 'GridCoordinate(row: $row, col: $col)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridCoordinate && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

/// Represents a coordinate in screen space.
class ScreenCoordinate {
  final double x;
  final double y;

  const ScreenCoordinate(this.x, this.y);

  @override
  String toString() => 'ScreenCoordinate(x: $x, y: $y)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenCoordinate && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

/// A game grid that manages the 10x10 board for a 1010-style puzzle game.
/// 
/// This class handles:
/// - Screen-size-based grid cell calculation for responsive design
/// - Grid coordinate conversion utilities
/// - Placement validation and collision detection
/// - Game state management with occupied cell tracking
class GameGrid {
  /// The standard grid size for 1010 games.
  static const int _gridSize = 10;

  /// The screen width used for grid calculations.
  final double screenWidth;

  /// The screen height used for grid calculations.
  final double screenHeight;

  /// The size of each grid cell in pixels.
  final double cellSize;

  /// The horizontal offset of the grid from the left edge of the screen.
  final double offsetX;

  /// The vertical offset of the grid from the top edge of the screen.
  final double offsetY;

  /// The grid state tracking which cells are occupied.
  /// True indicates the cell is occupied, false indicates it's empty.
  final List<List<bool>> _occupiedCells;

  /// Creates a new [GameGrid] with the specified screen dimensions.
  /// 
  /// The grid will be:
  /// - 80% of screen width (leaving 10% margin on each side)
  /// - Square cells (cellSize = gridWidth / 10)
  /// - Vertically centered on the screen
  GameGrid({
    required this.screenWidth,
    required this.screenHeight,
  })  : cellSize = (screenWidth * 0.8) / _gridSize,
        offsetX = (screenWidth - (screenWidth * 0.8)) / 2,
        offsetY = (screenHeight - (screenWidth * 0.8)) / 2,
        _occupiedCells = List.generate(
          _gridSize,
          (row) => List.generate(_gridSize, (col) => false),
        );

  /// Returns true if the specified grid cell is occupied.
  /// 
  /// Returns false for out-of-bounds coordinates for safety.
  bool isOccupied(int row, int col) {
    if (row < 0 || row >= _gridSize || col < 0 || col >= _gridSize) {
      return false;
    }
    return _occupiedCells[row][col];
  }

  /// Sets the occupied state of the specified grid cell.
  /// 
  /// Does nothing for out-of-bounds coordinates.
  void setOccupied(int row, int col, bool occupied) {
    if (row < 0 || row >= _gridSize || col < 0 || col >= _gridSize) {
      return;
    }
    _occupiedCells[row][col] = occupied;
  }

  /// Converts screen coordinates to grid coordinates.
  /// 
  /// The returned coordinates may be negative or exceed the grid bounds
  /// if the screen coordinates are outside the grid area.
  GridCoordinate screenToGrid(double screenX, double screenY) {
    final gridX = screenX - offsetX;
    final gridY = screenY - offsetY;
    
    final col = (gridX / cellSize).floor();
    final row = (gridY / cellSize).floor();
    
    return GridCoordinate(row, col);
  }

  /// Converts grid coordinates to screen coordinates.
  /// 
  /// Returns the top-left corner of the specified grid cell.
  ScreenCoordinate gridToScreen(int row, int col) {
    final screenX = offsetX + (col * cellSize);
    final screenY = offsetY + (row * cellSize);
    
    return ScreenCoordinate(screenX, screenY);
  }

  /// Snaps screen coordinates to the nearest grid cell center.
  /// 
  /// If the coordinates are outside the grid bounds, they will be
  /// clamped to the nearest edge cell.
  ScreenCoordinate snapToGrid(double screenX, double screenY) {
    final gridCoord = screenToGrid(screenX, screenY);
    
    // Clamp to grid boundaries
    final clampedRow = gridCoord.row.clamp(0, _gridSize - 1);
    final clampedCol = gridCoord.col.clamp(0, _gridSize - 1);
    
    // Convert back to screen coordinates (cell center)
    final screenCoord = gridToScreen(clampedRow, clampedCol);
    return ScreenCoordinate(
      screenCoord.x + cellSize / 2,
      screenCoord.y + cellSize / 2,
    );
  }

  /// Checks if a block of the specified dimensions can be placed at the given grid position.
  /// 
  /// Returns false if:
  /// - The block would extend beyond the grid boundaries
  /// - Any of the cells the block would occupy are already occupied
  bool canPlaceBlock(int startRow, int startCol, int blockHeight, int blockWidth) {
    // Check bounds
    if (startRow < 0 || startCol < 0) return false;
    if (startRow + blockHeight > _gridSize) return false;
    if (startCol + blockWidth > _gridSize) return false;
    
    // Check for occupied cells
    for (int row = startRow; row < startRow + blockHeight; row++) {
      for (int col = startCol; col < startCol + blockWidth; col++) {
        if (isOccupied(row, col)) {
          return false;
        }
      }
    }
    
    return true;
  }

  /// Places a block at the specified grid position.
  /// 
  /// Returns true if the block was successfully placed, false if the
  /// placement is invalid (see [canPlaceBlock] for validation rules).
  bool placeBlock(int startRow, int startCol, int blockHeight, int blockWidth) {
    if (!canPlaceBlock(startRow, startCol, blockHeight, blockWidth)) {
      return false;
    }
    
    // Mark all cells as occupied
    for (int row = startRow; row < startRow + blockHeight; row++) {
      for (int col = startCol; col < startCol + blockWidth; col++) {
        setOccupied(row, col, true);
      }
    }
    
    return true;
  }

  /// Removes a block from the specified grid position.
  /// 
  /// Clears the occupied state for all cells that the block covers.
  void removeBlock(int startRow, int startCol, int blockHeight, int blockWidth) {
    for (int row = startRow; row < startRow + blockHeight; row++) {
      for (int col = startCol; col < startCol + blockWidth; col++) {
        setOccupied(row, col, false);
      }
    }
  }

  /// Clears the entire grid, setting all cells to unoccupied.
  void clearGrid() {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        _occupiedCells[row][col] = false;
      }
    }
  }

  /// Returns a copy of the current grid state.
  /// 
  /// Useful for debugging or creating save states.
  List<List<bool>> getGridState() {
    return _occupiedCells.map((row) => List<bool>.from(row)).toList();
  }

  /// Returns the total width of the grid in pixels.
  double get gridWidth => cellSize * _gridSize;

  /// Returns the total height of the grid in pixels.
  double get gridHeight => cellSize * _gridSize;

  /// Returns the grid size (always 10 for 1010 games).
  int get gridSize => _gridSize;

  @override
  String toString() {
    return 'GameGrid(screenSize: ${screenWidth}x$screenHeight, '
           'cellSize: $cellSize, offset: ($offsetX, $offsetY))';
  }
}
