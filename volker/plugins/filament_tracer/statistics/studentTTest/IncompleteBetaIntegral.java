/*************************************************************************
Cephes Math Library Release 2.8:  June, 2000
Copyright by Stephen L. Moshier

Contributors:
    * Sergey Bochkanov (ALGLIB project). Translation from C to
      pseudocode.

See subroutines comments for additional copyrights.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

- Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer listed
  in this license in the documentation and/or other materials
  provided with the distribution.

- Neither the name of the copyright holders nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*************************************************************************/
package statistics.studentTTest;

/*************************************************************************
Incomplete beta integral

Returns incomplete beta integral of the arguments, evaluated
from zero to x.  The function is defined as

                 x
    -            -
   | (a+b)      | |  a-1     b-1
 -----------    |   t   (1-t)   dt.
  -     -     | |
 | (a) | (b)   -
                0

The domain of definition is 0 <= x <= 1.  In this
implementation a and b are restricted to positive values.
The integral from x to 1 may be obtained by the symmetry
relation

   1 - incbet( a, b, x )  =  incbet( b, a, 1-x ).

The integral is evaluated by a continued fraction expansion
or, when b*x is small, by a power series.

ACCURACY:

Tested at uniformly distributed random points (a,b,x) with a and b
in "domain" and x between 0 and 1.
                                       Relative error
arithmetic   domain     # trials      peak         rms
   IEEE      0,5         10000       6.9e-15     4.5e-16
   IEEE      0,85       250000       2.2e-13     1.7e-14
   IEEE      0,1000      30000       5.3e-12     6.3e-13
   IEEE      0,10000    250000       9.3e-11     7.1e-12
   IEEE      0,100000    10000       8.7e-10     4.8e-11
Outputs smaller than the IEEE gradual underflow threshold
were excluded from these statistics.

Cephes Math Library, Release 2.8:  June, 2000
Copyright 1984, 1995, 2000 by Stephen L. Moshier
*************************************************************************/
public class IncompleteBetaIntegral {
	public static double incompleteBeta(double a,
	        double b,
	        double x)
	    {
	        double result = 0;
	        double t = 0;
	        double xc = 0;
	        double w = 0;
	        double y = 0;
	        int flag = 0;
	        DoubleValue sg = new DoubleValue();
	        sg.setValue(0);
	        double big = 0;
	        double biginv = 0;
	        double maxgam = 0;
	        double minlog = 0;
	        double maxlog = 0;

	        big = 4.503599627370496e15;
	        biginv = 2.22044604925031308085e-16;
	        maxgam = 171.624376956302725;
	        minlog = Math.log(APMath.MinRealNumber);
	        maxlog = Math.log(APMath.MaxRealNumber);
	        // System.Diagnostics.Debug.Assert(a>0 & b>0, "Domain error in IncompleteBeta");
	        // System.Diagnostics.Debug.Assert(x>=0 & x<=1, "Domain error in IncompleteBeta");
	        if( x==0 )
	        {
	            result = 0;
	            return result;
	        }
	        if( x==1 )
	        {
	            result = 1;
	            return result;
	        }
	        flag = 0;
	        if( b*x<=1.0 & x<=0.95 )
	        {
	            result = incompleteBetaPowerSeries(a, b, x, maxgam);
	            return result;
	        }
	        w = 1.0-x;
	        if( x>a/(a+b) )
	        {
	            flag = 1;
	            t = a;
	            a = b;
	            b = t;
	            xc = x;
	            x = w;
	        }
	        else
	        {
	            xc = w;
	        }
	        if( flag==1 & b*x<=1.0 & x<=0.95 )
	        {
	            t = incompleteBetaPowerSeries(a, b, x, maxgam);
	            if( t<=APMath.MachineEpsilon )
	            {
	                result = 1.0-APMath.MachineEpsilon;
	            }
	            else
	            {
	                result = 1.0-t;
	            }
	            return result;
	        }
	        y = x*(a+b-2.0)-(a-1.0);
	        if( y<0.0 )
	        {
	            w = incompleteBetaFractionExpansion(a, b, x, big, biginv);
	        }
	        else
	        {
	            w = incompleteBetaFractionExpansionTwo(a, b, x, big, biginv)/xc;
	        }
	        y = a*Math.log(x);
	        t = b*Math.log(xc);
	        if( a+b<maxgam & Math.abs(y)<maxlog & Math.abs(t)<maxlog )
	        {
	            t = Math.pow(xc, b);
	            t = t*Math.pow(x, a);
	            t = t/a;
	            t = t*w;
	            t = t*(GammaFunction.gamma(a+b)/(GammaFunction.gamma(a)*GammaFunction.gamma(b)));
	            if( flag==1 )
	            {
	                if( t<=APMath.MachineEpsilon )
	                {
	                    result = 1.0-APMath.MachineEpsilon;
	                }
	                else
	                {
	                    result = 1.0-t;
	                }
	            }
	            else
	            {
	                result = t;
	            }
	            return result;
	        }
	        y = y+t+GammaFunction.lngamma(a+b, sg)-GammaFunction.lngamma(a, sg)-GammaFunction.lngamma(b, sg);
	        y = y+Math.log(w/a);
	        if( y<minlog )
	        {
	            t = 0.0;
	        }
	        else
	        {
	            t = Math.exp(y);
	        }
	        if( flag==1 )
	        {
	            if( t<=APMath.MachineEpsilon )
	            {
	                t = 1.0-APMath.MachineEpsilon;
	            }
	            else
	            {
	                t = 1.0-t;
	            }
	        }
	        result = t;
	        return result;
	    }


