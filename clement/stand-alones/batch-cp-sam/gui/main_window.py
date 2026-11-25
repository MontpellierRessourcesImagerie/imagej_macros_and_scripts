"""Main window of the batch Cellpose-SAM segmentation."""

from pathlib import Path
from threading import Thread
import torch
from qtpy.QtCore import QObject, Signal
from qtpy.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QGroupBox,
    QCheckBox,
    QPushButton,
    QProgressBar,
    QMessageBox,
)

from core.settings import BatchSettings
from core.batch import BatchRunner, BatchCallbacks, ImageJob
from gui.widgets import FolderSelector, ImageTable, CalibrationBox, ObjectSettingsBox

SETTINGS_PATH = Path(__file__).resolve().parent.parent / "qt_gui_settings.json"

RUN_STYLE_ENABLED  = "background-color: #4CAF50; color: white; font-weight: bold; padding: 10px;"
RUN_STYLE_DISABLED = "background-color: #A9A9A9; color: gray; font-weight: normal; padding: 10px;"


class QtBatchCallbacks(QObject, BatchCallbacks):
    """Forwards the batch events (emitted from the worker thread) to the GUI thread through signals."""

    started      = Signal(int)
    image_status = Signal(int, str)
    progress     = Signal(int, int)
    finished     = Signal()

    def on_started(self, total):          self.started.emit(total)
    def on_image_status(self, row, text): self.image_status.emit(row, text)
    def on_progress(self, done, total):   self.progress.emit(done, total)
    def on_finished(self):                self.finished.emit()


class MainWindow(QWidget):

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Batch Cellpose-SAM")
        self.setMinimumWidth(700)
        self.worker_thread = None
        self.callbacks = QtBatchCallbacks()
        self._build_ui()
        self._connect()
        self._apply_settings(BatchSettings.load(SETTINGS_PATH))

    # -- UI construction -------------------------------------------------

    def _build_ui(self):
        root = QVBoxLayout(self)

        # Header: input folder and discovered images
        self.folder_selector = FolderSelector()
        self.image_table = ImageTable()
        root.addWidget(self.folder_selector)
        root.addWidget(self.image_table, 1)

        self.use_gpu = QCheckBox("Use GPU acceleration")
        if not torch.cuda.is_available():
            self.use_gpu.setEnabled(False)
            self.use_gpu.setToolTip("No CUDA device available.")
        root.addWidget(self.use_gpu)

        # General information about the images
        self.calibration = CalibrationBox()
        root.addWidget(self.calibration)

        # Two columns: cells | nuclei
        self.cells_box  = ObjectSettingsBox("Cells")
        self.nuclei_box = ObjectSettingsBox("Nuclei")
        columns = QHBoxLayout()
        columns.addWidget(self.cells_box)
        columns.addWidget(self.nuclei_box)
        root.addLayout(columns)

        # Options requiring both cells and nuclei
        self.options_box = QGroupBox("Options")
        self.nuclei_assist = QCheckBox("Use the nuclei channel to help the cells segmentation")
        self.export_cytoplasm = QCheckBox("Also export the cells without their nucleus")
        options_layout = QVBoxLayout(self.options_box)
        options_layout.addWidget(self.nuclei_assist)
        options_layout.addWidget(self.export_cytoplasm)
        root.addWidget(self.options_box)

        # Run
        self.run_btn = QPushButton("Run")
        self.run_btn.setStyleSheet(RUN_STYLE_ENABLED)
        self.progress_bar = QProgressBar()
        root.addWidget(self.run_btn)
        root.addWidget(self.progress_bar)

    def _connect(self):
        self.folder_selector.folder_changed.connect(self.image_table.populate)
        self.cells_box.toggled.connect(self._update_options_state)
        self.nuclei_box.toggled.connect(self._update_options_state)
        self.run_btn.clicked.connect(self.on_run_clicked)
        self.callbacks.started.connect(self._on_started)
        self.callbacks.image_status.connect(self.image_table.set_status)
        self.callbacks.progress.connect(self._on_progress)
        self.callbacks.finished.connect(self._on_finished)

    def _update_options_state(self):
        both = self.cells_box.isChecked() and self.nuclei_box.isChecked()
        self.options_box.setEnabled(both)
        self.options_box.setToolTip("" if both else "Requires both cells and nuclei to be enabled.")

    # -- Settings <-> UI -------------------------------------------------

    def _apply_settings(self, s: BatchSettings):
        self.folder_selector.set_folder(s.folder_path)
        self.use_gpu.setChecked(s.use_gpu and torch.cuda.is_available())
        self.calibration.set_values(s.xy_pixel_size, s.is_3d, s.z_pixel_size)
        self.cells_box.set_settings(s.cells)
        self.nuclei_box.set_settings(s.nuclei)
        self.nuclei_assist.setChecked(s.nuclei_assist_cells)
        self.export_cytoplasm.setChecked(s.export_cytoplasm)
        self._update_options_state()

    def _collect_settings(self):
        return BatchSettings(
            folder_path         = self.folder_selector.folder(),
            use_gpu             = self.use_gpu.isChecked(),
            xy_pixel_size       = self.calibration.xy_size.value(),
            is_3d               = self.calibration.is_3d.isChecked(),
            z_pixel_size        = self.calibration.z_size.value(),
            cells               = self.cells_box.get_settings(),
            nuclei              = self.nuclei_box.get_settings(),
            nuclei_assist_cells = self.nuclei_assist.isChecked(),
            export_cytoplasm    = self.export_cytoplasm.isChecked(),
        )

    # -- Run -------------------------------------------------------------

    def set_controls_enabled(self, enabled):
        for w in (self.folder_selector, self.image_table, self.use_gpu, self.calibration,
                  self.cells_box, self.nuclei_box, self.run_btn):
            w.setEnabled(enabled)
        if enabled:
            self._update_options_state()
        else:
            self.options_box.setEnabled(False)
        if not torch.cuda.is_available():
            self.use_gpu.setEnabled(False)
        self.run_btn.setStyleSheet(RUN_STYLE_ENABLED if enabled else RUN_STYLE_DISABLED)

    def on_run_clicked(self):
        settings = self._collect_settings()
        errors = settings.validate()
        selected = self.image_table.selected_images()
        if not selected:
            errors.append("No image selected.")
        if errors:
            QMessageBox.warning(self, "Cannot run", "\n".join(errors))
            return

        settings.save(SETTINGS_PATH)
        self.image_table.mark_pending()
        jobs = [ImageJob(path=path, row=row) for row, path in selected]
        runner = BatchRunner(settings, jobs, self.callbacks)
        self.set_controls_enabled(False)
        self.worker_thread = Thread(target=runner.run, daemon=True)
        self.worker_thread.start()

    def _on_started(self, total):
        self.progress_bar.setMaximum(total)
        self.progress_bar.setValue(0)

    def _on_progress(self, done, total):
        self.progress_bar.setMaximum(total)
        self.progress_bar.setValue(done)

    def _on_finished(self):
        self.set_controls_enabled(True)
        self.progress_bar.reset()
        self.worker_thread = None
        print("Processing finished.")

    def closeEvent(self, event):
        if self.worker_thread is None: # don't overwrite the settings used by a running batch
            self._collect_settings().save(SETTINGS_PATH)
        super().closeEvent(event)
