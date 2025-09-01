import 'package:flutter_test/flutter_test.dart';
import 'package:drag_engine/drag_engine.dart';

void main() {
  group('Enhanced DragController', () {
    late DragController controller;
    late DraggableBlock testBlock;

    setUp(() {
      controller = DragController();
      testBlock = const DraggableBlock(
        x: 100,
        y: 200,
        width: 50,
        height: 30,
      );
    });

    test('should detect touch on a draggable block', () {
      controller.addBlock(testBlock);

      // Touch inside the block
      final hitBlock = controller.getBlockAtPoint(125, 215);
      expect(hitBlock, equals(testBlock));

      // Touch outside the block
      final missedBlock = controller.getBlockAtPoint(50, 50);
      expect(missedBlock, isNull);
    });

    test('should start drag and center block on touch point', () {
      controller.addBlock(testBlock);

      // Start drag at a point within the block
      controller.startDragAt(125, 215);

      expect(controller.isDragging, true);
      expect(controller.draggedBlock, isNotNull);
      
      // Block should be centered on the touch point
      final draggedBlock = controller.draggedBlock!;
      expect(draggedBlock.x, 125 - 25); // 125 - width/2
      expect(draggedBlock.y, 215 - 15); // 215 - height/2
    });

    test('should update dragged block position to follow touch movement', () {
      controller.addBlock(testBlock);
      controller.startDragAt(125, 215);

      // Move to a new position
      controller.updateDragPosition(const Offset(200, 300));

      final draggedBlock = controller.draggedBlock!;
      expect(draggedBlock.x, 200 - 25); // centered on new position
      expect(draggedBlock.y, 300 - 15);
    });

    test('should return null when touch is outside all blocks', () {
      controller.addBlock(testBlock);

      // Try to start drag outside the block
      controller.startDragAt(50, 50);

      expect(controller.isDragging, false);
      expect(controller.draggedBlock, isNull);
    });

    test('should end drag and update block position in collection', () {
      controller.addBlock(testBlock);
      controller.startDragAt(125, 215);
      controller.updateDragPosition(const Offset(200, 300));

      // End the drag
      controller.endDrag();

      expect(controller.isDragging, false);
      expect(controller.draggedBlock, isNull);
      
      // The block in the collection should be updated to the new position
      final updatedBlock = controller.getBlockAtPoint(200, 300);
      expect(updatedBlock, isNotNull);
      expect(updatedBlock!.x, 200 - 25);
      expect(updatedBlock.y, 300 - 15);
    });

    test('should handle multiple blocks and drag the correct one', () {
      const block1 = DraggableBlock(x: 50, y: 50, width: 30, height: 30);
      const block2 = DraggableBlock(x: 150, y: 150, width: 40, height: 40);

      controller.addBlock(block1);
      controller.addBlock(block2);

      // Start drag on block2
      controller.startDragAt(170, 170);

      expect(controller.isDragging, true);
      expect(controller.draggedBlock!.width, 40); // Should be block2
      
      // block1 should not be affected
      final block1Position = controller.getBlockAtPoint(65, 65);
      expect(block1Position, equals(block1));
    });
  });
}
