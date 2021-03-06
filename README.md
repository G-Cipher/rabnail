# rabnail
A feature-crept replacement for Jacob Brown's WireThumb gallery generator.

## Dependencies

[ImageMagick] command-line utilities: convert, identify, and mogrify.

## Usage
```
usage: rabnail.sh [options] [filename(s)]

      -o  thumbnail type: jpg, png, gif   [jpg]
      -q  quality: 0 smallest, 100 best   [75]
      -w  width in pixels                 [150]
      -b  thumbnail border in pixels      [0]
      -p  thumbnails per page             [65]
      -c  gallery color or hex "\#ffffff" [none]
      -i  html gallery filename           [index].html
```

## Example
See example output here: http://reboots.g-cipher.net/mark/

## Old Changelog (pre-git)

Updated 2012-05-29: Minor modification to account for recent versions of
convert which broke height and width tags, **again**.

Updated 2009-04-25: New features added:

* Explicitly sets world-readable permissions for files and directories
generated.
* New -i option specifies an alternate gallery filename instead of
index[n].html.
* Rabnail now embeds a token in every index it creates and checks for presence
of this token before deleting or overwriting old indices. The countless hours
of labor in your root index.html are safe.

Updated 2008-02-08: Minor modification to account for recent versions of
convert which broke height and width tags.

  [imagemagick]: http://www.imagemagick.org/
