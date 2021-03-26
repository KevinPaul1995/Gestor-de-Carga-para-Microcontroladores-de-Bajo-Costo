
void carga(){
mouse='0';                           //para que se muestre el menu principal desde void draw
selectInput("Seleccione un Archivo .HEX:", "hex");
fondo();
}
                                                   int t=70;
void hex(File selection) 
{
  if (selection == null) 
  {
    puerto.stop();
    println("No ha seleccionado nada");           //si no se ha seleccionado un archivo
  } 
  if (COMtext=="NoCOM") //si aun no se selecciona un puerto COM
  {
    estado="Seleccione COM";
  }
  else                                            // si sí se seleccionó un archivo y se tiene puerto COM
    {
      puerto= new Serial(this, COMtext,9600);
      estado="Cargando";
      textSize(15);  
      text(estado,300,301); 
      archivosalida= createWriter("opcode.txt");  //crea opcode.txt en el mismo directorio
      archivosalida.flush();                      // Escribir archivo    
      lineas = loadStrings(selection);            // guarda las lineas como Strings (ARCHIVO HEX HECHO LINEAS)
      String [] recordtypes=new String[lineas.length];// identificar lineas de grabación
      int tamtamlineas=0;                         // numero de lineas de grabación
      int [] indices=new int[lineas.length];      // los indices con datos de grabación
      int aux=0;                          
      for (int i = 0 ; i < lineas.length; i++)    // me muevo en lineas para llenar recordtypes
      {     
        recordtypes[i]=(str(lineas[i].charAt(7))+str(lineas[i].charAt(8)));
      }
      for (int i = 0 ; i < recordtypes.length; i++) // me muevo en recordtypes para llenar tamlineas 
      {
        if ((recordtypes[i].charAt(0)=='0')&&(recordtypes[i].charAt(1)=='0'))// si es una linea de grabación
        {

          tamtamlineas++;  //cuantas lineas de grabación hay
          indices[aux]=i;  // todos lo indices están aumentados 1 para diferenciar de los 0 de valor vacío
          aux++;
        }    
      }// for llena tamtamlineas
      
      int [] tamlineas=new int[tamtamlineas];    // Un vector para almacenar el tamaño de cada línea
      int [] dirsl=new int[tamtamlineas];
      int [] dirsh=new int[tamtamlineas];
      String [] datos=new String[tamtamlineas];
      for (int i = 0 ; i < tamtamlineas; i++) //llena valores en os vectores
      {
        tamlineas[i]=unhex(str(lineas[indices[i]].charAt(1))+str(lineas[indices[i]].charAt(2))); //guarda tam de linea
        dirsl[i]=unhex(str(lineas[indices[i]].charAt(5))+str(lineas[indices[i]].charAt(6)));      //guarda direcciones bajas
        dirsh[i]=unhex(str(lineas[indices[i]].charAt(3))+str(lineas[indices[i]].charAt(4)));      //guarda direcciones altas
        datos[i]=lineas[indices[i]].substring(9,lineas[indices[i]].length()-2);                   //guarda datos        
        println(tamlineas[i]+"  "+dirsl[i]+"  "+dirsh[i]+"  "+datos[i]);        //imprime todo   
      } //for llena valores 
      println("");
      for (int i = 0 ; i < tamtamlineas; i++)  // agrupa en 16
      {
        int aux2=1,aux3=0;
        //aux2 es para ir quitando datos de las lineas siguientes
        //aux 3 es para moverme en los datos de la fila siguiente de 2 en dos
        while((tamlineas[i]<16)&&(tamlineas[tamtamlineas-1]>0))
        {
          
          println(str(tamlineas[i])+"   "+str(i+aux2));
          if((i+aux2)<tamtamlineas)// para no sobre pasar el tamaño de tamlineas
          {
            //println("tam "+str(tamlineas[i])+"     de donde resto "+str(i+aux2)+"   "+str(i)+"   aux2"+aux2);
            if(tamlineas[i+aux2]>0) //si aun tengo datos disponibles en la fila de donde quito datos
            {
              datos[i]=datos[i]+datos[i+aux2].substring(0,2);
              tamlineas[i]=tamlineas[i]+1;//sumo un dato a la linea actual
              
              datos[i+aux2]=datos[i+aux2].substring(2,datos[i+aux2].length());
              tamlineas[i+aux2]=tamlineas[i+aux2]-1; //quito un dato de las líneas de abajo
              dirsl[i+aux2]=dirsl[i+aux2]+1; // acomodo la dirección de la siguiente linea
              //println("resta   "+tamlineas[i+aux2]);
            }//if
            else //si ya se aacbaron los datos de esta fila voy a la siguiente
            {
              //println("cambio linea");
              aux2++;
              aux3=0;
            }//else
          }// if para no superar tamtamlineas
        }//while
        println(tamlineas[i]+"  "+dirsl[i]+"  "+dirsh[i]+"  "+datos[i]);        //imprime todo   
      }//for agrupa en 16
      println(" ");
      for (int i = 0 ; i < tamtamlineas; i++)  // si ya no quedan datos disponibles relleno con 0000
      {
        while (tamlineas[i]<16&&tamlineas[i]>0)
        {
          datos[i]=datos[i]+"00";
          tamlineas[i]++;
        }
        println(tamlineas[i]+"  "+dirsl[i]+"  "+dirsh[i]+"  "+datos[i]);        //imprime todo   
      }//rellenar posiciones con 0000
      
      for (int i = 0 ; i < tamtamlineas; i++)  // manda la información al microcontrolador
      {
        if (tamlineas[i]>0) // solo envia las lineas con datos
        {
          puerto.write(tamlineas[i]);    
          archivosalida.print(tamlineas[i]+" ");
          delay(t);
          puerto.write(dirsl[i]/2); 
          archivosalida.print(dirsl[i]+" ");
          delay(t);
          puerto.write(dirsh[i]);
          archivosalida.print(dirsh[i]+"   ");
          delay(t);
          println(" ");
          for (int j = 0 ; j < datos[i].length() ; j=j+2) // for envia datos
          {
            puerto.write(unhex(str(datos[i].charAt(j))+str(datos[i].charAt(j+1))));
            delay(t);
            archivosalida.print(((str(datos[i].charAt(j))+str(datos[i].charAt(j+1))))+(" "));// guarda el el txt del opcode
            //print(" "+binary(unhex((str(datos[i].charAt(j))+str(datos[i].charAt(j+1)))))); // imprime en binario
            print(" "+(unhex((str(datos[i].charAt(j))+str(datos[i].charAt(j+1)))))); // imprime en int
          } //for envia datos
          archivosalida.println("");
        }//if tamlinea mayor a 0
      }// manda información al micro
      ////                                           GOTO DEL BL
      String [] gotobl={"8","0","0","8A","15","0A","16","B0","2F",(str(datos[0].charAt(12))+str(datos[0].charAt(13))),(str(datos[0].charAt(14))+str(datos[0].charAt(15)))};
      for (int i = 0 ; i < gotobl.length ; i++) // envia al micro goto del bl
      {
        puerto.write(unhex(gotobl[i]));
        //archivosalida.println(unhex(gotobl[i]));
        println(gotobl[i]);
        delay(t);
      } // goto bl
      ////                                           GOTO DEL USUARIO
      String [] gotousuario={"8","AC","1F",(str(datos[0].charAt(0))+str(datos[0].charAt(1))),(str(datos[0].charAt(2))+str(datos[0].charAt(3))),(str(datos[0].charAt(4))+str(datos[0].charAt(5))),(str(datos[0].charAt(6))+str(datos[0].charAt(7))),(str(datos[0].charAt(8))+str(datos[0].charAt(9))),(str(datos[0].charAt(10))+str(datos[0].charAt(11))),(str(datos[0].charAt(12))+str(datos[0].charAt(13))),(str(datos[0].charAt(14))+str(datos[0].charAt(15)))};
      for (int i = 0 ; i < gotousuario.length ; i++) // envia al micro goto del bl
      {
        puerto.write(unhex(gotousuario[i]));
        //archivosalida.println(unhex(gotousuario[i]));
        println(gotousuario[i]);
        delay(t);
      } // goto bl    
      archivosalida.close();  
      println("FIN");
      estado="Cargado";
      puerto.stop();
    }//else, si se ha seleccionado un .hex

}// fin función     














  
