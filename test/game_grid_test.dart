import 'package:test/test.dart';
import 'package:drag_engine/src/game_grid.dart';

void main() {
  group('GameGrid', () {
    late GameGrid grid;
    const double screenWidth = 400.0;
    const double screenHeight = 800.0;

    setUp(() {
      grid = GameGrid(screenWidth: screenWidth, screenHeight: screenHeight);
    });

    group('Construction', () {
      test('creates with correct dimensions', () {
        expect(grid.screenWidth, equals(screenWidth));
        expect(grid.screenHeight, equals(screenHeight));
        expect(grid.gridSize, equals(10));
      });

      test('calculates correct cell size', () {
        // Grid width should be 80% of screen width
        const expectedGridWidth = screenWidth * 0.8;
        const expectedCellSize = expectedGridWidth / 10;
        expect(grid.cellSize, equals(expectedCellSize));
      });

      test('initializes empty grid state', () {
        for (int row = 0; row < grid.gridSize; row++) {
          for (int col = 0; col < grid.gridSize; col++) {
            expect(grid.isOccupied(row, col), isFalse);
          }
        }
      });

      test('calculates correct grid offsets', () {
        // Grid should be centered horizontally
        const expectedGridWidth = screenWidth * 0.8;
        const expectedOffsetX = (screenWidth - expectedGridWidth) / 2;
        expect(grid.offsetX, equals(expectedOffsetX));
        
        // Grid should be vertically centered
        const expectedGridHeight = expectedGridWidth; // Square grid
        const expectedOffsetY = (screenHeight - expectedGridHeight) / 2;
        expect(grid.offsetY, equals(expectedOffsetY));
      });
    });

    group('Coordinate Conversion', () {
      test('converts screen coordinates to grid coordinates', () {
        // Test center of first cell (0,0)
        final centerX = grid.offsetX + grid.cellSize / 2;
        final centerY = grid.offsetY + grid.cellSize / 2;
        final gridCoord = grid.screenToGrid(centerX, centerY);
        
        expect(gridCoord.row, equals(0));
        expect(gridCoord.col, equals(0));
      });

      test('converts grid coordinates to screen coordinates', () {
        // Test grid position (0,0)
        final screenCoord = grid.gridToScreen(0, 0);
        
        expect(screenCoord.x, equals(grid.offsetX));
        expect(screenCoord.y, equals(grid.offsetY));
      });

      test('round-trip coordinate conversion is accurate', () {
        // Test multiple positions
        const testPositions = [
          (0, 0),
          (5, 5),
          (9, 9),
          (2, 7),
        ];

        for (final (row, col) in testPositions) {
          final screenCoord = grid.gridToScreen(row, col);
          final gridCoord = grid.screenToGrid(screenCoord.x, screenCoord.y);
          
          expect(gridCoord.row, equals(row));
          expect(gridCoord.col, equals(col));
        }
      });

      test('handles out-of-bounds screen coordinates', () {
        // Test negative coordinates
        final coord1 = grid.screenToGrid(-10, -10);
        expect(coord1.row, lessThan(0));
        expect(coord1.col, lessThan(0));

        // Test coordinates beyond grid
        final coord2 = grid.screenToGrid(screenWidth + 10, screenHeight + 10);
        expect(coord2.row, greaterThan(9));
        expect(coord2.col, greaterThan(9));
      });
    });

    group('Grid State Management', () {
      test('marks cells as occupied', () {
        expect(grid.isOccupied(0, 0), isFalse);
        
        grid.setOccupied(0, 0, true);
        expect(grid.isOccupied(0, 0), isTrue);
      });

      test('clears occupied cells', () {
        grid.setOccupied(5, 5, true);
        expect(grid.isOccupied(5, 5), isTrue);
        
        grid.setOccupied(5, 5, false);
        expect(grid.isOccupied(5, 5), isFalse);
      });

      test('handles out-of-bounds grid coordinates safely', () {
        // Should not throw exceptions
        expect(() => grid.isOccupied(-1, 0), returnsNormally);
        expect(() => grid.isOccupied(0, -1), returnsNormally);
        expect(() => grid.isOccupied(10, 0), returnsNormally);
        expect(() => grid.isOccupied(0, 10), returnsNormally);
        
        // Out of bounds should return false for safety
        expect(grid.isOccupied(-1, 0), isFalse);
        expect(grid.isOccupied(0, -1), isFalse);
        expect(grid.isOccupied(10, 0), isFalse);
        expect(grid.isOccupied(0, 10), isFalse);
      });
    });

    group('Placement Validation', () {
      test('validates placement of 1x1 block', () {
        // Empty grid should allow placement anywhere
        expect(grid.canPlaceBlock(0, 0, 1, 1), isTrue);
        expect(grid.canPlaceBlock(9, 9, 1, 1), isTrue);
        expect(grid.canPlaceBlock(5, 5, 1, 1), isTrue);
      });

      test('validates placement of larger blocks', () {
        // 2x2 block
        expect(grid.canPlaceBlock(0, 0, 2, 2), isTrue);
        expect(grid.canPlaceBlock(8, 8, 2, 2), isTrue);
        expect(grid.canPlaceBlock(9, 9, 2, 2), isFalse); // Would extend beyond grid
        
        // 3x1 block (3 rows, 1 column)
        expect(grid.canPlaceBlock(0, 0, 3, 1), isTrue);
        expect(grid.canPlaceBlock(8, 0, 3, 1), isFalse); // Would extend beyond grid (rows 8,9,10)
      });

      test('prevents placement on occupied cells', () {
        // Occupy center cell
        grid.setOccupied(5, 5, true);
        
        // 1x1 block should not be placeable on occupied cell
        expect(grid.canPlaceBlock(5, 5, 1, 1), isFalse);
        
        // 2x2 block overlapping with occupied cell should not be placeable
        expect(grid.canPlaceBlock(4, 4, 2, 2), isFalse);
        expect(grid.canPlaceBlock(5, 4, 2, 2), isFalse);
        expect(grid.canPlaceBlock(4, 5, 2, 2), isFalse);
        expect(grid.canPlaceBlock(5, 5, 2, 2), isFalse);
        
        // Non-overlapping blocks should still be placeable
        expect(grid.canPlaceBlock(0, 0, 2, 2), isTrue);
        expect(grid.canPlaceBlock(7, 7, 2, 2), isTrue);
      });

      test('validates out-of-bounds placement', () {
        // Negative positions
        expect(grid.canPlaceBlock(-1, 0, 1, 1), isFalse);
        expect(grid.canPlaceBlock(0, -1, 1, 1), isFalse);
        
        // Beyond grid boundaries
        expect(grid.canPlaceBlock(10, 0, 1, 1), isFalse);
        expect(grid.canPlaceBlock(0, 10, 1, 1), isFalse);
        
        // Partially beyond boundaries
        expect(grid.canPlaceBlock(9, 0, 2, 1), isFalse);
        expect(grid.canPlaceBlock(0, 9, 1, 2), isFalse);
      });
    });

    group('Block Placement and Removal', () {
      test('places block and updates grid state', () {
        expect(grid.canPlaceBlock(2, 3, 2, 2), isTrue);
        
        final success = grid.placeBlock(2, 3, 2, 2);
        expect(success, isTrue);
        
        // Check all cells are occupied
        expect(grid.isOccupied(2, 3), isTrue);
        expect(grid.isOccupied(2, 4), isTrue);
        expect(grid.isOccupied(3, 3), isTrue);
        expect(grid.isOccupied(3, 4), isTrue);
        
        // Check adjacent cells are not affected
        expect(grid.isOccupied(1, 3), isFalse);
        expect(grid.isOccupied(2, 2), isFalse);
        expect(grid.isOccupied(4, 3), isFalse);
        expect(grid.isOccupied(2, 5), isFalse);
      });

      test('fails to place block on invalid position', () {
        // First occupy a cell
        grid.setOccupied(1, 1, true);
        
        // Try to place overlapping block
        final success = grid.placeBlock(0, 0, 2, 2);
        expect(success, isFalse);
        
        // Grid state should remain unchanged
        expect(grid.isOccupied(0, 0), isFalse);
        expect(grid.isOccupied(0, 1), isFalse);
        expect(grid.isOccupied(1, 0), isFalse);
        expect(grid.isOccupied(1, 1), isTrue); // Originally occupied cell unchanged
      });

      test('removes block and clears grid state', () {
        // Place a block first
        grid.placeBlock(4, 4, 3, 2);
        
        // Verify placement
        for (int row = 4; row < 7; row++) {
          for (int col = 4; col < 6; col++) {
            expect(grid.isOccupied(row, col), isTrue);
          }
        }
        
        // Remove the block
        grid.removeBlock(4, 4, 3, 2);
        
        // Verify removal
        for (int row = 4; row < 7; row++) {
          for (int col = 4; col < 6; col++) {
            expect(grid.isOccupied(row, col), isFalse);
          }
        }
      });

      test('clears entire grid', () {
        // Place several blocks
        grid.placeBlock(0, 0, 2, 2);
        grid.placeBlock(5, 5, 1, 1);
        grid.placeBlock(8, 8, 2, 2);
        
        // Verify some cells are occupied
        expect(grid.isOccupied(0, 0), isTrue);
        expect(grid.isOccupied(5, 5), isTrue);
        expect(grid.isOccupied(8, 8), isTrue);
        
        // Clear grid
        grid.clearGrid();
        
        // Verify all cells are empty
        for (int row = 0; row < grid.gridSize; row++) {
          for (int col = 0; col < grid.gridSize; col++) {
            expect(grid.isOccupied(row, col), isFalse);
          }
        }
      });
    });

    group('Grid Snapping', () {
      test('snaps screen coordinates to nearest grid position', () {
        // Test coordinate that should snap to cell (1, 2)
        final testX = grid.offsetX + grid.cellSize * 2.7; // Between cells 2 and 3, floors to 2
        final testY = grid.offsetY + grid.cellSize * 1.3; // Between cells 1 and 2, floors to 1
        final snapped = grid.snapToGrid(testX, testY);
        
        // The coordinate floors to grid position (1, 2), then snaps to center
        final expectedScreen = grid.gridToScreen(1, 2);
        final expectedCenterX = expectedScreen.x + grid.cellSize / 2;
        final expectedCenterY = expectedScreen.y + grid.cellSize / 2;
        expect(snapped.x, closeTo(expectedCenterX, 0.1));
        expect(snapped.y, closeTo(expectedCenterY, 0.1));
      });

      test('snaps to grid boundaries when outside grid', () {
        // Test coordinates outside grid
        final snapped1 = grid.snapToGrid(-50, -50);
        final expectedTopLeft = grid.gridToScreen(0, 0);
        final expectedCenterX1 = expectedTopLeft.x + grid.cellSize / 2;
        final expectedCenterY1 = expectedTopLeft.y + grid.cellSize / 2;
        expect(snapped1.x, equals(expectedCenterX1));
        expect(snapped1.y, equals(expectedCenterY1));
        
        final snapped2 = grid.snapToGrid(screenWidth + 50, screenHeight + 50);
        final expectedBottomRight = grid.gridToScreen(9, 9);
        final expectedCenterX2 = expectedBottomRight.x + grid.cellSize / 2;
        final expectedCenterY2 = expectedBottomRight.y + grid.cellSize / 2;
        expect(snapped2.x, equals(expectedCenterX2));
        expect(snapped2.y, equals(expectedCenterY2));
      });
    });
  });
}
