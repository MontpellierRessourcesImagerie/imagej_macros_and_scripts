import java.util.ArrayList;
import java.util.List;
import java.util.Collections;

import java.awt.Point;
import java.awt.Polygon;
import ij.IJ;
import ij.ImagePlus;
import ij.Macro;
import ij.gui.Line;
import ij.gui.PointRoi;
import ij.gui.PolygonRoi;
import ij.gui.Roi;
import ij.plugin.*;
import ij.plugin.frame.RoiManager;
import ij.process.ImageProcessor;

public class RoiToLineTool{
    private boolean debugFlag = false;
    public int connectivity = 8;

    private ImagePlus image;
    private Roi roi;

    List<Point> pointsA = new ArrayList();
    List<Point> pointsB = new ArrayList();
    

    public RoiToLineTool(ImagePlus imp){
        this.image = imp;
        this.roi = imp.getRoi();
    }

    public ImagePlus getImage(){
        return this.image;
    }

    public Roi getRoi(){
        return this.roi;
    }

    public void run(){
        makeLineFromRoi(this.roi);
    }
    public void debugRun(){
        debugFlag = true;
        run();
    }

    private void print(String s){
        if(debugFlag){
            IJ.log(s);
        }
    }
    
    public void makeLineFromRoi(Roi roi){
        Point[] containedPoints = roi.getContainedPoints();

        pointsA.add(containedPoints[0]);
        pointsB.add(containedPoints[0]);
        
        exploreFromPoint(containedPoints[0],roi,pointsA);
        exploreFromPoint(containedPoints[0],roi,pointsB);

        pointsB.remove(0);

        Collections.reverse(pointsB);
        pointsB.addAll(pointsA);

        int[] pointsX = new int[pointsB.size()];
        int[] pointsY = new int[pointsB.size()];

        print("List :");
        int i=0;
        for(Point p : pointsB){
            pointsX[i] = (int) p.getX();
            pointsY[i++] = (int) p.getY();
            print(p.toString());
        }

        Roi newRoi = new PolygonRoi(pointsX,pointsY,i, Roi.POLYLINE);
        
        this.image.setRoi(newRoi);
        this.image.updateAndDraw();
    }
    
    public void exploreFromPoint(Point firstPoint, Roi roi, List<Point> pointList){

        while(true){
            Point point = getNextNeighboor(pointList.get(pointList.size()-1),roi);
            if(point==null){    break;}
            pointList.add(point);
        }
    }
    
    private Point getNextNeighboor(Point currentPoint,Roi roi){
        int pointX = (int) currentPoint.getX();
        int pointY = (int) currentPoint.getY();
        print("Leaving ("+pointX+","+pointY+")");
        if(connectivity==4){
            return getNextNeighboor4(currentPoint, roi);
        }else{
            return getNextNeighboor8(currentPoint, roi);    
        }

    }

    private Point getNeighboor(Point currentPoint,Roi roi,int xMovement,int yMovement){
        int pointX = xMovement + (int) currentPoint.getX();
        int pointY = yMovement + (int) currentPoint.getY();
        print("Search ("+ pointX+","+pointY+")");
        
        if(roi.contains(pointX,pointY)){
            print("Found ("+pointX+","+pointY+") !");

            for(Point pastPoint : pointsA){
                if(pastPoint.getX() == pointX && 
                   pastPoint.getY() == pointY){ 
                    print("The point is already in the List A");
                    return null;
                }
            }

            for(Point pastPoint : pointsB){
                if(pastPoint.getX() == pointX && 
                   pastPoint.getY() == pointY){
                    print("The point is already in the List B");
                    return null;
                }
            }
            return new Point(pointX,pointY);
        }
        return null;
    }

    private Point getNextNeighboor8(Point currentPoint,Roi roi){
        Point point;

        point = getNextNeighboor4(currentPoint, roi);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, -1, -1);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, -1, 1);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, 1, 1);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, 1, -1);
        if(point!=null){    return point;}

        return null;
    }

    private Point getNextNeighboor4(Point currentPoint,Roi roi){
        Point point;

        point = getNeighboor(currentPoint, roi, -1, 0);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, 0, -1);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, 1, 0);
        if(point!=null){    return point;}

        point = getNeighboor(currentPoint, roi, 0, 1);
        if(point!=null){    return point;}

        return null;
    }
}