	    /*************************************************************************
	    Inverse of imcomplete beta integral

	    Given y, the function finds x such that

	     incbet( a, b, x ) = y .

	    The routine performs interval halving or Newton iterations to find the
	    root of incbet(a,b,x) - y = 0.


	    ACCURACY:

	                         Relative error:
	                   x     a,b
	    arithmetic   domain  domain  # trials    peak       rms
	       IEEE      0,1    .5,10000   50000    5.8e-12   1.3e-13
	       IEEE      0,1   .25,100    100000    1.8e-13   3.9e-15
	       IEEE      0,1     0,5       50000    1.1e-12   5.5e-15
	    With a and b constrained to half-integer or integer values:
	       IEEE      0,1    .5,10000   50000    5.8e-12   1.1e-13
	       IEEE      0,1    .5,100    100000    1.7e-14   7.9e-16
	    With a = .5, b constrained to half-integer or integer values:
	       IEEE      0,1    .5,10000   10000    8.3e-11   1.0e-11

	    Cephes Math Library Release 2.8:  June, 2000
	    Copyright 1984, 1996, 2000 by Stephen L. Moshier
	    *************************************************************************/
	    public static double inverseIncompleteBeta(double a,
	        double b,
	        double y)
	    {
	        double result = 0;
	        double aaa = 0;
	        double bbb = 0;
	        double y0 = 0;
	        double d = 0;
	        double yyy = 0;
	        double x = 0;
	        double x0 = 0;
	        double x1 = 0;
	        double lgm = 0;
	        double yp = 0;
	        double di = 0;
	        double dithresh = 0;
	        double yl = 0;
	        double yh = 0;
	        double xt = 0;
	        int i = 0;
	        int rflg = 0;
	        int dir = 0;
	        int nflg = 0;
	        DoubleValue s = new DoubleValue();
	        s.setValue(0);
	        int mainlooppos = 0;
	        int ihalve = 0;
	        int ihalvecycle = 0;
	        int newt = 0;
	        int newtcycle = 0;
	        int breaknewtcycle = 0;
	        int breakihalvecycle = 0;

	        i = 0;
	        // System.Diagnostics.Debug.Assert(y>=0 & y<=1, "Domain error in InvIncompleteBeta");
	        if( y==0 )
	        {
	            result = 0;
	            return result;
	        }
	        if( y==1.0 )
	        {
	            result = 1;
	            return result;
	        }
	        x0 = 0.0;
	        yl = 0.0;
	        x1 = 1.0;
	        yh = 1.0;
	        nflg = 0;
	        mainlooppos = 0;
	        ihalve = 1;
	        ihalvecycle = 2;
	        newt = 3;
	        newtcycle = 4;
	        breaknewtcycle = 5;
	        breakihalvecycle = 6;
	        while( true )
	        {
	            
	            //
	            // start
	            //
	            if( mainlooppos==0 )
	            {
	                if( a<=1.0 | b<=1.0 )
	                {
	                    dithresh = 1.0e-6;
	                    rflg = 0;
	                    aaa = a;
	                    bbb = b;
	                    y0 = y;
	                    x = aaa/(aaa+bbb);
	                    yyy = incompleteBeta(aaa, bbb, x);
	                    mainlooppos = ihalve;
	                    continue;
	                }
	                else
	                {
	                    dithresh = 1.0e-4;
	                }
	                yp = -NormalDistribution.inverseOfNormalDistribution(y);
	                if( y>0.5 )
	                {
	                    rflg = 1;
	                    aaa = b;
	                    bbb = a;
	                    y0 = 1.0-y;
	                    yp = -yp;
	                }
	                else
	                {
	                    rflg = 0;
	                    aaa = a;
	                    bbb = b;
	                    y0 = y;
	                }
	                lgm = (yp*yp-3.0)/6.0;
	                x = 2.0/(1.0/(2.0*aaa-1.0)+1.0/(2.0*bbb-1.0));
	                d = yp*Math.sqrt(x+lgm)/x-(1.0/(2.0*bbb-1.0)-1.0/(2.0*aaa-1.0))*(lgm+5.0/6.0-2.0/(3.0*x));
	                d = 2.0*d;
	                if( d<Math.log(APMath.MinRealNumber) )
	                {
	                    x = 0;
	                    break;
	                }
	                x = aaa/(aaa+bbb*Math.exp(d));
	                yyy = incompleteBeta(aaa, bbb, x);
	                yp = (yyy-y0)/y0;
	                if( Math.abs(yp)<0.2 )
	                {
	                    mainlooppos = newt;
	                    continue;
	                }
	                mainlooppos = ihalve;
	                continue;
	            }
	            
	            //
	            // ihalve
	            //
	            if( mainlooppos==ihalve )
	            {
	                dir = 0;
	                di = 0.5;
	                i = 0;
	                mainlooppos = ihalvecycle;
	                continue;
	            }
	            
	            //
	            // ihalvecycle
	            //
	            if( mainlooppos==ihalvecycle )
	            {
	                if( i<=99 )
	                {
	                    if( i!=0 )
	                    {
	                        x = x0+di*(x1-x0);
	                        if( x==1.0 )
	                        {
	                            x = 1.0-APMath.MachineEpsilon;
	                        }
	                        if( x==0.0 )
	                        {
	                            di = 0.5;
	                            x = x0+di*(x1-x0);
	                            if( x==0.0 )
	                            {
	                                break;
	                            }
	                        }
	                        yyy = incompleteBeta(aaa, bbb, x);
	                        yp = (x1-x0)/(x1+x0);
	                        if( Math.abs(yp)<dithresh )
	                        {
	                            mainlooppos = newt;
	                            continue;
	                        }
	                        yp = (yyy-y0)/y0;
	                        if( Math.abs(yp)<dithresh )
	                        {
	                            mainlooppos = newt;
	                            continue;
	                        }
	                    }
	                    if( yyy<y0 )
	                    {
	                        x0 = x;
	                        yl = yyy;
	                        if( dir<0 )
	                        {
	                            dir = 0;
	                            di = 0.5;
	                        }
	                        else
	                        {
	                            if( dir>3 )
	                            {
	                                di = 1.0-(1.0-di)*(1.0-di);
	                            }
	                            else
	                            {
	                                if( dir>1 )
	                                {
	                                    di = 0.5*di+0.5;
	                                }
	                                else
	                                {
	                                    di = (y0-yyy)/(yh-yl);
	                                }
	                            }
	                        }
	                        dir = dir+1;
	                        if( x0>0.75 )
	                        {
	                            if( rflg==1 )
	                            {
	                                rflg = 0;
	                                aaa = a;
	                                bbb = b;
	                                y0 = y;
	                            }
	                            else
	                            {
	                                rflg = 1;
	                                aaa = b;
	                                bbb = a;
	                                y0 = 1.0-y;
	                            }
	                            x = 1.0-x;
	                            yyy = incompleteBeta(aaa, bbb, x);
	                            x0 = 0.0;
	                            yl = 0.0;
	                            x1 = 1.0;
	                            yh = 1.0;
	                            mainlooppos = ihalve;
	                            continue;
	                        }
	                    }
	                    else
	                    {
	                        x1 = x;
	                        if( rflg==1 & x1<APMath.MachineEpsilon )
	                        {
	                            x = 0.0;
	                            break;
	                        }
	                        yh = yyy;
	                        if( dir>0 )
	                        {
	                            dir = 0;
	                            di = 0.5;
	                        }
	                        else
	                        {
	                            if( dir<-3 )
	                            {
	                                di = di*di;
	                            }
	                            else
	                            {
	                                if( dir<-1 )
	                                {
	                                    di = 0.5*di;
	                                }
	                                else
	                                {
	                                    di = (yyy-y0)/(yh-yl);
	                                }
	                            }
	                        }
	                        dir = dir-1;
	                    }
	                    i = i+1;
	                    mainlooppos = ihalvecycle;
	                    continue;
	                }
	                else
	                {
	                    mainlooppos = breakihalvecycle;
	                    continue;
	                }
	            }
	            
	            //
	            // breakihalvecycle
	            //
	            if( mainlooppos==breakihalvecycle )
	            {
	                if( x0>=1.0 )
	                {
	                    x = 1.0-APMath.MachineEpsilon;
	                    break;
	                }
	                if( x<=0.0 )
	                {
	                    x = 0.0;
	                    break;
	                }
	                mainlooppos = newt;
	                continue;
	            }
	            
	            //
	            // newt
	            //
	            if( mainlooppos==newt )
	            {
	                if( nflg!=0 )
	                {
	                    break;
	                }
	                nflg = 1;
	                lgm = GammaFunction.lngamma(aaa+bbb, s)-GammaFunction.lngamma(aaa, s)-GammaFunction.lngamma(bbb, s);
	                i = 0;
	                mainlooppos = newtcycle;
	                continue;
	            }
	            
	            //
	            // newtcycle
	            //
	            if( mainlooppos==newtcycle )
	            {
	                if( i<=7 )
	                {
	                    if( i!=0 )
	                    {
	                        yyy = incompleteBeta(aaa, bbb, x);
	                    }
	                    if( yyy<yl )
	                    {
	                        x = x0;
	                        yyy = yl;
	                    }
	                    else
	                    {
	                        if( yyy>yh )
	                        {
	                            x = x1;
	                            yyy = yh;
	                        }
	                        else
	                        {
	                            if( yyy<y0 )
	                            {
	                                x0 = x;
	                                yl = yyy;
	                            }
	                            else
	                            {
	                                x1 = x;
	                                yh = yyy;
	                            }
	                        }
	                    }
	                    if( x==1.0 | x==0.0 )
	                    {
	                        mainlooppos = breaknewtcycle;
	                        continue;
	                    }
	                    d = (aaa-1.0)*Math.log(x)+(bbb-1.0)*Math.log(1.0-x)+lgm;
	                    if( d<Math.log(APMath.MinRealNumber) )
	                    {
	                        break;
	                    }
	                    if( d>Math.log(APMath.MaxRealNumber) )
	                    {
	                        mainlooppos = breaknewtcycle;
	                        continue;
	                    }
	                    d = Math.exp(d);
	                    d = (yyy-y0)/d;
	                    xt = x-d;
	                    if( xt<=x0 )
	                    {
	                        yyy = (x-x0)/(x1-x0);
	                        xt = x0+0.5*yyy*(x-x0);
	                        if( xt<=0.0 )
	                        {
	                            mainlooppos = breaknewtcycle;
	                            continue;
	                        }
	                    }
	                    if( xt>=x1 )
	                    {
	                        yyy = (x1-x)/(x1-x0);
	                        xt = x1-0.5*yyy*(x1-x);
	                        if( xt>=1.0 )
	                        {
	                            mainlooppos = breaknewtcycle;
	                            continue;
	                        }
	                    }
	                    x = xt;
	                    if( Math.abs(d/x)<128.0*APMath.MachineEpsilon )
	                    {
	                        break;
	                    }
	                    i = i+1;
	                    mainlooppos = newtcycle;
	                    continue;
	                }
	                else
	                {
	                    mainlooppos = breaknewtcycle;
	                    continue;
	                }
	            }
	            
	            //
	            // breaknewtcycle
	            //
	            if( mainlooppos==breaknewtcycle )
	            {
	                dithresh = 256.0*APMath.MachineEpsilon;
	                mainlooppos = ihalve;
	                continue;
	            }
	        }
	        
	        //
	        // done
	        //
	        if( rflg!=0 )
	        {
	            if( x<=APMath.MachineEpsilon )
	            {
	                x = 1.0-APMath.MachineEpsilon;
	            }
	            else
	            {
	                x = 1.0-x;
	            }
	        }
	        result = x;
	        return result;
	    }


