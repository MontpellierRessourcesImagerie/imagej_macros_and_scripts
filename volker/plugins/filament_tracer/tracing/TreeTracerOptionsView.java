package tracing;

import java.awt.BorderLayout;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JTabbedPane;
import java.awt.Rectangle;
import java.util.Observable;
import java.util.Observer;
import javax.swing.JLabel;
import java.awt.GridLayout;
import javax.swing.JTextField;
import javax.swing.JCheckBox;

public class TreeTracerOptionsView extends JFrame implements Observer {

	private static final long serialVersionUID = 1L;

	private JPanel jContentPane = null;

	private TreeTracerOptions model;

	private JPanel mainPanel = null;

	private JTabbedPane optionsTabbedPane = null;

	private JPanel seedPointsFinderPanel = null;

	private JPanel filamentTracerPanel = null;

	private JLabel fractionOfHorizontalLinesLabel = null;

	private JTextField fractionOfHorizontalLinesTextField = null;

	private JTextField fractionOfVerticalLinesTextField = null;

	private JLabel fractionOfVerticalLinesLabel = null;

	private JTextField canThresholdScalingFactorTextField = null;

	private JLabel canThresholdScalingFactorLabel = null;

	private JTextField signalNoiseRatioRegionsRadiusTextField = null;

	private JLabel signalNoiseRatioRegionsRadiusLabel = null;

	private JTextField stepSizeTextField = null;

	private JLabel stepSizeLabel = null;

	private JTextField maxFilamentWidthTextField = null;

	private JLabel maxFilamentWidthLabel = null;

	private JTextField minimumTractingLengthTextField = null;

	private JLabel minimumTracingLengthLabel = null;

	private JPanel generalOptionsPanel = null;

	private JCheckBox enhanceContrastCheckBox = null;

	private JCheckBox useSkeletonCheckBox = null;

	/**
	 * This is the default constructor
	 */
	public TreeTracerOptionsView() {
		super();
		initialize();
	}

	public TreeTracerOptionsView(TreeTracerOptions options) {
		super();
		model = options;
		model.addObserver(this);
		initialize();
		this.setup();
	}

