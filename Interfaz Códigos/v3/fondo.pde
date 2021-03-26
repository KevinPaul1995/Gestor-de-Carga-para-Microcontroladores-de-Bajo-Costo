// imprime la imagen de fondo
void fondo()
{
// imagen de fondo
background(0);
imgfondo=loadImage("1.png");
imageMode(CORNER);
tint(0,20,30);
image(imgfondo, 0, 0, 900, 600);
}
