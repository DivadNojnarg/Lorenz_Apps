#include <stdio.h>
#include <stdarg.h>
#include <R.h>
#include <Rinternals.h>
#include <Rmath.h>
#include <R_ext/Rdynload.h>
#define JAC_Rprintf Rprintf
#define _idx (&_solveData->subjects[_cSub])->idx
#define JAC0_Rprintf if ( (&_solveData->subjects[_cSub])->jac_counter == 0) Rprintf
#define ODE_Rprintf Rprintf
#define ODE0_Rprintf if ( (&_solveData->subjects[_cSub])->dadt_counter == 0) Rprintf
#define LHS_Rprintf Rprintf
#define _safe_log(a) (((a) <= 0) ? log(DOUBLE_EPS) : log(a))
#define safe_zero(a) ((a) == 0 ? DOUBLE_EPS : (a))
#define _as_zero(a) (fabs(a) < sqrt(DOUBLE_EPS) ? 0.0 : a)
#define factorial(a) exp(lgamma1p(a))
#define sign_exp(sgn, x)(((sgn) > 0.0) ? exp(x) : (((sgn) < 0.0) ? -exp(x) : 0.0))
#define R_pow(a, b) (((a) == 0 && (b) <= 0) ? R_pow(DOUBLE_EPS, b) : R_pow(a, b))
#define R_pow_di(a, b) (((a) == 0 && (b) <= 0) ? R_pow_di(DOUBLE_EPS, b) : R_pow_di(a, b))
#define Rx_pow(a, b) (((a) == 0 && (b) <= 0) ? R_pow(DOUBLE_EPS, b) : R_pow(a, b))
#define Rx_pow_di(a, b) (((a) == 0 && (b) <= 0) ? R_pow_di(DOUBLE_EPS, b) : R_pow_di(a, b))
typedef void (*t_dydt)(int *neq, double t, double *A, double *DADT);
typedef void (*t_calc_jac)(int *neq, double t, double *A, double *JAC, unsigned int __NROWPD__);
typedef void (*t_calc_lhs)(int cSub, double t, double *A, double *lhs);
typedef void (*t_update_inis)(int cSub, double *);
typedef void (*t_dydt_lsoda_dum)(int *neq, double *t, double *A, double *DADT);
typedef void (*t_jdum_lsoda)(int *neq, double *t, double *A,int *ml, int *mu, double *JAC, int *nrowpd);
typedef int (*t_dydt_liblsoda)(double t, double *y, double *ydot, void *data);
typedef void (*t_ode_current)();

typedef struct {
  // These options should not change based on an individual solve
  int badSolve;
  double ATOL;          //absolute error
  double RTOL;          //relative error
  double H0;
  double HMIN;
  int mxstep;
  int MXORDN;
  int MXORDS;
  //
  int do_transit_abs;
  int nlhs;
  int neq;
  int stiff;
  int ncov;
  char modNamePtr[1000];
  int *par_cov;
  double *inits;
  double *scale;
  int do_par_cov;
  // approx fun options
  double f1;
  double f2;
  int kind;
  int is_locf;
  int cores;
  int extraCmt;
  double hmax2; // Determined by diff
  double *rtol2;
  double *atol2;
  int nDisplayProgress;
  int ncoresRV;
  int isChol;
  int *svar;
  int abort;
} rx_solving_options;


typedef struct {
  int *slvr_counter;
  int *dadt_counter;
  int *jac_counter;
  double *InfusionRate;
  int *BadDose;
  int nBadDose;
  double HMAX; // Determined by diff
  double tlast;
  double podo;
  double *par_ptr;
  double *dose;
  double *solve;
  double *lhs;
  int  *evid;
  int *rc;
  double *cov_ptr;
  int n_all_times;
  int ixds;
  int ndoses;
  double *all_times;
  double *dv;
  int *idose;
  int idosen;
  int id;
  int sim;
  int idx;
  double ylow;
  double yhigh;
  double lambda;
  double yj;
} rx_solving_options_ind;

