float[][] kernel_blur = {{ 1.0/9, 1.0/9, 1.0/9}, 
                    { 1.0/9, 1.0/9, 1.0/9}, 
                    { 1.0/9, 1.0/9, 1.0/9}};
float[][] kernel_edge = {{ 1, 1, 1}, 
                    { 0,  0, 0}, 
                    { -1, -1, -1}};
                    
PImage img, tempImg;
int estado;
long tBegin,tEnd;
boolean TIMEDRUN = false;

void setup() {
  if (TIMEDRUN) tBegin = System.currentTimeMillis();
  estado = 0; 
  img = loadImage("garrafa_cheia.png"); // Load the original image
  tempImg = createImage(img.width, img.height, RGB);
  size(img.width, img.height);
  if (!TIMEDRUN) noLoop();
}

void mouseClicked(){
  estado++;
  loop();
}

void draw() {
  // mostra imagem inicial
  if (estado == 0){
      image(img, 0, 0);
  } else
  // blur para remover artefatos da imagem
  if (estado == 1){
      img.loadPixels();
      tempImg = createImage(img.width, img.height, RGB);
      tempImg.loadPixels();
      for (int y = 1; y < img.height-1; y++) {
        for (int x = 1; x < img.width-1; x++) {
          float sum = 0; // Kernel sum for this pixel
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              int pos = (y + ky)*img.width + (x + kx);
              float val = red(img.pixels[pos]);
              sum += kernel_blur[ky+1][kx+1] * val;
            }
          }
          // For this pixel in the new image, set the gray value
          // based on the sum from the kernel
          tempImg.pixels[y*img.width + x] = color(sum, sum, sum);
        }
      }
      // State that there are changes to edgeImg.pixels[]
      tempImg.updatePixels();
      img.copy(tempImg,0,0,width,height,0,0,width,height);
  } else
  // thresholding
  if (estado == 2){
      img.loadPixels();
      for (int y = 0; y < img.height; y++) {
        for (int x = 0; x < img.width; x++) {
          int pos = y*width + x;
          if (brightness(img.pixels[pos]) > 180)
            img.pixels[pos] = color(255,255,255);
          else img.pixels[pos] = color(0,0,0);
        }
      }
      img.updatePixels();
  } else
  // erosão
  if (estado == 3){
      filter(ERODE);
      img = get();
  } else
  // dilatação
  if (estado == 4){
      filter(DILATE);
      img = get();
  } else
  // detecção de borda
  if (estado == 5){
      img.loadPixels();
      tempImg = createImage(img.width, img.height, RGB);
      tempImg.loadPixels();
      for (int y = 1; y < img.height-1; y++) {
        for (int x = 1; x < img.width-1; x++) {
          float sum = 0;
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              int pos = (y + ky)*img.width + (x + kx);
              float val = red(img.pixels[pos]);
              sum += kernel_edge[ky+1][kx+1] * val;
            }
          }
          // For this pixel in the new image, set the gray value
          // based on the sum from the kernel
          tempImg.pixels[y*img.width + x] = color(sum, sum, sum);
        }
      }
      tempImg.updatePixels();
      img.copy(tempImg,0,0,width,height,0,0,width,height);
  }else
  // aplicação de máscara para região de interesse
  if (estado == 6){
      img = loadImage("mask.png");
      img.loadPixels();
      tempImg = get();
      tempImg.loadPixels();
      for (int y = 0; y < img.height; y++) {
        for (int x = 0; x < img.width; x++) {
          int pos = y*width + x;
          if (brightness(img.pixels[pos]) == 255)
            img.pixels[pos] = tempImg.pixels[pos];
        }
      }
      img.updatePixels();
  }else
  // contagem de pontos
  if (estado == 7){
      img.loadPixels();
      int count = 0;
      for (int y = 0; y < img.height; y++) {
        for (int x = 0; x < img.width; x++) {
          int pos = y*width + x;
          if (brightness(img.pixels[pos]) != 0) count++;
        }
      }
      System.out.println("contagem = "+count);
  }
  
  image(img,0,0);
  if (TIMEDRUN){
    estado++;
    if (estado == 8){
      tEnd = System.currentTimeMillis();
      System.out.print("tempo de execução: "+ (tEnd-tBegin));
    }
  }else{
    noLoop();
    saveFrame("passo##.png");
  }
}

