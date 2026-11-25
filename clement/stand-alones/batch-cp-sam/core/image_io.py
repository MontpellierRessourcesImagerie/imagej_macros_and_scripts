"""Reading multi-channel TIFF files and writing label images."""

from pathlib import Path
import numpy as np
import tifffile
import xarray as xr
from cellpose_napari import ImageUtils

CANONICAL_AXES = "TZCYX"
TIFF_EXTENSIONS = (".tif", ".tiff")


def list_tiff_files(folder):
    """Sorted list of the TIFF files directly contained in `folder`."""
    folder = Path(folder)
    if not folder.is_dir():
        return []
    return sorted(
        (p for p in folder.iterdir() if p.is_file() and p.suffix.lower() in TIFF_EXTENSIONS),
        key=lambda p: p.name.lower()
    )


class MultiChannelImage:
    """
    A TIFF image opened as a `xr.DataArray` with canonical axes (a subset of TZCYX).
    Channels are extracted as TZCYX arrays (with C=1), as expected by cellpose-napari.
    """

    def __init__(self, path, is_3d):
        self.path  = Path(path)
        self.is_3d = is_3d
        self.data  = self._read()
        self._check_dimensionality()

    # -- Reading ---------------------------------------------------------

    def _read(self):
        with tifffile.TiffFile(self.path) as tif:
            series = tif.series[0]
            data   = series.asarray()
            axes   = series.axes.upper().replace("S", "C")
        if len(axes) != data.ndim or any(a not in CANONICAL_AXES for a in axes) or len(set(axes)) != len(axes):
            axes = self._guess_axes(data.ndim)
        da = xr.DataArray(data, dims=list(axes))
        da = da.transpose(*[a for a in CANONICAL_AXES if a in da.dims])
        if "C" not in da.dims: # single channel image
            da = da.expand_dims({"C": 1}, axis=da.dims.index("Y"))
        return da

    def _guess_axes(self, ndim):
        """Fallback when the file metadata doesn't describe the axes."""
        guesses = {
            True : {3: "ZYX", 4: "ZCYX", 5: "TZCYX"},
            False: {2: "YX", 3: "CYX", 4: "TCYX"},
        }
        axes = guesses[self.is_3d].get(ndim)
        if axes is None:
            raise ValueError(f"Cannot interpret an image with {ndim} dimensions.")
        return axes

    def _check_dimensionality(self):
        n_slices = self.data.sizes.get("Z", 1)
        if self.is_3d and n_slices <= 1:
            raise ValueError("The image is 2D but the 3D option is checked.")
        if not self.is_3d and n_slices > 1:
            raise ValueError("The image is a 3D stack but the 3D option is unchecked.")

    # -- Accessors -------------------------------------------------------

    @property
    def n_channels(self):
        return self.data.sizes["C"]

    def channel(self, index):
        """Returns the channel `index` (1-based) as a TZCYX `xr.DataArray`."""
        if not (1 <= index <= self.n_channels):
            raise ValueError(f"Channel {index} requested but the image has {self.n_channels} channel(s).")
        ch = self.data.isel(C=[index - 1])
        return ImageUtils.ensureAxes(ch, list(CANONICAL_AXES))


class LabelWriter:
    """Writes label images (TZCYX buffers with C=1) as calibrated ImageJ TIFF files."""

    def __init__(self, output_folder, xy_pixel_size, z_pixel_size, is_3d):
        self.output_folder = Path(output_folder)
        self.xy_pixel_size = xy_pixel_size
        self.z_pixel_size  = z_pixel_size
        self.is_3d         = is_3d
        self.output_folder.mkdir(parents=True, exist_ok=True)

    def _to_imagej_axes(self, labels):
        labels = labels.isel(C=0)
        if not self.is_3d:
            labels = labels.isel(Z=0)
        if labels.sizes["T"] == 1:
            labels = labels.isel(T=0)
        return labels

    def write(self, labels, name):
        labels = self._to_imagej_axes(labels)
        axes   = "".join(str(a) for a in labels.dims)
        values = np.asarray(labels.values)
        if values.max(initial=0) > np.iinfo(np.uint16).max:
            raise ValueError(f"Too many labels to be saved as 16-bit in '{name}'.")
        metadata = {"axes": axes, "unit": "um"}
        if self.is_3d:
            metadata["spacing"] = self.z_pixel_size
        path = self.output_folder / name
        tifffile.imwrite(
            path,
            values.astype(np.uint16),
            imagej=True,
            resolution=(1.0 / self.xy_pixel_size, 1.0 / self.xy_pixel_size),
            metadata=metadata,
        )
        return path
