from ij import IJ
from ij.plugin.frame import (
    Recorder,
    Editor
)
from ij.gui import (
    Toolbar,
    WaitForUserDialog
)
from ij.plugin import Scaler

import re
import os

from java.awt import BorderLayout, GridBagLayout, GridBagConstraints, Insets, Dimension, Font
from java.awt.event import ActionListener
from javax.swing import (JFrame, JPanel, JButton, JDialog, JTextArea,
                         JScrollPane, JLabel, BorderFactory, SwingUtilities,
                         Box, BoxLayout)
import java.lang.System as System

entries           = []
_INSTRUCTION_TYPE = 0
_FX_NAME          = 1
_ARGS             = 2
_ICON_STR         = 3

# ---------------------------------------------------------------------------
# Function to create a tool icon from a 16x16 RGB image.
# ---------------------------------------------------------------------------

def awt_color_to_hex3(color):
    r = int(color.getRed()   * 15 / 255.0 + 0.5)
    g = int(color.getGreen() * 15 / 255.0 + 0.5)
    b = int(color.getBlue()  * 15 / 255.0 + 0.5)
    return "C" + "{:X}{:X}{:X}".format(r, g, b).lower()

def pos_to_hex3(x, y):
    x = int(x)
    y = int(y)
    return "D" + "{:X}{:X}".format(x, y).lower()

def img_to_tool_icon(img):
    if img.getBitDepth() != 24:
        print("Only RGB images are handled")
        return None

    inv = True
    inv = not IJ.altKeyDown()

    if img.getWidth() != 16 or img.getHeight() != 16:
        scaled = Scaler.resize(img, 16, 16, 1, "bilinear")
        img.close()
        img = scaled
        img.show()

    if inv:
        img.getProcessor().invert()

    bg_clr = Toolbar.getBackgroundColor()
    prc    = img.getProcessor()
    clrs   = set()

    for y in range(img.getHeight()):
        for x in range(img.getWidth()):
            clrs.add(prc.getColor(x, y))

    txt = ""
    for clr in clrs:
        if clr == bg_clr:
            continue
        txt +=  awt_color_to_hex3(clr)
        for y in range(img.getHeight()):
            for x in range(img.getWidth()):
                val = prc.getColor(x, y)
                if val == clr:
                    txt += pos_to_hex3(x, y)
    img.close()
    return txt

# ---------------------------------------------------------------------------
# Read the Macro Recorder
# ---------------------------------------------------------------------------

def parse_run(text):
    pattern = r'run\("([^"]+)"(?:,\s*"([^"]*)")?\);'
    match = re.match(pattern, text)
    if match:
        name = match.group(1)
        args = match.group(2)
        return [0, name, args, ""]
    else:
        return None

def read_recorder():
	rd = Recorder.getInstance()
	if rd is None:
		return []
	txt   = rd.getText()
	lines = txt.split("\n")
	items = []
	for line in lines:
		if line.startswith("//") or len(line) <= 1:
			continue
		elif line.startswith("run("):
			res = parse_run(line)
			if res is not None:
				items.append(res)
		else:
			items.append([1, line, "", ""])
	return items


# ---------------------------------------------------------------------------
# Argument-edit dialog
# ---------------------------------------------------------------------------

class EditArgsDialog(JDialog):
    """
    A small modal dialog showing the current args string in a text area.
    On OK the entry list is updated and the label button is refreshed.
    """

    def __init__(self, owner_frame, entry, row_index, launcher):
        JDialog.__init__(self, owner_frame, "Edit arguments", True)
        self.entry = entry
        self.launcher = launcher
        self.row_index = row_index
        self._build_ui()
        self.pack()
        self.setLocationRelativeTo(owner_frame)
        self.setVisible(True)

    def _build_ui(self):
        panel = JPanel(BorderLayout(8, 8))
        panel.setBorder(BorderFactory.createEmptyBorder(12, 12, 12, 12))

        # Header label
        header = JLabel("Arguments for: " + self.entry[_FX_NAME])
        header.setFont(header.getFont().deriveFont(Font.BOLD))
        panel.add(header, BorderLayout.NORTH)

        # Text area pre-filled with current args
        self.text_area = JTextArea(self.entry[_ARGS], 5, 50)
        self.text_area.setLineWrap(True)
        self.text_area.setWrapStyleWord(True)
        scroll = JScrollPane(self.text_area)
        scroll.setPreferredSize(Dimension(440, 110))
        panel.add(scroll, BorderLayout.CENTER)

        # OK / Cancel buttons
        btn_panel = JPanel()
        btn_panel.setLayout(BoxLayout(btn_panel, BoxLayout.X_AXIS))
        btn_panel.add(Box.createHorizontalGlue())

        cancel_btn = JButton("Cancel")
        cancel_btn.addActionListener(lambda e: self.dispose())
        btn_panel.add(cancel_btn)
        btn_panel.add(Box.createHorizontalStrut(8))

        ok_btn = JButton("OK")
        ok_btn.addActionListener(self._on_ok)
        self.getRootPane().setDefaultButton(ok_btn)
        btn_panel.add(ok_btn)

        panel.add(btn_panel, BorderLayout.SOUTH)
        self.add(panel)

    def _on_ok(self, event):
        new_args = self.text_area.getText()
        self.entry[_ARGS] = new_args
        self.launcher.refresh_row(self.row_index)
        self.dispose()


