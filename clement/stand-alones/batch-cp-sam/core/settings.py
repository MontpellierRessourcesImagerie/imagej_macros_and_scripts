"""Persistent settings of the batch segmentation."""

import json
from dataclasses import dataclass, field, asdict
from pathlib import Path


@dataclass
class ObjectSettings:
    """Settings of one kind of object to segment (cells or nuclei)."""
    enabled : bool  = True
    channel : int   = 1      # 1-based channel index
    diameter: float = 30.0   # median diameter, in pixels

    @classmethod
    def from_dict(cls, data, default):
        data = data or {}
        return cls(
            enabled  = bool(data.get("enabled", default.enabled)),
            channel  = int(data.get("channel", default.channel)),
            diameter = float(data.get("diameter", default.diameter)),
        )


@dataclass
class BatchSettings:
    folder_path        : str   = ""
    use_gpu            : bool  = False
    xy_pixel_size      : float = 1.0
    is_3d              : bool  = True
    z_pixel_size       : float = 1.0
    cells              : ObjectSettings = field(default_factory=lambda: ObjectSettings(True, 1, 220.0))
    nuclei             : ObjectSettings = field(default_factory=lambda: ObjectSettings(True, 2, 100.0))
    nuclei_assist_cells: bool  = True  # feed the nuclei channel as secondary channel for the cells
    export_cytoplasm   : bool  = False # export cells minus their nuclei

    # -- Derived values --------------------------------------------------

    @property
    def anisotropy(self):
        if not self.is_3d or self.xy_pixel_size <= 0:
            return 1.0
        return self.z_pixel_size / self.xy_pixel_size

    @property
    def uses_nuclei_assist(self):
        return self.cells.enabled and self.nuclei.enabled and self.nuclei_assist_cells

    @property
    def produces_cytoplasm(self):
        return self.cells.enabled and self.nuclei.enabled and self.export_cytoplasm

    def validate(self):
        """Returns a list of human readable errors (empty if the settings are usable)."""
        errors = []
        if not Path(self.folder_path).is_dir():
            errors.append("The input folder does not exist.")
        if not (self.cells.enabled or self.nuclei.enabled):
            errors.append("Enable at least cells or nuclei segmentation.")
        if self.xy_pixel_size <= 0:
            errors.append("The XY pixel size must be strictly positive.")
        if self.is_3d and self.z_pixel_size <= 0:
            errors.append("The Z pixel size must be strictly positive.")
        if self.is_3d and self.anisotropy < 1.0:
            errors.append("The Z pixel size must be greater than or equal to the XY pixel size.")
        return errors

    # -- (De)serialization -----------------------------------------------

    @classmethod
    def from_dict(cls, data):
        default = cls()
        data = dict(data or {})
        cls._migrate_legacy(data)
        return cls(
            folder_path         = str(data.get("folder_path", default.folder_path)),
            use_gpu             = bool(data.get("use_gpu", default.use_gpu)),
            xy_pixel_size       = float(data.get("xy_pixel_size", default.xy_pixel_size)),
            is_3d               = bool(data.get("is_3d", default.is_3d)),
            z_pixel_size        = float(data.get("z_pixel_size", default.z_pixel_size)),
            cells               = ObjectSettings.from_dict(data.get("cells"), default.cells),
            nuclei              = ObjectSettings.from_dict(data.get("nuclei"), default.nuclei),
            nuclei_assist_cells = bool(data.get("nuclei_assist_cells", default.nuclei_assist_cells)),
            export_cytoplasm    = bool(data.get("export_cytoplasm", default.export_cytoplasm)),
        )

    @staticmethod
    def _migrate_legacy(data):
        """Converts the settings written by the previous version of the GUI."""
        if "cells" not in data and "membrane_channel" in data:
            data["cells"] = {
                "enabled" : True,
                "channel" : data["membrane_channel"],
                "diameter": data.get("median_diameter", 220),
            }
        if "nuclei" not in data and "nuclei_channel" in data:
            data["nuclei"] = {"enabled": True, "channel": data["nuclei_channel"]}
        if "nuclei_assist_cells" not in data and "use_secondary" in data:
            data["nuclei_assist_cells"] = data["use_secondary"]

    def to_dict(self):
        return asdict(self)

    def save(self, path):
        with open(path, "w") as f:
            json.dump(self.to_dict(), f, indent=4)

    @classmethod
    def load(cls, path):
        path = Path(path)
        if not path.is_file():
            return cls()
        try:
            with open(path) as f:
                return cls.from_dict(json.load(f))
        except (OSError, ValueError, TypeError) as e:
            print(f"Could not read settings from {path} ({e}), using defaults.")
            return cls()