typedef struct {
  rx_solving_options_ind *subjects;
  rx_solving_options *op;
  int nsub;
  int nsim;
  int nall;
  int nobs;
  int nr;
  int add_cov;
  int matrix;
  double stateTrim;
  int *stateIgnore;
} rx_solve;

typedef void (*t_set_solve)(rx_solve *);
typedef rx_solve *(*t_get_solve)();


rx_solve *getRxSolve_();
rx_solve *getRxSolve(SEXP ptr);

void par_solve(rx_solve *rx);

rx_solving_options *getRxOp(rx_solve *rx);

SEXP RxODE_df(int doDose, int doTBS);
SEXP RxODE_par_df();

rx_solving_options_ind *rxOptionsIniEnsure(int mx);

void rxUpdateFuns(SEXP trans);
#define abs_log1p(x) (((x) + 1.0 > 0.0) ? log1p(x) : (((x) + 1.0 > 0.0) ? log1p(-x) : 0.0))
#define abs_log(x) ((fabs(x) <= sqrt(DOUBLE_EPS)) ? log(sqrt(DOUBLE_EPS)) : (((x) > 0.0) ? log(x) ? (((x) == 0) ? 0.0 : log(-x))))
#define _IR (_solveData->subjects[_cSub].InfusionRate)
#define _PP (_solveData->subjects[_cSub].par_ptr)
#define _SR (INTEGER(stateRmS))
#define rx_lambda_ _solveData->subjects[_cSub].lambda
#define rx_yj_ _solveData->subjects[_cSub].yj
#define rxTBS(x, lm, yj)  _powerD(x,  lm, (int)(yj))
#define rxTBSi(x, lm, yj) _powerDi(x,  lm, (int)(yj))
#define rxTBSd(x, lm, yj) _powerDD(x, lm, (int)(yj))
#define rxTBSd2(x, lm, yj) _powerDDD(x, lm, (int)(yj))

// Types for par pointers.r
typedef double (*RxODE_fn) (double x);
typedef double (*RxODE_fn2) (double x, double y);
typedef double (*RxODE_fn3i) (double x, double y, int i);
typedef double (*RxODE_fn2i) (double x, int i);
typedef int (*RxODE_fn0i) ();
typedef double (*RxODE_vec) (int val, rx_solve *rx, unsigned int id);
typedef double (*RxODE_val) (rx_solve *rx, unsigned int id);
typedef void (*RxODE_assign_ptr)(SEXP);
typedef void (*RxODE_ode_solver_old_c)(int *neq,double *theta,double *time,int *evid,int *ntime,double *inits,double *dose,double *ret,double *atol,double *rtol,int *stiff,int *transit_abs,int *nlhs,double *lhs,int *rc);

RxODE_fn3i _powerD, _powerDD, _powerDDD, _powerDi;

RxODE_assign_ptr _assign_ptr = NULL;

typedef void (*_rxRmModelLibType)(const char *inp);
_rxRmModelLibType _rxRmModelLib = NULL;

typedef SEXP (*_rxGetModelLibType)(const char *s);
_rxGetModelLibType _rxGetModelLib = NULL;

RxODE_ode_solver_old_c _old_c = NULL;

RxODE_fn0i _ptrid=NULL;

typedef  SEXP (*_rx_asgn) (SEXP objectSEXP);
_rx_asgn _RxODE_rxAssignPtr =NULL;

typedef int(*_rxIsCurrentC_type)(SEXP);
_rxIsCurrentC_type _rxIsCurrentC=NULL;

typedef double(*_rxSumType)(double *, int, double *, int, int);
_rxSumType _sumPS = NULL;

double _sum(double *input, double *pld, int m, int type, int n, ...){
  va_list valist;
  va_start(valist, n);
  for (unsigned int i = 0; i < n; i++){
    input[i] = va_arg(valist, double);
  }
  va_end(valist);
  return _sumPS(input, n, pld, m, type);
}

