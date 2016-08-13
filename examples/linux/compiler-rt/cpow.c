#include <complex.h>



double complex cpow(double complex z, double complex c)
{
	return cexp(c * clog(z));
}
