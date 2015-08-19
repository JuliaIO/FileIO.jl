add_format(format"BMP", UInt8[0x42,0x4d], ".bmp")
add_loader(format"BMP", :ImageMagick)
add_saver(format"BMP", :ImageMagick)
add_format(format"BMP2", (), ".bmp2")
add_loader(format"BMP2", :ImageMagick)
add_saver(format"BMP2", :ImageMagick)
add_format(format"BMP3", (), ".bmp3")
add_loader(format"BMP3", :ImageMagick)
add_saver(format"BMP3", :ImageMagick)
add_format(format"AAI", (), ".aai")
add_loader(format"AAI", :ImageMagick)
add_saver(format"AAI", :ImageMagick)
add_format(format"ART", (), ".art")
add_loader(format"ART", :ImageMagick)
add_saver(format"ART", :ImageMagick)
add_format(format"ARW", (), ".arw")
add_loader(format"ARW", :ImageMagick)
add_saver(format"ARW", :ImageMagick)
add_format(format"AVI", UInt8[0x52,0x49,0x46,0x46], ".avi")
add_loader(format"AVI", :ImageMagick)
add_saver(format"AVI", :ImageMagick)
add_format(format"AVS", (), ".avs")
add_loader(format"AVS", :ImageMagick)
add_saver(format"AVS", :ImageMagick)
add_format(format"CALS", (), ".cals")
add_loader(format"CALS", :ImageMagick)
add_saver(format"CALS", :ImageMagick)
add_format(format"CGM", (), ".cgm")
add_loader(format"CGM", :ImageMagick)
add_saver(format"CGM", :ImageMagick)
add_format(format"CIN", (), ".cin")
add_loader(format"CIN", :ImageMagick)
add_saver(format"CIN", :ImageMagick)
add_format(format"CMYK", (), ".cmyk")
add_loader(format"CMYK", :ImageMagick)
add_saver(format"CMYK", :ImageMagick)
add_format(format"CMYKA", (), ".cmyka")
add_loader(format"CMYKA", :ImageMagick)
add_saver(format"CMYKA", :ImageMagick)
add_format(format"CR2", (), ".cr2")
add_loader(format"CR2", :ImageMagick)
add_saver(format"CR2", :ImageMagick)
add_format(format"CRW", UInt8[0x49,0x49,0x1a,0x00,0x00,0x00,0x48,0x45], ".crw")
add_loader(format"CRW", :ImageMagick)
add_saver(format"CRW", :ImageMagick)
add_format(format"CUR", UInt8[0x00,0x00,0x02,0x00], ".cur")
add_loader(format"CUR", :ImageMagick)
add_saver(format"CUR", :ImageMagick)
add_format(format"CUT", (), ".cut")
add_loader(format"CUT", :ImageMagick)
add_saver(format"CUT", :ImageMagick)
add_format(format"DCM", (), ".dcm")
add_loader(format"DCM", :ImageMagick)
add_saver(format"DCM", :ImageMagick)
add_format(format"DCR", (), ".dcr")
add_loader(format"DCR", :ImageMagick)
add_saver(format"DCR", :ImageMagick)
add_format(format"DCX", UInt8[0xb1,0x68,0xde,0x3a], ".dcx")
add_loader(format"DCX", :ImageMagick)
add_saver(format"DCX", :ImageMagick)
add_format(format"DDS", (), ".dds")
add_loader(format"DDS", :ImageMagick)
add_saver(format"DDS", :ImageMagick)
add_format(format"DJVU", (), ".djvu")
add_loader(format"DJVU", :ImageMagick)
add_saver(format"DJVU", :ImageMagick)
add_format(format"DNG", (), ".dng")
add_loader(format"DNG", :ImageMagick)
add_saver(format"DNG", :ImageMagick)
add_format(format"DOT", UInt8[0xd0,0xcf,0x11,0xe0,0xa1,0xb1,0x1a,0xe1], ".dot")
add_loader(format"DOT", :ImageMagick)
add_saver(format"DOT", :ImageMagick)
add_format(format"DPX", (), ".dpx")
add_loader(format"DPX", :ImageMagick)
add_saver(format"DPX", :ImageMagick)
add_format(format"EMF", (), ".emf")
add_loader(format"EMF", :ImageMagick)
add_saver(format"EMF", :ImageMagick)
add_format(format"EPDF", (), ".epdf")
add_loader(format"EPDF", :ImageMagick)
add_saver(format"EPDF", :ImageMagick)
add_format(format"EPI", (), ".epi")
add_loader(format"EPI", :ImageMagick)
add_saver(format"EPI", :ImageMagick)
add_format(format"EPS", UInt8[0x25,0x21,0x50,0x53,0x2d,0x41,0x64,0x6f], ".eps")
add_loader(format"EPS", :ImageMagick)
add_saver(format"EPS", :ImageMagick)
add_format(format"EPS2", (), ".eps2")
add_loader(format"EPS2", :ImageMagick)
add_saver(format"EPS2", :ImageMagick)
add_format(format"EPS3", (), ".eps3")
add_loader(format"EPS3", :ImageMagick)
add_saver(format"EPS3", :ImageMagick)
add_format(format"EPSF", (), ".epsf")
add_loader(format"EPSF", :ImageMagick)
add_saver(format"EPSF", :ImageMagick)
add_format(format"EPSI", (), ".epsi")
add_loader(format"EPSI", :ImageMagick)
add_saver(format"EPSI", :ImageMagick)
add_format(format"EPT", (), ".ept")
add_loader(format"EPT", :ImageMagick)
add_saver(format"EPT", :ImageMagick)
add_format(format"EXR", (), ".exr")
add_loader(format"EXR", :ImageMagick)
add_saver(format"EXR", :ImageMagick)
add_format(format"FAX", (), ".fax")
add_loader(format"FAX", :ImageMagick)
add_saver(format"FAX", :ImageMagick)
add_format(format"FIG", (), ".fig")
add_loader(format"FIG", :ImageMagick)
add_saver(format"FIG", :ImageMagick)
add_format(format"FITS", (), ".fits")
add_loader(format"FITS", :ImageMagick)
add_saver(format"FITS", :ImageMagick)
add_format(format"FPX", (), ".fpx")
add_loader(format"FPX", :ImageMagick)
add_saver(format"FPX", :ImageMagick)
add_format(format"GIF", UInt8[0x47,0x49,0x46,0x38], ".gif")
add_loader(format"GIF", :ImageMagick)
add_saver(format"GIF", :ImageMagick)
add_format(format"GPLT", (), ".gplt")
add_loader(format"GPLT", :ImageMagick)
add_saver(format"GPLT", :ImageMagick)
add_format(format"GRAY", (), ".gray")
add_loader(format"GRAY", :ImageMagick)
add_saver(format"GRAY", :ImageMagick)
add_format(format"HDR", UInt8[0x23,0x3f,0x52,0x41,0x44,0x49,0x41,0x4e], ".hdr")
add_loader(format"HDR", :ImageMagick)
add_saver(format"HDR", :ImageMagick)
add_format(format"HPGL", (), ".hpgl")
add_loader(format"HPGL", :ImageMagick)
add_saver(format"HPGL", :ImageMagick)
add_format(format"HRZ", (), ".hrz")
add_loader(format"HRZ", :ImageMagick)
add_saver(format"HRZ", :ImageMagick)
add_format(format"HTML", (), ".html")
add_loader(format"HTML", :ImageMagick)
add_saver(format"HTML", :ImageMagick)
add_format(format"ICO", UInt8[0x00,0x00,0x01,0x00], ".ico")
add_loader(format"ICO", :ImageMagick)
add_saver(format"ICO", :ImageMagick)
add_format(format"INFO", UInt8[0x7a,0x62,0x65,0x78], ".info")
add_loader(format"INFO", :ImageMagick)
add_saver(format"INFO", :ImageMagick)
add_format(format"INLINE", (), ".inline")
add_loader(format"INLINE", :ImageMagick)
add_saver(format"INLINE", :ImageMagick)
add_format(format"JBIG", (), ".jbig")
add_loader(format"JBIG", :ImageMagick)
add_saver(format"JBIG", :ImageMagick)
add_format(format"JNG", (), ".jng")
add_loader(format"JNG", :ImageMagick)
add_saver(format"JNG", :ImageMagick)
add_format(format"JP2", UInt8[0x00,0x00,0x00,0x0c,0x6a,0x50,0x20,0x20], ".jp2")
add_loader(format"JP2", :ImageMagick)
add_saver(format"JP2", :ImageMagick)
add_format(format"JPT", (), ".jpt")
add_loader(format"JPT", :ImageMagick)
add_saver(format"JPT", :ImageMagick)
add_format(format"J2C", (), ".j2c")
add_loader(format"J2C", :ImageMagick)
add_saver(format"J2C", :ImageMagick)
add_format(format"J2K", (), ".j2k")
add_loader(format"J2K", :ImageMagick)
add_saver(format"J2K", :ImageMagick)
add_format(format"JPEG", UInt8[0xff,0xd8,0xff,0xe3], ".jpeg")
add_loader(format"JPEG", :ImageMagick)
add_saver(format"JPEG", :ImageMagick)
add_format(format"JXR", (), ".jxr")
add_loader(format"JXR", :ImageMagick)
add_saver(format"JXR", :ImageMagick)
add_format(format"JSON", (), ".json")
add_loader(format"JSON", :ImageMagick)
add_saver(format"JSON", :ImageMagick)
add_format(format"MAN", (), ".man")
add_loader(format"MAN", :ImageMagick)
add_saver(format"MAN", :ImageMagick)
add_format(format"MAT", (), ".mat")
add_loader(format"MAT", :ImageMagick)
add_saver(format"MAT", :ImageMagick)
add_format(format"MIFF", (), ".miff")
add_loader(format"MIFF", :ImageMagick)
add_saver(format"MIFF", :ImageMagick)
add_format(format"MONO", (), ".mono")
add_loader(format"MONO", :ImageMagick)
add_saver(format"MONO", :ImageMagick)
add_format(format"MNG", (), ".mng")
add_loader(format"MNG", :ImageMagick)
add_saver(format"MNG", :ImageMagick)
add_format(format"M2V", (), ".m2v")
add_loader(format"M2V", :ImageMagick)
add_saver(format"M2V", :ImageMagick)
add_format(format"MPEG", (), ".mpeg")
add_loader(format"MPEG", :ImageMagick)
add_saver(format"MPEG", :ImageMagick)
add_format(format"MPC", (), ".mpc")
add_loader(format"MPC", :ImageMagick)
add_saver(format"MPC", :ImageMagick)
add_format(format"MPR", (), ".mpr")
add_loader(format"MPR", :ImageMagick)
add_saver(format"MPR", :ImageMagick)
add_format(format"MRW", (), ".mrw")
add_loader(format"MRW", :ImageMagick)
add_saver(format"MRW", :ImageMagick)
add_format(format"MSL", (), ".msl")
add_loader(format"MSL", :ImageMagick)
add_saver(format"MSL", :ImageMagick)
add_format(format"MTV", (), ".mtv")
add_loader(format"MTV", :ImageMagick)
add_saver(format"MTV", :ImageMagick)
add_format(format"MVG", (), ".mvg")
add_loader(format"MVG", :ImageMagick)
add_saver(format"MVG", :ImageMagick)
add_format(format"NEF", (), ".nef")
add_loader(format"NEF", :ImageMagick)
add_saver(format"NEF", :ImageMagick)
add_format(format"ORF", (), ".orf")
add_loader(format"ORF", :ImageMagick)
add_saver(format"ORF", :ImageMagick)
add_format(format"OTB", (), ".otb")
add_loader(format"OTB", :ImageMagick)
add_saver(format"OTB", :ImageMagick)
add_format(format"P7", (), ".p7")
add_loader(format"P7", :ImageMagick)
add_saver(format"P7", :ImageMagick)
add_format(format"PALM", (), ".palm")
add_loader(format"PALM", :ImageMagick)
add_saver(format"PALM", :ImageMagick)
add_format(format"PAM", (), ".pam")
add_loader(format"PAM", :ImageMagick)
add_saver(format"PAM", :ImageMagick)
add_format(format"CLIPBOARD", (), ".clipboard")
add_loader(format"CLIPBOARD", :ImageMagick)
add_saver(format"CLIPBOARD", :ImageMagick)
add_format(format"PBM", (), ".pbm")
add_loader(format"PBM", :ImageMagick)
add_saver(format"PBM", :ImageMagick)
add_format(format"PCD", (), ".pcd")
add_loader(format"PCD", :ImageMagick)
add_saver(format"PCD", :ImageMagick)
add_format(format"PCDS", (), ".pcds")
add_loader(format"PCDS", :ImageMagick)
add_saver(format"PCDS", :ImageMagick)
add_format(format"PCL", (), ".pcl")
add_loader(format"PCL", :ImageMagick)
add_saver(format"PCL", :ImageMagick)
add_format(format"PCX", UInt8[0x0a,0x05,0x01,0x01], ".pcx")
add_loader(format"PCX", :ImageMagick)
add_saver(format"PCX", :ImageMagick)
add_format(format"PDB", UInt8[0x73,0x7a,0x65,0x7a], ".pdb")
add_loader(format"PDB", :ImageMagick)
add_saver(format"PDB", :ImageMagick)
add_format(format"PDF", UInt8[0x25,0x50,0x44,0x46], ".pdf")
add_loader(format"PDF", :ImageMagick)
add_saver(format"PDF", :ImageMagick)
add_format(format"PEF", (), ".pef")
add_loader(format"PEF", :ImageMagick)
add_saver(format"PEF", :ImageMagick)
add_format(format"PFA", (), ".pfa")
add_loader(format"PFA", :ImageMagick)
add_saver(format"PFA", :ImageMagick)
add_format(format"PFB", (), ".pfb")
add_loader(format"PFB", :ImageMagick)
add_saver(format"PFB", :ImageMagick)
add_format(format"PFM", (), ".pfm")
add_loader(format"PFM", :ImageMagick)
add_saver(format"PFM", :ImageMagick)
add_format(format"PGM", UInt8[0x50,0x35,0x0a], ".pgm")
add_loader(format"PGM", :ImageMagick)
add_saver(format"PGM", :ImageMagick)
add_format(format"PICON", (), ".picon")
add_loader(format"PICON", :ImageMagick)
add_saver(format"PICON", :ImageMagick)
add_format(format"PICT", (), ".pict")
add_loader(format"PICT", :ImageMagick)
add_saver(format"PICT", :ImageMagick)
add_format(format"PIX", (), ".pix")
add_loader(format"PIX", :ImageMagick)
add_saver(format"PIX", :ImageMagick)
add_format(format"PNG", UInt8[0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a], ".png")
add_loader(format"PNG", :ImageMagick)
add_saver(format"PNG", :ImageMagick)
add_format(format"PNG8", (), ".png8")
add_loader(format"PNG8", :ImageMagick)
add_saver(format"PNG8", :ImageMagick)
add_format(format"PNG00", (), ".png00")
add_loader(format"PNG00", :ImageMagick)
add_saver(format"PNG00", :ImageMagick)
add_format(format"PNG24", (), ".png24")
add_loader(format"PNG24", :ImageMagick)
add_saver(format"PNG24", :ImageMagick)
add_format(format"PNG32", (), ".png32")
add_loader(format"PNG32", :ImageMagick)
add_saver(format"PNG32", :ImageMagick)
add_format(format"PNG48", (), ".png48")
add_loader(format"PNG48", :ImageMagick)
add_saver(format"PNG48", :ImageMagick)
add_format(format"PNG64", (), ".png64")
add_loader(format"PNG64", :ImageMagick)
add_saver(format"PNG64", :ImageMagick)
add_format(format"PNM", (), ".pnm")
add_loader(format"PNM", :ImageMagick)
add_saver(format"PNM", :ImageMagick)
add_format(format"PPM", (), ".ppm")
add_loader(format"PPM", :ImageMagick)
add_saver(format"PPM", :ImageMagick)
add_format(format"PS", (), ".ps")
add_loader(format"PS", :ImageMagick)
add_saver(format"PS", :ImageMagick)
add_format(format"PS2", (), ".ps2")
add_loader(format"PS2", :ImageMagick)
add_saver(format"PS2", :ImageMagick)
add_format(format"PS3", (), ".ps3")
add_loader(format"PS3", :ImageMagick)
add_saver(format"PS3", :ImageMagick)
add_format(format"PSB", (), ".psb")
add_loader(format"PSB", :ImageMagick)
add_saver(format"PSB", :ImageMagick)
add_format(format"PSD", UInt8[0x38,0x42,0x50,0x53], ".psd")
add_loader(format"PSD", :ImageMagick)
add_saver(format"PSD", :ImageMagick)
add_format(format"PTIF", (), ".ptif")
add_loader(format"PTIF", :ImageMagick)
add_saver(format"PTIF", :ImageMagick)
add_format(format"PWP", (), ".pwp")
add_loader(format"PWP", :ImageMagick)
add_saver(format"PWP", :ImageMagick)
add_format(format"RAD", (), ".rad")
add_loader(format"RAD", :ImageMagick)
add_saver(format"RAD", :ImageMagick)
add_format(format"RAF", (), ".raf")
add_loader(format"RAF", :ImageMagick)
add_saver(format"RAF", :ImageMagick)
add_format(format"RGB", UInt8[0x01,0xda,0x01,0x01,0x00,0x03], ".rgb")
add_loader(format"RGB", :ImageMagick)
add_saver(format"RGB", :ImageMagick)
add_format(format"RGBA", (), ".rgba")
add_loader(format"RGBA", :ImageMagick)
add_saver(format"RGBA", :ImageMagick)
add_format(format"RFG", (), ".rfg")
add_loader(format"RFG", :ImageMagick)
add_saver(format"RFG", :ImageMagick)
add_format(format"RLA", (), ".rla")
add_loader(format"RLA", :ImageMagick)
add_saver(format"RLA", :ImageMagick)
add_format(format"RLE", (), ".rle")
add_loader(format"RLE", :ImageMagick)
add_saver(format"RLE", :ImageMagick)
add_format(format"SCT", (), ".sct")
add_loader(format"SCT", :ImageMagick)
add_saver(format"SCT", :ImageMagick)
add_format(format"SFW", (), ".sfw")
add_loader(format"SFW", :ImageMagick)
add_saver(format"SFW", :ImageMagick)
add_format(format"SGI", (), ".sgi")
add_loader(format"SGI", :ImageMagick)
add_saver(format"SGI", :ImageMagick)
add_format(format"SHTML", (), ".shtml")
add_loader(format"SHTML", :ImageMagick)
add_saver(format"SHTML", :ImageMagick)
add_format(format"SID,", (), ".sid,")
add_loader(format"SID,", :ImageMagick)
add_saver(format"SID,", :ImageMagick)
add_format(format"SPARSE-COLOR", (), ".sparse-color")
add_loader(format"SPARSE-COLOR", :ImageMagick)
add_saver(format"SPARSE-COLOR", :ImageMagick)
add_format(format"SUN", (), ".sun")
add_loader(format"SUN", :ImageMagick)
add_saver(format"SUN", :ImageMagick)
add_format(format"SVG", (), ".svg")
add_loader(format"SVG", :ImageMagick)
add_saver(format"SVG", :ImageMagick)
add_format(format"TGA", (), ".tga")
add_loader(format"TGA", :ImageMagick)
add_saver(format"TGA", :ImageMagick)
add_format(format"TIFF", UInt8[0x4d,0x4d,0x00,0x2b], ".tiff")
add_loader(format"TIFF", :ImageMagick)
add_saver(format"TIFF", :ImageMagick)
add_format(format"TIM", (), ".tim")
add_loader(format"TIM", :ImageMagick)
add_saver(format"TIM", :ImageMagick)
add_format(format"TTF", (), ".ttf")
add_loader(format"TTF", :ImageMagick)
add_saver(format"TTF", :ImageMagick)
add_format(format"TXT", (), ".txt")
add_loader(format"TXT", :ImageMagick)
add_saver(format"TXT", :ImageMagick)
add_format(format"UIL", (), ".uil")
add_loader(format"UIL", :ImageMagick)
add_saver(format"UIL", :ImageMagick)
add_format(format"UYVY", (), ".uyvy")
add_loader(format"UYVY", :ImageMagick)
add_saver(format"UYVY", :ImageMagick)
add_format(format"VICAR", (), ".vicar")
add_loader(format"VICAR", :ImageMagick)
add_saver(format"VICAR", :ImageMagick)
add_format(format"VIFF", (), ".viff")
add_loader(format"VIFF", :ImageMagick)
add_saver(format"VIFF", :ImageMagick)
add_format(format"WBMP", (), ".wbmp")
add_loader(format"WBMP", :ImageMagick)
add_saver(format"WBMP", :ImageMagick)
add_format(format"WDP", (), ".wdp")
add_loader(format"WDP", :ImageMagick)
add_saver(format"WDP", :ImageMagick)
add_format(format"WEBP", (), ".webp")
add_loader(format"WEBP", :ImageMagick)
add_saver(format"WEBP", :ImageMagick)
add_format(format"WMF", UInt8[0xd7,0xcd,0xc6,0x9a], ".wmf")
add_loader(format"WMF", :ImageMagick)
add_saver(format"WMF", :ImageMagick)
add_format(format"WPG", UInt8[0xff,0x57,0x50,0x43], ".wpg")
add_loader(format"WPG", :ImageMagick)
add_saver(format"WPG", :ImageMagick)
add_format(format"X", (), ".x")
add_loader(format"X", :ImageMagick)
add_saver(format"X", :ImageMagick)
add_format(format"XBM", (), ".xbm")
add_loader(format"XBM", :ImageMagick)
add_saver(format"XBM", :ImageMagick)
add_format(format"XCF", (), ".xcf")
add_loader(format"XCF", :ImageMagick)
add_saver(format"XCF", :ImageMagick)
add_format(format"XPM", (), ".xpm")
add_loader(format"XPM", :ImageMagick)
add_saver(format"XPM", :ImageMagick)
add_format(format"XWD", (), ".xwd")
add_loader(format"XWD", :ImageMagick)
add_saver(format"XWD", :ImageMagick)
add_format(format"X3F", (), ".x3f")
add_loader(format"X3F", :ImageMagick)
add_saver(format"X3F", :ImageMagick)
add_format(format"YCBCR", (), ".ycbcr")
add_loader(format"YCBCR", :ImageMagick)
add_saver(format"YCBCR", :ImageMagick)
add_format(format"YCBCRA", (), ".ycbcra")
add_loader(format"YCBCRA", :ImageMagick)
add_saver(format"YCBCRA", :ImageMagick)
add_format(format"YUV", (), ".yuv")
add_loader(format"YUV", :ImageMagick)
add_saver(format"YUV", :ImageMagick)