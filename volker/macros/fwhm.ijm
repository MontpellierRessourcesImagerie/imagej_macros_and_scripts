y = getProfile();
x = Array.getSequence(y.length);
Fit.doFit('gaussian', x, y);
d = Fit.p(3);
FWHM = 2* sqrt(2 * log(2)) * d;
print(FWHM);
