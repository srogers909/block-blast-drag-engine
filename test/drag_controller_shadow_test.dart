import 'package:flutter_test/flutter_test.dart';
import 'package:drag_engine/drag_engine.dart';

void main() {
  group('DragController Shadow Integration', () {
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

    test('should have no drop shadow when not dragging', () {
      controller.addBlock(testBlock);
      
      expect(controller.dropShadow, isNull);
    });

    test('should create drop shadow when drag starts', () {
      controller.addBlock(testBlock);
      
      controller.startDragAt(125, 215);
      
      expect(controller.dropShadow, isNotNull);
      expect(controller.dropShadow!.width, 50);
      expect(controller.dropShadow!.height, 30);
    });

    test('should position drop shadow 50px above small block', () {
      controller.addBlock(testBlock);
      
      // Start drag at center of block
      controller.startDragAt(125, 215);
      
      final shadow = controller.dropShadow!;
      final draggedBlock = controller.draggedBlock!;
      
      // Shadow should be positioned above the dragged block
      // For a 30px tall block: shadow y = block.y - 50 - 30 = block.y - 80
      expect(shadow.y, draggedBlock.y - 80);
      expect(shadow.x, draggedBlock.x);
    });

    test('should increase shadow offset for tall blocks', () {
      // Create a tall block
      const tallBlock = DraggableBlock(x: 100, y: 200, width: 40, height: 80);
      controller.addBlock(tallBlock);
      
      controller.startDragAt(120, 240);
      
      final shadow = controller.dropShadow!;
      final draggedBlock = controller.draggedBlock!;
      
      // For an 80px tall block: offset = max(50, 80 + 10) = 90
      // Shadow y = block.y - 90 - 80 = block.y - 170
      expect(shadow.y, draggedBlock.y - 170);
    });

    test('should update drop shadow position when block moves', () {
      controller.addBlock(testBlock);
      controller.startDragAt(125, 215);
      
      final initialShadow = controller.dropShadow!;
      final initialShadowX = initialShadow.x;
      
      // Move the block
      controller.updateDragPosition(const Offset(200, 300));
      
      final updatedShadow = controller.dropShadow!;
      
      // Shadow should have moved with the block
      expect(updatedShadow.x, isNot(initialShadowX));
      expect(updatedShadow.x, 200 - 25); // Block centered on 200, so x = 200 - width/2
    });

    test('should ensure shadow never overlaps with dragged block', () {
      // Test with various block heights
      for (final height in [20, 40, 60, 80, 100]) {
        final block = DraggableBlock(
          x: 100,
          y: 300,
          width: 30,
          height: height.toDouble(),
        );
        
        controller.clearBlocks();
        controller.addBlock(block);
        controller.startDragAt(115, 300 + height / 2);
        
        final shadow = controller.dropShadow!;
        final draggedBlock = controller.draggedBlock!;
        
        // Shadow bottom should be above block top
        final shadowBottom = shadow.y + shadow.height;
        final blockTop = draggedBlock.y;
        
        expect(shadowBottom, lessThan(blockTop),
          reason: 'Shadow should not overlap with block (height: $height)');
      }
    });

    test('should remove drop shadow when drag ends', () {
      controller.addBlock(testBlock);
      controller.startDragAt(125, 215);
      
      expect(controller.dropShadow, isNotNull);
      
      controller.endDrag();
      
      expect(controller.dropShadow, isNull);
    });

    test('should remove drop shadow when drag is cancelled', () {
      controller.addBlock(testBlock);
      controller.startDragAt(125, 215);
      
      expect(controller.dropShadow, isNotNull);
      
      controller.cancelDrag();
      
      expect(controller.dropShadow, isNull);
    });

    test('should maintain shadow-block relationship throughout drag', () {
      controller.addBlock(testBlock);
      controller.startDragAt(125, 215);
      
      // Test multiple position updates
      final positions = [
        const Offset(150, 250),
        const Offset(200, 300),
        const Offset(250, 350),
      ];
      
      for (final position in positions) {
        controller.updateDragPosition(position);
        
        final shadow = controller.dropShadow!;
        final draggedBlock = controller.draggedBlock!;
        
        // Shadow should always be same size as block
        expect(shadow.width, draggedBlock.width);
        expect(shadow.height, draggedBlock.height);
        
        // Shadow should always be positioned above block
        expect(shadow.y + shadow.height, lessThan(draggedBlock.y));
        
        // Shadow should be horizontally aligned with block
        expect(shadow.x, draggedBlock.x);
      }
    });

    test('should handle multiple blocks with correct shadow for dragged block', () {
      const block1 = DraggableBlock(x: 50, y: 50, width: 30, height: 20);
      const block2 = DraggableBlock(x: 150, y: 150, width: 40, height: 60);
      
      controller.addBlock(block1);
      controller.addBlock(block2);
      
      // Drag the taller block (block2)
      controller.startDragAt(170, 180);
      
      final shadow = controller.dropShadow!;
      
      // Shadow should match block2's dimensions, not block1's
      expect(shadow.width, 40);
      expect(shadow.height, 60);
      
      // Shadow offset should be appropriate for the tall block
      // offset = max(50, 60 + 10) = 70
      final draggedBlock = controller.draggedBlock!;
      expect(shadow.y, draggedBlock.y - 70 - 60);
    });
  });
}
