/* file mymod.c */
#include <R.h>
static double parms[3];

#define a parms[0]
#define b parms[1]
#define c parms[2]

/* initializer  */
void initmod(void (* odeparms)(int *, double *))
{
  int N=3;
  odeparms(&N, parms);
}
/* Derivatives and 1 output variable */
void derivs(int *neq, double *t, double *y, double *ydot, double *yout, int *ip)
{
  if (ip[0] <1) error("nout should be at least 1");
  ydot[0] = a * (y[1] - y[0]);
  ydot[1] = y[0] * (c - y[2]) - y[1];
  ydot[2] = y[0] * y[1] - b * y[2];
  
  yout[0] = y[0] + y[1] + y[2];
}

/* The Jacobian matrix */
void jac(int *neq, double *t, double *y, int *ml, int *mu,
         double *pd, int *nrowpd, double *yout, int *ip)
{
  pd[0] = -a;
  pd[1] = c - y[2];
  pd[2] = y[1];
  pd[(*nrowpd)] = a;
  pd[(*nrowpd) + 1] = -1;
  pd[(*nrowpd) + 2] = y[0];
  pd[(*nrowpd)*2] = 0;
  pd[2*(*nrowpd) + 1] = -y[0];
  pd[2*(*nrowpd) + 2] = -b;
}

/* END file mymod.c */
