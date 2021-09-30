package tracing;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Observable;
import java.util.Properties;

public class TreeTracerOptions extends Observable {

	protected TreeTracerOptionsView view;
	
	protected boolean enhanceContrast;

	protected float horizontalLinesFraction;
	protected float verticalLinesFraction;
	protected float canThresholdScalingFactor;
	protected int snrEstimationRegionRadius;
	protected boolean useSkeletonPoints;
	
	protected int maxFilamentWidth;
	protected int stepSize;
	protected float minTracingLength;
	
	protected Properties properties;

	public TreeTracerOptions() {
		this.setDefaultValues();
		File optionsFile = new File(this.getFilename());
		if (optionsFile.exists()) {
			this.loadOptions();
		}
	}
	
	public void setDefaultValues() {
		enhanceContrast = true;
		
		horizontalLinesFraction = 0.25f;
		verticalLinesFraction = 0.25f;
		
		canThresholdScalingFactor = 0.16f;
		
		snrEstimationRegionRadius = 6;
		
		useSkeletonPoints = false;
		
		maxFilamentWidth = 6;
		
		stepSize = 2;
		
		minTracingLength = 20;
	}
	
	public void show() {
		this.getView().setVisible(true);
	}

	public TreeTracerOptionsView getView() {
		if (view==null) view = new TreeTracerOptionsView(this);
		return view;
	}

	public float getCanThresholdScalingFactor() {
		return canThresholdScalingFactor;
	}

	public void setCanThresholdScalingFactor(float canThresholdScalingFactor) {
		this.canThresholdScalingFactor = canThresholdScalingFactor;
	}

	public float getHorizontalLinesFraction() {
		return horizontalLinesFraction;
	}

	public void setHorizontalLinesFraction(float horizontalLinesFraction) {
		this.horizontalLinesFraction = horizontalLinesFraction;
	}

	public int getMaxFilamentWidth() {
		return maxFilamentWidth;
	}

	public void setMaxFilamentWidth(int maxFilamentWidth) {
		this.maxFilamentWidth = maxFilamentWidth;
	}

	public float getMinTracingLength() {
		return minTracingLength;
	}

	public void setMinTracingLength(float minTracingLength) {
		this.minTracingLength = minTracingLength;
	}

	public int getSnrEstimationRegionRadius() {
		return snrEstimationRegionRadius;
	}

	public void setSnrEstimationRegionRadius(int snrEstimationRegionRadius) {
		this.snrEstimationRegionRadius = snrEstimationRegionRadius;
	}

	public int getStepSize() {
		return stepSize;
	}

	public void setStepSize(int stepSize) {
		this.stepSize = stepSize;
	}

	public float getVerticalLinesFraction() {
		return verticalLinesFraction;
	}

	public void setVerticalLinesFraction(float verticalLinesFraction) {
		this.verticalLinesFraction = verticalLinesFraction;
	}

	public void saveOptions() {
		properties = new Properties();
		properties.setProperty("enhance_contrast", Boolean.toString(this.isEnhanceContrast()));
		properties.setProperty("horizontal_lines_fraction", Float.toString(this.getHorizontalLinesFraction()));
		properties.setProperty("vertical_lines_fraction", Float.toString(this.getVerticalLinesFraction()));
		properties.setProperty("can_threshold_scaling_factor", Float.toString(this.getCanThresholdScalingFactor()));
		properties.setProperty("snr_estimation_region_radius", Integer.toString(this.getSnrEstimationRegionRadius()));
		properties.setProperty("max_filament_width", Integer.toString(this.getMaxFilamentWidth()));
		properties.setProperty("step_size", Integer.toString(this.getStepSize()));
		properties.setProperty("min_tracing_length", Float.toString(this.getMinTracingLength()));
		properties.setProperty("use_skeleton_points", Boolean.toString(this.getUseSkeletonPoints()));
		FileOutputStream out = null;
		try {
			out = new FileOutputStream(this.getFilename());
			properties.store(out, "Parameters for the MRI Tree Tracer");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				out.close();
			} catch (IOException e2) {
				/*ignore*/
			}
		}
	}

	public void loadOptions() {
		properties = new Properties();
		FileInputStream in = null;
		try {
			in = new FileInputStream(this.getFilename());
			properties.load(in);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				in.close();
			} catch (IOException e2) {
				/*ignore*/
			}
		}
		this.setEnhanceContrast(Boolean.parseBoolean(properties.getProperty("enhance_contrast")));
		this.setHorizontalLinesFraction(Float.parseFloat(properties.getProperty("horizontal_lines_fraction")));
		this.setVerticalLinesFraction(Float.parseFloat(properties.getProperty("vertical_lines_fraction")));
		this.setCanThresholdScalingFactor(Float.parseFloat(properties.getProperty("can_threshold_scaling_factor")));
		this.setSnrEstimationRegionRadius(Integer.parseInt(properties.getProperty("snr_estimation_region_radius")));
		this.setMaxFilamentWidth(Integer.parseInt(properties.getProperty("max_filament_width")));
		this.setStepSize(Integer.parseInt(properties.getProperty("step_size")));
		this.setMinTracingLength(Float.parseFloat(properties.getProperty("min_tracing_length")));
		this.setUseSkeletonPoints(Boolean.parseBoolean(properties.getProperty("use_skeleton_points")));
	}
	
	public String getFilename() {
		return "mri_tree_tracer_config.txt";
	}

	public boolean isEnhanceContrast() {
		return enhanceContrast;
	}

	public void setEnhanceContrast(boolean enhanceContrast) {
		this.enhanceContrast = enhanceContrast;
	}

	public boolean getUseSkeletonPoints() {
		return useSkeletonPoints;
	}

	public void setUseSkeletonPoints(boolean value) {
		useSkeletonPoints = value;
	}
}
