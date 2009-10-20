#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

void asmRoberts(const unsigned char* src, unsigned char* dst, int ancho, int alto, int wstep);
void asmPrewitt(const unsigned char* src, unsigned char* dst, int ancho, int alto, int wstep);
void FreiChen(const unsigned char* src, unsigned char* dst, int ancho, int alto, int wstep);
void asmSobel(const unsigned char* src, unsigned char* dst, int ancho, int alto, int wstep, int xorder, int yorder);


int main( int argc, char** argv )
{

	int tscl;
	
	IplImage * src = 0;
	IplImage * dst = 0;

	char *filename = "lena.bmp";
	char *operacion = "r1";


	// SE CARGA UNA IMAGEN EN ESCALA DE GRISES 
	
	
	// Mensaje de error - Parámetros incorrectos
	if (argc == 1) {

		printf("\n\nparametros incorrectos\n");
		printf("Sintaxis: 'ejecutable [archivo] operacion' \n");
		printf("El nombre del archivo es opcional, por defecto toma lena.bmp y operacion va de r1 a r6 \n\n");

		exit(1);

	}


	// Si solo se obtiene un parámetro, este es el tipo de procesamiento, y se trabaja por defecto con al imagen Lena.bmp
	else if(argc == 2) {

		operacion = argv[1];

	}


	// Si se obtienen dos parámetros, el primero es el tipo de procesamiento y el segundo el nombre de la imagen a cargar
	else {

		filename = argv[1];
		operacion = argv[2];

	}
	

	// Mensaje de error - No se pudo cargar la imagen / Imagen no encontrada
	if((src = cvLoadImage (filename, CV_LOAD_IMAGE_GRAYSCALE)) == NULL) {

		printf("\n\nArchivo No Encontrado\n\n\n"); 
		exit(1);

	}


	// SE CREA UNA IMAGEN DESTINO DE IGUAL TAMAÑO A LA QUE SE ACABA DE CARGAR
	dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1);

	
	// SE TOMA EL ESTADO DEL TSC ANTES DE INICIAR EL PROCESAMIENTO DE BORDES
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));



	// SELECCIÓN DE PROCESAMIENTO DE BORDES A REALIZAR

	// Roberts
	if(!strcmp(operacion,"r1")) {
		
		asmRoberts(src->imageData, dst->imageData, src->width, src->height, src->widthStep);
	
		// SE TOMA EL ESTADO DEL TSC DESPUÉS DE REALIZADO EL PROCESAMIENTO Y SE CALCULA LA DIFERENCIA, 				
		// OBTENÍENDOSE LA CANTIDAD DE CLOCK INSUMIDOS POR EL ALGORITMO
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		printf("Ciclos de reloj aproximados: %i \n",tscl);

		cvSaveImage("roberts.bmp", dst);
	}


	// Prewitt
	else if(!strcmp(operacion,"r2")) {
	
		asmPrewitt(src->imageData, dst->imageData, src->width, src->height, src->widthStep);
		
		// SE TOMA EL ESTADO DEL TSC DESPUÉS DE REALIZADO EL PROCESAMIENTO Y SE CALCULA LA DIFERENCIA, 			
		// OBTENÍENDOSE LA CANTIDAD DE CLOCK INSUMIDOS POR EL ALGORITMO
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		printf("Ciclos de reloj aproximados: %i \n",tscl);
	
		cvSaveImage("prewitt.bmp", dst);
	
	}

		
	// Sobel X
	else if(!strcmp(operacion,"r3")) {
	
		asmSobel(src->imageData, dst->imageData, src->width, src->height, src->widthStep, 1, 0);

		// SE TOMA EL ESTADO DEL TSC DESPUÉS DE REALIZADO EL PROCESAMIENTO Y SE CALCULA LA DIFERENCIA, 			
		// OBTENÍENDOSE LA CANTIDAD DE CLOCK INSUMIDOS POR EL ALGORITMO
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		printf("Ciclos de reloj aproximados: %i \n",tscl);

		cvSaveImage("sobelX.bmp", dst);
	
	}

	
	// Sobel Y
	else if(!strcmp(operacion,"r4")) {

		asmSobel(src->imageData, dst->imageData, src->width, src->height, src->widthStep, 0, 1);
	
		// SE TOMA EL ESTADO DEL TSC DESPUÉS DE REALIZADO EL PROCESAMIENTO Y SE CALCULA LA DIFERENCIA, 
		// OBTENÍENDOSE LA CANTIDAD DE CLOCK INSUMIDOS POR EL ALGORITMO
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		printf("Ciclos de reloj aproximados: %i \n",tscl);

		cvSaveImage("sobelY.bmp", dst);
		
	}


	// Sobel XY
	else if(!strcmp(operacion,"r5")) {

		asmSobel(src->imageData, dst->imageData, src->width, src->height, src->widthStep, 1, 1);

		// SE TOMA EL ESTADO DEL TSC DESPUÉS DE REALIZADO EL PROCESAMIENTO Y SE CALCULA LA DIFERENCIA, 			
		// OBTENÍENDOSE LA CANTIDAD DE CLOCK INSUMIDOS POR EL ALGORITMO
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		printf("Ciclos de reloj aproximados: %i \n",tscl);
		
		cvSaveImage("sobelXY.bmp", dst);
		
	}
	
	
	// Frei - Chen
	else if(!strcmp(operacion,"r6")) {
	
		asmPrewitt(src->imageData, dst->imageData, src->width, src->height, src->widthStep);
		
		// SE TOMA EL ESTADO DEL TSC DESPUÉS DE REALIZADO EL PROCESAMIENTO Y SE CALCULA LA DIFERENCIA,
		// OBTENÍENDOSE LA CANTIDAD DE CLOCK INSUMIDOS POR EL ALGORITMO
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		printf("Ciclos de reloj aproximados: %i \n",tscl);
	
		cvSaveImage("prewitt.bmp", dst);
	
	}

	
	// Mensaje de Error - Parámetros incorrectos / Operación no soportada
	else {
	
		printf("\n\nparametros incorrectos\n");
		printf("Sintaxis: 'ejecutable [archivo] operacion' \n");
		printf("El nombre del archivo es opcional, por defecto toma lena.bmp y operacion va de r1 a r5 \n\n");
			
	}
		
	return 0;

}