# ---------------------------------------------------------------------------
# Main launcher window
# ---------------------------------------------------------------------------

class QuickLauncher(JFrame):

    def __init__(self):
        JFrame.__init__(self, "Quick Launcher")
        self.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE)
        self._row_panels = []     # keep references for refresh
        self._build_ui()
        self.pack()
        self.setMinimumSize(Dimension(320, 80))
        self.setLocationRelativeTo(None)
        self.setVisible(True)
        self.icon_font = Font("Serif", Font.PLAIN, 16)

    # ------------------------------------------------------------------
    # UI construction
    # ------------------------------------------------------------------

    def _build_ui(self):
        outer = JPanel(BorderLayout())
        outer.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8))

        # Grid panel (rows of command buttons)
        self.grid_panel = JPanel(GridBagLayout())
        outer.add(self.grid_panel, BorderLayout.CENTER)

        # Bottom buttons
        bottom = JPanel()
        bottom.setLayout(BoxLayout(bottom, BoxLayout.Y_AXIS))
        bottom.setBorder(BorderFactory.createEmptyBorder(8, 0, 0, 0))

        button_row = JPanel()
        button_row.setLayout(BoxLayout(button_row, BoxLayout.X_AXIS))
        button_row.setAlignmentX(0.5)
        
        from_btn = JButton("Append recorder")
        from_btn.addActionListener(self._on_from_recorder)
        button_row.add(from_btn)
        button_row.add(Box.createHorizontalStrut(8))
        
        reset_btn = JButton("Reset from recorder")
        reset_btn.addActionListener(self._on_reset_from_recorder)
        button_row.add(reset_btn)
        
        bottom.add(button_row)
        bottom.add(Box.createVerticalStrut(4))

        toolset_btn = JButton("As toolset")
        toolset_btn.setAlignmentX(0.5)
        toolset_btn.addActionListener(self._on_as_toolset)
        bottom.add(toolset_btn)

        outer.add(bottom, BorderLayout.SOUTH)
        self.add(outer)

    def _add_row(self, index):
        """
        Add (or refresh) a single row at the given index in the grid.
        Each row: [label button (stretch)] [gear button] [down button]
        """
        entry = entries[index]

        gbc = GridBagConstraints()
        gbc.gridy = index
        gbc.insets = Insets(2, 2, 2, 2)
        gbc.fill = GridBagConstraints.HORIZONTAL

        # -- Label button (runs the command when clicked) --
        label_btn = JButton(entry[_FX_NAME])
        label_btn.setToolTipText(entry[_ARGS] if entry[_ARGS] else "(no arguments)")
        # Capture index for the closure
        captured = index
        label_btn.addActionListener(
            lambda e, i=captured: self._run_entry(i))

        gbc.gridx = 0
        gbc.weightx = 1.0
        self.grid_panel.add(label_btn, gbc)

        # -- Gear button --
        gear_btn = JButton(u"\u2699") 
        gear_btn.setPreferredSize(Dimension(30, 30))
        gear_btn.setMaximumSize(Dimension(30, 30))
        gear_btn.setFont(self.icon_font)
        gear_btn.setToolTipText("Edit arguments")
        gear_btn.addActionListener(
            lambda e, i=captured: self._on_gear(i))

        gbc.gridx = 1
        gbc.weightx = 0.0
        gbc.fill = GridBagConstraints.NONE
        self.grid_panel.add(gear_btn, gbc)

        # -- Image button --
        image_btn = JButton(u"\U0001F5BC")
        image_btn.setPreferredSize(Dimension(30, 30))
        image_btn.setMaximumSize(Dimension(30, 30))
        image_btn.setFont(self.icon_font)
        image_btn.setToolTipText("Set icon")
        image_btn.addActionListener(
            lambda e, i=captured: self._on_set_icon(i))

        gbc.gridx = 2
        self.grid_panel.add(image_btn, gbc)

        # -- Garbage button --
        garbage_btn = JButton(u"\U0001F5D1")
        garbage_btn.setPreferredSize(Dimension(30, 30))
        garbage_btn.setMaximumSize(Dimension(30, 30))
        garbage_btn.setFont(self.icon_font)
        garbage_btn.setToolTipText("Delete entry")
        garbage_btn.addActionListener(
            lambda e, i=captured: self._on_delete(i))
        
        gbc.gridx = 3
        self.grid_panel.add(garbage_btn, gbc)

    def _rebuild_grid(self):
        """Clear and repopulate the grid panel from the entries list."""
        self.grid_panel.removeAll()
        for i in range(len(entries)):
            self._add_row(i)
        self.grid_panel.revalidate()
        self.grid_panel.repaint()
        self.pack()

    def refresh_row(self, index):
        """
        Called by EditArgsDialog after an args edit.
        Rebuilds the whole grid (simplest safe approach for row count changes).
        """
        self._rebuild_grid()

    # ------------------------------------------------------------------
    # Button callbacks
    # ------------------------------------------------------------------

    def _run_entry(self, index):
        entry = entries[index]
        if entry[_INSTRUCTION_TYPE] == 0:
            if entry[_ARGS]:
                IJ.run(entry[_FX_NAME], entry[_ARGS])
            else:
                IJ.run(entry[_FX_NAME])
        else:
            IJ.runMacro(entry[_FX_NAME])

    def _on_gear(self, index):
        EditArgsDialog(self, entries[index], index, self)

    def _on_set_icon(self, index):
        img = IJ.getImage()
        if img is None:
            return
        icon_str = img_to_tool_icon(img)
        if icon_str is not None:
            entries[index][_ICON_STR] = icon_str

    def _on_from_recorder(self, event):
        new_entries = read_recorder()
        if len(new_entries) == 0:
            return
        for instruction, name, args, icon in new_entries:
            entries.append([instruction, name, args, icon])
        self._rebuild_grid()

    def _on_reset_from_recorder(self, event):
        new_entries = read_recorder()
        if len(new_entries) == 0:
            return
        while len(entries) > 0:
            del entries[0]
        for instruction, name, args, icon in new_entries:
            entries.append([instruction, name, args, icon])
        print(entries)
        self._rebuild_grid()

    def _on_delete(self, index):
        del entries[index]
        self._rebuild_grid()

    def _on_as_toolset(self, event):
        as_toolset_callback(list(entries))


