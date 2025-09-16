# Lattice Light Sheet (LLS) Transforms

> This toolset allows to apply a deskewing or a cover-glass transform (CGT) to a stack acquired by a LLS. The default values configured there are the ones used by Zeiss' machine.

## Install

Download the `jars`, `macros` and `plugins` folders and merge them with your Fiji's hierarchy.

## Usage

- If the toolset is correctly installed, you must have a `LLS Transforms` in your "More tools" menu.
- This toolset is composed of four buttons:
    - Deskew only
    - CGT only
    - CGT within a range
    - Measure
    
#### Deskew only

- Open an image acquired on the LLS
- (Click): Applies the deskewing to the image with Zeiss' settings
- (Alt+Click): Allows you to provide a custom angle for the deskewing.

#### CGT only

- Open an image acquired on the LLS
- (Click): Applies the cover-glass transform to the image with Zeiss' settings
- (Alt+Click): Allows you to provide a custom angle for the CGT.

### CGT within a range

- Creates N versions of CGT to a same image within a range of angles.
- Settings:
    - Angle: Theoretical angle
    - Shift: Subtracted and added angle to the theoretical angle
    - Step: Angle between two CGT
    - Output: Output folder in which result images will be exported.
- Example: For an angle **A**, a shift **S** and a step **s**, the cover-glass transform will be applied for the angles from **A-S** to **A+S** every **s** degrees.

### Metrics

- Takes as input the folder filled by the previous macro.
- Creates a results table characterizing the objects found in the images.
- You must manually provide the threshold value used to create the masks.