	    /*************************************************************************
	    Continued fraction expansion #1 for incomplete beta integral

	    Cephes Math Library, Release 2.8:  June, 2000
	    Copyright 1984, 1995, 2000 by Stephen L. Moshier
	    *************************************************************************/
	    private static double incompleteBetaFractionExpansion(double a,
	        double b,
	        double x,
	        double big,
	        double biginv)
	    {
	        double result = 0;
	        double xk = 0;
	        double pk = 0;
	        double pkm1 = 0;
	        double pkm2 = 0;
	        double qk = 0;
	        double qkm1 = 0;
	        double qkm2 = 0;
	        double k1 = 0;
	        double k2 = 0;
	        double k3 = 0;
	        double k4 = 0;
	        double k5 = 0;
	        double k6 = 0;
	        double k7 = 0;
	        double k8 = 0;
	        double r = 0;
	        double t = 0;
	        double ans = 0;
	        double thresh = 0;
	        int n = 0;

	        k1 = a;
	        k2 = a+b;
	        k3 = a;
	        k4 = a+1.0;
	        k5 = 1.0;
	        k6 = b-1.0;
	        k7 = k4;
	        k8 = a+2.0;
	        pkm2 = 0.0;
	        qkm2 = 1.0;
	        pkm1 = 1.0;
	        qkm1 = 1.0;
	        ans = 1.0;
	        r = 1.0;
	        n = 0;
	        thresh = 3.0*APMath.MachineEpsilon;
	        do
	        {
	            xk = -(x*k1*k2/(k3*k4));
	            pk = pkm1+pkm2*xk;
	            qk = qkm1+qkm2*xk;
	            pkm2 = pkm1;
	            pkm1 = pk;
	            qkm2 = qkm1;
	            qkm1 = qk;
	            xk = x*k5*k6/(k7*k8);
	            pk = pkm1+pkm2*xk;
	            qk = qkm1+qkm2*xk;
	            pkm2 = pkm1;
	            pkm1 = pk;
	            qkm2 = qkm1;
	            qkm1 = qk;
	            if( qk!=0 )
	            {
	                r = pk/qk;
	            }
	            if( r!=0 )
	            {
	                t = Math.abs((ans-r)/r);
	                ans = r;
	            }
	            else
	            {
	                t = 1.0;
	            }
	            if( t<thresh )
	            {
	                break;
	            }
	            k1 = k1+1.0;
	            k2 = k2+1.0;
	            k3 = k3+2.0;
	            k4 = k4+2.0;
	            k5 = k5+1.0;
	            k6 = k6-1.0;
	            k7 = k7+2.0;
	            k8 = k8+2.0;
	            if( Math.abs(qk)+Math.abs(pk)>big )
	            {
	                pkm2 = pkm2*biginv;
	                pkm1 = pkm1*biginv;
	                qkm2 = qkm2*biginv;
	                qkm1 = qkm1*biginv;
	            }
	            if( Math.abs(qk)<biginv | Math.abs(pk)<biginv )
	            {
	                pkm2 = pkm2*big;
	                pkm1 = pkm1*big;
	                qkm2 = qkm2*big;
	                qkm1 = qkm1*big;
	            }
	            n = n+1;
	        }
	        while( n!=300 );
	        result = ans;
	        return result;
	    }


