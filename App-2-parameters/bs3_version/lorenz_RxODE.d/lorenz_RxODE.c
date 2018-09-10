#include <math.h>
#define max(a,b) (((a)>(b))?(a):(b))
#define min(a,b) (((a)<(b))?(a):(b))
extern long dadt_counter;
extern double InfusionRate[99];
extern double *par_ptr;
extern double podo;
extern double tlast;

// prj-specific differential eqns
void RxODE_mod_lorenz_RxODE_dydt(unsigned int neq, double t, double *__zzStateVar__, double *__DDtStateVar__)
{
double
	X,
	a,
	Y,
	c,
	Z,
	b;

	a = par_ptr[0];
	c = par_ptr[1];
	b = par_ptr[2];

	X = __zzStateVar__[0];
	Y = __zzStateVar__[1];
	Z = __zzStateVar__[2];

	__DDtStateVar__[0] = InfusionRate[0] + a *( Y - X);
	__DDtStateVar__[1] = InfusionRate[1] + X *( c - Z) - Y;
	__DDtStateVar__[2] = InfusionRate[2] + X * Y - b * Z;
    dadt_counter++;
}

// prj-specific derived vars
void RxODE_mod_lorenz_RxODE_calc_lhs(double t, double *__zzStateVar__, double *lhs) {
double
	X,
	a,
	Y,
	c,
	Z,
	b;

	a = par_ptr[0];
	c = par_ptr[1];
	b = par_ptr[2];

	X = __zzStateVar__[0];
	Y = __zzStateVar__[1];
	Z = __zzStateVar__[2];


}
