import 'package:flutter/material.dart';

/// A controller that manages drag and drop operations.
/// 
/// This class provides the core functionality for handling drag gestures,
/// managing drag state, and coordinating between draggable items and drop targets.
class DragController {
  /// Whether a drag operation is currently in progress.
  bool _isDragging = false;

  /// The current position of the dragged item.
  Offset? _currentPosition;

  /// Creates a new [DragController].
  DragController();

  /// Returns true if a drag operation is currently in progress.
  bool get isDragging => _isDragging;

  /// Returns the current drag position, or null if not dragging.
  Offset? get currentPosition => _currentPosition;

  /// Starts a drag operation at the specified position.
  void startDrag(Offset position) {
    _isDragging = true;
    _currentPosition = position;
  }

  /// Updates the drag position during an active drag operation.
  void updateDragPosition(Offset position) {
    if (_isDragging) {
      _currentPosition = position;
    }
  }

  /// Ends the current drag operation.
  void endDrag() {
    _isDragging = false;
    _currentPosition = null;
  }

  /// Cancels the current drag operation.
  void cancelDrag() {
    _isDragging = false;
    _currentPosition = null;
  }
}
