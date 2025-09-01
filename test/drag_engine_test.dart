import 'package:flutter_test/flutter_test.dart';
import 'package:drag_engine/drag_engine.dart';

void main() {
  group('DragController', () {
    late DragController controller;

    setUp(() {
      controller = DragController();
    });

    test('should initialize with no active drag', () {
      expect(controller.isDragging, false);
      expect(controller.currentPosition, null);
    });

    test('should start drag operation when block exists at position', () {
      const testPosition = Offset(100, 200);
      const testBlock = DraggableBlock(x: 50, y: 150, width: 100, height: 100);
      
      controller.addBlock(testBlock);
      controller.startDrag(testPosition);
      
      expect(controller.isDragging, true);
      expect(controller.currentPosition, testPosition);
    });

    test('should update drag position during active drag', () {
      const startPosition = Offset(100, 200);
      const newPosition = Offset(150, 250);
      const testBlock = DraggableBlock(x: 50, y: 150, width: 100, height: 100);
      
      controller.addBlock(testBlock);
      controller.startDrag(startPosition);
      controller.updateDragPosition(newPosition);
      
      expect(controller.isDragging, true);
      expect(controller.currentPosition, newPosition);
    });

    test('should not update position when not dragging', () {
      const testPosition = Offset(100, 200);
      
      controller.updateDragPosition(testPosition);
      
      expect(controller.isDragging, false);
      expect(controller.currentPosition, null);
    });

    test('should end drag operation and reset state', () {
      const testPosition = Offset(100, 200);
      
      controller.startDrag(testPosition);
      controller.endDrag();
      
      expect(controller.isDragging, false);
      expect(controller.currentPosition, null);
    });

    test('should cancel drag operation and reset state', () {
      const testPosition = Offset(100, 200);
      
      controller.startDrag(testPosition);
      controller.cancelDrag();
      
      expect(controller.isDragging, false);
      expect(controller.currentPosition, null);
    });
  });

  group('Package', () {
    test('should export version constant', () {
      expect(version, '0.1.0');
    });
  });
}
