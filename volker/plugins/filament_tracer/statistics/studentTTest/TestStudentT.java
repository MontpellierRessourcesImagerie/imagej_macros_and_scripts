package statistics.studentTTest;

public class TestStudentT {
	
	public static void main(String[] args) {
		test();
	}
	
	public static boolean testStudentT(boolean silent)
    {
        boolean result;
        int pass = 0;
        int passcount = 0;
        int maxn = 0;
        int n = 0;
        int m = 0;
        int i = 0;
        int qcnt = 0;
        double[] x = new double[0];
        double[] y = new double[0];
        double[] qtbl = new double[0];
        double[] ptbl = new double[0];
        double[] lptbl = new double[0];
        double[] rptbl = new double[0];
        double bt = 0;
        double lt = 0;
        double rt = 0;
        double v = 0;
        boolean waserrors;

        waserrors = false;
        maxn = 1000;
        passcount = 20000;
        x = new double[maxn-1+1];
        y = new double[maxn-1+1];
        qcnt = 8;
        ptbl = new double[qcnt-1+1];
        lptbl = new double[qcnt-1+1];
        rptbl = new double[qcnt-1+1];
        qtbl = new double[qcnt-1+1];
        qtbl[0] = 0.25;
        qtbl[1] = 0.15;
        qtbl[2] = 0.10;
        qtbl[3] = 0.05;
        qtbl[4] = 0.04;
        qtbl[5] = 0.03;
        qtbl[6] = 0.02;
        qtbl[7] = 0.01;
        
        StudentTTest studentTTest = new StudentTTest();
        if( !silent )
        {
            System.out.print("TESTING STUDENT T");
            System.out.println();
        }
        
        //
        // 1-sample test
        //
        if( !silent )
        {
        	System.out.print("Testing 1-sample test for 1-type errors");
        	System.out.println();
        }
        n = 15;
        for(i=0; i<=qcnt-1; i++)
        {
            ptbl[i] = 0;
            lptbl[i] = 0;
            rptbl[i] = 0;
        }
        for(pass=1; pass<=passcount; pass++)
        {
            
            //
            // Both tails
            //
            generateNormRandomNumbers(n, 0.0, 1+4*APMath.randomReal(), x);
            studentTTest.studentTTest(x, n, 0);
            bt = studentTTest.getBothtails();
            for(i=0; i<=qcnt-1; i++)
            {
                if( bt<=qtbl[i] )
                {
                    ptbl[i] = ptbl[i]+(double)(1)/(double)(passcount);
                }
            }
            
            //
            // Left tail
            //
            generateNormRandomNumbers(n, 0.5*APMath.randomReal(), 1+4*APMath.randomReal(), x);
            studentTTest.studentTTest(x, n, 0);
            lt = studentTTest.getLefttail();
            for(i=0; i<=qcnt-1; i++)
            {
                if( lt<=qtbl[i] )
                {
                    lptbl[i] = lptbl[i]+(double)(1)/(double)(passcount);
                }
            }
            
            //
            // Right tail
            //
            generateNormRandomNumbers(n, -(0.5*APMath.randomReal()), 1+4*APMath.randomReal(), x);
            studentTTest.studentTTest(x, n, 0);
            rt = studentTTest.getRighttail();
            for(i=0; i<=qcnt-1; i++)
            {
                if( rt<=qtbl[i] )
                {
                    rptbl[i] = rptbl[i]+(double)(1)/(double)(passcount);
                }
            }
        }
        if( !silent )
        {
            System.out.print("Expect. Both    Left    Right");
            System.out.println();
            for(i=0; i<=qcnt-1; i++)
            {            	
                System.out.printf("%3.3f", qtbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%3.3f",ptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%3.3f",lptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%3.3f",rptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.println();
            }
        }
        for(i=0; i<=qcnt-1; i++)
        {
            waserrors = waserrors | ptbl[i]/qtbl[i]>1.3 | qtbl[i]/ptbl[i]>1.3;
            waserrors = waserrors | lptbl[i]>qtbl[i]*1.3;
            waserrors = waserrors | rptbl[i]>qtbl[i]*1.3;
        }
        
        //
        // 2-sample test
        //
        if( !silent )
        {
            System.out.println();
            System.out.println();
            System.out.print("Testing 2-sample test for 1-type errors");
            System.out.println();
        }
        for(i=0; i<=qcnt-1; i++)
        {
            ptbl[i] = 0;
            lptbl[i] = 0;
            rptbl[i] = 0;
        }
        for(pass=1; pass<=passcount; pass++)
        {
            n = 5+APMath.randomInteger(20);
            m = 5+APMath.randomInteger(20);
            v = 1+4*APMath.randomReal();
            
            //
            // Both tails
            //
            generateNormRandomNumbers(n, 0.0, v, x);
            generateNormRandomNumbers(m, 0.0, v, y);
            studentTTest.studentTTest(x, n, y, m);
            bt = studentTTest.getBothtails();
            for(i=0; i<=qcnt-1; i++)
            {
                if( bt<=qtbl[i] )
                {
                    ptbl[i] = ptbl[i]+(double)(1)/(double)(passcount);
                }
            }
            
            //
            // Left tail
            //
            generateNormRandomNumbers(n, 0.5*APMath.randomReal(), v, x);
            generateNormRandomNumbers(m, 0.0, v, y);
            studentTTest.studentTTest(x, n, y, m);
           lt = studentTTest.getLefttail();
            for(i=0; i<=qcnt-1; i++)
            {
                if( lt<=qtbl[i] )
                {
                    lptbl[i] = lptbl[i]+(double)(1)/(double)(passcount);
                }
            }
            
            //
            // Right tail
            //
            generateNormRandomNumbers(n, -(0.5*APMath.randomReal()), v, x);
            generateNormRandomNumbers(m, 0.0, v, y);
            studentTTest.studentTTest(x, n, y, m);
            rt = studentTTest.getRighttail();
            for(i=0; i<=qcnt-1; i++)
            {
                if( rt<=qtbl[i] )
                {
                    rptbl[i] = rptbl[i]+(double)(1)/(double)(passcount);
                }
            }
        }
        if( !silent )
        {
            System.out.print("Expect. Both    Left    Right");
            System.out.println();
            for(i=0; i<=qcnt-1; i++)
            {
                System.out.printf("%1.4f",qtbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%1.4f",ptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%1.4f",lptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%1.4f",rptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.println();
            }
        }
        for(i=0; i<=qcnt-1; i++)
        {
            waserrors = waserrors | ptbl[i]/qtbl[i]>1.3 | qtbl[i]/ptbl[i]>1.3;
            waserrors = waserrors | lptbl[i]>qtbl[i]*1.3;
            waserrors = waserrors | rptbl[i]>qtbl[i]*1.3;
        }
        
        //
        // Unequal variance test
        //
        if( !silent )
        {
            System.out.println();
            System.out.println();
            System.out.print("Testing unequal variance test for 1-type errors");
            System.out.println();
        }
        for(i=0; i<=qcnt-1; i++)
        {
            ptbl[i] = 0;
            lptbl[i] = 0;
            rptbl[i] = 0;
        }
        for(pass=1; pass<=passcount; pass++)
        {
            n = 15+APMath.randomInteger(20);
            m = 15+APMath.randomInteger(20);
            
            //
            // Both tails
            //
            generateNormRandomNumbers(n, 0.0, 1+4*APMath.randomReal(),  x);
            generateNormRandomNumbers(m, 0.0, 1+4*APMath.randomReal(),  y);
            studentTTest.unequalVarianceTTest(x, n, y, m);
            bt = studentTTest.getBothtails();
            for(i=0; i<=qcnt-1; i++)
            {
                if( bt<=qtbl[i] )
                {
                    ptbl[i] = ptbl[i]+(double)(1)/(double)(passcount);
                }
            }
            
            //
            // Left tail
            //
            generateNormRandomNumbers(n, 0.5*APMath.randomReal(), 1+4*APMath.randomReal(), x);
            generateNormRandomNumbers(m, 0.0, 1+4*APMath.randomReal(), y);
            studentTTest.unequalVarianceTTest(x, n, y, m);
            lt = studentTTest.getLefttail();
            for(i=0; i<=qcnt-1; i++)
            {
                if( lt<=qtbl[i] )
                {
                    lptbl[i] = lptbl[i]+(double)(1)/(double)(passcount);
                }
            }
            
            //
            // Right tail
            //
            generateNormRandomNumbers(n, -(0.5*APMath.randomReal()), 1+4*APMath.randomReal(), x);
            generateNormRandomNumbers(m, 0.0, 1+4*APMath.randomReal(), y);
            studentTTest.unequalVarianceTTest(x, n, y, m);
            rt = studentTTest.getRighttail();
            for(i=0; i<=qcnt-1; i++)
            {
                if( rt<=qtbl[i] )
                {
                    rptbl[i] = rptbl[i]+(double)(1)/(double)(passcount);
                }
            }
        }
        if( !silent )
        {
            System.out.print("Expect. Both    Left    Right");
            System.out.println();
            for(i=0; i<=qcnt-1; i++)
            {
                System.out.printf("%1.4f",qtbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%1.4f",ptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%1.4f",lptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.printf("%1.4f",rptbl[i]*100);
                System.out.print("%");
                System.out.print("   ");
                System.out.println();
            }
        }
        for(i=0; i<=qcnt-1; i++)
        {
            waserrors = waserrors | ptbl[i]/qtbl[i]>1.3 | qtbl[i]/ptbl[i]>1.3;
            waserrors = waserrors | lptbl[i]>qtbl[i]*1.3;
            waserrors = waserrors | rptbl[i]>qtbl[i]*1.3;
        }
        
        if( !silent )
        {
            if( waserrors )
            {
                System.out.print("TEST FAILED");
                System.out.println();
            }
            else
            {
                System.out.print("TEST PASSED");
                System.out.println();
            }
        }
        result = !waserrors;
        return result;
    }


    private static void generateNormRandomNumbers(int n,
        double mean,
        double sigma,
        double[] r)
    {
        int i = 0;
        double u = 0;
        double v = 0;
        double sum = 0;

        i = 0;
        while( i<n )
        {
            u = (2*APMath.randomInteger(2)-1)*APMath.randomReal();
            v = (2*APMath.randomInteger(2)-1)*APMath.randomReal();
            sum = u*u+v*v;
            if( sum<1 & sum>0 )
            {
                sum = Math.sqrt(-(2*Math.log(sum)/sum));
                if( i<n )
                {
                    r[i] = sigma*u*sum+mean;
                }
                if( i+1<n )
                {
                    r[i+1] = sigma*v*sum+mean;
                }
                i = i+2;
            }
        }
    }


    /*************************************************************************
    Silent unit test
    *************************************************************************/
    public static boolean testSilent()
    {
        boolean result;

        result = testStudentT(true);
        return result;
    }


    /*************************************************************************
    Unit test
    *************************************************************************/
    public static boolean test()
    {
        boolean result;

        result = testStudentT(false);
        return result;
    }
}
