# Convert a directory of LSM files to BioRad .PIC
java_import "ij.IJ"
java_import "ij.process.StackConverter"

input_directory  = "/home/mark/lsm-examples/"
output_directory = "/home/mark/lsm-examples/biorad/"

include_class 'util.BatchOpener'
include_class 'Biorad_Writer'

# Check that the input directory exists:
unless FileTest.directory? input_directory
  ij.IJ.error "Input directory '#{input_directory} was not found"
  exit(-1)
end

# Create the output directory if it doesn't exist:
unless FileTest.exist? output_directory
  Dir.mkdir output_directory
end

# Biorad filenames have a standard format, which we generate with
# this function.  ('channel' should be 1-indexed):
def make_biorad_filename(lsm_filename,channel)
  lsm_filename.gsub(/.lsm$/,sprintf("%02d.pic",channel))
end

Dir.entries(input_directory).each do |e|
  # Skip anything that doesn't have a '.lsm' extension:
  next unless e =~ /\.lsm$/
  puts "Converting: #{e}"
  # Open the image file to an array of ImagePlus objects:
  a = BatchOpener.open("#{input_directory}#{e}")
  # Create the writer plugin object:
  writer = Biorad_Writer.new
  # Now, for each channel in the input image, write out
  index = 0
  a.each do |image|
    # The Biorad_Writer doesn't like COLOR_256 images, so convert to
    # GRAY8:
    ij.process.StackConverter.new(image).convertToGray8
    biorad_filename = make_biorad_filename e, index + 1
    puts "    Writing: #{biorad_filename}"
    writer.save image, output_directory, biorad_filename
    index += 1
    image.close
  end
end

ij.IJ.showMessage("Finished converting to Biorad format!")
