import sys
import torch
import json
import os
from pathlib import Path
from batch_cp_sam import run_cellpose_sam, get_prefix
from PyQt6.QtWidgets import QTableWidget, QTableWidgetItem, QCheckBox as QCheckBoxWidget
from PyQt6.QtCore import Qt, pyqtSignal, QObject
from threading import Thread
from PyQt6.QtWidgets import (QApplication, QWidget, QVBoxLayout, QHBoxLayout, 
                             QLineEdit, QDoubleSpinBox, QSpinBox, QPushButton, 
                             QLabel, QFileDialog, QCheckBox, QFormLayout, QProgressBar)

class ProgressSignal(QObject):
    signal = pyqtSignal(int, int, str, int)
    def emit(self, iteration, index, text, total):
        self.signal.emit(iteration, index, text, total)

class FinishedSignal(QObject):
    signal = pyqtSignal()
    def emit(self):
        self.signal.emit()

class ProcessingGui(QWidget):
    def __init__(self):
        super().__init__()
        self.progress_signal = ProgressSignal()
        self.finished_signal = FinishedSignal()
        self.progress_signal.signal.connect(self.update_callback)
        self.finished_signal.signal.connect(self.on_processing_finished)
        self.init_ui()

    def get_default_settings(self):
        return {
            "folder_path"     : "",
            "median_diameter" : 220,
            "xy_pixel_size"   : 0.0971045,
            "z_pixel_size"    : 0.3,
            "nuclei_channel"  : 3,
            "membrane_channel": 4,
            "use_secondary"   : True,
            "use_gpu"         : torch.cuda.is_available()
        }
    
    def save_settings(self, settings):
        file_path = __file__.replace('.py', '_settings.json')
        with open(file_path, 'w') as f:
            json.dump(settings, f, indent=4)

    def load_settings(self):
        file_path = __file__.replace('.py', '_settings.json')
        loaded = {}
        if Path(file_path).exists():
            with open(file_path, 'r') as f:
                loaded = json.load(f)
        else:
            loaded = self.get_default_settings()
        loaded['use_gpu'] = torch.cuda.is_available() and loaded.get('use_gpu', False)
        return loaded

    def init_ui(self):
        self.setWindowTitle('Batch CellPoseSAM')
        self.setMinimumWidth(700)
        settings = self.load_settings()
        
        # Main Layout
        self.layout = QVBoxLayout()
        self.form_layout = QFormLayout()

        # 1. Folder Path Selection
        self.path_input = QLineEdit()
        self.path_button = QPushButton("Browse")
        self.path_button.clicked.connect(self.get_folder)
        path_layout = QHBoxLayout()
        path_layout.addWidget(self.path_input)
        path_layout.addWidget(self.path_button)

        # Image table
        self.image_table = QTableWidget()
        self.image_table.setColumnCount(3)
        self.image_table.setHorizontalHeaderLabels(["Select", "Image Name", "Status"])
        header = self.image_table.horizontalHeader()
        header.setStretchLastSection(False)
        header.setSectionResizeMode(0, header.ResizeMode.ResizeToContents)
        header.setSectionResizeMode(1, header.ResizeMode.Stretch)
        header.setSectionResizeMode(2, header.ResizeMode.ResizeToContents)

        # 2. Median Diameter (Int: 5 to 1000)
        self.median_diameter = QSpinBox()
        self.median_diameter.setRange(5, 1000)
        self.median_diameter.setValue(settings['median_diameter']) # Default value

        # 3. XY Pixel Size (Float: 0.0 to 2.0)
        self.xy_size = QDoubleSpinBox()
        self.xy_size.setDecimals(8)
        self.xy_size.setRange(0.0, 2.0)
        self.xy_size.setSingleStep(0.1)
        self.xy_size.setValue(settings['xy_pixel_size'])

        # 4. Z Pixel Size (Float: 0.0 to 2.0)
        self.z_size = QDoubleSpinBox()
        self.z_size.setDecimals(5)
        self.z_size.setRange(0.0, 2.0)
        self.z_size.setSingleStep(0.1)
        self.z_size.setValue(settings['z_pixel_size'])

        # 5. Membrane Channel (Int: 1 to 10)
        self.membrane_chan = QSpinBox()
        self.membrane_chan.setRange(1, 10)
        self.membrane_chan.setValue(settings['membrane_channel'])

        # 6. Nuclei Channel (Int: 1 to 10)
        self.nuclei_chan = QSpinBox()
        self.nuclei_chan.setRange(1, 10)
        self.nuclei_chan.setValue(settings['nuclei_channel'])

        # 7. GPU Checkbox
        self.use_gpu = QCheckBox("Use GPU acceleration")
        cuda_ok = torch.cuda.is_available()
        if cuda_ok:
            self.use_gpu.setChecked(settings['use_gpu'])
        else:
            self.use_gpu.setEnabled(False)

        # 8. Use secondary channel checkbox
        self.use_secondary = QCheckBox("Use secondary channel (nuclei)")
        self.use_secondary.stateChanged.connect(self.toggle_nuclei_channel)
        self.use_secondary.setChecked(settings['use_secondary'])

        h_layout = QHBoxLayout()
        h_layout.addWidget(self.nuclei_chan)
        h_layout.addWidget(self.use_secondary)

        # Add rows to form
        self.form_layout.addRow("Folder Path:", path_layout)
        self.form_layout.addRow(self.image_table)
        self.form_layout.addRow("Median Diameter:", self.median_diameter)
        self.form_layout.addRow("XY Pixel Size:", self.xy_size)
        self.form_layout.addRow("Z Pixel Size:", self.z_size)
        self.form_layout.addRow("Membrane Channel:", self.membrane_chan)
        self.form_layout.addRow("Nuclei Channel:", h_layout)
        self.form_layout.addRow(self.use_gpu)

        # 8. Run Button
        self.run_btn = QPushButton("Run")
        self.run_btn.setStyleSheet("background-color: #4CAF50; color: white; font-weight: bold; padding: 10px;")
        self.run_btn.clicked.connect(self.on_run_clicked)

        # Progress bar, displayed during processing only
        self.progress_bar = QProgressBar()

        self.layout.addLayout(self.form_layout)
        self.layout.addWidget(self.run_btn)
        self.layout.addWidget(self.progress_bar)

        self.setLayout(self.layout)

    def toggle_nuclei_channel(self, state):
        if state == 0:
            self.nuclei_chan.setEnabled(False)
        else:
            self.nuclei_chan.setEnabled(True)

    def update_callback(self, iteration, index, text, total):
        self.progress_bar.setMaximum(total)
        self.progress_bar.setValue(iteration)
        if (iteration == 0 and total == 0):
            self.progress_bar.reset()
            return
        self.image_table.setItem(index, 2, QTableWidgetItem(text))
        
    def set_enabled(self, enabled):
        self.path_input.setEnabled(enabled)
        self.median_diameter.setEnabled(enabled)
        self.xy_size.setEnabled(enabled)
        self.z_size.setEnabled(enabled)
        self.nuclei_chan.setEnabled(enabled)
        self.membrane_chan.setEnabled(enabled)
        self.use_gpu.setEnabled(enabled)
        self.run_btn.setEnabled(enabled)
        self.use_secondary.setEnabled(enabled)
        self.image_table.setEnabled(enabled)
        if enabled:
            self.run_btn.setStyleSheet("background-color: #4CAF50; color: white; font-weight: bold; padding: 10px;")
        else:
            self.run_btn.setStyleSheet("background-color: #A9A9A9; color: gray; font-weight: normal; padding: 10px;")

    def get_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Directory")
        if folder:
            self.path_input.setText(folder)
            self.update_image_table(folder)

    def get_folder_content(self, folder):
        p = get_prefix()
        return [item for item in os.listdir(folder) if (item.lower().endswith('.tif') or item.lower().endswith('.tiff')) and not item.startswith(p)]
    
    def update_image_table(self, folder):
        content = self.get_folder_content(folder)
        self.image_table.setRowCount(len(content))
        for i, img in enumerate(content):
            select_checkbox = QCheckBoxWidget()
            select_checkbox.setChecked(True)
            select_checkbox.stateChanged.connect(lambda state, row=i: self.on_image_checkbox_changed(row, state))
            name_item = QTableWidgetItem(img)
            name_item.setFlags(name_item.flags() & ~Qt.ItemFlag.ItemIsEditable)
            status_item = QTableWidgetItem("📍 Discovered")
            self.image_table.setCellWidget(i, 0, select_checkbox)
            self.image_table.setItem(i, 1, name_item)
            self.image_table.setItem(i, 2, status_item)

    def on_image_checkbox_changed(self, row, state):
        name_item = self.image_table.item(row, 1)
        if name_item is not None:
            if state == Qt.CheckState.Checked.value:
                name_item.setFlags(name_item.flags() | Qt.ItemFlag.ItemIsEditable)
            else:
                name_item.setFlags(name_item.flags() & ~Qt.ItemFlag.ItemIsEditable)

    def images_from_table(self):
        images = []
        for i in range(self.image_table.rowCount()):
            checkbox = self.image_table.cellWidget(i, 0)
            if checkbox is not None and checkbox.isChecked():
                name_item = self.image_table.item(i, 1)
                if name_item is not None:
                    images.append((name_item.text(), i))
                    self.image_table.item(i, 2).setText("⏳ Pending")
            else:
                self.image_table.item(i, 2).setText("🚫 Skipped")
        return images

    def on_processing_finished(self):
        self.set_enabled(True)
        self.update_callback(0, 0, "", 0)
        self.progress_bar.reset()
        print("Processing finished.")

    def on_run_clicked(self):
        self.set_enabled(False)
        settings = {
            "folder_path"     : self.path_input.text(),
            "median_diameter" : self.median_diameter.value(),
            "xy_pixel_size"   : self.xy_size.value(),
            "z_pixel_size"    : self.z_size.value(),
            "nuclei_channel"  : self.nuclei_chan.value(),
            "membrane_channel": self.membrane_chan.value(),
            "use_gpu"         : self.use_gpu.isChecked(),
            "use_secondary"   : self.use_secondary.isChecked()
        }
        self.save_settings(settings)

        images_list = self.images_from_table()
        self.worker_thread = Thread(
            target=self.run_method,
            args=(settings, images_list),
            daemon=True
        )
        self.worker_thread.start()

    def run_method(self, settings, images_list):
        """Runs in a background thread."""
        try:
            run_cellpose_sam(
                settings,
                content=images_list,
                callback=self.progress_signal.emit
            )
        finally:
            self.finished_signal.emit()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    gui = ProcessingGui()
    gui.show()
    sys.exit(app.exec())