import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class v3 extends PApplet {

   // librería serial
Serial puerto;                // Mi puerto se llama puerto
int numpuerto=0;              //para sacar el numero del puerto com
int bauds=9600;                
String estado=" ";
String[] puertos=(Serial.list());
String COMtext="NoCOM";
PImage imgfondo;              // nombre de las imágenes
char dato='r';                // 
char boton;                   // para ver que botón selecciona el Mouse
int strokeayuda,strokecarga,strokeinfo; // para los colores de fondo
String [] lineas;             // guarda cada línea como un String
char mouse='0';
/////////////////////////////////////////////      OPCODE   ////////////////////////////////////////////////////////
PrintWriter archivosalida;
int tamlinea=0;               //cantidad de lineas a enviarse en el opcode
int dirh=0;                   //Dirección alta de memoria
int dirl=0;                   //Dirección baja de memoria
String recordtype="";         //Tipo de datos del opcode
int datomicro=0;              //datos low transoformados a int

//Variables para almacenar el cuarto dato del nuevo firmware
int a=0;
int b=0;
//////////////////////////////////////////////   VOID SETUP    ////////////////////////////////////////////////////
public void setup()
{

//puerto= new Serial(this, puertos[0],9600);

background(0);
}

/////////////////////////////////////////////////  VOID DRAW  /////////////////////////////////////////////////
public void draw()
{
  if (mouse=='0')
  {
    fondo(); // imprime imagen y fondo
    inicio();// menu principal
  }
  else if (mouse=='1')
  {
    COM();
  }
  else if (mouse=='2')
  {
    baud();
  }

}
public void COM()
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
      strokeinfo=0xff219FFC;
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
public void baud()
{
  mouse='2';
  fondo();
  textSize(30);                      
  textAlign(CENTER);      
  text("Configurar Baudios", 300, 101);  
  fill(255);
  noStroke();
  rect(300, 200, 400, 15, 7);
  text(bauds, 300, 170);  
  stroke(0xff219FFC);
  rect(map(bauds, 4000, 115200, 100, 500), 200, 10, 30, 7);
  text("OK", 300, 310);  
  stroke(255);
  noFill();
  if ((mouseX>=250)&&(mouseX<=350)&&(mouseY<=325)&&(mouseY>=275))
  {
    stroke(0xff219FFC); 
    boton='l'; 
  }
  rect(300, 300, 100, 50);
}

public void carga(){
mouse='0';                           //para que se muestre el menu principal desde void draw
selectInput("Seleccione un Archivo .HEX:", "hex");
fondo();
}
                                                   int t=70;
public void hex(File selection) 
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














  
// imprime la imagen de fondo
public void fondo()
{
// imagen de fondo
background(0);
imgfondo=loadImage("1.png");
imageMode(CORNER);
tint(0,20,30);
image(imgfondo, 0, 0, 900, 600);
}
public void inicio()
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
    strokeayuda=0xff219FFC;                       // Si el mouse está en el botón ayuda se pinta
    boton='a';
  }
  else
  {
    strokeayuda=255;                           // Si el mouse no está sobre boton ayuda se queda blanco
  }                          

  //boton cargar
  if ((mouseX>225)&&(mouseX<375)&&(mouseY<240)&&(mouseY>200))
  {
    strokecarga=0xff219FFC;                       // Si el mouse está en el botón cargar se pinta
    boton='c';
  }
  else
  {
    strokecarga=255;                           // Si el mouse no está sobre boton cargar se queda blanco
  }

  //boton info
  if ((mouseX>400)&&(mouseX<500)&&(mouseY<240)&&(mouseY>200))
  {
    strokeinfo=0xff219FFC;
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
        fill(0xffFF0A0A);
      }
      else if (estado=="Cargado")
      {
        fill(0xff63FF0A);
      }
      ellipse(x,340,10,10);
    }
    fill(255);
  }// if estado diferente de espacio
}
public void mousePressed()
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

public void mouseDragged() 
{
  if (mouse=='2')
  {
    if ((mouseX>=100)&&(mouseX<=500)&&(mouseY<=220)&&(mouseY>=180))
    {
      bauds = 400*round((map(mouseX,100,500,4000,115200))/400);
    }
  }
}
  public void settings() { 
size(600,400); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "v3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
