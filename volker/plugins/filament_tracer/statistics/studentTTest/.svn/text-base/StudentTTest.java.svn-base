/*************************************************************************
	Copyright (c) 2007, Sergey Bochkanov (ALGLIB project).

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

public class StudentTTest {
	    private double bothtails;
	    private double lefttail;
	    private double righttail;


		/*************************************************************************
	    One-sample t-test

	    This test checks three hypotheses about the mean of the given sample.  The
	    following tests are performed:
	        * two-tailed test (null hypothesis - the mean is equal  to  the  given
	          value)
	        * left-tailed test (null hypothesis - the  mean  is  greater  than  or
	          equal to the given value)
	        * right-tailed test (null hypothesis - the mean is less than or  equal
	          to the given value).

	    The test is based on the assumption that  a  given  sample  has  a  normal
	    distribution and  an  unknown  dispersion.  If  the  distribution  sharply
	    differs from normal, the test will work incorrectly.

	    Input parameters:
	        X       -   sample. Array whose index goes from 0 to N-1.
	        N       -   size of sample.
	        Mean    -   assumed value of the mean.

	    Output parameters:
	        BothTails   -   p-value for two-tailed test.
	                        If BothTails is less than the given significance level
	                        the null hypothesis is rejected.
	        LeftTail    -   p-value for left-tailed test.
	                        If LeftTail is less than the given significance level,
	                        the null hypothesis is rejected.
	        RightTail   -   p-value for right-tailed test.
	                        If RightTail is less than the given significance level
	                        the null hypothesis is rejected.

	      -- ALGLIB --
	         Copyright 08.09.2006 by Bochkanov Sergey
	    *************************************************************************/
	    public void studentTTest(double[] x,
	        int n,
	        double mean)
	    {
	        int i = 0;
	        double xmean = 0;
	        double xvariance = 0;
	        double xstddev = 0;
	        double v1 = 0;
	        double v2 = 0;
	        double stat = 0;
	        double s = 0;

	        if( n<=1 )
	        {
	            bothtails = 1.0;
	            lefttail = 1.0;
	            righttail = 1.0;
	            return;
	        }
	        
	        //
	        // Mean
	        //
	        xmean = 0;
	        for(i=0; i<=n-1; i++)
	        {
	            xmean = xmean+x[i];
	        }
	        xmean = xmean/n;
	        
	        //
	        // Variance (using corrected two-pass algorithm)
	        //
	        xvariance = 0;
	        xstddev = 0;
	        if( n!=1 )
	        {
	            v1 = 0;
	            for(i=0; i<=n-1; i++)
	            {
	                v1 = v1+Math.pow(x[i]-xmean, 2);
	            }
	            v2 = 0;
	            for(i=0; i<=n-1; i++)
	            {
	                v2 = v2+(x[i]-xmean);
	            }
	            v2 = Math.pow(v2,2)/n;
	            xvariance = (v1-v2)/(n-1);
	            if( xvariance<0 )
	            {
	                xvariance = 0;
	            }
	            xstddev = Math.sqrt(xvariance);
	        }
	        if( xstddev==0 )
	        {
	            bothtails = 1.0;
	            lefttail = 1.0;
	            righttail = 1.0;
	            return;
	        }
	        
	        //
	        // Statistic
	        //
	        stat = (xmean-mean)/(xstddev/Math.sqrt(n));
	        s = StudentTDistribution.studentTDistribution(n-1, stat);
	        bothtails = 2*Math.min(s, 1-s);
	        lefttail = s;
	        righttail = 1-s;
	    }


	    /*************************************************************************
	    Two-sample pooled test

	    This test checks three hypotheses about the mean of the given samples. The
	    following tests are performed:
	        * two-tailed test (null hypothesis - the means are equal)
	        * left-tailed test (null hypothesis - the mean of the first sample  is
	          greater than or equal to the mean of the second sample)
	        * right-tailed test (null hypothesis - the mean of the first sample is
	          less than or equal to the mean of the second sample).

	    Test is based on the following assumptions:
	        * given samples have normal distributions
	        * dispersions are equal
	        * samples are independent.

	    Input parameters:
	        X       -   sample 1. Array whose index goes from 0 to N-1.
	        N       -   size of sample.
	        Y       -   sample 2. Array whose index goes from 0 to M-1.
	        M       -   size of sample.

	    Output parameters:
	        BothTails   -   p-value for two-tailed test.
	                        If BothTails is less than the given significance level
	                        the null hypothesis is rejected.
	        LeftTail    -   p-value for left-tailed test.
	                        If LeftTail is less than the given significance level,
	                        the null hypothesis is rejected.
	        RightTail   -   p-value for right-tailed test.
	                        If RightTail is less than the given significance level
	                        the null hypothesis is rejected.

	      -- ALGLIB --
	         Copyright 18.09.2006 by Bochkanov Sergey
	    *************************************************************************/
	    public void studentTTest(double[] x,
	        int n,
	        double[] y,
	        int m)
	    {
	        int i = 0;
	        double xmean = 0;
	        double ymean = 0;
	        double stat = 0;
	        double s = 0;
	        double p = 0;

	        if( n<=1 | m<=1 )
	        {
	            bothtails = 1.0;
	            lefttail = 1.0;
	            righttail = 1.0;
	            return;
	        }
	        
	        //
	        // Mean
	        //
	        xmean = 0;
	        for(i=0; i<=n-1; i++)
	        {
	            xmean = xmean+x[i];
	        }
	        xmean = xmean/n;
	        ymean = 0;
	        for(i=0; i<=m-1; i++)
	        {
	            ymean = ymean+y[i];
	        }
	        ymean = ymean/m;
	        
	        //
	        // S
	        //
	        s = 0;
	        for(i=0; i<=n-1; i++)
	        {
	            s = s+Math.pow(x[i]-xmean,2);
	        }
	        for(i=0; i<=m-1; i++)
	        {
	            s = s+Math.pow(y[i]-ymean,2);
	        }
	        s = Math.sqrt(s*((double)(1)/(double)(n)+(double)(1)/(double)(m))/(n+m-2));
	        if( s==0 )
	        {
	            bothtails = 1.0;
	            lefttail = 1.0;
	            righttail = 1.0;
	            return;
	        }
	        
	        //
	        // Statistic
	        //
	        stat = (xmean-ymean)/s;
	        p = StudentTDistribution.studentTDistribution(n+m-2, stat);
	        bothtails = 2*Math.min(p, 1-p);
	        lefttail = p;
	        righttail = 1-p;
	    }


	    /*************************************************************************
	    Two-sample unpooled test

	    This test checks three hypotheses about the mean of the given samples. The
	    following tests are performed:
	        * two-tailed test (null hypothesis - the means are equal)
	        * left-tailed test (null hypothesis - the mean of the first sample  is
	          greater than or equal to the mean of the second sample)
	        * right-tailed test (null hypothesis - the mean of the first sample is
	          less than or equal to the mean of the second sample).

	    Test is based on the following assumptions:
	        * given samples have normal distributions
	        * samples are independent.
	    Dispersion equality is not required

	    Input parameters:
	        X - sample 1. Array whose index goes from 0 to N-1.
	        N - size of the sample.
	        Y - sample 2. Array whose index goes from 0 to M-1.
	        M - size of the sample.

	    Output parameters:
	        BothTails   -   p-value for two-tailed test.
	                        If BothTails is less than the given significance level
	                        the null hypothesis is rejected.
	        LeftTail    -   p-value for left-tailed test.
	                        If LeftTail is less than the given significance level,
	                        the null hypothesis is rejected.
	        RightTail   -   p-value for right-tailed test.
	                        If RightTail is less than the given significance level
	                        the null hypothesis is rejected.

	      -- ALGLIB --
	         Copyright 18.09.2006 by Bochkanov Sergey
	    *************************************************************************/
	    public void unequalVarianceTTest(double[] x,
	        int n,
	        double[] y,
	        int m)
	    {
	        int i = 0;
	        double xmean = 0;
	        double ymean = 0;
	        double xvar = 0;
	        double yvar = 0;
	        double df = 0;
	        double p = 0;
	        double stat = 0;
	        double c = 0;

	        if( n<=1 | m<=1 )
	        {
	            bothtails = 1.0;
	            lefttail = 1.0;
	            righttail = 1.0;
	            return;
	        }
	        
	        //
	        // Mean
	        //
	        xmean = 0;
	        for(i=0; i<=n-1; i++)
	        {
	            xmean = xmean+x[i];
	        }
	        xmean = xmean/n;
	        ymean = 0;
	        for(i=0; i<=m-1; i++)
	        {
	            ymean = ymean+y[i];
	        }
	        ymean = ymean/m;
	        
	        //
	        // Variance (using corrected two-pass algorithm)
	        //
	        xvar = 0;
	        for(i=0; i<=n-1; i++)
	        {
	            xvar = xvar+Math.pow(x[i]-xmean,2);
	        }
	        xvar = xvar/(n-1);
	        yvar = 0;
	        for(i=0; i<=m-1; i++)
	        {
	            yvar = yvar+Math.pow(y[i]-ymean,2);
	        }
	        yvar = yvar/(m-1);
	        if( xvar==0 | yvar==0 )
	        {
	            bothtails = 1.0;
	            lefttail = 1.0;
	            righttail = 1.0;
	            return;
	        }
	        
	        //
	        // Statistic
	        //
	        stat = (xmean-ymean)/Math.sqrt(xvar/n+yvar/m);
	        c = xvar/n/(xvar/n+yvar/m);
	        df = (n-1)*(m-1)/((m-1)*Math.pow(c,2)+(n-1)*(1-Math.pow(c,2)));
	        if( stat>0 )
	        {
	            p = 1-0.5*IncompleteBetaIntegral.incompleteBeta(df/2, 0.5, df/(df+Math.pow(stat,2)));
	        }
	        else
	        {
	            p = 0.5*IncompleteBetaIntegral.incompleteBeta(df/2, 0.5, df/(df+Math.pow(stat,2)));
	        }
	        bothtails = 2*Math.min(p, 1-p);
	        lefttail = p;
	        righttail = 1-p;
	    }


		public double getBothtails() {
			return bothtails;
		}


		public double getLefttail() {
			return lefttail;
		}


		public double getRighttail() {
			return righttail;
		}
}
