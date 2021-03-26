void mousePressed()
{
  if (boton=='a')
  {COM();}
  if (boton=='c')
  {carga();}
  if (boton=='i')
  {baud();}
  if (boton=='k') // se seleccionó un poerto en el menu COM
  {
    println(puertos[numpuerto]);
    COMtext=(puertos[numpuerto]);
    mouse='0'; // para que vuelva al menu principal
    estado=" ";
  }
  if (boton=='l') // viene del menu COM
  {
  //puerto= new Serial(this,COMtext,9600);
  mouse='0';
  }
}

void mouseDragged() 
{
  if (mouse=='2')
  {
    if ((mouseX>=100)&&(mouseX<=500)&&(mouseY<=220)&&(mouseY>=180))
    {
      bauds = 400*round((map(mouseX,100,500,4000,115200))/400);
    }
  }
}
