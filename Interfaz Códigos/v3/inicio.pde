void inicio()
{
  // Imprime el Título "Gestor de Carga"
  textSize(35);                      
  textAlign(CENTER);                    
  text("Gestor de Carga",300,101);          
  rectMode(CENTER);
  noFill();
  stroke(255);         
  textSize(20);

  boton='x';                                  // botón es x, a menos que el mouse esté sobre un botón

//boton COM
  if ((mouseX>100)&&(mouseX<200)&&(mouseY<240)&&(mouseY>200))
  {
    strokeayuda=#219FFC;                       // Si el mouse está en el botón ayuda se pinta
    boton='a';
  }
  else
  {
    strokeayuda=255;                           // Si el mouse no está sobre boton ayuda se queda blanco
  }                          

  //boton cargar
  if ((mouseX>225)&&(mouseX<375)&&(mouseY<240)&&(mouseY>200))
  {
    strokecarga=#219FFC;                       // Si el mouse está en el botón cargar se pinta
    boton='c';
  }
  else
  {
    strokecarga=255;                           // Si el mouse no está sobre boton cargar se queda blanco
  }

  //boton info
  if ((mouseX>400)&&(mouseX<500)&&(mouseY<240)&&(mouseY>200))
  {
    strokeinfo=#219FFC;
    boton='i';
  }
  else
  {
    strokeinfo=255;
  }

  //println(boton);

/////////////////////////////////////////  IMPRIME LOS BOTONES //////////////////////////////////////////////////
  
  stroke(strokecarga);
  text("Cargar .HEX",300,230);
  rect(300,220,150,40);

//imprime boton de puerto com
  stroke(strokeayuda);
  text(COMtext,150,230);
  rect(150,220,100,40);

//imprime boton de baud
  stroke(strokeinfo);
  text(bauds,450,230);
  rect(450,220,100,40);

  stroke(255);
// imprime estado
  textSize(20);  
  text(estado,300,301); 
  if (estado!=" ")
  {
    for(int x=260;x<=340;x=x+20)
    {
      if (estado=="Cargando")
      {
        fill(#FF0A0A);
      }
      else if (estado=="Cargado")
      {
        fill(#63FF0A);
      }
      ellipse(x,340,10,10);
    }
    fill(255);
  }// if estado diferente de espacio
}