	private void setup() {
		getEnhanceContrastCheckBox().setSelected(model.isEnhanceContrast());
		getFractionOfHorizontalLinesTextField().setText(Float.toString(model.getHorizontalLinesFraction()));
		getFractionOfVerticalLinesTextField().setText(Float.toString(model.getVerticalLinesFraction()));
		getCanThresholdScalingFactorTextField().setText(Float.toString(model.getCanThresholdScalingFactor()));
		getSignalNoiseRatioRegionsRadiusTextField().setText(Integer.toString(model.getSnrEstimationRegionRadius()));
		getStepSizeTextField().setText(Integer.toString(model.getStepSize()));
		getMaxFilamentWidthTextField().setText(Integer.toString(model.getMaxFilamentWidth()));
		getMinimumTractingLengthTextField().setText(Float.toString(model.getMinTracingLength()));
		getUseSkeletonCheckBox().setSelected(model.getUseSkeletonPoints());
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(433, 371);
		this.setContentPane(getJContentPane());
		this.setTitle("tree tracer options");
		this.addWindowListener(new java.awt.event.WindowAdapter() {
			public void windowClosing(java.awt.event.WindowEvent e) {
				model.saveOptions();
			}
		});
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			jContentPane = new JPanel();
			jContentPane.setLayout(new BorderLayout());
			jContentPane.add(getMainPanel(), BorderLayout.CENTER);
		}
		return jContentPane;
	}

	public void update(Observable arg0, Object arg1) {
		// TODO Auto-generated method stub
		
	}

	/**
	 * This method initializes mainPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getMainPanel() {
		if (mainPanel == null) {
			GridLayout gridLayout = new GridLayout();
			gridLayout.setRows(1);
			gridLayout.setColumns(1);
			mainPanel = new JPanel();
			mainPanel.setLayout(gridLayout);
			mainPanel.add(getOptionsTabbedPane(), null);
		}
		return mainPanel;
	}

	/**
	 * This method initializes optionsTabbedPane	
	 * 	
	 * @return javax.swing.JTabbedPane	
	 */
	private JTabbedPane getOptionsTabbedPane() {
		if (optionsTabbedPane == null) {
			optionsTabbedPane = new JTabbedPane();
			optionsTabbedPane.addTab("seed points finder", null, getSeedPointsFinderPanel(), null);
			optionsTabbedPane.addTab("filament tracer", null, getFilamentTracerPanel(), null);
			optionsTabbedPane.addTab("general", null, getGeneralOptionsPanel(), null);
		}
		return optionsTabbedPane;
	}

	/**
	 * This method initializes seedPointsFinderPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getSeedPointsFinderPanel() {
		if (seedPointsFinderPanel == null) {
			signalNoiseRatioRegionsRadiusLabel = new JLabel();
			signalNoiseRatioRegionsRadiusLabel.setBounds(new Rectangle(89, 165, 311, 16));
			signalNoiseRatioRegionsRadiusLabel.setText("radius of regions for signal-to-noise-ratio estimation");
			canThresholdScalingFactorLabel = new JLabel();
			canThresholdScalingFactorLabel.setBounds(new Rectangle(89, 116, 180, 16));
			canThresholdScalingFactorLabel.setText("Can-threshold scaling factor");
			fractionOfVerticalLinesLabel = new JLabel();
			fractionOfVerticalLinesLabel.setBounds(new Rectangle(89, 64, 158, 16));
			fractionOfVerticalLinesLabel.setText("fraction of vertical lines");
			fractionOfHorizontalLinesLabel = new JLabel();
			fractionOfHorizontalLinesLabel.setBounds(new Rectangle(89, 34, 158, 16));
			fractionOfHorizontalLinesLabel.setText("fraction of horizontal lines");
			seedPointsFinderPanel = new JPanel();
			seedPointsFinderPanel.setLayout(null);
			seedPointsFinderPanel.add(fractionOfHorizontalLinesLabel, null);
			seedPointsFinderPanel.add(getFractionOfHorizontalLinesTextField(), null);
			seedPointsFinderPanel.add(getFractionOfVerticalLinesTextField(), null);
			seedPointsFinderPanel.add(fractionOfVerticalLinesLabel, null);
			seedPointsFinderPanel.add(getCanThresholdScalingFactorTextField(), null);
			seedPointsFinderPanel.add(canThresholdScalingFactorLabel, null);
			seedPointsFinderPanel.add(getSignalNoiseRatioRegionsRadiusTextField(), null);
			seedPointsFinderPanel.add(signalNoiseRatioRegionsRadiusLabel, null);
			seedPointsFinderPanel.add(getUseSkeletonCheckBox(), null);
		}
		return seedPointsFinderPanel;
	}

	/**
	 * This method initializes filamentTracerPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getFilamentTracerPanel() {
		if (filamentTracerPanel == null) {
			minimumTracingLengthLabel = new JLabel();
			minimumTracingLengthLabel.setBounds(new Rectangle(89, 161, 158, 16));
			minimumTracingLengthLabel.setText("minimum tracing length");
			maxFilamentWidthLabel = new JLabel();
			maxFilamentWidthLabel.setBounds(new Rectangle(89, 98, 158, 16));
			maxFilamentWidthLabel.setText("maximum filament width");
			stepSizeLabel = new JLabel();
			stepSizeLabel.setBounds(new Rectangle(89, 34, 158, 16));
			stepSizeLabel.setText("step size");
			filamentTracerPanel = new JPanel();
			filamentTracerPanel.setLayout(null);
			filamentTracerPanel.add(getStepSizeTextField(), null);
			filamentTracerPanel.add(stepSizeLabel, null);
			filamentTracerPanel.add(getMaxFilamentWidthTextField(), null);
			filamentTracerPanel.add(maxFilamentWidthLabel, null);
			filamentTracerPanel.add(getMinimumTractingLengthTextField(), null);
			filamentTracerPanel.add(minimumTracingLengthLabel, null);
		}
		return filamentTracerPanel;
	}

	/**
	 * This method initializes fractionOfHorizontalLinesTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getFractionOfHorizontalLinesTextField() {
		if (fractionOfHorizontalLinesTextField == null) {
			fractionOfHorizontalLinesTextField = new JTextField();
			fractionOfHorizontalLinesTextField.setBounds(new Rectangle(41, 32, 36, 20));
			fractionOfHorizontalLinesTextField
					.addFocusListener(new java.awt.event.FocusAdapter() {
						public void focusLost(java.awt.event.FocusEvent e) {
							model.setHorizontalLinesFraction(Float.parseFloat(getFractionOfHorizontalLinesTextField().getText()));
						}
					});
			fractionOfHorizontalLinesTextField
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.setHorizontalLinesFraction(Float.parseFloat(getFractionOfHorizontalLinesTextField().getText()));
						}
					});
		}
		return fractionOfHorizontalLinesTextField;
	}

	/**
	 * This method initializes fractionOfVerticalLinesTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getFractionOfVerticalLinesTextField() {
		if (fractionOfVerticalLinesTextField == null) {
			fractionOfVerticalLinesTextField = new JTextField();
			fractionOfVerticalLinesTextField.setBounds(new Rectangle(41, 62, 36, 20));
			fractionOfVerticalLinesTextField
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.setVerticalLinesFraction(Float.parseFloat(getFractionOfVerticalLinesTextField().getText()));
						}
					});
			fractionOfVerticalLinesTextField
					.addFocusListener(new java.awt.event.FocusAdapter() {
						public void focusLost(java.awt.event.FocusEvent e) {
							model.setVerticalLinesFraction(Float.parseFloat(getFractionOfVerticalLinesTextField().getText()));
						}
					});
		}
		return fractionOfVerticalLinesTextField;
	}

	/**
	 * This method initializes canThresholdScalingFactorTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getCanThresholdScalingFactorTextField() {
		if (canThresholdScalingFactorTextField == null) {
			canThresholdScalingFactorTextField = new JTextField();
			canThresholdScalingFactorTextField.setBounds(new Rectangle(41, 114, 36, 20));
			canThresholdScalingFactorTextField
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.setCanThresholdScalingFactor(Float.parseFloat(getCanThresholdScalingFactorTextField().getText()));
						}
					});
			canThresholdScalingFactorTextField
					.addFocusListener(new java.awt.event.FocusAdapter() {
						public void focusLost(java.awt.event.FocusEvent e) {
							model.setCanThresholdScalingFactor(Float.parseFloat(getCanThresholdScalingFactorTextField().getText()));
						}
					});
		}
		return canThresholdScalingFactorTextField;
	}

	/**
	 * This method initializes signalNoiseRatioRegionsRadiusTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getSignalNoiseRatioRegionsRadiusTextField() {
		if (signalNoiseRatioRegionsRadiusTextField == null) {
			signalNoiseRatioRegionsRadiusTextField = new JTextField();
			signalNoiseRatioRegionsRadiusTextField.setBounds(new Rectangle(41, 163, 36, 20));
			signalNoiseRatioRegionsRadiusTextField
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.setSnrEstimationRegionRadius(Integer.parseInt(getSignalNoiseRatioRegionsRadiusTextField().getText()));
						}
					});
			signalNoiseRatioRegionsRadiusTextField
					.addFocusListener(new java.awt.event.FocusAdapter() {
						public void focusLost(java.awt.event.FocusEvent e) {
							model.setSnrEstimationRegionRadius(Integer.parseInt(getSignalNoiseRatioRegionsRadiusTextField().getText()));
						}
					});
		}
		return signalNoiseRatioRegionsRadiusTextField;
	}

	/**
	 * This method initializes stepSizeTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getStepSizeTextField() {
		if (stepSizeTextField == null) {
			stepSizeTextField = new JTextField();
			stepSizeTextField.setBounds(new Rectangle(41, 32, 36, 20));
			stepSizeTextField.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.setStepSize(Integer.parseInt(getStepSizeTextField().getText()));
				}
			});
			stepSizeTextField.addFocusListener(new java.awt.event.FocusAdapter() {
				public void focusLost(java.awt.event.FocusEvent e) {
					model.setStepSize(Integer.parseInt(getStepSizeTextField().getText()));
				}
			});
		}
		return stepSizeTextField;
	}

	/**
	 * This method initializes maxFilamentWidthTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getMaxFilamentWidthTextField() {
		if (maxFilamentWidthTextField == null) {
			maxFilamentWidthTextField = new JTextField();
			maxFilamentWidthTextField.setBounds(new Rectangle(41, 96, 36, 20));
			maxFilamentWidthTextField
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.setMaxFilamentWidth(Integer.parseInt(getMaxFilamentWidthTextField().getText()));
						}
					});
			maxFilamentWidthTextField.addFocusListener(new java.awt.event.FocusAdapter() {
				public void focusLost(java.awt.event.FocusEvent e) {
					model.setMaxFilamentWidth(Integer.parseInt(getMaxFilamentWidthTextField().getText()));
				}
			});
		}
		return maxFilamentWidthTextField;
	}

	/**
	 * This method initializes minimumTractingLengthTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getMinimumTractingLengthTextField() {
		if (minimumTractingLengthTextField == null) {
			minimumTractingLengthTextField = new JTextField();
			minimumTractingLengthTextField.setBounds(new Rectangle(41, 159, 36, 20));
			minimumTractingLengthTextField
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.setMinTracingLength(Float.parseFloat(getMinimumTractingLengthTextField().getText()));
						}
					});
			minimumTractingLengthTextField
					.addFocusListener(new java.awt.event.FocusAdapter() {
						public void focusLost(java.awt.event.FocusEvent e) {
							model.setMinTracingLength(Float.parseFloat(getMinimumTractingLengthTextField().getText()));
						}
					});
		}
		return minimumTractingLengthTextField;
	}

	/**
	 * This method initializes generalOptionsPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getGeneralOptionsPanel() {
		if (generalOptionsPanel == null) {
			generalOptionsPanel = new JPanel();
			generalOptionsPanel.setLayout(null);
			generalOptionsPanel.add(getEnhanceContrastCheckBox(), null);
		}
		return generalOptionsPanel;
	}

	/**
	 * This method initializes enhanceContrastCheckBox	
	 * 	
	 * @return javax.swing.JCheckBox	
	 */
	private JCheckBox getEnhanceContrastCheckBox() {
		if (enhanceContrastCheckBox == null) {
			enhanceContrastCheckBox = new JCheckBox();
			enhanceContrastCheckBox.setBounds(new Rectangle(41, 32, 220, 21));
			enhanceContrastCheckBox.setText("use contrast enhancement");
			enhanceContrastCheckBox.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.setEnhanceContrast(!model.isEnhanceContrast());
				}
			});
		}
		return enhanceContrastCheckBox;
	}

	/**
	 * This method initializes useSkeletonCheckBox	
	 * 	
	 * @return javax.swing.JCheckBox	
	 */
	private JCheckBox getUseSkeletonCheckBox() {
		if (useSkeletonCheckBox == null) {
			useSkeletonCheckBox = new JCheckBox();
			useSkeletonCheckBox.setBounds(new Rectangle(49, 223, 340, 21));
			useSkeletonCheckBox.setText("use skeleton end- and branching points");
			useSkeletonCheckBox.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.setUseSkeletonPoints(!model.getUseSkeletonPoints());
				}
			});
		}
		return useSkeletonCheckBox;
	}

}  //  @jve:decl-index=0:visual-constraint="10,10"