# ---------------------------------------------------------------------------
# "As toolset" callback -- wire up your own logic here
# ---------------------------------------------------------------------------

def as_toolset_callback(snapshot):
    just_show = IJ.altKeyDown()
    default_icons = [
         "T5e161", "T5e162", "T5e163", "T5e164", "T5e165", "T5e166", "T5e167", "T5e168"
    ]
    max_items = len(default_icons)
    lines = []
    title = IJ.getString("Toolset name?", "My toolset")

    for i, (instrunction, name, args, icon) in enumerate(snapshot):
        if i >= max_items:
            print("Too many entries for a single toolset, skipping from:", name)
            break
        line = 'macro "Launch step ' + str(i+1) + ' Action Tool - ' + (icon if icon else default_icons[i]) + '" {\n\t'
        if instrunction == 0:
            if args:
                line += 'run("{}", "{}");'.format(name, args)
            else:
                line += 'run("{}");'.format(name)
        else:
            line += name
        line += '\n}\n\n'
        lines.append(line)
    
    macro_text = "\n".join(lines)
    if just_show:
         Editor.createMacro(title, macro_text)
    else:
        folder = IJ.getDirectory("macros")
        folder = os.path.join(folder, "toolsets")
        ts_path = os.path.join(folder, title + ".ijm")
        with open(ts_path, "w") as f:
            f.write(macro_text)
        IJ.showMessage("Toolset saved", "Saved as:\n" + ts_path)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

SwingUtilities.invokeLater(lambda: QuickLauncher())
