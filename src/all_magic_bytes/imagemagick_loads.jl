
#
#taken from
filestr = """
BMP RW Microsoft Windows bitmap    By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.
BMP2 RW Microsoft Windows bitmap    By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.
BMP3 RW  Microsoft Windows bitmap    By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.
AAI RW  AAI Dune image
ART RW  PFS: 1st Publisher  Format originally used on the Macintosh (MacPaint?) and later used for PFS: 1st Publisher clip art.
ARW R   Sony Digital Camera Alpha Raw Image Format
AVI R   Microsoft Audio/Visual Interleaved
AVS RW  AVS X image
CALS    R   Continuous Acquisition and Life-cycle Support Type 1 image  Specified in MIL-R-28002 and MIL-PRF-28002. Standard blueprint archive format as used by the US military to replace microfiche.
CGM R   Computer Graphics Metafile  Requires ralcgm to render CGM files.
CIN RW  Kodak Cineon Image Format   Use -set to specify the image gamma or black and white points (e.g. -set gamma 1.7, -set reference-black 95, -set reference-white 685). Properties include cin:file.create_date, cin:file.create_time, cin:file.filename, cin:file.version, cin:film.count, cin:film.format, cin:film.frame_id, cin:film.frame_position, cin:film.frame_rate, cin:film.id, cin:film.offset, cin:film.prefix, cin:film.slate_info, cin:film.type, cin:image.label, cin:origination.create_date, cin:origination.create_time, cin:origination.device, cin:origination.filename, cin:origination.model, cin:origination.serial, cin:origination.x_offset, cin:origination.x_pitch, cin:origination.y_offset, cin:origination.y_pitch, cin:user.data.
CMYK    RW  Raw cyan, magenta, yellow, and black samples    Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.
CMYKA   RW  Raw cyan, magenta, yellow, black, and alpha samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.
CR2 R   Canon Digital Camera Raw Image Format   Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. cr2:image.cr2).
CRW R   Canon Digital Camera Raw Image Format
CUR R   Microsoft Cursor Icon
CUT R   DR Halo
DCM R   Digital Imaging and Communications in Medicine (DICOM) image    Used by the medical community for images like X-rays. ImageMagick sets the initial display range based on the Window Center (0028,1050) and Window Width (0028,1051) tags. Use -define dcm:display-range=reset to set the display range to the minimum and maximum pixel values.
DCR R   Kodak Digital Camera Raw Image File
DCX RW  ZSoft IBM PC multi-page Paintbrush image
DDS RW  Microsoft Direct Draw Surface   Use -define to specify the compression (e.g. -define dds:compression={dxt1, dxt5, none}). Other defines include dds:cluster-fit={true,false}, dds:weight-by-alpha={true,false}, and use dds:mipmaps to set the number of mipmaps.
DIB RW  Microsoft Windows Device Independent Bitmap DIB is a BMP file without the BMP header. Used to support embedded images in compound formats like WMF.
DJVU    R
DNG R   Digital Negative    Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. dng:image.dng).
DOT R   Graph Visualization Use -define to specify the layout engine (e.g. -define dot:layout-engine=twopi).
DPX RW  SMPTE Digital Moving Picture Exchange 2.0 (SMPTE 268M-2003) Use -set to specify the image gamma or black and white points (e.g. -set gamma 1.7, -set reference-black 95, -set reference-white 685).
EMF R   Microsoft Enhanced Metafile (32-bit)    Only available under Microsoft Windows.
EPDF    RW  Encapsulated Portable Document Format
EPI RW  Adobe Encapsulated PostScript Interchange format    Requires Ghostscript to read.
EPS RW  Adobe Encapsulated PostScript   Requires Ghostscript to read.
EPS2    W   Adobe Level II Encapsulated PostScript  Requires Ghostscript to read.
EPS3    W   Adobe Level III Encapsulated PostScript Requires Ghostscript to read.
EPSF    RW  Adobe Encapsulated PostScript   Requires Ghostscript to read.
EPSI    RW  Adobe Encapsulated PostScript Interchange format    Requires Ghostscript to read.
EPT RW  Adobe Encapsulated PostScript Interchange format with TIFF preview  Requires Ghostscript to read.
EXR RW  High dynamic-range (HDR) file format developed by Industrial Light & Magic  See High Dynamic-Range Images for details on this image format. Requires the OpenEXR delegate library.
FAX RW  Group 3 TIFF    This format is a fixed width of 1728 as required by the standard. See TIFF format. Note that FAX machines use non-square pixels which are 1.5 times wider than they are tall but computer displays use square pixels so FAX images may appear to be narrow unless they are explicitly resized using a resize specification of 100x150%.
FIG R   FIG graphics format Requires TransFig.
FITS    RW  Flexible Image Transport System To specify a single-precision floating-point format, use -define quantum:format=floating-point. Set the depth to 64 for a double-precision floating-point format.
FPX RW  FlashPix Format FlashPix has the option to store mega- and giga-pixel images at various resolutions in a single file which permits conservative bandwidth and fast reveal times when displayed within a Web browser. Requires the FlashPix SDK.
GIF RW  CompuServe Graphics Interchange Format  8-bit RGB PseudoColor with up to 256 palette entires. Specify the format GIF87 to write the older version 87a of the format. Use -transparent-color to specify the GIF transparent color (e.g. -transparent-color wheat).
GPLT    R   Gnuplot plot files  Requires gnuplot4.0.tar.Z or later.
GRAY    RW  Raw gray samples    Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.
HDR RW  Radiance RGBE image format
HPGL    R   HP-GL plotter language  Requires hp2xx-3.4.4.tar.gz
HRZ RW  Slow Scane TeleVision
HTML    RW  Hypertext Markup Language with a client-side image map  Also known as HTM. Requires html2ps to read.
ICO R   Microsoft icon  Also known as ICON.
INFO    W   Format and characteristics of the image
INLINE  RW  Base64-encoded inline image The inline image look similar to inline:data:;base64,/9j/4AAQSk...knrn//2Q==. If the inline image exceeds 5000 characters, reference it from a file (e.g. inline:inline.txt). You can also write a base64-encoded image. Embed the mime type in the filename, for example, convert myimage inline:jpeg:myimage.txt.
JBIG    RW  Joint Bi-level Image experts Group file interchange format  Also known as BIE and JBG. Requires jbigkit-1.6.tar.gz.
JNG RW  Multiple-image Network Graphics JPEG in a PNG-style wrapper with transparency. Requires libjpeg and libpng-1.0.11 or later, libpng-1.2.5 or later recommended.
JP2 RW  JPEG-2000 JP2 File Format Syntax    Specify the encoding options with the -define option See JP2 Encoding Options for more details.
JPT RW  JPEG-2000 Code Stream Syntax    Specify the encoding options with the -define option See JP2 Encoding Options for more details.
J2C RW  JPEG-2000 Code Stream Syntax    Specify the encoding options with the -define option See JP2 Encoding Options for more details.
J2K RW  JPEG-2000 Code Stream Syntax    Specify the encoding options with the -define option See JP2 Encoding Options for more details.
JPEG    RW  Joint Photographic Experts Group JFIF format    Note, JPEG is a lossy compression. In addition, you cannot create black and white images with JPEG nor can you save transparency.
JXR RW  JPEG extended range Requires the jxrlib delegate library. Put the JxrDecApp and JxrEncApp applications in your execution path.
JSON    W   JavaScript Object Notation, a lightweight data-interchange format   Include additional attributes about the image with these defines: -define json:locate, -define json:limit, -define json:moments, or -define json:features.
MAN R   Unix reference manual pages Requires that GNU groff and Ghostcript are installed.
MAT R   MATLAB image format
MIFF    RW  Magick image file format    This format persists all image attributes known to ImageMagick. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.
MONO    RW  Bi-level bitmap in least-significant-byte first order
MNG RW  Multiple-image Network Graphics A PNG-like Image Format Supporting Multiple Images, Animation and Transparent JPEG. Requires libpng-1.0.11 or later, libpng-1.2.5 or later recommended. An interframe delay of 0 generates one frame with each additional layer composited on top. For motion, be sure to specify a non-zero delay.
M2V RW  Motion Picture Experts Group file interchange format (version 2)    Requires ffmpeg.
MPEG    RW  Motion Picture Experts Group file interchange format (version 1)    Requires ffmpeg.
MPC RW  Magick Persistent Cache image file format   The most efficient data processing pattern is a write-once, read-many-times pattern. The image is generated or copied from source, then various analyses are performed on the image pixels over time. MPC supports this pattern. MPC is the native in-memory ImageMagick uncompressed file format. This file format is identical to that used by ImageMagick to represent images in memory and is read by mapping the file directly into memory. The MPC format is not portable and is not suitable as an archive format. It is suitable as an intermediate format for high-performance image processing. The MPC format requires two files to support one image. Image attributes are written to a file with the extension .mpc, whereas, image pixels are written to a file with the extension .cache.
MPR RW  Magick Persistent Registry  This format permits you to write to and read images from memory. The image persists until the program exits. For example, let's use the MPR to create a checkerboard:
MRW R   Sony (Minolta) Raw Image File
MSL RW  Magick Scripting Language   MSL is the XML-based scripting language supported by the conjure utility. MSL requires the libxml2 delegate library.
MTV RW  MTV Raytracing image format
MVG RW  Magick Vector Graphics. The native ImageMagick vector metafile format. A text file containing vector drawing commands accepted by convert's -draw option.
NEF R   Nikon Digital SLR Camera Raw Image File
ORF R   Olympus Digital Camera Raw Image File
OTB RW  On-the-air Bitmap
P7  RW  Xv's Visual Schnauzer thumbnail format
PALM    RW  Palm pixmap
PAM W   Common 2-dimensional bitmap format
CLIPBOARD   RW  Windows Clipboard   Only available under Microsoft Windows.
PBM RW  Portable bitmap format (black and white)
PCD RW  Photo CD    The maximum resolution written is 768x512 pixels since larger images require huffman compression (which is not supported).
PCDS    RW  Photo CD    Decode with the sRGB color tables.
PCL W   HP Page Control Language    Use -define to specify fit to page option (e.g. -define pcl:fit-to-page=true).
PCX RW  ZSoft IBM PC Paintbrush file
PDB RW  Palm Database ImageViewer Format
PDF RW  Portable Document Format    Requires Ghostscript to read. By default, ImageMagick sets the page size to the MediaBox. Some PDF files, however, have a CropBox or TrimBox that is smaller than the MediaBox and may include white space, registration or cutting marks outside the CropBox or TrimBox. To force ImageMagick to use the CropBox or TrimBox rather than the MediaBox, use -define (e.g. -define pdf:use-cropbox=true or -define pdf:use-trimbox=true). Use -density to improve the appearance of your PDF rendering (e.g. -density 300x300). Use -alpha remove to remove transparency. To specify direct conversion from Postscript to PDF, use -define delegate:bimodel=true. Use -define pdf:fit-page=true to scale to the page size.
PEF R   Pentax Electronic File  Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. pef:image.pef).
PFA R   Postscript Type 1 font (ASCII)  Opening as file returns a preview image.
PFB R   Postscript Type 1 font (binary) Opening as file returns a preview image.
PFM RW  Portable float map format
PGM RW  Portable graymap format (gray scale)
PICON   RW  Personal Icon
PICT    RW  Apple Macintosh QuickDraw/PICT file
PIX R   Alias/Wavefront RLE image format
PNG RW  Portable Network Graphics   Requires libpng-1.0.11 or later, libpng-1.2.5 or later recommended. The PNG specification does not support pixels-per-inch units, only pixels-per-centimeter. To avoid reading a particular associated image profile, use -define profile:skip=name (e.g. profile:skip=ICC).
PNG8    RW  Portable Network Graphics   8-bit indexed with optional binary transparency
PNG00   RW  Portable Network Graphics   PNG inheriting subformat from original
PNG24   RW  Portable Network Graphics   opaque or binary transparent 24-bit RGB
PNG32   RW  Portable Network Graphics   opaque or transparent 32-bit RGBA
PNG48   RW  Portable Network Graphics   opaque or binary transparent 48-bit RGB
PNG64   RW  Portable Network Graphics   opaque or transparent 64-bit RGB
PNM RW  Portable anymap PNM is a family of formats supporting portable bitmaps (PBM) , graymaps (PGM), and pixmaps (PPM). There is no file format associated with pnm itself. If PNM is used as the output format specifier, then ImageMagick automagically selects the most appropriate format to represent the image. The default is to write the binary version of the formats. Use -compress none to write the ASCII version of the formats.
PPM RW  Portable pixmap format (color)
PS  RW  Adobe PostScript file   Requires Ghostscript to read. To force ImageMagick to respect the crop box, use -define (e.g. -define eps:use-cropbox=true). Use -density to improve the appearance of your Postscript rendering (e.g. -density 300x300). Use -alpha remove to remove transparency. To specify direct conversion from PDF to Postscript, use -define delegate:bimodel=true.
PS2 RW  Adobe Level II PostScript file  Requires Ghostscript to read.
PS3 RW  Adobe Level III PostScript file Requires Ghostscript to read.
PSB RW  Adobe Large Document Format
PSD RW  Adobe Photoshop bitmap file
PTIF    RW  Pyramid encoded TIFF    Multi-resolution TIFF containing successively smaller versions of the image down to the size of an icon.
PWP R   Seattle File Works multi-image file
RAD R   Radiance image file Requires that ra_ppm from the Radiance software package be installed.
RAF R   Fuji CCD-RAW Graphic File
RGB RW  Raw red, green, and blue samples    Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.
RGBA    RW  Raw red, green, blue, and alpha samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.
RFG RW  LEGO Mindstorms EV3 Robot Graphics File
RLA R   Alias/Wavefront image file
RLE R   Utah Run length encoded image file
SCT R   Scitex Continuous Tone Picture
SFW R   Seattle File Works image
SGI RW  Irix RGB image
SHTML   W   Hypertext Markup Language client-side image map Used to write HTML clickable image maps based on a the output of montage or a format which supports tiled images such as MIFF.
SID, MrSID  R   Multiresolution seamless image  Requires the mrsidgeodecode command line utility that decompresses MG2 or MG3 SID image files.
SPARSE-COLOR    W   Raw text file   Format compatible with the -sparse-color option. Lists only non-fully-transparent pixels.
SUN RW  SUN Rasterfile
SVG RW  Scalable Vector Graphics    ImageMagick utilizes inkscape if its in your execution path otherwise RSVG. If neither are available, ImageMagick reverts to its internal SVG renderer. The default resolution is 90dpi.
TGA RW  Truevision Targa image  Also known as formats ICB, VDA, and VST.
TIFF    RW  Tagged Image File Format    Also known as TIF. Requires tiff-v3.6.1.tar.gz or later. Use -define to specify the rows per strip (e.g. -define tiff:rows-per-strip=8). To define the tile geometry, use for example, -define tiff:tile-geometry=128x128. To specify a signed format, use -define quantum:format=signed. To specify a single-precision floating-point format, use -define quantum:format=floating-point. Set the depth to 64 for a double-precision floating-point format. Use -define quantum:polarity=min-is-black or -define quantum:polarity=min-is-white toggle the photometric interpretation for a bilevel image. Specify the extra samples as associated or unassociated alpha with, for example, -define tiff:alpha=unassociated. Set the fill order with -define tiff:fill-order=msb|lsb. Set the TIFF endianess with -define tiff:endian=msb|lsb. Use -define tiff:exif-properties=false to skip reading the EXIF properties. You can set a number of TIFF software attributes including document name, host computer, artist, timestamp, make, model, software, and copyright. For example, -set tiff:software "My Company". If you want to ignore certain TIFF tags, use this option: -define tiff:ignore-tags=comma-separated-list-of-tag-IDs
TIM R   PSX TIM file
TTF R   TrueType font file  Requires freetype 2. Opening as file returns a preview image. Use -set if you do not want to hint glyph outlines after their scaling to device pixels (e.g. -set type:hinting off).
TXT RW  Raw text file
UIL W   X-Motif UIL table
UYVY    RW  Interleaved YUV raw image   Use -size and -depth command line options to specify width and height. Use -sampling-factor to set the desired subsampling (e.g. -sampling-factor 4:2:2).
VICAR   RW  VICAR rasterfile format
VIFF    RW  Khoros Visualization Image File Format
WBMP    RW  Wireless bitmap Support for uncompressed monochrome only.
WDP RW  JPEG extended range Requires the jxrlib delegate library. Put the JxrDecApp and JxrEncApp applications in your execution path.
WEBP    RW  Weppy image format  Requires the WEBP delegate library. Specify the encoding options with the -define option See WebP Encoding Options for more details.
WMF R   Windows Metafile    Requires libwmf. By default, renders WMF files using the dimensions specified by the metafile header. Use the -density option to adjust the output resolution, and thereby adjust the output size. The default output resolution is 72DPI so -density 144 results in an image twice as large as the default. Use -background color to specify the WMF background color (default white) or -texture filename to specify a background texture image.
WPG R   Word Perfect Graphics File
X   RW  display or import an image to or from an X11 server Use -define to obtain the image from the root window (e.g. -define x:screen=true). Set x:silent=true to turn off the beep when importing an image.
XBM RW  X Windows system bitmap, black and white only   Used by the X Windows System to store monochrome icons.
XCF R   GIMP image
XPM RW  X Windows system pixmap Also known as PM. Used by the X Windows System to store color icons.
XWD RW  X Windows system window dump    Used by the X Windows System to save/display screen dumps.
X3F R   Sigma Camera RAW Picture File
YCbCr   RW  Raw Y, Cb, and Cr samples   Use -size and -depth to specify the image width, height, and depth.
YCbCrA  RW  Raw Y, Cb, Cr, and alpha samples    Use -size and -depth to specify the image width, height, and depth.
YUV RW"""