	    /*************************************************************************
	    Continued fraction expansion #2
	    for incomplete beta integral

	    Cephes Math Library, Release 2.8:  June, 2000
	    Copyright 1984, 1995, 2000 by Stephen L. Moshier
	    *************************************************************************/
	    private static double incompleteBetaFractionExpansionTwo(double a,
	        double b,
	        double x,
	        double big,
	        double biginv)
	    {
	        double result = 0;
	        double xk = 0;
	        double pk = 0;
	        double pkm1 = 0;
	        double pkm2 = 0;
	        double qk = 0;
	        double qkm1 = 0;
	        double qkm2 = 0;
	        double k1 = 0;
	        double k2 = 0;
	        double k3 = 0;
	        double k4 = 0;
	        double k5 = 0;
	        double k6 = 0;
	        double k7 = 0;
	        double k8 = 0;
	        double r = 0;
	        double t = 0;
	        double ans = 0;
	        double z = 0;
	        double thresh = 0;
	        int n = 0;

	        k1 = a;
	        k2 = b-1.0;
	        k3 = a;
	        k4 = a+1.0;
	        k5 = 1.0;
	        k6 = a+b;
	        k7 = a+1.0;
	        k8 = a+2.0;
	        pkm2 = 0.0;
	        qkm2 = 1.0;
	        pkm1 = 1.0;
	        qkm1 = 1.0;
	        z = x/(1.0-x);
	        ans = 1.0;
	        r = 1.0;
	        n = 0;
	        thresh = 3.0*APMath.MachineEpsilon;
	        do
	        {
	            xk = -(z*k1*k2/(k3*k4));
	            pk = pkm1+pkm2*xk;
	            qk = qkm1+qkm2*xk;
	            pkm2 = pkm1;
	            pkm1 = pk;
	            qkm2 = qkm1;
	            qkm1 = qk;
	            xk = z*k5*k6/(k7*k8);
	            pk = pkm1+pkm2*xk;
	            qk = qkm1+qkm2*xk;
	            pkm2 = pkm1;
	            pkm1 = pk;
	            qkm2 = qkm1;
	            qkm1 = qk;
	            if( qk!=0 )
	            {
	                r = pk/qk;
	            }
	            if( r!=0 )
	            {
	                t = Math.abs((ans-r)/r);
	                ans = r;
	            }
	            else
	            {
	                t = 1.0;
	            }
	            if( t<thresh )
	            {
	                break;
	            }
	            k1 = k1+1.0;
	            k2 = k2-1.0;
	            k3 = k3+2.0;
	            k4 = k4+2.0;
	            k5 = k5+1.0;
	            k6 = k6+1.0;
	            k7 = k7+2.0;
	            k8 = k8+2.0;
	            if( Math.abs(qk)+Math.abs(pk)>big )
	            {
	                pkm2 = pkm2*biginv;
	                pkm1 = pkm1*biginv;
	                qkm2 = qkm2*biginv;
	                qkm1 = qkm1*biginv;
	            }
	            if( Math.abs(qk)<biginv | Math.abs(pk)<biginv )
	            {
	                pkm2 = pkm2*big;
	                pkm1 = pkm1*big;
	                qkm2 = qkm2*big;
	                qkm1 = qkm1*big;
	            }
	            n = n+1;
	        }
	        while( n!=300 );
	        result = ans;
	        return result;
	    }


