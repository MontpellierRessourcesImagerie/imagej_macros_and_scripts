/**
 * Convolve a 1D-array with a kernel.
 */
 
radius = 1;

Dialog.create("Convolve plot options");
Dialog.addNumber("radius:", radius);
Dialog.show();
radius = Dialog.getNumber();

kernel = meanKernel(radius);
Plot.getValues(xpoints, ypoints);
smoothedArray = convolve(ypoints, kernel, "constant");
Plot.setColor("green");
Plot.add("line", smoothedArray); 
Plot.setColor("black");
    
 
function meanKernel(radius) {
    n = 2 * radius + 1;
    kernel = newArray(n);
    for (i = 0; i < n; i++) {
        kernel[i] = 1 / n;
    }
    return kernel;
}
 
function convolve(array, kernel, borderHandling) {
    if ((kernel.length % 2) == 0) {
        exit("The size of the kernel needs to be odd but the kernel size is: " + kernel.length);
    }
    
    kernelCenterIndex = Math.floor(kernel.length / 2);
    resultArray = newArray(array.length);
    for (i = 0; i < resultArray.length; i++) {
        sum = 0;
        for (k = 0; k < kernel.length; k++) {
            currentFactor = kernel[k];
            currentIndex = i - kernelCenterIndex + k;
            currentValue = array[i];
            if (currentIndex > -1 && currentIndex < array.length) {
                currentValue = array[currentIndex];
            }
            sum = sum + currentValue * currentFactor;
        }
        resultArray[i] = sum;
    }
    return resultArray;
}