a = split(filestr, "\r\n")
readlist = []
writelist = []
for elem in a
	splitted = split(elem)
	f, rw = splitted
	description = join(splitted[3:end], " ")
	lc = uppercase(f)
	fl = "File{:$lc}, #=$description=#\n"
	contains("RW", "R") && push!(readlist, lc)
	contains("RW", "W") && push!(writelist, lc)
end

magics= readdlm(Pkg.dir("FileIO", "src", "all_magic_bytes", "all_signatures.txt"), ',', UTF8String)
f = open(Pkg.dir("FileIO", "src", "all_magic_bytes", "registry.jl"), "w")
magics_dict = Dict([magics[i, 1] => magics[i, 2] for i=1:size(magics, 1)])

fs = open(Pkg.dir("FileIO", "src","imagemagick_registry.jl"), "w")
for elem in readlist
    format = string("format\"", elem, "\"")
    if haskey(magics_dict, elem)
        magic = magics_dict[elem]
        magic = hex2bytes(replace(string(magic), " ", ""))
        println(fs, "add_format(", format, ", ", string(magic), ", \".", lowercase(elem), "\")")
    else # no magic bytes!?
        println(fs, "add_format(", format, ", (), \".", lowercase(elem), "\")")
    end
    println(fs, "add_loader(", format, ", :ImageMagick)")
    if elem in writelist
        println(fs, "add_saver(", format, ", :ImageMagick)")
    end
end
#println(fs, "Union(\n$(join(readlist)))")
#println(fs, "Union(\n$(join(writelist)))")
close(fs)
