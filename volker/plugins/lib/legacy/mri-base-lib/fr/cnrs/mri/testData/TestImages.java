package fr.cnrs.mri.testData;

public class TestImages {
/*
 * Use slashes as separator on all systems windows included. 
 * A file created from such a string will be correct on all systems.
 */
public static final	String fileSource = "/media/DONNEES/testdata/";	
public static final String path = fileSource + "test_images/";
public static final String outputPath = fileSource + "test_output/" ;
public static final String metaDataTestImages = fileSource + "meta-data-test-images/" ;
	
	public static String image01Head() {
		return path +"01/head.tif";
	}
	
	public static String image01Date(){
		return "2009-02-02 02:02:00.0";
	}
	
	public static String image01ModificationDate() {
		return "2010-09-08 13:04:45.0";
	}
	
	public static String imageLeaf() {
		return path +"01/leaf.tif";
	}
	
	public static String imageLSM() {
		return path +"01/100xbille02vertetrouge2048par2048.lsm";
	}
	
	public static String imageDIB() {
		return path +"01/Logo.dib";
	}
	
	public static String image02Head(){
		return path +"02/head.tif";
	}
	
	public static String imageOrgan_of_corti(){
		return path + "01/organ-of-corti.tif";
	}
	
	public static String imageCardio(){
		return path + "01/Cardio.bmp";
	}
	
	public static String imageBlobs(){
		return path+"01/blobs.gif";
	}
	
	public static String imageBoats(){
		return path+"01/boats.gif";
	}
	
	public static String imageBridge(){
		return path+"01/bridge.gif";
	}
	
	public static String imageBat_cochlea_renderings(){
		return path+"01/bat-cochlea-renderings.tif";
	}
	
	public static String imageBat_cochlea_volume(){
		return path+ "01/bat-cochlea-volume.tif";
	}
	
	public static String imageAuPbSn40(){
		return path + "01/AuPbSn40.jpg";
	}

	public static String imageNdpi(){
		return metaDataTestImages + "ndpi/2008-10-01 13.22.53.ndpi";
	}
	
	public static String imageNdpiDate(){
		return "2008-10-01 11:31:00.0";
	}
	
	public static String imageNdpiModificationDate() {
		return "2010-09-08 13:10:31.0";
	}	
	
	public static String imageNdpiLoup1(){
		return path + "01/Loup 1 - 2007-01-31 14.18.58.ndpi";
	}
	
	public static String imageNdpiLoup4(){
		return path + "01/loup 4 CT - 2007-01-31 14.57.10.ndpi";
	}
	
	public static String imageSTK(){
		return path + "01/droit2-psf.STK";
	}
	
	public static String imageSTKDate(){
		return "2009-01-16 15:13:00.0";
	}
	
	public static String imageFits(){
		return path + "01/gel.fits";
	}
	
	public static String imageFitsDate(){
		return "2009-07-28 10:20:00.0";
	}
	
	public static String imageDCM(){
		return path + "01/Cardio.dcm";
	}
	
	public static String imageDCMDate(){
		return "2005-03-28 08:35:00.0";
	}
	
	public static String video (){
		return path + "01/nipkow.avi";
	}


	public static String videoDate (){
		return "2006-06-22 16:19:00.0";
	}
	
	public static String imageMriStack (){
		return path + "01/mri-stack.tif";
	}
	
	public static String imageMriStackDate (){
		return "2007-04-13 21:19:00.0";
	}
	
	public static String imageNileBend (){
		return path + "01/NileBend.tif";
	}
	
	public static String imageNileBendDate (){
		return "2009-07-28 15:13:00.0";
	}
	
	public static String imageHelaCcells (){
		return path + "01/hela-cells.tif";
	}
	
	public static String imageHelaCcellsDate (){
		return "2007-04-30 17:37:00.0";
	}
	
	public static String imageCerSag (){
		return path + "01/cer-sag.gif";
	}
	
	public static String imageCerSagDate (){
		return "2009-01-28 11:46:00.0";
	}
	
	public static String imageClown (){
		return path + "01/clown.jpg";
	}
	
	public static String amenatonStk() {
		return metaDataTestImages + "amenaton (stk tif)/stk/1.stk";
	}

	public static String amenatonTif() {
		return metaDataTestImages + "amenaton (stk tif)/tif/007.tif";
	}

	public static String avi01() {
		return metaDataTestImages + "avi/C2PH1a.AVI";
	}

	public static String bmp() {
		return metaDataTestImages + "dib/Logo.bmp";
	}
	
	public static String ims27() {
		return metaDataTestImages + "ims/t1-head0000-27.ims";
	}

	public static String ims30() {
		return metaDataTestImages + "ims/t1-head0000-30.ims";
	}

	public static String ims55() {
		return metaDataTestImages + "ims/t1-head0000-55.ims";
	}

	public static String lsm2d01() {
		return metaDataTestImages + "jezabel (lsm)/lsm-2d/FCbASwt1.lsm";
	}

	public static String lsm3d01() {
		return metaDataTestImages + "jezabel (lsm)/lsm-3d/A44ppax3h2.lsm";
	}

	public static String jpg01() {
		return metaDataTestImages + "jpg/Fibroblast_Cell_Nucleus.jpg";
	}

	public static String lei01() {
		return metaDataTestImages + "lcs (.lei)/pn103cyce.lei";
	}

	public static String mov01() {
		return metaDataTestImages + "mov/Ncad_Ampho.mov";
	}

	public static String nd01() {
		return metaDataTestImages + "nd/X228andX383TAPeC105/U2OSx228andX383.nd";
	}

	public static String ndpi01() {
		return metaDataTestImages + "ndpi/2008-10-01 13.22.53.ndpi";
	}

	public static String stk02() {
		return metaDataTestImages + "nefertiti/stk/IPA3_Well1_PH_Pos1_0002.stk";
	}

	public static String tif02() {
		return metaDataTestImages + "nefertiti/tif/EB3siGW_Well1_GFP_Pos1_0029.tif";
	}

	public static String tif03() {
		return metaDataTestImages + "nefertiti/tif/expt1_Well1_GFP_Pos1_0002.tif";
	}

	public static String stk03() {
		return metaDataTestImages + "osiris/stk/HeLa full beta_w1Cy3_s1.STK";
	}

	public static String tif04() {
		return metaDataTestImages + "osiris/tif/ccna2.tif";
	}

	public static String tif05() {
		return metaDataTestImages + "philistin/tif/_Well1_PH_Pos1_0010.tif";
	}
	
	public static String pic01() {
		return metaDataTestImages + "pic (biorad)/sdub/sdub7.pic";
	}

	public static String pic02() {
		return metaDataTestImages + "pic (biorad)/taaba/TAABA27.PIC";
	}

	public static String tif06() {
		return metaDataTestImages + "rahotep/RAHOTEP_080417110002_D04f03d1.TIF";
	}

	public static String tif07() {
		return metaDataTestImages + "scan/U2OSx595ex569_cond5of200309TAP/Scan20x1_w1_s12_t1.TIF";
	}

	public static String tif08() {
		return metaDataTestImages + "tefnout/tif/g3A+KCl1_c0.tif";
	}

	public static String tif09() {
		return metaDataTestImages + "tefnout/tif/mmc 11.tif";
	}

	public static String zvi01() {
		return metaDataTestImages + "zvi/probleme apotome x20.zvi";
	}
	
	public static String bigNDPI() {
		return fileSource + "09-03-1126-1 - 2009-10-15 17.36.26.ndpi";
	}
}
