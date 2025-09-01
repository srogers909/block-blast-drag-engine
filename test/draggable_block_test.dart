import 'package:flutter_test/flutter_test.dart';
import 'package:drag_engine/src/draggable_block.dart';

void main() {
  group('DraggableBlock', () {
    test('should create a rectangular block with position and size', () {
      const block = DraggableBlock(
        x: 100,
        y: 200,
        width: 50,
        height: 30,
      );

      expect(block.x, 100);
      expect(block.y, 200);
      expect(block.width, 50);
      expect(block.height, 30);
    });

    test('should detect if a point is within block bounds', () {
      const block = DraggableBlock(
        x: 100,
        y: 200,
        width: 50,
        height: 30,
      );

      // Point inside block
      expect(block.containsPoint(125, 215), true);
      
      // Point at edges (inclusive)
      expect(block.containsPoint(100, 200), true); // top-left
      expect(block.containsPoint(150, 230), true); // bottom-right
      
      // Points outside block
      expect(block.containsPoint(99, 215), false);  // left of block
      expect(block.containsPoint(151, 215), false); // right of block
      expect(block.containsPoint(125, 199), false); // above block
      expect(block.containsPoint(125, 231), false); // below block
    });

    test('should update block position', () {
      const originalBlock = DraggableBlock(
        x: 100,
        y: 200,
        width: 50,
        height: 30,
      );

      final updatedBlock = originalBlock.copyWith(x: 150, y: 250);

      expect(updatedBlock.x, 150);
      expect(updatedBlock.y, 250);
      expect(updatedBlock.width, 50); // unchanged
      expect(updatedBlock.height, 30); // unchanged
    });

    test('should center block on a given point', () {
      const block = DraggableBlock(
        x: 100,
        y: 200,
        width: 50,
        height: 30,
      );

      // Center the block on point (200, 300)
      final centeredBlock = block.centerOn(200, 300);

      // Block should be positioned so its center is at (200, 300)
      // Center of block should be at (x + width/2, y + height/2)
      // So x should be 200 - 25 = 175, y should be 300 - 15 = 285
      expect(centeredBlock.x, 175);
      expect(centeredBlock.y, 285);
      expect(centeredBlock.width, 50);
      expect(centeredBlock.height, 30);
    });
  });
}
