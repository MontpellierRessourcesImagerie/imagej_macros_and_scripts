"""Cellpose-SAM inference, based on the workers of cellpose-napari."""

import gc
import torch
from cellpose import io, models
from cellpose_napari.workers.inference_cpsam import CPSAMInference


class SharedModel:
    """
    Lazily loads the Cellpose-SAM model once and shares it between all the inferences
    (cells, nuclei, every image), instead of reloading it for each call.
    """

    def __init__(self, use_gpu, pretrained_model="cpsam"):
        self.use_gpu = use_gpu
        self.pretrained_model = pretrained_model
        self._model = None

    def get(self):
        if self._model is None:
            io.logger_setup()
            self._model = models.CellposeModel(
                gpu=self.use_gpu,
                pretrained_model=self.pretrained_model
            )
        return self._model

    def release(self):
        self._model = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()


class SharedModelInference(CPSAMInference):
    """`CPSAMInference` that takes its model from a `SharedModel` instead of instantiating it."""

    def __init__(self, shared_model, **kwargs):
        super().__init__(use_gpu=shared_model.use_gpu, **kwargs)
        self.shared_model = shared_model

    def instanciate_model(self):
        return self.shared_model.get()


class ObjectSegmenter:
    """Segments one kind of object (cells or nuclei) with fixed parameters."""

    def __init__(self, shared_model, diameter, anisotropy, min_size=15, cell_prob=0.0, flow_thr=0.4, flow_smooth=0):
        self.shared_model = shared_model
        self.params = dict(
            diameter=diameter,
            anisotropy=anisotropy,
            min_size=min_size,
            cell_prob=cell_prob,
            flow_thr=flow_thr,
            flow_smooth=flow_smooth,
        )

    def segment(self, ch_main, ch_secondary=None):
        """
        Runs the inference on TZCYX channels (C=1 each).
        Returns the labels as a TZCYX `xr.DataArray` (C=1, uint16).
        """
        worker = SharedModelInference(
            self.shared_model,
            ch_main=ch_main,
            ch_secondary=ch_secondary,
            **self.params
        )
        for _ in worker.run(): # consume the generator (one step per time point)
            pass
        return worker.output_buffer