typedef double(*_rxProdType)(double*, double*, int, int);
_rxProdType _prodPS = NULL;

double _prod(double *input, double *p, int type, int n, ...){
  va_list valist;
  va_start(valist, n);
  for (unsigned int i = 0; i < n; i++){
    input[i] = va_arg(valist, double);
  }
  va_end(valist);
  return _prodPS(input, p, n, type);
}

double _sign(unsigned int n, ...){
  va_list valist;
  va_start(valist, n);
  double s = 1;
  for (unsigned int i = 0; i < n; i++){
    s = sign(va_arg(valist, double))*s;
    if (s == 0){
      break;
    }
  }
  va_end(valist);
  return s;
}

double _max(unsigned int n, ...){
  va_list valist;
  va_start(valist, n);
  double mx = NA_REAL;
  double tmp = 0;
  if (n >= 1){
    mx = va_arg(valist, double);
    for (unsigned int i = 1; i < n; i++){
      tmp = va_arg(valist, double);
      if (tmp>mx) mx=tmp;
    }
    va_end(valist);
  }
  return mx;
}

double _min(unsigned int n, ...){
  va_list valist;
  va_start(valist, n);
  double mn = NA_REAL;
  double tmp = 0;
  if (n >= 1){
    mn = va_arg(valist, double);
    for (unsigned int i = 1; i < n; i++){
      tmp = va_arg(valist, double);
      if (tmp<mn) mn=tmp;
    }
    va_end(valist);
  }
  return mn;
}

rx_solve *_solveData = NULL;

double _transit4P(double t, unsigned int id, double n, double mtt, double bio){
  double ktr = (n+1)/mtt;
  double lktr = log(n+1)-log(mtt);
  double tc = (t-(_solveData->subjects[id].tlast));
  return exp(log(bio*(_solveData->subjects[id].podo))+lktr+n*(lktr+log(tc))-ktr*(tc)-lgamma1p(n));
}

double _transit3P(double t, unsigned int id, double n, double mtt){
  double ktr = (n+1)/mtt;
  double lktr = log(n+1)-log(mtt);
  double tc = (t-(_solveData->subjects[id].tlast));
  return exp(log(_solveData->subjects[id].podo)+lktr+n*(lktr+log(tc))-ktr*(tc)-lgamma1p(n));
}

typedef double (*solveLinB_p) (rx_solve *rx, unsigned int id, double t, int linCmt, int diff1, int diff2, double d_A, double d_alpha, double d_B, double d_beta, double d_C, double d_gamma, double d_ka, double d_tlag);

solveLinB_p solveLinB;

typedef void (*_update_par_ptr_p)(double t, unsigned int id, rx_solve *rx, int idx);

_update_par_ptr_p _update_par_ptr;

RxODE_fn0i _prodType = NULL;
RxODE_fn0i _sumType = NULL;

extern void lorenz_RxODE__ode_solver_solvedata (rx_solve *solve){
  _solveData = solve;
}

extern rx_solve *lorenz_RxODE__ode_solver_get_solvedata(){
  return _solveData;
}

SEXP lorenz_RxODE__model_vars();
extern void lorenz_RxODE__ode_solver(int *neq,
			   double *theta,      //order:
			   double *time,
			   int *evid,
			   int *ntime,
			   double *inits,
			   double *dose,
			   double *ret,
			   double *atol,
			   double *rtol,
			   int *stiff,
			   int *transit_abs,
			   int *nlhs,
			   double *lhs,
			   int *rc){
  // Backward compatible ode solver for 0.5* C interface
  //if (_ptrid() != 1547216842 ){ _assign_ptr(lorenz_RxODE__model_vars());}
  double *_theta = theta;
  _old_c(neq, _theta, time, evid, ntime, inits, dose, ret, atol, rtol, stiff, transit_abs, nlhs, lhs, rc);
}

