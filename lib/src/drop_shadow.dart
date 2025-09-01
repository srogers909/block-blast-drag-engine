import 'dart:math' as math;

/// Represents a drop shadow that appears above a dragged block.
/// 
/// The drop shadow shows the user where the block will be positioned
/// if they release it at the current location.
class DropShadow {
  /// The x-coordinate of the shadow's top-left corner.
  final double x;
  
  /// The y-coordinate of the shadow's top-left corner.
  final double y;
  
  /// The width of the shadow.
  final double width;
  
  /// The height of the shadow.
  final double height;

  /// Creates a new [DropShadow] with the specified position and size.
  const DropShadow({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Creates a drop shadow positioned above the given block.
  /// 
  /// The shadow will be positioned at least [minOffset] pixels above the block,
  /// with additional offset added for taller blocks to prevent overlap.
  factory DropShadow.above({
    required double blockX,
    required double blockY,
    required double blockWidth,
    required double blockHeight,
    double minOffset = 50.0,
    double bufferSpace = 10.0,
  }) {
    // Calculate the offset needed to prevent overlap
    final offset = math.max(minOffset, blockHeight + bufferSpace);
    
    return DropShadow(
      x: blockX,
      y: blockY - offset - blockHeight, // Position above the block
      width: blockWidth,
      height: blockHeight,
    );
  }

  @override
  String toString() {
    return 'DropShadow(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropShadow &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, width, height);
  }
}
