x = newArray(0.00, 1.00, 2.00, 3.00, 4.00, 5.00)
y = newArray(0.00, 0.90, 4.50, 8.00, 18.00, 24.00) 

Fit.doFit('gaussian', x, y);
d = Fit.p(3);
FWHM = 2* sqrt(2 * log(2)) * d;
print(FWHM);
