//
//  2015 Magna cum laude. PD
//

#ifndef __Cocopops__bezier__
#define __Cocopops__bezier__

// a cubic Bézier curve (p1x,p1y) --> (p4x,p4y) with Control points (p2x,p2y) and (p3x,p3y)
typedef struct
{
	double p1x,p1y, p2x,p2y, p3x,p3y, p4x,p4y;
} bezier_t;

bezier_t bezier_make(double p1x,double p1y, double p2x,double p2y, double p3x,double p3y, double p4x,double p4y);

int bezier_iszero(bezier_t a);

// return whether line segments (p1x,p1y)--(p2x,p2y) and (q1x,q1y)--(q2x,q2y) intersect at some point contained in both
int lines_intersect(double p1x,double p1y, double p2x,double p2y, double q1x,double q1y, double q2x,double q2y);

// evaluate a Bézier curve A to obtain point A[T] into (*x,*y), where T in [0, 1]
void bezier_point(bezier_t a, double t, double *x, double *y);

// evaluate a Bézier curve A to obtain tangent A'[T] into (*x,*y), where T in [0, 1]
void bezier_tangent(bezier_t a, double t, double *x, double *y);

// reverse a Bézier path IN to get IN[1]-->IN[0] and place the result into *out
void bezier_reverse(bezier_t in, bezier_t *out);

// return T such that Bézier paths A and B intersect at A[T] = B[T'] (for some T') and set *intersect to 1, or bail out if no intersection exists
// Note: takes a simple, line segment approximation-based approach to find a single intersection point (in the general case, there may be multiple)
double bezier_intersection(bezier_t a, bezier_t b, int *intersect);

// split IN into two Bézier paths at demarcation point T, place IN[0]-->IN[T] into *out1, if out!=0 and IN[T]-->IN[1] into *out2, if out2!=0
void bezier_split(bezier_t in, bezier_t *out1, bezier_t *out2, double t);

// create a sub-path IN[T1]-->IN[T2] and put the output into *out
void bezier_subpath(bezier_t in, bezier_t *out, double t1, double t2);

#endif /* defined(__Cocopops__bezier__) */
