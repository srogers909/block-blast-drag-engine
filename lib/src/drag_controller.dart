import 'package:flutter/material.dart';
import 'draggable_block.dart';
import 'drop_shadow.dart';
import 'game_grid.dart';

/// A controller that manages drag and drop operations.
/// 
/// This class provides the core functionality for handling drag gestures,
/// managing drag state, and coordinating between draggable items and drop targets.
class DragController {
  /// Whether a drag operation is currently in progress.
  bool _isDragging = false;

  /// The current position of the dragged item.
  Offset? _currentPosition;

  /// Collection of all draggable blocks.
  final List<DraggableBlock> _blocks = [];

  /// The block currently being dragged, if any.
  DraggableBlock? _draggedBlock;

  /// The original index of the dragged block in the collection.
  int? _draggedBlockIndex;

  /// The drop shadow for the currently dragged block, if any.
  DropShadow? _dropShadow;

  /// The game grid for snapping and placement validation.
  GameGrid? _gameGrid;

  /// Creates a new [DragController].
  DragController();

  /// Returns true if a drag operation is currently in progress.
  bool get isDragging => _isDragging;

  /// Returns the current drag position, or null if not dragging.
  Offset? get currentPosition => _currentPosition;

  /// Returns the block currently being dragged, or null if not dragging.
  DraggableBlock? get draggedBlock => _draggedBlock;

  /// Returns the drop shadow for the currently dragged block, or null if not dragging.
  DropShadow? get dropShadow => _dropShadow;

  /// Returns the current game grid, or null if not set.
  GameGrid? get gameGrid => _gameGrid;

  /// Sets the game grid for grid-based operations.
  void setGameGrid(GameGrid gameGrid) {
    _gameGrid = gameGrid;
  }

  /// Checks if the currently dragged block can be placed at its current position.
  /// 
  /// Returns true if a block is being dragged, there's a game grid, and the
  /// block can be validly placed at the grid-snapped position.
  bool canPlaceCurrentBlock() {
    if (_draggedBlock == null || _gameGrid == null) return false;

    // Get the grid-snapped position for the block center
    final snappedPos = _gameGrid!.snapToGrid(
      _draggedBlock!.x + _draggedBlock!.width / 2,
      _draggedBlock!.y + _draggedBlock!.height / 2,
    );

    // Convert to grid coordinates for the top-left corner of the block
    final topLeftX = snappedPos.x - _draggedBlock!.width / 2;
    final topLeftY = snappedPos.y - _draggedBlock!.height / 2;
    final gridCoord = _gameGrid!.screenToGrid(topLeftX, topLeftY);

    // Calculate block size in grid cells (assuming each block cell = grid cell)
    final blockWidthInCells = (_draggedBlock!.width / _gameGrid!.cellSize).round();
    final blockHeightInCells = (_draggedBlock!.height / _gameGrid!.cellSize).round();

    return _gameGrid!.canPlaceBlock(
      gridCoord.row,
      gridCoord.col,
      blockHeightInCells,
      blockWidthInCells,
    );
  }

  /// Attempts to place the currently dragged block on the grid.
  /// 
  /// Returns true if the block was successfully placed, false otherwise.
  /// The block will be snapped to the grid and marked as placed in the game state.
  bool placeCurrentBlockOnGrid() {
    if (!canPlaceCurrentBlock()) return false;

    final snappedPos = _gameGrid!.snapToGrid(
      _draggedBlock!.x + _draggedBlock!.width / 2,
      _draggedBlock!.y + _draggedBlock!.height / 2,
    );

    // Convert to grid coordinates for the top-left corner of the block
    final topLeftX = snappedPos.x - _draggedBlock!.width / 2;
    final topLeftY = snappedPos.y - _draggedBlock!.height / 2;
    final gridCoord = _gameGrid!.screenToGrid(topLeftX, topLeftY);

    // Calculate block size in grid cells
    final blockWidthInCells = (_draggedBlock!.width / _gameGrid!.cellSize).round();
    final blockHeightInCells = (_draggedBlock!.height / _gameGrid!.cellSize).round();

    // Place the block on the grid
    final placed = _gameGrid!.placeBlock(
      gridCoord.row,
      gridCoord.col,
      blockHeightInCells,
      blockWidthInCells,
    );

    if (placed) {
      // Update the block's position to the snapped position
      _draggedBlock = _draggedBlock!.copyWith(
        x: topLeftX,
        y: topLeftY,
      );
      
      // Update the block in the collection
      if (_draggedBlockIndex != null) {
        _blocks[_draggedBlockIndex!] = _draggedBlock!;
      }
    }

    return placed;
  }

