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
	x1,
	k1,
	x2,
	k2,
	x3,
	k3;

	k1 = par_ptr[0];
	k2 = par_ptr[1];
	k3 = par_ptr[2];

	x1 = __zzStateVar__[0];
	x2 = __zzStateVar__[1];
	x3 = __zzStateVar__[2];

	__DDtStateVar__[0] = InfusionRate[0] + k1 *( x2 - x1);
	__DDtStateVar__[1] = InfusionRate[1] + k2 * x1 - x2 - x1 * x3;
	__DDtStateVar__[2] = InfusionRate[2] + k3 * x3 + x1 * x2;
    dadt_counter++;
}

// prj-specific derived vars
void RxODE_mod_lorenz_RxODE_calc_lhs(double t, double *__zzStateVar__, double *lhs) {
double
	x1,
	k1,
	x2,
	k2,
	x3,
	k3;

	k1 = par_ptr[0];
	k2 = par_ptr[1];
	k3 = par_ptr[2];

	x1 = __zzStateVar__[0];
	x2 = __zzStateVar__[1];
	x3 = __zzStateVar__[2];


}
