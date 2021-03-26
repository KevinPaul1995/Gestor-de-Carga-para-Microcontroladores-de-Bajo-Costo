void COM()
{
  noFill();
  mouse='1';
  fondo();
  textSize(30);                      
  textAlign(CENTER);      
  text("Seleccione un puerto disponible", 300, 101);  
  textSize(15);

  boton='x';                                  // botón es x, a menos que el mouse esté sobre un botón


  //println(boton);

  /////////////////////////////////////////  IMPRIME LOS BOTONES //////////////////////////////////////////////////

  int posy=130;
  for (int i = 0; i < puertos.length; i++)
  {  
    posy=posy+50;
    if ((mouseX>225)&&(mouseX<375)&&(mouseY<posy+10)&&(mouseY>posy-20))
    {
      numpuerto=i;     // numpuerto es para sacar i de esta función, porque i no es global
      strokeinfo=#219FFC;
      boton='k';      // indicador para que en MOUSE se tome el puerto com del valor de puertos[i]
    } 
    else
    {
      strokeinfo=255;
    }
    stroke(strokeinfo);
    text(puertos[i], 300, posy);
    rect(300, posy-5, 150, 30);
  }// for numpuerto
}  
