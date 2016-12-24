#!/bin/sh
# rabnail.sh (a)2012 reboots at g-cipher.net - http://reboots.g-cipher.net/
# Rabnail was originally conceived as a revision of Jacob Brown's WireThumb,
# which was released under the LGPL. Due to unfamiliarity with perl it has
# evolved into a wholly original work, and is effectively a feature-crept
# WireThumb workalike. This means as the author I am expected to come up
# with Terms & Conditions. Here goes:
# 1. Whereas reliance on copyright "law" only grants legitimacy to statist
#    dominion of human thought and action, and;
# 2. Whereas attempting to "license" a (barely) human-readable script cobbled
#    together from bits of bash tutorials would be inane in the extreme;
# The work below is hereby placed in the public domain. This software is
# free as in thought; do with it what you will.

# BUGS: Color may be a hex triplet, but the # must be escaped as: -c \#ffffff.
# No test for presence of user-specified files; lots of ugliness if files do
# not exist. Default text colors are invisible on some backgrounds.
# TODO: Add option to specify thumbnail height (preserve aspect ratio).
# Allow sorting by user-specified criteria rather than by asciibetical.
# Generate quick links to each gallery page in footer.

# Force create mask to world-readable
umask 0022

# Options parser
while [ $# -gt 0 ]
do
  case "$1" in
    -o)  output="$2"; shift;;
    -q)  quality="$2"; shift;;
    -w)  width="$2"; shift;;
    -c)  color="$2"; shift;;
    -b)  border="$2"; shift;;
    -p)  pixperpage="$2"; shift;;
    -i)  index="$2"; shift;;
    --)	shift; break;;
    -*)
      echo
      echo "usage: $0 [options] [filename(s)]"
      echo
      echo '      -o  thumbnail type: jpg, png, gif   [jpg]'
      echo '      -q  quality: 0 smallest, 100 best   [75]'
      echo '      -w  width in pixels                 [150]'
      echo '      -b  thumbnail border in pixels      [0]'
      echo '      -p  thumbnails per page             [65]'
      echo '      -c  gallery color or hex "\#ffffff" [none]'
      echo '      -i  html gallery filename           [index].html'
      echo
      exit 1;;
    *)  break;;
  esac
  shift
done

# Set option defaults
if [ -z "$output" ]; then output="jpg"; fi
if [ -z "$quality" ]; then quality="75"; fi
if [ -z "$width" ]; then width="150"; fi
if [ -z "$pixperpage" ]; then pixperpage="65"; fi
if [ -z "$border" ]; then border="0"; fi
if [ -z "$color" ]; then body="<body>"; else body="<body bgcolor=\"$color\">";fi
if [ -z "$index" ]; then index="index"; fi
#if [ -z "$color" ]; then color=""; fi

# HTML template
header='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"'"\n"'      "http://www.w3.org/TR/html4/loose.dtd">'"\n<html>\n<title>Gallery</title>\n"'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'"\n"'<!-- REMOVING THIS LINE WILL PREVENT RABNAIL FROM DELETING THIS INDEX -->'"\n"
footer="<center>\nGallery generated by <a href=\"https://github.com/G-Cipher/rabnail\">rabnail</a>.\n</center>\n</body>\n</html>"

# If no file arguments, add all files in the current directory that are
# supported by ImageMagick
if [ $# -eq 0 ]; then
  for file in *; do
    [ -f "$file" ] || continue
    identify "./$file[0]" > /dev/null 2>&1 || continue
    set "$@" "$file"
  done
fi
if [ $# -eq 0 ]; then
  echo
  echo "No image files present!"
  echo
  exit 1
fi

# Generate indices and thumbnails
echo
echo "Creating thumbnails of type $output, quality $quality, width $width."
echo

if [ ! -e "thumbs" ]; then mkdir thumbs ; fi

# Remove old indices

for file in $index*.html; do
  [ -e "$file" ] || continue
  if grep -q "PREVENT RABNAIL" "$file"; then
    echo "Deleting old rabnail index: $file"
    rm -f "$file"
  else
    echo "$file was not created by rabnail, cannot overwrite!"
    echo "Feel free to specify an alternate index name with the -i option."
    echo ""
    echo "Exiting..."
    exit 1
  fi
done

echo ""

#Create new indices
idx=""

echo -e "Creating $index.html" #debug
echo -e "$header $body" > "$index$idx.html"

n=1

while [ $# -gt 0 ]; do
  file="$1"
  shift
  if [ "$n" -gt "$pixperpage" ]; then
    idx=$((idx + 1))
    echo -e "$header $body" > "$index$idx.html"
    echo -e "Creating $index$idx.html" #debug
    n=1
  fi

  thumb="thumbs/${file%.*}_th.$output"
  mogrify -auto-orient "./$file[0]"
  convert -verbose -quality $quality -thumbnail $width "./$file[0]" "$thumb" |
  { IFS=">x+ " ; read x x x x x width height x
  echo "<a href=\"$file\"><img alt=\"$file\" src=\"$thumb\" border=\"$border\" width=\"$width\" height=\"$height\"></a>" \
     >> "$index$idx.html" ; }
  printf "%s\n" "$file --> $thumb"
  
  n=$((n + 1))

done

# Add navigation and finish indices
topen="<p><table width=\"95%\">\n<tr><td align=left>"
tclose="</td></tr>\n</table>"

for file in $index*.html; do
  idx="${file%.html}"
  idx=${idx#$index}
  next="$index$((idx + 1)).html"

  if [ -z "$idx" ]; then
    if [ -e "$next" ]; then
      echo -e "$topen</td><td align=right><a href=\"$next\">Next</a>$tclose" \
        >> $file
    else
      echo "<p>" >> $file
    fi
  elif [ $idx -gt 1 ]; then
    echo -e "$topen<a href=\"$index$((idx - 1)).html\">Back</a>" >> "$file"
    if [ -e "$next" ]; then
      echo "</td><td align=right><a href=\"$next\">Next</a>" >> "$file"
    fi
    echo -e "$tclose" >> "$file"
  else
    echo -e "$topen<a href=\"$index.html\">Back</a></td>" >> $file
    if [ -e "$next" ]; then
      echo "<td align=right><a href=\"$next\">Next</a>" >> $file
    else
      echo "<td align=right>" >> $file
    fi
    echo -e "$tclose" >> "$file"
  fi  
  echo -e "$footer" >> "$file"  
done

echo
echo "Finished!"
echo

exit 0
