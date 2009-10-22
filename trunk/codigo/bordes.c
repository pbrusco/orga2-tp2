#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

extern void asmRoberts(const char* src, char* dst, int ancho, int alto, int wstep);
extern void asmPrewitt(const char* src, char* dst, int ancho, int alto, int wstep);
extern void asmSobel(const char* src, char* dst, int ancho, int alto, int wstep, int xorder, int yorder);
extern void asmFreiChen(const char* src, char* dst, int ancho, int alto, int wstep);

int main( int argc, char** argv )
{

	int tscl;
	
	IplImage * src = 0;
	IplImage * dst = 0;

	char *filename = "lena.bmp";
	char *operacion = "r1";

	if (argc == 1) {
		printf("\n\nparametros incorrectos\n");
		printf("Sintaxis: 'ejecutable [archivo] operacion' \n");
		printf("El nombre del archivo es opcional, por defecto toma lena.bmp y operacion va de r1 a r5 \n\n");

		exit(1);
	}

	else if(argc == 2){
		operacion = argv[1];
	}
	else{
		filename = argv[1];
		operacion = argv[2];
	}
	
	if((src = cvLoadImage (filename, CV_LOAD_IMAGE_GRAYSCALE))==NULL){
		printf("\n\nArchivo No Encontrado\n\n\n"); 
		exit(1);
	}

	dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1);


	
	// Tomar estado del TSC antes de iniciar el procesamiento de bordes.
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));

	if(!strcmp(operacion,"r1"))
	{
		asmRoberts(src->imageData, dst->imageData, src->width, src->height, src->widthStep);
		// Tomo la medicion de tiempo con el TSC y calculo la diferencia. Resultado:
		// Cantidad de clocks insumidos por el algoritmo.
		 __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		cvSaveImage("roberts.bmp", dst);
	}
		else if(!strcmp(operacion,"r2"))
	{
		asmPrewitt(src->imageData, dst->imageData, src->width, src->height, src->widthStep);
		// Tomo la medicion de tiempo con el TSC y calculo la diferencia. Resultado:
		// Cantidad de clocks insumidos por el algoritmo.
		 __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		cvSaveImage("prewitt.bmp", dst);
	}
		else if(!strcmp(operacion,"r3"))
	{
		asmSobel(src->imageData, dst->imageData, src->width, src->height, src->widthStep, 1, 0);
		// Tomo la medicion de tiempo con el TSC y calculo la diferencia. Resultado:
		// Cantidad de clocks insumidos por el algoritmo.
		 __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		cvSaveImage("sobelX.bmp", dst);
	}
		else if(!strcmp(operacion,"r4"))
	{
		asmSobel(src->imageData, dst->imageData, src->width, src->height, src->widthStep, 0, 1);
		// Tomo la medicion de tiempo con el TSC y calculo la diferencia. Resultado:
		// Cantidad de clocks insumidos por el algoritmo.
		 __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		cvSaveImage("sobelY.bmp", dst);
	}
		else if(!strcmp(operacion,"r5"))
	{
		asmSobel(src->imageData, dst->imageData, src->width, src->height, src->widthStep, 1, 1);
		// Tomo la medicion de tiempo con el TSC y calculo la diferencia. Resultado:
		// Cantidad de clocks insumidos por el algoritmo.
		 __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		cvSaveImage("sobelXY.bmp", dst);
	}
		else if(!strcmp(operacion,"r6"))
	{
		asmFreiChen(src->imageData, dst->imageData, src->width, src->height, src->widthStep);
		// Tomo la medicion de tiempo con el TSC y calculo la diferencia. Resultado:
		// Cantidad de clocks insumidos por el algoritmo.
		 __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		cvSaveImage("freichen.bmp", dst);
	}


	else 	{
		printf("\n\nparametros incorrectos\n");
		printf("Sintaxis: 'ejecutable [archivo] operacion' \n");
		printf("El nombre del archivo es opcional, por defecto toma lena.bmp y operacion va de r1 a r6 \n\n");
			
		}
	printf("Ciclos de reloj aproximados: %i \n",tscl);
	

//esto lo uso para hacer pruebas y comparaciones!!!! se puede borrar
	cvSobel(src,dst,1,0,3);
	cvSaveImage("sobelXposta.bmp",dst);

	return 0;

}
