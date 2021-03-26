import processing.serial.*;   // librería serial
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
void setup()
{

//puerto= new Serial(this, puertos[0],9600);
size(600,400);
background(0);
}

/////////////////////////////////////////////////  VOID DRAW  /////////////////////////////////////////////////
void draw()
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
