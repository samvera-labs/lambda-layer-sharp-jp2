const sharp = require('sharp');

// 1x1 png
const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', 'base64');

sharp(png).rotate(180).toBuffer()

// jp2 test
const convertTograyscale = () => {
  sharp('test.jp2')
  .grayscale() // or .greyscale()
  .toFile('grey_test.jpg')
}

convertTograyscale()
