
OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
for file in `ls scad_files`; do
  echo "Processing $file"
  $OPENSCAD -o stl_files/$file.stl scad_files/$file
done
