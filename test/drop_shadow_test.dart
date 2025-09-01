import 'package:flutter_test/flutter_test.dart';
import 'package:drag_engine/src/drop_shadow.dart';

void main() {
  group('DropShadow', () {
    test('should create a drop shadow with specified position and size', () {
      const shadow = DropShadow(
        x: 100,
        y: 200,
        width: 50,
        height: 30,
      );

      expect(shadow.x, 100);
      expect(shadow.y, 200);
      expect(shadow.width, 50);
      expect(shadow.height, 30);
    });

    test('should create drop shadow 50px above small block using factory', () {
      // Small block: 30x20 at position (100, 200)
      final shadow = DropShadow.above(
        blockX: 100,
        blockY: 200,
        blockWidth: 30,
        blockHeight: 20,
      );

      // Shadow should be same size as block
      expect(shadow.width, 30);
      expect(shadow.height, 20);
      
      // Shadow should be positioned above block
      expect(shadow.x, 100); // Same x position as block
      
      // For a 20px tall block with 50px min offset:
      // Shadow y = blockY - offset - blockHeight
      // Shadow y = 200 - 50 - 20 = 130
      expect(shadow.y, 130);
    });

    test('should increase offset for tall blocks to prevent overlap', () {
      // Tall block: 30x80 at position (100, 200)
      final shadow = DropShadow.above(
        blockX: 100,
        blockY: 200,
        blockWidth: 30,
        blockHeight: 80,
      );

      // Shadow should be same size as block
      expect(shadow.width, 30);
      expect(shadow.height, 80);
      expect(shadow.x, 100);
      
      // For an 80px tall block:
      // Calculated offset = max(50, 80 + 10) = 90
      // Shadow y = 200 - 90 - 80 = 30
      expect(shadow.y, 30);
    });

    test('should use custom minimum offset when provided', () {
      // Block: 30x20 at position (100, 200) with 75px min offset
      final shadow = DropShadow.above(
        blockX: 100,
        blockY: 200,
        blockWidth: 30,
        blockHeight: 20,
        minOffset: 75,
      );

      // Shadow y = 200 - 75 - 20 = 105
      expect(shadow.y, 105);
    });

    test('should use custom buffer space when provided', () {
      // Tall block: 30x60 at position (100, 200) with 20px buffer
      final shadow = DropShadow.above(
        blockX: 100,
        blockY: 200,
        blockWidth: 30,
        blockHeight: 60,
        bufferSpace: 20,
      );

      // Calculated offset = max(50, 60 + 20) = 80
      // Shadow y = 200 - 80 - 60 = 60
      expect(shadow.y, 60);
    });

    test('should ensure shadow never overlaps with block', () {
      // Test various block sizes to ensure no overlap
      for (final blockHeight in [10, 30, 50, 80, 120]) {
        final shadow = DropShadow.above(
          blockX: 100,
          blockY: 200,
          blockWidth: 30,
          blockHeight: blockHeight.toDouble(),
        );

        // Shadow bottom should be above block top
        final shadowBottom = shadow.y + shadow.height;
        const blockTop = 200;
        
        expect(shadowBottom, lessThan(blockTop),
          reason: 'Shadow should not overlap with block (height: $blockHeight)');
      }
    });

    test('should support equality comparison', () {
      const shadow1 = DropShadow(x: 100, y: 200, width: 50, height: 30);
      const shadow2 = DropShadow(x: 100, y: 200, width: 50, height: 30);
      const shadow3 = DropShadow(x: 150, y: 200, width: 50, height: 30);

      expect(shadow1, equals(shadow2));
      expect(shadow1, isNot(equals(shadow3)));
    });

    test('should provide meaningful string representation', () {
      const shadow = DropShadow(x: 100, y: 200, width: 50, height: 30);
      
      expect(shadow.toString(), 
        'DropShadow(x: 100.0, y: 200.0, width: 50.0, height: 30.0)');
    });
  });
}
