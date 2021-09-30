package tracing;

import java.awt.BorderLayout;
import java.awt.Point;

import javax.swing.JPanel;
import javax.swing.JFrame;
import java.awt.Dimension;
import javax.swing.BoxLayout;
import javax.swing.JList;
import javax.swing.JScrollPane;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.JButton;
import java.awt.Rectangle;
import java.util.Observable;
import java.util.Observer;
import java.awt.Toolkit;
import java.awt.event.MouseEvent;
import javax.swing.JPopupMenu;
import javax.swing.JMenuItem;
import javax.swing.JMenuBar;
import javax.swing.JMenu;

public class TreeTracerView extends JFrame implements Observer {

	private static final long serialVersionUID = 1L;

	private JPanel jContentPane = null;

	private JPanel mainPanel = null;

	private JPanel treesPanel = null;

	private JPanel tracingsPanel = null;

	private JPanel seedPointsPanel = null;

	private JList seedsList = null;

	private JScrollPane seedsScrollPane = null;

	private JScrollPane tracingsScrollPane = null;

	private JList tracingsList = null;

	private JScrollPane treesScrollPane = null;

	private JList treesList = null;

	private JLabel treesLabel = null;

	private JLabel tracingsLabel = null;

	private JLabel seedsLabel = null;

	private JPanel treesActionsPanel = null;

	private JPanel tracingsActionsPanel = null;

	private JPanel seedsActionsPanel = null;

	private JPanel generalActionsPanel = null;

	private JButton addSeedsButton = null;

	private JButton traceButton = null;

	protected TreeTracer model = new TreeTracer();  //  @jve:decl-index=0:

	private JPopupMenu seedsPopupMenu = null;

	private JMenuItem removeSelectedSeedsMenuItem = null;

	private JPopupMenu tracingsPopupMenu = null;

	private JMenuItem removeSelectedTracingsMenuItem = null;

	private JButton findSeedsButton = null;

	private JMenuBar mainMenuBar = null;

	private JMenu optionsMenu = null;

	private JMenuItem editOptionsMenuItem = null;

	private JButton traceAllButton = null;

	private JButton traceBranchesButton = null;

	private JMenu sortTracingsMenu = null;

	private JMenuItem sortTracingsByLengthMenuItem = null;

	private JMenuItem sortTracingsByYDistanceMenuItem = null;

	private JMenuItem smoothMenuItem = null;

	private JMenuItem removeDuplicatesMenuItem = null;

	private JMenuItem measureMenuItem = null;

	private JMenuItem selectMenuItem = null;

	private JMenuItem sortSeedsByDistanceMenuItem = null;

	private JMenu sortMenu = null;

	private JMenuItem sortByYCoordinateMenuItem = null;

	private JButton createTreeButton = null;

	private JMenu selectMenu = null;

	private JMenuItem selectContourMenuItem = null;

	private JMenuItem sortTracingsByMeanIntensityMenuItem = null;

	private JMenuItem sortTracingsBySNRMenuItem = null;

	private JMenuItem drawCenterLinesMenuItem = null;

	private JMenu drawMenu = null;

	private JMenu colorsMenu = null;

	private JMenuItem cycleColorsMenuItem = null;

	private JPopupMenu treesPopupMenu = null;  //  @jve:decl-index=0:visual-constraint="671,487"

	private JMenuItem removeTreesMenuItem = null;

	/**
	 * This is the default constructor
	 */
	public TreeTracerView() {
		super();
		initialize();
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(596, 416);
		this.setJMenuBar(getMainMenuBar());
		this.setIconImage(Toolkit.getDefaultToolkit().getImage(
				getClass().getResource("/resources/images/icon.gif")));
		this.setContentPane(getJContentPane());
		this.setTitle("MRI Tree Tracer");
	}
	
