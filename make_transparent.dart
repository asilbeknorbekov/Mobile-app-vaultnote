import 'dart:io';
import 'package:image/image.dart';

void main() {
  final file = File('assets/images/logo.jpg');
  if (!file.existsSync()) {
    print('Logo not found');
    return;
  }
  
  final image = decodeImage(file.readAsBytesSync());
  if (image == null) return;
  
  // Make white (and near-white) pixels transparent
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      // Check if pixel is close to white
      if (pixel.r > 240 && pixel.g > 240 && pixel.b > 240) {
        image.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 0); // alpha 0
      }
    }
  }
  
  File('assets/images/logo.png').writeAsBytesSync(encodePng(image));
  print('Transparent logo saved to logo.png');
}