static R_NativePrimitiveArgType lorenz_RxODE__ode_solverrx_t[] = {
  //*neq, *theta, *time,  *evid, *ntime, *inits,   *dose,   *ret,     *atol,  *rtol,   *stiff, *transit_abs, *nlhs, *lhs, *rc
  INTSXP,REALSXP, REALSXP, INTSXP, INTSXP, REALSXP, REALSXP, REALSXP, REALSXP, REALSXP, INTSXP, INTSXP, INTSXP, REALSXP, INTSXP
};


// prj-specific differential eqns
void lorenz_RxODE__dydt(int *_neq, double t, double *__zzStateVar__, double *__DDtStateVar__)
{
  int _cSub = _neq[1];
  double   X,
  a,
  Y,
  c,
  Z,
  b;

  (void)t;
  (void)X;
  (void)a;
  (void)Y;
  (void)c;
  (void)Z;
  (void)b;

  _update_par_ptr(t, _cSub, _solveData, _idx);
  a = _PP[0];
  c = _PP[1];
  b = _PP[2];

  X = __zzStateVar__[0];
  Y = __zzStateVar__[1];
  Z = __zzStateVar__[2];

  __DDtStateVar__[0]=_IR[0]+a*(Y-X);
  __DDtStateVar__[1]=_IR[1]+X*(c-Z)-Y;
  __DDtStateVar__[2]=_IR[2]+X*Y-b*Z;
  (&_solveData->subjects[_cSub])->dadt_counter[0]++;
}

