//
//  2015 Magna cum laude. PD
//

#include "bezier.h"

int lines_intersect(double p1x,double p1y, double p2x,double p2y, double q1x,double q1y, double q2x,double q2y)
{
	double tmp;
	if (p1x == p2x) p1x -= 0.0001; else if (p1x > p2x) { tmp=p1x; p1x=p2x; p2x=tmp; tmp=p1y; p1y=p2y; p2y=tmp; }
	if (q1x == q2x) q2x += 0.0001; else if (q1x > q2x) { tmp=q1x; q1x=q2x; q2x=tmp; tmp=q1y; q1y=q2y; q2y=tmp; }
	double pa = (p2y-p1y) / (p2x-p1x), pc = p1y - pa*p1x;
	double qa = (q2y-q1y) / (q2x-q1x), qc = q1y - qa*q1x;
	if (pa == qa) return 0;
	double x = (qc - pc) / (pa - qa);
	return x+0.0001 > p1x && x-0.0001 < p2x && x+0.0001 > q1x && x-0.0001 < q2x;
}

bezier_t bezier_make(double p1x,double p1y, double p2x,double p2y, double p3x,double p3y, double p4x,double p4y)
{
	return (bezier_t){ p1x,p1y, p2x,p2y, p3x,p3y, p4x,p4y };
}

int bezier_iszero(bezier_t a)
{
	return a.p1x == a.p4x && a.p1y == a.p4y;
}

void bezier_reverse(bezier_t in, bezier_t *out)
{
	*out = (bezier_t){ in.p4x,in.p4y, in.p3x,in.p3y, in.p2x,in.p2y, in.p1x,in.p1y };
}

void bezier_point(bezier_t a, double t, double *x, double *y)
{
	double u=1-t, t0=u*u*u, t1=3.0*u*u*t, t2=3.0*u*t*t, t3=t*t*t;
	*x = t0*a.p1x + t1*a.p2x + t2*a.p3x + t3*a.p4x;
	*y = t0*a.p1y + t1*a.p2y + t2*a.p3y + t3*a.p4y;
}

void bezier_tangent(bezier_t a, double t, double *x, double *y)
{
	double u=1-t, t0=-3*u*u, t1=3*u*u - 6*t*u, t2=-3*t*t + 6*t*u, t3=3*t*t;
	*x = t0*a.p1x + t1*a.p2x + t2*a.p3x + t3*a.p4x;
	*y = t0*a.p1y + t1*a.p2y + t2*a.p3y + t3*a.p4y;
}

double iterate_bezier_intersection(bezier_t a, bezier_t b, double at0, double at1, double bt0, double bt1, int *intersect)
{
	if (at1-at0 < 0.01)
	{
		*intersect = 1;
		return 0.5*(at0+at1);
	}
	double a_mid = 0.5*(at0+at1), b_mid = 0.5*(bt0+bt1);
	double a1x,a1y, a2x,a2y, a3x,a3y, b1x,b1y, b2x,b2y, b3x,b3y;
	bezier_point(a, at0, &a1x, &a1y); bezier_point(a, a_mid, &a2x, &a2y); bezier_point(a, at1, &a3x, &a3y);
	bezier_point(b, bt0, &b1x, &b1y); bezier_point(b, b_mid, &b2x, &b2y); bezier_point(b, bt1, &b3x, &b3y);
	if (lines_intersect(a1x,a1y, a2x,a2y, b1x,b1y, b2x,b2y))
		return iterate_bezier_intersection(a,b, at0, a_mid, bt0, b_mid, intersect);
	else if (lines_intersect(a1x,a1y, a2x,a2y, b2x,b2y, b3x,b3y))
		return iterate_bezier_intersection(a,b, at0, a_mid, b_mid, bt1, intersect);
	else if (lines_intersect(a2x,a2y, a3x,a3y, b1x,b1y, b2x,b2y))
		return iterate_bezier_intersection(a,b, a_mid, at1, bt0, b_mid, intersect);
	else if (lines_intersect(a2x,a2y, a3x,a3y, b2x,b2y, b3x,b3y))
		return iterate_bezier_intersection(a,b, a_mid, at1, b_mid, bt1, intersect);
	else
		return 0.0;
}

double bezier_intersection(bezier_t a, bezier_t b, int *intersect)
{
	return iterate_bezier_intersection(a, b, 0.01, 0.99, 0.01, 0.99, intersect);
}

void bezier_split(bezier_t in, bezier_t *out1, bezier_t *out2, double t)
{
	double u=1.0-t;
	double p12x = u*in.p1x + t*in.p2x, p12y = u*in.p1y + t*in.p2y;
	double p23x = u*in.p2x + t*in.p3x, p23y = u*in.p2y + t*in.p3y;
	double p34x = u*in.p3x + t*in.p4x, p34y = u*in.p3y + t*in.p4y;
	double p123x = u*p12x + t*p23x, p123y = u*p12y + t*p23y;
	double p234x = u*p23x + t*p34x, p234y = u*p23y + t*p34y;
	double p1234x = u*p123x + t*p234x, p1234y = u*p123y + t*p234y;
	if (out1) *out1 = (bezier_t){ in.p1x,in.p1y, p12x,p12y, p123x,p123y, p1234x,p1234y };
	if (out2) *out2 = (bezier_t){ p1234x,p1234y, p234x,p234y, p34x,p34y, in.p4x,in.p4y };
}

void bezier_subpath(bezier_t in, bezier_t *out, double t1, double t2)
{
	bezier_split(in, out, (bezier_t *)0, t2);
	bezier_split(*out, (bezier_t *)0, out, t1/t2);
}