	    /*************************************************************************
	    Power series for incomplete beta integral.
	    Use when b*x is small and x not too close to 1.

	    Cephes Math Library, Release 2.8:  June, 2000
	    Copyright 1984, 1995, 2000 by Stephen L. Moshier
	    *************************************************************************/
	    private static double incompleteBetaPowerSeries(double a,
	        double b,
	        double x,
	        double maxgam)
	    {
	        double result = 0;
	        double s = 0;
	        double t = 0;
	        double u = 0;
	        double v = 0;
	        double n = 0;
	        double t1 = 0;
	        double z = 0;
	        double ai = 0;
	        DoubleValue sg = new DoubleValue();
	        sg.setValue(0);

	        ai = 1.0/a;
	        u = (1.0-b)*x;
	        v = u/(a+1.0);
	        t1 = v;
	        t = u;
	        n = 2.0;
	        s = 0.0;
	        z = APMath.MachineEpsilon*ai;
	        while( Math.abs(v)>z )
	        {
	            u = (n-b)*x/n;
	            t = t*u;
	            v = t/(a+n);
	            s = s+v;
	            n = n+1.0;
	        }
	        s = s+t1;
	        s = s+ai;
	        u = a*Math.log(x);
	        if( a+b<maxgam & Math.abs(u)<Math.log(APMath.MaxRealNumber) )
	        {
	            t = GammaFunction.gamma(a+b)/(GammaFunction.gamma(a)*GammaFunction.gamma(b));
	            s = s*t*Math.pow(x, a);
	        }
	        else
	        {
	            t = GammaFunction.lngamma(a+b, sg)-GammaFunction.lngamma(a, sg)-GammaFunction.lngamma(b, sg)+u+Math.log(s);
	            if( t<Math.log(APMath.MinRealNumber) )
	            {
	                s = 0.0;
	            }
	            else
	            {
	                s = Math.exp(t);
	            }
	        }
	        result = s;
	        return result;
	    }
}
