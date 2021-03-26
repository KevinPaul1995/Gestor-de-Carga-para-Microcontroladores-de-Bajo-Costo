void baud()
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
  stroke(#219FFC);
  rect(map(bauds, 4000, 115200, 100, 500), 200, 10, 30, 7);
  text("OK", 300, 310);  
  stroke(255);
  noFill();
  if ((mouseX>=250)&&(mouseX<=350)&&(mouseY<=325)&&(mouseY>=275))
  {
    stroke(#219FFC); 
    boton='l'; 
  }
  rect(300, 300, 100, 50);
}
