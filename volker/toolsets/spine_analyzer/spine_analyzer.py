from javax.swing import JFrame
from java.awt import BorderLayout
from javax.swing import JLabel
from ij import WindowManager


frame = JFrame("FrameDemo")
frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE)
emptyLabel = JLabel("Hello")
frame.getContentPane().add(emptyLabel, BorderLayout.CENTER)
frame.pack()
frame.setVisible(True)

WindowManager.addWindow(frame)