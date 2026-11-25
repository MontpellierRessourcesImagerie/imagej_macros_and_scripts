"""Batch processing of a list of images: cells, nuclei and cells without nuclei."""

import traceback
from dataclasses import dataclass
from pathlib import Path
import numpy as np

from core.image_io import MultiChannelImage, LabelWriter
from core.segmentation import SharedModel, ObjectSegmenter

OUTPUT_FOLDER_NAME = "segmentation"


@dataclass
class ImageJob:
    path: Path
    row : int   # row in the GUI table, used to report the status


class BatchCallbacks:
    """Hooks called by `BatchRunner`. Override what you need (all methods are no-ops)."""
    def on_started(self, total): pass
    def on_image_status(self, row, status): pass
    def on_progress(self, done, total): pass
    def on_finished(self): pass


class BatchRunner:

    def __init__(self, settings, jobs, callbacks=None):
        self.settings  = settings
        self.jobs      = list(jobs)
        self.callbacks = callbacks or BatchCallbacks()
        self.output_folder = Path(settings.folder_path) / OUTPUT_FOLDER_NAME

    # -- Setup -----------------------------------------------------------

    def _make_segmenters(self, shared_model):
        s = self.settings
        cells  = ObjectSegmenter(shared_model, s.cells.diameter,  s.anisotropy) if s.cells.enabled  else None
        nuclei = ObjectSegmenter(shared_model, s.nuclei.diameter, s.anisotropy) if s.nuclei.enabled else None
        return cells, nuclei

    def _make_writer(self):
        s = self.settings
        return LabelWriter(self.output_folder, s.xy_pixel_size, s.z_pixel_size, s.is_3d)

    # -- Processing ------------------------------------------------------

    @staticmethod
    def remove_nuclei(cells, nuclei):
        """Cells labels with the pixels covered by any nucleus set to 0."""
        cytoplasm = cells.copy()
        cytoplasm.values[np.asarray(nuclei.values) > 0] = 0
        return cytoplasm

    def _process_image(self, job, cells_segmenter, nuclei_segmenter, writer):
        s     = self.settings
        image = MultiChannelImage(job.path, s.is_3d)
        stem  = job.path.stem

        nuclei_ch = image.channel(s.nuclei.channel) if s.nuclei.enabled else None
        cells_ch  = image.channel(s.cells.channel)  if s.cells.enabled  else None

        nuclei_labels = None
        if nuclei_segmenter is not None:
            self.callbacks.on_image_status(job.row, "▶️ Nuclei...")
            nuclei_labels = nuclei_segmenter.segment(nuclei_ch)
            writer.write(nuclei_labels, f"{stem}_nuclei.tif")

        cells_labels = None
        if cells_segmenter is not None:
            self.callbacks.on_image_status(job.row, "▶️ Cells...")
            secondary = nuclei_ch if s.uses_nuclei_assist else None
            cells_labels = cells_segmenter.segment(cells_ch, secondary)
            writer.write(cells_labels, f"{stem}_cells.tif")

        if s.produces_cytoplasm:
            writer.write(self.remove_nuclei(cells_labels, nuclei_labels), f"{stem}_cytoplasm.tif")

    def run(self):
        total = len(self.jobs)
        self.callbacks.on_started(total)
        shared_model = SharedModel(self.settings.use_gpu)
        try:
            cells_segmenter, nuclei_segmenter = self._make_segmenters(shared_model)
            writer = self._make_writer()
            for i, job in enumerate(self.jobs):
                print(f"  - [{i+1}/{total}] Processing: {job.path.name}")
                try:
                    self._process_image(job, cells_segmenter, nuclei_segmenter, writer)
                    self.callbacks.on_image_status(job.row, "✅ Done")
                except Exception as e:
                    traceback.print_exc()
                    self.callbacks.on_image_status(job.row, f"❌ {e}")
                self.callbacks.on_progress(i + 1, total)
            print(f"Done. Results saved in: {self.output_folder}")
        finally:
            shared_model.release()
            self.callbacks.on_finished()
