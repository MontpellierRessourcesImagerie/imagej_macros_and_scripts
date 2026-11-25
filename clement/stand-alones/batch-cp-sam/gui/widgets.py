"""Reusable widgets of the batch segmentation GUI."""

from pathlib import Path
from qtpy.QtCore import Qt, Signal
from qtpy.QtWidgets import (
    QWidget,
    QHBoxLayout,
    QFormLayout,
    QLineEdit,
    QPushButton,
    QFileDialog,
    QGroupBox,
    QCheckBox,
    QSpinBox,
    QDoubleSpinBox,
    QTableWidget,
    QTableWidgetItem,
    QHeaderView,
)

from core.settings import ObjectSettings
from core.image_io import list_tiff_files


class FolderSelector(QWidget):
    """Line edit + 'Browse' button. Emits `folder_changed` with the new path."""

    folder_changed = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.line_edit = QLineEdit()
        self.line_edit.setPlaceholderText("Folder containing the images to segment")
        self.browse_btn = QPushButton("Browse")
        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.line_edit)
        layout.addWidget(self.browse_btn)
        self.browse_btn.clicked.connect(self._browse)
        self.line_edit.editingFinished.connect(lambda: self.folder_changed.emit(self.folder()))

    def _browse(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Directory", self.folder())
        if folder:
            self.set_folder(folder)

    def folder(self):
        return self.line_edit.text().strip()

    def set_folder(self, folder):
        self.line_edit.setText(folder)
        self.folder_changed.emit(folder)


class ImageTable(QTableWidget):
    """Lists the discovered images, lets the user (de)select them and displays their status."""

    COL_SELECT, COL_NAME, COL_STATUS = range(3)

    def __init__(self, parent=None):
        super().__init__(0, 3, parent)
        self.setHorizontalHeaderLabels(["Select", "Image name", "Status"])
        self.verticalHeader().setVisible(False)
        header = self.horizontalHeader()
        header.setSectionResizeMode(self.COL_SELECT, QHeaderView.ResizeMode.ResizeToContents)
        header.setSectionResizeMode(self.COL_NAME,   QHeaderView.ResizeMode.Stretch)
        header.setSectionResizeMode(self.COL_STATUS, QHeaderView.ResizeMode.ResizeToContents)
        self.setMinimumHeight(150)
        self.paths = []

    def populate(self, folder):
        self.paths = list_tiff_files(folder) if folder else []
        self.setRowCount(len(self.paths))
        for row, path in enumerate(self.paths):
            checkbox = QCheckBox()
            checkbox.setChecked(True)
            container = QWidget()
            layout = QHBoxLayout(container)
            layout.setContentsMargins(0, 0, 0, 0)
            layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
            layout.addWidget(checkbox)
            self.setCellWidget(row, self.COL_SELECT, container)
            name_item = QTableWidgetItem(path.name)
            name_item.setFlags(name_item.flags() & ~Qt.ItemFlag.ItemIsEditable)
            self.setItem(row, self.COL_NAME, name_item)
            self.set_status(row, "📍 Discovered")

    def _checkbox(self, row):
        container = self.cellWidget(row, self.COL_SELECT)
        return container.findChild(QCheckBox) if container is not None else None

    def set_status(self, row, text):
        item = QTableWidgetItem(text)
        item.setFlags(item.flags() & ~Qt.ItemFlag.ItemIsEditable)
        item.setToolTip(text)
        self.setItem(row, self.COL_STATUS, item)

    def selected_images(self):
        """List of (row, path) of the checked images."""
        selected = []
        for row, path in enumerate(self.paths):
            cb = self._checkbox(row)
            if cb is not None and cb.isChecked():
                selected.append((row, path))
        return selected

    def mark_pending(self):
        """Sets the status of every image according to its selection, before a run."""
        for row in range(len(self.paths)):
            cb = self._checkbox(row)
            self.set_status(row, "⏳ Pending" if cb is not None and cb.isChecked() else "🚫 Skipped")


class CalibrationBox(QGroupBox):
    """General information about the images: pixel sizes and 2D/3D."""

    def __init__(self, parent=None):
        super().__init__("Image calibration", parent)
        self.xy_size = QDoubleSpinBox()
        self.xy_size.setDecimals(7)
        self.xy_size.setRange(0.000001, 1000.0)
        self.xy_size.setSingleStep(0.01)
        self.xy_size.setSuffix(" µm")

        self.is_3d = QCheckBox("3D stacks")
        self.z_size = QDoubleSpinBox()
        self.z_size.setDecimals(6)
        self.z_size.setRange(0.000001, 1000.0)
        self.z_size.setSingleStep(0.1)
        self.z_size.setSuffix(" µm")
        self.is_3d.toggled.connect(self.z_size.setEnabled)

        z_row = QHBoxLayout()
        z_row.addWidget(self.is_3d)
        z_row.addWidget(self.z_size, 1)

        layout = QFormLayout(self)
        layout.addRow("XY pixel size:", self.xy_size)
        layout.addRow("Z pixel size:", z_row)

    def set_values(self, xy_pixel_size, is_3d, z_pixel_size):
        self.xy_size.setValue(xy_pixel_size)
        self.z_size.setValue(z_pixel_size)
        self.is_3d.setChecked(is_3d)
        self.z_size.setEnabled(is_3d)


class ObjectSettingsBox(QGroupBox):
    """Checkable column holding the parameters of one kind of object (cells or nuclei)."""

    def __init__(self, title, parent=None):
        super().__init__(title, parent)
        self.setCheckable(True)
        self.channel = QSpinBox()
        self.channel.setRange(1, 32)
        self.diameter = QDoubleSpinBox()
        self.diameter.setDecimals(1)
        self.diameter.setRange(1.0, 5000.0)
        self.diameter.setSuffix(" px")
        layout = QFormLayout(self)
        layout.addRow("Channel index:", self.channel)
        layout.addRow("Median diameter:", self.diameter)

    def set_settings(self, s: ObjectSettings):
        self.setChecked(s.enabled)
        self.channel.setValue(s.channel)
        self.diameter.setValue(s.diameter)

    def get_settings(self):
        return ObjectSettings(
            enabled=self.isChecked(),
            channel=self.channel.value(),
            diameter=self.diameter.value(),
        )