// Jacobian derived vars
void lorenz_RxODE__calc_jac(int *_neq, double t, double *__zzStateVar__, double *__PDStateVar__, unsigned int __NROWPD__) {
  int _cSub=_neq[1];
  (&_solveData->subjects[_cSub])->jac_counter[0]++;
}
// Functional based initial conditions.
void lorenz_RxODE__inis(int _cSub, double *__zzStateVar__){
  double t=0;
  double   X,
  a,
  Y,
  c,
  Z,
  b;

  (void)t;
  (void)X;
  (void)a;
  (void)Y;
  (void)c;
  (void)Z;
  (void)b;

  _update_par_ptr(0.0, _cSub, _solveData, _idx);
  a = _PP[0];
  c = _PP[1];
  b = _PP[2];

  X = __zzStateVar__[0];
  Y = __zzStateVar__[1];
  Z = __zzStateVar__[2];

  __zzStateVar__[0]=X;
  __zzStateVar__[1]=Y;
  __zzStateVar__[2]=Z;
}
// prj-specific derived vars
void lorenz_RxODE__calc_lhs(int _cSub, double t, double *__zzStateVar__, double *_lhs) {
  double   __DDtStateVar_0__,
  __DDtStateVar_1__,
  __DDtStateVar_2__,
  X,
  a,
  Y,
  c,
  Z,
  b;

  (void)t;
  (void)__DDtStateVar_0__;
  (void)__DDtStateVar_1__;
  (void)__DDtStateVar_2__;
  (void)X;
  (void)a;
  (void)Y;
  (void)c;
  (void)Z;
  (void)b;

  _update_par_ptr(t, _cSub, _solveData, _idx);
  a = _PP[0];
  c = _PP[1];
  b = _PP[2];

  X = __zzStateVar__[0];
  Y = __zzStateVar__[1];
  Z = __zzStateVar__[2];

  __DDtStateVar_0__=_IR[0]+a*(Y-X);
  __DDtStateVar_1__=_IR[1]+X*(c-Z)-Y;
  __DDtStateVar_2__=_IR[2]+X*Y-b*Z;

}
extern SEXP lorenz_RxODE__model_vars(){
  int pro=0;
  SEXP _mv = PROTECT(_rxGetModelLib("rx_5c2c6f8a65d272301b81504c87d75239_x64_model_vars"));pro++;
  if (!_rxIsCurrentC(_mv)){
    SEXP lst      = PROTECT(allocVector(VECSXP, 16));pro++;
    SEXP names    = PROTECT(allocVector(STRSXP, 16));pro++;
    SEXP params   = PROTECT(allocVector(STRSXP, 3));pro++;
    SEXP lhs      = PROTECT(allocVector(STRSXP, 0));pro++;
    SEXP state    = PROTECT(allocVector(STRSXP, 3));pro++;
    SEXP stateRmS = PROTECT(allocVector(INTSXP, 3));pro++;
    SEXP timeInt = PROTECT(allocVector(INTSXP, 1));pro++;
    INTEGER(timeInt)[0] = 1547216842;
    SEXP sens     = PROTECT(allocVector(STRSXP, 0));pro++;
    SEXP normState= PROTECT(allocVector(STRSXP, 3));pro++;
    SEXP fn_ini   = PROTECT(allocVector(STRSXP, 0));pro++;
    SEXP dfdy     = PROTECT(allocVector(STRSXP, 0));pro++;
    SEXP tran     = PROTECT(allocVector(STRSXP, 14));pro++;
    SEXP trann    = PROTECT(allocVector(STRSXP, 14));pro++;
    SEXP mmd5     = PROTECT(allocVector(STRSXP, 2));pro++;
    SEXP mmd5n    = PROTECT(allocVector(STRSXP, 2));pro++;
    SEXP model    = PROTECT(allocVector(STRSXP, 4));pro++;
    SEXP modeln   = PROTECT(allocVector(STRSXP, 4));pro++;
    SEXP solve    = PROTECT(allocVector(VECSXP, 4));pro++;
    SEXP solven   = PROTECT(allocVector(STRSXP, 4));pro++;
    SEXP initsr   = PROTECT(allocVector(REALSXP, 3));pro++;
    SEXP scaler   = PROTECT(allocVector(REALSXP, 3));pro++;
    SEXP infusionr= PROTECT(allocVector(REALSXP, 3));pro++;
    SEXP badDosei = PROTECT(allocVector(INTSXP, 3));pro++;
    SEXP version    = PROTECT(allocVector(STRSXP, 3));pro++;
    SEXP versionn   = PROTECT(allocVector(STRSXP, 3));pro++;
    SET_STRING_ELT(version,0,mkChar("0.8.0-5"));
    SET_STRING_ELT(version,1,mkChar("https://github.com/nlmixrdevelopment/RxODE"));
    SET_STRING_ELT(version,2,mkChar("468b2fd3681be7452327b6618edd78c5"));
    SET_STRING_ELT(versionn,0,mkChar("version"));
    SET_STRING_ELT(versionn,1,mkChar("repo"));
    SET_STRING_ELT(versionn,2,mkChar("md5"));
    SET_STRING_ELT(solven,0,mkChar("inits"));
    SET_VECTOR_ELT(solve,  0,initsr);
    SET_STRING_ELT(solven,1,mkChar("scale"));
    SET_VECTOR_ELT(solve,  1,scaler);
    SET_STRING_ELT(solven,2,mkChar("infusion"));
    SET_VECTOR_ELT(solve,  2,infusionr);
    SET_STRING_ELT(solven,3,mkChar("badDose"));
    SET_VECTOR_ELT(solve,  3,badDosei);
    setAttrib(solve, R_NamesSymbol, solven);
    SET_STRING_ELT(params,0,mkChar("a"));
    SET_STRING_ELT(params,1,mkChar("c"));
    SET_STRING_ELT(params,2,mkChar("b"));
    SET_STRING_ELT(state,0,mkChar("X"));
    SET_STRING_ELT(normState,0,mkChar("X"));
    _SR[0] = 0;
    SET_STRING_ELT(state,1,mkChar("Y"));
    SET_STRING_ELT(normState,1,mkChar("Y"));
    _SR[1] = 0;
    SET_STRING_ELT(state,2,mkChar("Z"));
    SET_STRING_ELT(normState,2,mkChar("Z"));
    _SR[2] = 0;
    SET_STRING_ELT(modeln,0,mkChar("model"));
    SET_STRING_ELT(model,0,mkChar("\n   d/dt(X) = a * (Y - X);\n   d/dt(Y) = X * (c - Z) - Y;\n   d/dt(Z) = X * Y - b * Z;\n\n"));
    SET_STRING_ELT(modeln,1,mkChar("normModel"));
    SET_STRING_ELT(model,1,mkChar("d/dt(X)=a*(Y-X);\nd/dt(Y)=X*(c-Z)-Y;\nd/dt(Z)=X*Y-b*Z;\n"));
    SET_STRING_ELT(modeln,2,mkChar("parseModel"));
    SET_STRING_ELT(model,2,mkChar("__DDtStateVar__[0] = _IR[0] + a*(Y-X);\n__DDtStateVar__[1] = _IR[1] + X*(c-Z)-Y;\n__DDtStateVar__[2] = _IR[2] + X*Y-b*Z;\n"));
    SET_STRING_ELT(modeln,3,mkChar("expandModel"));
    SET_STRING_ELT(model,3,mkChar("\n   d/dt(X) = a * (Y - X);\n   d/dt(Y) = X * (c - Z) - Y;\n   d/dt(Z) = X * Y - b * Z;\n\n"));
    SEXP ini    = PROTECT(allocVector(REALSXP,0));pro++;
    SEXP inin   = PROTECT(allocVector(STRSXP, 0));pro++;
    SET_STRING_ELT(names,0,mkChar("params"));
    SET_VECTOR_ELT(lst,  0,params);
    SET_STRING_ELT(names,1,mkChar("lhs"));
    SET_VECTOR_ELT(lst,  1,lhs);
    SET_STRING_ELT(names,2,mkChar("state"));
    SET_VECTOR_ELT(lst,  2,state);
    SET_STRING_ELT(names,3,mkChar("trans"));
    SET_VECTOR_ELT(lst,  3,tran);
    SET_STRING_ELT(names,5,mkChar("model"));
    SET_VECTOR_ELT(lst,  5,model);
    SET_STRING_ELT(names,4,mkChar("ini"));
    SET_VECTOR_ELT(lst,  4,ini);
    SET_STRING_ELT(names,6,mkChar("md5"));
    SET_VECTOR_ELT(lst,  6,mmd5);
    SET_STRING_ELT(names,7,mkChar("podo"));
    SET_VECTOR_ELT(lst,  7,ScalarLogical(0));
    SET_STRING_ELT(names,8,mkChar("dfdy"));
    SET_VECTOR_ELT(lst,  8,dfdy);
    SET_STRING_ELT(names,9,mkChar("sens"));
    SET_VECTOR_ELT(lst,  9,sens);
    SET_STRING_ELT(names,10,mkChar("fn.ini"));
    SET_VECTOR_ELT(lst,  10,fn_ini);
    SET_STRING_ELT(names,11,mkChar("state.ignore"));
    SET_VECTOR_ELT(lst,  11,stateRmS);
    SET_STRING_ELT(names,12,mkChar("solve"));
    SET_VECTOR_ELT(lst,  12,solve);
    SET_STRING_ELT(names,13,mkChar("version"));
    SET_VECTOR_ELT(lst,  13,version);
    SET_STRING_ELT(names,14,mkChar("normal.state"));
    SET_VECTOR_ELT(lst,  14,normState);
    SET_STRING_ELT(names,15,mkChar("timeId"));
    SET_VECTOR_ELT(lst,  15,timeInt);
    SET_STRING_ELT(mmd5n,0,mkChar("file_md5"));
    SET_STRING_ELT(mmd5,0,mkChar("dcaa33e094e5c0e8fe5b4b2efebd4b5a"));
    SET_STRING_ELT(mmd5n,1,mkChar("parsed_md5"));
    SET_STRING_ELT(mmd5,1,mkChar("5fd7163a303ede435aa8cce6189d9c87"));
    SET_STRING_ELT(trann,0,mkChar("lib.name"));
    SET_STRING_ELT(tran, 0,mkChar("lorenz_RxODE_"));
    SET_STRING_ELT(trann,1,mkChar("jac"));
    SET_STRING_ELT(tran,1,mkChar("fullint"));
    SET_STRING_ELT(trann,2,mkChar("prefix"));
    SET_STRING_ELT(tran, 2,mkChar("lorenz_RxODE__"));
    SET_STRING_ELT(trann,3,mkChar("dydt"));
    SET_STRING_ELT(tran, 3,mkChar("lorenz_RxODE__dydt"));
    SET_STRING_ELT(trann,4,mkChar("calc_jac"));
    SET_STRING_ELT(tran, 4,mkChar("lorenz_RxODE__calc_jac"));
    SET_STRING_ELT(trann,5,mkChar("calc_lhs"));
    SET_STRING_ELT(tran, 5,mkChar("lorenz_RxODE__calc_lhs"));
    SET_STRING_ELT(trann,6,mkChar("model_vars"));
    SET_STRING_ELT(tran, 6,mkChar("lorenz_RxODE__model_vars"));
    SET_STRING_ELT(trann,7,mkChar("ode_solver"));
    SET_STRING_ELT(tran, 7,mkChar("lorenz_RxODE__ode_solver"));
    SET_STRING_ELT(trann,8,mkChar("inis"));
    SET_STRING_ELT(tran, 8,mkChar("lorenz_RxODE__inis"));
    SET_STRING_ELT(trann,  9,mkChar("dydt_lsoda"));
    SET_STRING_ELT(tran,   9,mkChar("lorenz_RxODE__dydt_lsoda"));
    SET_STRING_ELT(trann,10,mkChar("calc_jac_lsoda"));
    SET_STRING_ELT(tran, 10,mkChar("lorenz_RxODE__calc_jac_lsoda"));
    SET_STRING_ELT(trann,11,mkChar("ode_solver_solvedata"));
    SET_STRING_ELT(tran, 11,mkChar("lorenz_RxODE__ode_solver_solvedata"));
    SET_STRING_ELT(trann,12,mkChar("ode_solver_get_solvedata"));
    SET_STRING_ELT(tran, 12,mkChar("lorenz_RxODE__ode_solver_get_solvedata"));
    SET_STRING_ELT(trann,13,mkChar("dydt_liblsoda"));
    SET_STRING_ELT(tran, 13,mkChar("lorenz_RxODE__dydt_liblsoda"));
    setAttrib(tran, R_NamesSymbol, trann);
    setAttrib(mmd5, R_NamesSymbol, mmd5n);
    setAttrib(model, R_NamesSymbol, modeln);
    setAttrib(ini, R_NamesSymbol, inin);
    setAttrib(version, R_NamesSymbol, versionn);
    setAttrib(lst, R_NamesSymbol, names);
    SEXP cls = PROTECT(allocVector(STRSXP, 1));pro++;
    SET_STRING_ELT(cls, 0, mkChar("rxModelVars"));
    classgets(lst, cls);
    _assign_ptr(lst);
    UNPROTECT(pro);
    return lst;
  } else {
    UNPROTECT(pro);
    return _mv;
  }
}

