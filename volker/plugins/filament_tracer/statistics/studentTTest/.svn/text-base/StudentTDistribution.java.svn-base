/*************************************************************************
Cephes Math Library Release 2.8:  June, 2000
Copyright 1984, 1987, 1995, 2000 by Stephen L. Moshier

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
Student's t distribution

Computes the integral from minus infinity to t of the Student
t distribution with integer k > 0 degrees of freedom:

                                     t
                                     -
                                    | |
             -                      |         2   -(k+1)/2
            | ( (k+1)/2 )           |  (     x   )
      ----------------------        |  ( 1 + --- )        dx
                    -               |  (      k  )
      sqrt( k pi ) | ( k/2 )        |
                                  | |
                                   -
                                  -inf.

Relation to incomplete beta integral:

       1 - stdtr(k,t) = 0.5 * incbet( k/2, 1/2, z )
where
       z = k/(k + t**2).

For t < -2, this is the method of computation.  For higher t,
a direct method is derived from integration by parts.
Since the function is symmetric about t=0, the area under the
right tail of the density is found by calling the function
with -t instead of t.

ACCURACY:

Tested at random 1 <= k <= 25.  The "domain" refers to t.
                     Relative error:
arithmetic   domain     # trials      peak         rms
   IEEE     -100,-2      50000       5.9e-15     1.4e-15
   IEEE     -2,100      500000       2.7e-15     4.9e-17

Cephes Math Library Release 2.8:  June, 2000
Copyright 1984, 1987, 1995, 2000 by Stephen L. Moshier
*************************************************************************/
public class StudentTDistribution {
	    public static double studentTDistribution(int k,
	        double t)
	    {
	        double result = 0;
	        double x = 0;
	        double rk = 0;
	        double z = 0;
	        double f = 0;
	        double tz = 0;
	        double p = 0;
	        double xsqk = 0;
	        int j = 0;

	        // System.Diagnostics.Debug.Assert(k>0, "Domain error in StudentTDistribution");
	        if( t==0 )
	        {
	            result = 0.5;
	            return result;
	        }
	        if( t<-2.0 )
	        {
	            rk = k;
	            z = rk/(rk+t*t);
	            result = 0.5*IncompleteBetaIntegral.incompleteBeta(0.5*rk, 0.5, z);
	            return result;
	        }
	        if( t<0 )
	        {
	            x = -t;
	        }
	        else
	        {
	            x = t;
	        }
	        rk = k;
	        z = 1.0+x*x/rk;
	        if( k%2!=0 )
	        {
	            xsqk = x/Math.sqrt(rk);
	            p = Math.atan(xsqk);
	            if( k>1 )
	            {
	                f = 1.0;
	                tz = 1.0;
	                j = 3;
	                while( j<=k-2 & tz/f>APMath.MachineEpsilon )
	                {
	                    tz = tz*((j-1)/(z*j));
	                    f = f+tz;
	                    j = j+2;
	                }
	                p = p+f*xsqk/z;
	            }
	            p = p*2.0/Math.PI;
	        }
	        else
	        {
	            f = 1.0;
	            tz = 1.0;
	            j = 2;
	            while( j<=k-2 & tz/f>APMath.MachineEpsilon )
	            {
	                tz = tz*((j-1)/(z*j));
	                f = f+tz;
	                j = j+2;
	            }
	            p = f*x/Math.sqrt(z*rk);
	        }
	        if( t<0 )
	        {
	            p = -p;
	        }
	        result = 0.5+0.5*p;
	        return result;
	    }


	    /*************************************************************************
	    Functional inverse of Student's t distribution

	    Given probability p, finds the argument t such that stdtr(k,t)
	    is equal to p.

	    ACCURACY:

	    Tested at random 1 <= k <= 100.  The "domain" refers to p:
	                         Relative error:
	    arithmetic   domain     # trials      peak         rms
	       IEEE    .001,.999     25000       5.7e-15     8.0e-16
	       IEEE    10^-6,.001    25000       2.0e-12     2.9e-14

	    Cephes Math Library Release 2.8:  June, 2000
	    Copyright 1984, 1987, 1995, 2000 by Stephen L. Moshier
	    *************************************************************************/
	    public static double inverseStudentTDistribution(int k,
	        double p)
	    {
	        double result = 0;
	        double t = 0;
	        double rk = 0;
	        double z = 0;
	        int rflg = 0;

	        // System.Diagnostics.Debug.Assert(k>0 & p>0 & p<1, "Domain error in InvStudentTDistribution");
	        rk = k;
	        if( p>0.25 & p<0.75 )
	        {
	            if( p==0.5 )
	            {
	                result = 0;
	                return result;
	            }
	            z = 1.0-2.0*p;
	            z = IncompleteBetaIntegral.inverseIncompleteBeta(0.5, 0.5*rk, Math.abs(z));
	            t = Math.sqrt(rk*z/(1.0-z));
	            if( p<0.5 )
	            {
	                t = -t;
	            }
	            result = t;
	            return result;
	        }
	        rflg = -1;
	        if( p>=0.5 )
	        {
	            p = 1.0-p;
	            rflg = 1;
	        }
	        z = IncompleteBetaIntegral.inverseIncompleteBeta(0.5*rk, 0.5, 2.0*p);
	        if( APMath.MaxRealNumber*z<rk )
	        {
	            result = rflg*APMath.MaxRealNumber;
	            return result;
	        }
	        t = Math.sqrt(rk/z-rk);
	        result = rflg*t;
	        return result;
	    }
}
