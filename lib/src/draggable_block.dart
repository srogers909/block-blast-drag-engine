/// A simple rectangular block that can be dragged around.
/// 
/// This class represents a draggable block with position and size properties,
/// along with methods for hit detection and positioning.
class DraggableBlock {
  /// The x-coordinate of the block's top-left corner.
  final double x;
  
  /// The y-coordinate of the block's top-left corner.
  final double y;
  
  /// The width of the block.
  final double width;
  
  /// The height of the block.
  final double height;

  /// Creates a new [DraggableBlock] with the specified position and size.
  const DraggableBlock({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Returns true if the given point is within the bounds of this block.
  /// 
  /// The bounds are inclusive, meaning points on the edges are considered inside.
  bool containsPoint(double pointX, double pointY) {
    return pointX >= x &&
           pointX <= x + width &&
           pointY >= y &&
           pointY <= y + height;
  }

  /// Creates a copy of this block with optionally updated properties.
  DraggableBlock copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return DraggableBlock(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Returns a new block positioned so that its center is at the given point.
  DraggableBlock centerOn(double centerX, double centerY) {
    return DraggableBlock(
      x: centerX - width / 2,
      y: centerY - height / 2,
      width: width,
      height: height,
    );
  }

  @override
  String toString() {
    return 'DraggableBlock(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DraggableBlock &&
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