  /// Adds a block to the collection of draggable blocks.
  void addBlock(DraggableBlock block) {
    _blocks.add(block);
  }

  /// Removes a block from the collection of draggable blocks.
  void removeBlock(DraggableBlock block) {
    _blocks.remove(block);
  }

  /// Returns the block at the specified point, or null if no block is found.
  DraggableBlock? getBlockAtPoint(double x, double y) {
    // Search from the end of the list (top-most blocks first)
    for (int i = _blocks.length - 1; i >= 0; i--) {
      if (_blocks[i].containsPoint(x, y)) {
        return _blocks[i];
      }
    }
    return null;
  }

  /// Starts a drag operation at the specified position.
  /// 
  /// If a block is found at the position, it will be centered on the touch point
  /// and dragging will begin. If no block is found, no drag operation starts.
  void startDragAt(double x, double y) {
    final block = getBlockAtPoint(x, y);
    if (block != null) {
      _isDragging = true;
      _currentPosition = Offset(x, y);
      
      // Find the index of the block being dragged
      _draggedBlockIndex = _blocks.indexOf(block);
      
      // Center the block on the touch point
      _draggedBlock = block.centerOn(x, y);
      
      // Calculate and create the drop shadow
      _updateDropShadow();
    }
  }

  /// Starts a drag operation at the specified position.
  void startDrag(Offset position) {
    startDragAt(position.dx, position.dy);
  }

  /// Updates the drag position during an active drag operation.
  void updateDragPosition(Offset position) {
    if (_isDragging && _draggedBlock != null) {
      _currentPosition = position;
      _draggedBlock = _draggedBlock!.centerOn(position.dx, position.dy);
      
      // Update the drop shadow position
      _updateDropShadow();
    }
  }

  /// Ends the current drag operation.
  /// 
  /// The dragged block's final position will be updated in the collection.
  void endDrag() {
    if (_isDragging && _draggedBlock != null && _draggedBlockIndex != null) {
      // Update the block's position in the collection
      _blocks[_draggedBlockIndex!] = _draggedBlock!;
    }
    
    _isDragging = false;
    _currentPosition = null;
    _draggedBlock = null;
    _draggedBlockIndex = null;
    _dropShadow = null;
  }

  /// Cancels the current drag operation.
  /// 
  /// The dragged block will return to its original position.
  void cancelDrag() {
    _isDragging = false;
    _currentPosition = null;
    _draggedBlock = null;
    _draggedBlockIndex = null;
    _dropShadow = null;
  }

  /// Returns a copy of all blocks in the collection.
  List<DraggableBlock> get blocks => List.unmodifiable(_blocks);

  /// Clears all blocks from the collection.
  void clearBlocks() {
    _blocks.clear();
  }

  /// Updates the drop shadow position based on the current dragged block.
  void _updateDropShadow() {
    if (_draggedBlock != null) {
      double shadowX = _draggedBlock!.x;
      double shadowY = _draggedBlock!.y;
      
      // If we have a game grid, snap the shadow to the grid
      if (_gameGrid != null) {
        final snappedPos = _gameGrid!.snapToGrid(
          _draggedBlock!.x + _draggedBlock!.width / 2,
          _draggedBlock!.y + _draggedBlock!.height / 2,
        );
        shadowX = snappedPos.x - _draggedBlock!.width / 2;
        shadowY = snappedPos.y - _draggedBlock!.height / 2;
      }
      
      _dropShadow = DropShadow.above(
        blockX: shadowX,
        blockY: shadowY,
        blockWidth: _draggedBlock!.width,
        blockHeight: _draggedBlock!.height,
      );
    }
  }
}