extern void lorenz_RxODE__dydt_lsoda(int *neq, double *t, double *A, double *DADT)
{
  lorenz_RxODE__dydt(neq, *t, A, DADT);
}

extern int lorenz_RxODE__dydt_liblsoda(double t, double *y, double *ydot, void *data)
{
  int *neq = (int*)(data);
  lorenz_RxODE__dydt(neq, t, y, ydot);
  return(0);
}

extern void lorenz_RxODE__calc_jac_lsoda(int *neq, double *t, double *A,int *ml, int *mu, double *JAC, int *nrowpd){
  // Update all covariate parameters
  lorenz_RxODE__calc_jac(neq, *t, A, JAC, *nrowpd);
}

//Initilize the dll to match RxODE's calls
void R_init_lorenz_RxODE_ (DllInfo *info){
  // Get C callables on load; Otherwise it isn't thread safe
  _assign_ptr=(RxODE_assign_ptr) R_GetCCallable("RxODE","RxODE_assign_fn_pointers");
  _rxRmModelLib=(_rxRmModelLibType) R_GetCCallable("RxODE","rxRmModelLib");
  _rxGetModelLib=(_rxGetModelLibType) R_GetCCallable("RxODE","rxGetModelLib");
  _old_c = (RxODE_ode_solver_old_c) R_GetCCallable("RxODE","rxSolveOldC");
  _RxODE_rxAssignPtr=(_rx_asgn)R_GetCCallable("RxODE","_RxODE_rxAssignPtr");
  _rxIsCurrentC = (_rxIsCurrentC_type)R_GetCCallable("RxODE","rxIsCurrentC");
  _sumPS  = (_rxSumType) R_GetCCallable("PreciseSums","PreciseSums_sum_r");
  _prodPS = (_rxProdType) R_GetCCallable("PreciseSums","PreciseSums_prod_r");
  _prodType=(RxODE_fn0i)R_GetCCallable("PreciseSums", "PreciseSums_prod_get");
  _sumType=(RxODE_fn0i)R_GetCCallable("PreciseSums", "PreciseSums_sum_get");
  _ptrid=(RxODE_fn0i)R_GetCCallable("RxODE", "RxODE_current_fn_pointer_id");
  _powerD=(RxODE_fn3i)R_GetCCallable("RxODE", "powerD");
  _powerDi=(RxODE_fn3i)R_GetCCallable("RxODE", "powerDi");
  _powerDD=(RxODE_fn3i)R_GetCCallable("RxODE", "powerDD");
  _powerDDD=(RxODE_fn3i)R_GetCCallable("RxODE", "powerDDD");
  solveLinB=(solveLinB_p)R_GetCCallable("RxODE", "solveLinB");
  _update_par_ptr=(_update_par_ptr_p) R_GetCCallable("RxODE","_update_par_ptr");
  // Register the outside functions
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__ode_solver",       (DL_FUNC) lorenz_RxODE__ode_solver);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__inis", (DL_FUNC) lorenz_RxODE__inis);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__inis", (DL_FUNC) lorenz_RxODE__inis);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__dydt", (DL_FUNC) lorenz_RxODE__dydt);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__calc_lhs", (DL_FUNC) lorenz_RxODE__calc_lhs);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__calc_jac", (DL_FUNC) lorenz_RxODE__calc_jac);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__dydt_lsoda", (DL_FUNC) lorenz_RxODE__dydt_lsoda);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__calc_jac_lsoda", (DL_FUNC) lorenz_RxODE__calc_jac_lsoda);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__ode_solver_solvedata", (DL_FUNC) lorenz_RxODE__ode_solver_solvedata);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__ode_solver_get_solvedata", (DL_FUNC) lorenz_RxODE__ode_solver_get_solvedata);
  R_RegisterCCallable("lorenz_RxODE_","lorenz_RxODE__dydt_liblsoda", (DL_FUNC) lorenz_RxODE__dydt_liblsoda);
  
  static const R_CMethodDef cMethods[] = {
    {"lorenz_RxODE__ode_solver", (DL_FUNC) &lorenz_RxODE__ode_solver, 15, lorenz_RxODE__ode_solverrx_t},
    {NULL, NULL, 0, NULL}
  };
  
  R_CallMethodDef callMethods[]  = {
    {"lorenz_RxODE__model_vars", (DL_FUNC) &lorenz_RxODE__model_vars, 0},
    {NULL, NULL, 0}
  };
  R_registerRoutines(info, cMethods, callMethods, NULL, NULL);
  R_useDynamicSymbols(info,FALSE);
}

void R_unload_lorenz_RxODE_ (DllInfo *info){
  // Free resources required for single subject solve.
  SEXP _mv = PROTECT(_rxGetModelLib("lorenz_RxODE__model_vars"));
  if (!isNull(_mv)){
    _rxRmModelLib("lorenz_RxODE__model_vars");
  }
  UNPROTECT(1);
}