	public TreeTracerView(TreeTracer tracer) {
		super();
		this.model = tracer;
		model.addObserver(this);
		initialize();
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
			jContentPane.add(getGeneralActionsPanel(), BorderLayout.SOUTH);
		}
		return jContentPane;
	}

	/**
	 * This method initializes mainPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getMainPanel() {
		if (mainPanel == null) {
			mainPanel = new JPanel();
			mainPanel
					.setLayout(new BoxLayout(getMainPanel(), BoxLayout.X_AXIS));
			mainPanel.add(getTreesPanel(), null);
			mainPanel.add(getTracingsPanel(), null);
			mainPanel.add(getSeedPointsPanel(), null);
		}
		return mainPanel;
	}

	/**
	 * This method initializes treesPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getTreesPanel() {
		if (treesPanel == null) {
			treesLabel = new JLabel();
			treesLabel.setText("trees");
			treesLabel.setHorizontalAlignment(SwingConstants.CENTER);
			treesPanel = new JPanel();
			treesPanel.setLayout(new BorderLayout());
			treesPanel.add(treesLabel, BorderLayout.NORTH);
			treesPanel.add(getTreesScrollPane(), BorderLayout.CENTER);
			treesPanel.add(getTreesActionsPanel(), BorderLayout.SOUTH);
		}
		return treesPanel;
	}

	/**
	 * This method initializes tracingsPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getTracingsPanel() {
		if (tracingsPanel == null) {
			tracingsLabel = new JLabel();
			tracingsLabel.setText("tracings");
			tracingsLabel.setHorizontalAlignment(SwingConstants.CENTER);
			tracingsPanel = new JPanel();
			tracingsPanel.setLayout(new BorderLayout());
			tracingsPanel.add(getTracingsScrollPane(), BorderLayout.CENTER);
			tracingsPanel.add(tracingsLabel, BorderLayout.NORTH);
			tracingsPanel.add(getTracingsActionsPanel(), BorderLayout.SOUTH);
		}
		return tracingsPanel;
	}

	/**
	 * This method initializes seedPointsPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getSeedPointsPanel() {
		if (seedPointsPanel == null) {
			seedsLabel = new JLabel();
			seedsLabel.setText("seeds");
			seedsLabel.setHorizontalAlignment(SwingConstants.CENTER);
			seedPointsPanel = new JPanel();
			seedPointsPanel.setLayout(new BorderLayout());
			seedPointsPanel.add(getSeedsScrollPane(), BorderLayout.CENTER);
			seedPointsPanel.add(seedsLabel, BorderLayout.NORTH);
			seedPointsPanel.add(getSeedsActionsPanel(), BorderLayout.SOUTH);
		}
		return seedPointsPanel;
	}

	/**
	 * This method initializes seedsList
	 * 
	 * @return javax.swing.JList
	 */
	private JList getSeedsList() {
		if (seedsList == null) {
			seedsList = new JList();
			seedsList.addMouseListener(new java.awt.event.MouseAdapter() {
				public void mousePressed(java.awt.event.MouseEvent e) {
					if (e.getButton() != MouseEvent.BUTTON3)
						return;
					JPopupMenu menu = getSeedsPopupMenu();
					Point origin = getSeedsList().getLocationOnScreen();
					menu.setLocation(e.getX() + origin.x, e.getY() + origin.y);
					menu.show(e.getComponent(), e.getX(), e.getY());
				}
			});
			seedsList
					.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
						public void valueChanged(
								javax.swing.event.ListSelectionEvent e) {
							if (e.getValueIsAdjusting())
								return;
							model.showSeeds(getSeedsList().getSelectedValues());
						}
					});
		}
		return seedsList;
	}

	/**
	 * This method initializes seedsScrollPane
	 * 
	 * @return javax.swing.JScrollPane
	 */
	private JScrollPane getSeedsScrollPane() {
		if (seedsScrollPane == null) {
			seedsScrollPane = new JScrollPane();
			seedsScrollPane.setViewportView(getSeedsList());
		}
		return seedsScrollPane;
	}

	/**
	 * This method initializes tracingsScrollPane
	 * 
	 * @return javax.swing.JScrollPane
	 */
	private JScrollPane getTracingsScrollPane() {
		if (tracingsScrollPane == null) {
			tracingsScrollPane = new JScrollPane();
			tracingsScrollPane.setViewportView(getTracingsList());
		}
		return tracingsScrollPane;
	}

	/**
	 * This method initializes tracingsList
	 * 
	 * @return javax.swing.JList
	 */
	private JList getTracingsList() {
		if (tracingsList == null) {
			tracingsList = new JList();
			tracingsList
					.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
						public void valueChanged(
								javax.swing.event.ListSelectionEvent e) {
							if (e.getValueIsAdjusting()) return;
							model.showTracings(getTracingsList().getSelectedValues());
						}
					});
			tracingsList.addMouseListener(new java.awt.event.MouseAdapter() {
				public void mousePressed(java.awt.event.MouseEvent e) {
					if (e.getButton() != MouseEvent.BUTTON3)
						return;
					JPopupMenu menu = getTracingsPopupMenu();
					Point origin = getTracingsList().getLocationOnScreen();
					menu.setLocation(e.getX() + origin.x, e.getY() + origin.y);
					menu.show(e.getComponent(), e.getX(), e.getY());
				}
			});
		}
		return tracingsList;
	}

	/**
	 * This method initializes treesScrollPane
	 * 
	 * @return javax.swing.JScrollPane
	 */
	private JScrollPane getTreesScrollPane() {
		if (treesScrollPane == null) {
			treesScrollPane = new JScrollPane();
			treesScrollPane.setViewportView(getTreesList());
		}
		return treesScrollPane;
	}

	/**
	 * This method initializes treesList
	 * 
	 * @return javax.swing.JList
	 */
	private JList getTreesList() {
		if (treesList == null) {
			treesList = new JList();
			treesList
					.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
						public void valueChanged(javax.swing.event.ListSelectionEvent e) {
							if (e.getValueIsAdjusting())
								return;
							model.showTrees(getTreesList()
									.getSelectedValues());
						}
					});
			treesList.addMouseListener(new java.awt.event.MouseAdapter() {
				public void mousePressed(java.awt.event.MouseEvent e) {
					if (e.getButton() != MouseEvent.BUTTON3)
						return;
					JPopupMenu menu = getTreesPopupMenu();
					Point origin = getTracingsList().getLocationOnScreen();
					menu.setLocation(e.getX() + origin.x, e.getY() + origin.y);
					menu.show(e.getComponent(), e.getX(), e.getY());
				}
			});
		}
		return treesList;
	}

	/**
	 * This method initializes treesActionsPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getTreesActionsPanel() {
		if (treesActionsPanel == null) {
			treesActionsPanel = new JPanel();
			treesActionsPanel.setLayout(null);
		}
		return treesActionsPanel;
	}

	/**
	 * This method initializes tracingsActionsPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getTracingsActionsPanel() {
		if (tracingsActionsPanel == null) {
			tracingsActionsPanel = new JPanel();
			tracingsActionsPanel.setLayout(null);
			tracingsActionsPanel.setPreferredSize(new Dimension(1, 150));
			tracingsActionsPanel.add(getTraceAllButton(), null);
			tracingsActionsPanel.add(getTraceBranchesButton(), null);
			tracingsActionsPanel.add(getCreateTreeButton(), null);
		}
		return tracingsActionsPanel;
	}

	/**
	 * This method initializes seedsActionsPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getSeedsActionsPanel() {
		if (seedsActionsPanel == null) {
			seedsActionsPanel = new JPanel();
			seedsActionsPanel.setLayout(null);
			seedsActionsPanel.setPreferredSize(new Dimension(1, 150));
			seedsActionsPanel.add(getAddSeedsButton(), null);
			seedsActionsPanel.add(getTraceButton(), null);
			seedsActionsPanel.add(getFindSeedsButton(), null);
		}
		return seedsActionsPanel;
	}

	/**
	 * This method initializes generalActionsPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getGeneralActionsPanel() {
		if (generalActionsPanel == null) {
			generalActionsPanel = new JPanel();
			generalActionsPanel.setLayout(null);
		}
		return generalActionsPanel;
	}

	/**
	 * This method initializes addSeedsButton
	 * 
	 * @return javax.swing.JButton
	 */
	private JButton getAddSeedsButton() {
		if (addSeedsButton == null) {
			addSeedsButton = new JButton();
			addSeedsButton.setBounds(new Rectangle(45, 62, 102, 25));
			addSeedsButton.setText("add seeds");
			addSeedsButton
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.addSeeds();
						}
					});
		}
		return addSeedsButton;
	}

	/**
	 * This method initializes traceButton
	 * 
	 * @return javax.swing.JButton
	 */
	private JButton getTraceButton() {
		if (traceButton == null) {
			traceButton = new JButton();
			traceButton.setBounds(new Rectangle(45, 112, 102, 25));
			traceButton.setText("trace");
			traceButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.trace((Point[])getSeedsList().getSelectedValues());
				}
			});
		}
		return traceButton;
	}

	public void update(Observable sender, Object aspect) {
		if (aspect.equals("seeds"))
			this.handleChangedSeeds();
		if (aspect.equals("tracings"))
			this.handleChangedTracings();
		if (aspect.equals("trees"))
			this.handleChangedTrees();

	}

	private void handleChangedTrees() {
		this.getTreesList().setListData(model.trees);
	}

	private void handleChangedTracings() {
		this.getTracingsList().setListData(model.tracings);
	}

	private void handleChangedSeeds() {
		this.getSeedsList().setListData(model.seeds);
	}

	/**
	 * This method initializes seedsPopupMenu
	 * 
	 * @return javax.swing.JPopupMenu
	 */
	private JPopupMenu getSeedsPopupMenu() {
		if (seedsPopupMenu == null) {
			seedsPopupMenu = new JPopupMenu();
			seedsPopupMenu.add(getRemoveSelectedSeedsMenuItem());
			seedsPopupMenu.add(getSortMenu());
		}
		return seedsPopupMenu;
	}

	/**
	 * This method initializes removeSelectedSeedsMenuItem
	 * 
	 * @return javax.swing.JMenuItem
	 */
	private JMenuItem getRemoveSelectedSeedsMenuItem() {
		if (removeSelectedSeedsMenuItem == null) {
			removeSelectedSeedsMenuItem = new JMenuItem();
			removeSelectedSeedsMenuItem.setText("remove");
			removeSelectedSeedsMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.removeSeeds(getSeedsList()
									.getSelectedValues());
						}
					});
		}
		return removeSelectedSeedsMenuItem;
	}

	/**
	 * This method initializes tracingsPopupMenu
	 * 
	 * @return javax.swing.JPopupMenu
	 */
	private JPopupMenu getTracingsPopupMenu() {
		if (tracingsPopupMenu == null) {
			tracingsPopupMenu = new JPopupMenu();
			tracingsPopupMenu.add(getColorsMenu());
			tracingsPopupMenu.add(getDrawMenu());
			tracingsPopupMenu.add(getMeasureMenuItem());
			tracingsPopupMenu.add(getRemoveSelectedTracingsMenuItem());
			tracingsPopupMenu.add(getRemoveDuplicatesMenuItem());
			tracingsPopupMenu.add(getSelectMenu());
			tracingsPopupMenu.add(getSmoothMenuItem());
			tracingsPopupMenu.add(getSortTracingsMenu());
		}
		return tracingsPopupMenu;
	}

	/**
	 * This method initializes removeSelectedTracingsMenuItem
	 * 
	 * @return javax.swing.JMenuItem
	 */
	private JMenuItem getRemoveSelectedTracingsMenuItem() {
		if (removeSelectedTracingsMenuItem == null) {
			removeSelectedTracingsMenuItem = new JMenuItem();
			removeSelectedTracingsMenuItem.setText("remove");
			removeSelectedTracingsMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.removeTracings(getTracingsList()
									.getSelectedValues());
						}
					});
		}
		return removeSelectedTracingsMenuItem;
	}

	/**
	 * This method initializes findSeedsButton
	 * 
	 * @return javax.swing.JButton
	 */
	private JButton getFindSeedsButton() {
		if (findSeedsButton == null) {
			findSeedsButton = new JButton();
			findSeedsButton.setBounds(new Rectangle(45, 12, 102, 25));
			findSeedsButton.setText("find seeds");
			findSeedsButton
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.findSeedPoints();
						}
					});
		}
		return findSeedsButton;
	}

	/**
	 * This method initializes mainMenuBar
	 * 
	 * @return javax.swing.JMenuBar
	 */
	private JMenuBar getMainMenuBar() {
		if (mainMenuBar == null) {
			mainMenuBar = new JMenuBar();
			mainMenuBar.add(getOptionsMenu());
		}
		return mainMenuBar;
	}

	/**
	 * This method initializes optionsMenu
	 * 
	 * @return javax.swing.JMenu
	 */
	private JMenu getOptionsMenu() {
		if (optionsMenu == null) {
			optionsMenu = new JMenu();
			optionsMenu.setText("options");
			optionsMenu.add(getEditOptionsMenuItem());
		}
		return optionsMenu;
	}

	/**
	 * This method initializes editOptionsMenuItem
	 * 
	 * @return javax.swing.JMenuItem
	 */
	private JMenuItem getEditOptionsMenuItem() {
		if (editOptionsMenuItem == null) {
			editOptionsMenuItem = new JMenuItem();
			editOptionsMenuItem.setText("edit");
			editOptionsMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							showOptions();
						}
					});
		}
		return editOptionsMenuItem;
	}

	public void showOptions() {
		model.getOptions().show();
	}

	/**
	 * This method initializes traceAllButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getTraceAllButton() {
		if (traceAllButton == null) {
			traceAllButton = new JButton();
			traceAllButton.setPreferredSize(new Dimension(93, 26));
			traceAllButton.setText("trace");
			traceAllButton.setBounds(new Rectangle(45, 12, 102, 25));
			traceAllButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.traceAll();
				}
			});
		}
		return traceAllButton;
	}

	/**
	 * This method initializes traceBranchesButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getTraceBranchesButton() {
		if (traceBranchesButton == null) {
			traceBranchesButton = new JButton();
			traceBranchesButton.setBounds(new Rectangle(33, 62, 127, 25));
			traceBranchesButton.setText("trace branches");
			traceBranchesButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.traceBranches(getTracingsList().getSelectedValue());
				}
			});
		}
		return traceBranchesButton;
	}

	/**
	 * This method initializes sortTracingsMenu	
	 * 	
	 * @return javax.swing.JMenu	
	 */
	private JMenu getSortTracingsMenu() {
		if (sortTracingsMenu == null) {
			sortTracingsMenu = new JMenu();
			sortTracingsMenu.setText("sort");
			sortTracingsMenu.add(getSortTracingsByLengthMenuItem());
			sortTracingsMenu.add(getSortTracingsByMeanIntensityMenuItem());
			sortTracingsMenu.add(getSortTracingsBySNRMenuItem());
			sortTracingsMenu.add(getSortTracingsByYDistanceMenuItem());
		}
		return sortTracingsMenu;
	}

	/**
	 * This method initializes sortTracingsByLengthMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSortTracingsByLengthMenuItem() {
		if (sortTracingsByLengthMenuItem == null) {
			sortTracingsByLengthMenuItem = new JMenuItem();
			sortTracingsByLengthMenuItem.setText("by length");
			sortTracingsByLengthMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.sortTracingsByLength();
						}
					});
		}
		return sortTracingsByLengthMenuItem;
	}

	/**
	 * This method initializes sortTracingsByYDistanceMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSortTracingsByYDistanceMenuItem() {
		if (sortTracingsByYDistanceMenuItem == null) {
			sortTracingsByYDistanceMenuItem = new JMenuItem();
			sortTracingsByYDistanceMenuItem.setText("by y-distance");
			sortTracingsByYDistanceMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.sortTracingsByYDistance();
						}
					});
		}
		return sortTracingsByYDistanceMenuItem;
	}

	/**
	 * This method initializes smoothMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSmoothMenuItem() {
		if (smoothMenuItem == null) {
			smoothMenuItem = new JMenuItem();
			smoothMenuItem.setText("smooth");
			smoothMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.smooth(getTracingsList().getSelectedValues());
				}
			});
		}
		return smoothMenuItem;
	}

	/**
	 * This method initializes removeDuplicatesMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getRemoveDuplicatesMenuItem() {
		if (removeDuplicatesMenuItem == null) {
			removeDuplicatesMenuItem = new JMenuItem();
			removeDuplicatesMenuItem.setText("remove duplicates");
			removeDuplicatesMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.removeDuplicateTracings();
				}
			});
		}
		return removeDuplicatesMenuItem;
	}

	/**
	 * This method initializes measureMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getMeasureMenuItem() {
		if (measureMenuItem == null) {
			measureMenuItem = new JMenuItem();
			measureMenuItem.setText("measure");
			measureMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.measureTracings(getTracingsList().getSelectedValues());
				}
			});
		}
		return measureMenuItem;
	}

	/**
	 * This method initializes selectMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSelectMenuItem() {
		if (selectMenuItem == null) {
			selectMenuItem = new JMenuItem();
			selectMenuItem.setText("center");
			selectMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.selectTracing(getTracingsList().getSelectedValue());
				}
			});
		}
		return selectMenuItem;
	}

	/**
	 * This method initializes sortSeedsByDistanceMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSortSeedsByDistanceMenuItem() {
		if (sortSeedsByDistanceMenuItem == null) {
			sortSeedsByDistanceMenuItem = new JMenuItem();
			sortSeedsByDistanceMenuItem.setText("by distance");
			sortSeedsByDistanceMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.sortSeedsByDistance();
						}
					});
		}
		return sortSeedsByDistanceMenuItem;
	}

	/**
	 * This method initializes sortMenu	
	 * 	
	 * @return javax.swing.JMenu	
	 */
	private JMenu getSortMenu() {
		if (sortMenu == null) {
			sortMenu = new JMenu();
			sortMenu.setText("sort");
			sortMenu.add(getSortSeedsByDistanceMenuItem());
			sortMenu.add(getSortByYCoordinateMenuItem());
		}
		return sortMenu;
	}

	/**
	 * This method initializes sortByYCoordinateMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSortByYCoordinateMenuItem() {
		if (sortByYCoordinateMenuItem == null) {
			sortByYCoordinateMenuItem = new JMenuItem();
			sortByYCoordinateMenuItem.setText("sort by y-coordinate");
			sortByYCoordinateMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.sortSeedsByYCoordinate();
						}
					});
		}
		return sortByYCoordinateMenuItem;
	}

	/**
	 * This method initializes createTreeButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getCreateTreeButton() {
		if (createTreeButton == null) {
			createTreeButton = new JButton();
			createTreeButton.setBounds(new Rectangle(33, 112, 127, 25));
			createTreeButton.setText("create tree");
			createTreeButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.createTree();
				}
			});
		}
		return createTreeButton;
	}

	/**
	 * This method initializes selectMenu	
	 * 	
	 * @return javax.swing.JMenu	
	 */
	private JMenu getSelectMenu() {
		if (selectMenu == null) {
			selectMenu = new JMenu();
			selectMenu.setText("select");
			selectMenu.add(getSelectMenuItem());
			selectMenu.add(getSelectContourMenuItem());
		}
		return selectMenu;
	}

	/**
	 * This method initializes selectContourMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSelectContourMenuItem() {
		if (selectContourMenuItem == null) {
			selectContourMenuItem = new JMenuItem();
			selectContourMenuItem.setText("contour");
			selectContourMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.selectTracingContour(getTracingsList().getSelectedValue());
				}
			});
		}
		return selectContourMenuItem;
	}

	/**
	 * This method initializes sortTracingsByMeanIntensityMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSortTracingsByMeanIntensityMenuItem() {
		if (sortTracingsByMeanIntensityMenuItem == null) {
			sortTracingsByMeanIntensityMenuItem = new JMenuItem();
			sortTracingsByMeanIntensityMenuItem.setText("by mean intensity");
			sortTracingsByMeanIntensityMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.sortTracingsByMeanIntensity();
						}
					});
		}
		return sortTracingsByMeanIntensityMenuItem;
	}

	/**
	 * This method initializes sortTracingsBySNRMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getSortTracingsBySNRMenuItem() {
		if (sortTracingsBySNRMenuItem == null) {
			sortTracingsBySNRMenuItem = new JMenuItem();
			sortTracingsBySNRMenuItem.setText("by snr estimation");
			sortTracingsBySNRMenuItem
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							model.sortTracingsBySNR();
						}
					});
		}
		return sortTracingsBySNRMenuItem;
	}

	/**
	 * This method initializes drawCenterLinesMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getDrawCenterLinesMenuItem() {
		if (drawCenterLinesMenuItem == null) {
			drawCenterLinesMenuItem = new JMenuItem();
			drawCenterLinesMenuItem.setText("center lines");
			drawCenterLinesMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.drawCenterlines();
				}
			});
		}
		return drawCenterLinesMenuItem;
	}

	/**
	 * This method initializes drawMenu	
	 * 	
	 * @return javax.swing.JMenu	
	 */
	private JMenu getDrawMenu() {
		if (drawMenu == null) {
			drawMenu = new JMenu();
			drawMenu.setText("draw");
			drawMenu.add(getDrawCenterLinesMenuItem());
		}
		return drawMenu;
	}

	/**
	 * This method initializes colorsMenu	
	 * 	
	 * @return javax.swing.JMenu	
	 */
	private JMenu getColorsMenu() {
		if (colorsMenu == null) {
			colorsMenu = new JMenu();
			colorsMenu.setText("colors");
			colorsMenu.add(getCycleColorsMenuItem());
		}
		return colorsMenu;
	}

	/**
	 * This method initializes cycleColorsMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getCycleColorsMenuItem() {
		if (cycleColorsMenuItem == null) {
			cycleColorsMenuItem = new JMenuItem();
			cycleColorsMenuItem.setText("cycle colors");
			cycleColorsMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.cycleColors(tracingsList.getSelectedValues());
				}
			});
		}
		return cycleColorsMenuItem;
	}

	/**
	 * This method initializes treesPopupMenu	
	 * 	
	 * @return javax.swing.JPopupMenu	
	 */
	private JPopupMenu getTreesPopupMenu() {
		if (treesPopupMenu == null) {
			treesPopupMenu = new JPopupMenu();
			treesPopupMenu.add(getRemoveTreesMenuItem());
		}
		return treesPopupMenu;
	}

	/**
	 * This method initializes removeTreesMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getRemoveTreesMenuItem() {
		if (removeTreesMenuItem == null) {
			removeTreesMenuItem = new JMenuItem();
			removeTreesMenuItem.setText("remove");
			removeTreesMenuItem.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.removeTrees(getTreesList()
							.getSelectedValues());
				}
			});
		}
		return removeTreesMenuItem;
	}

}  
