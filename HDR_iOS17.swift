import Cocoa
import CoreImage

// HDR_iOS17.swift — Convert HDR images to 10-bit HEIC for Apple Photos
// Requires macOS 14 (Sonoma) or later · Swift 5.9+
// Updated for macOS 26 (Tahoe) / iOS 26

func printUsage() {
    print("""
    Usage: swift HDR_iOS17.swift <input> <output.heic> <quality> <mode>

    Arguments:
      input    Path to source image (TIFF, PNG, AVIF, JPEG, or RAW)
      output   Path for the output HEIC file (must end with .heic)
      quality  Compression quality from 0.1 to 1.0  (e.g. 0.85)
               Note: values below 0.75 may lose HDR detail
      mode     Export mode — see table below

    Export Modes:
      1  8-bit  HEIF · Display P3  · compressed    Standard SDR (smaller file)
      2  8-bit  HEIF · Display P3  · lossless      Standard SDR (full quality)
      3  10-bit HEIF · Display P3  · compressed    Wide-gamut SDR (smaller file)
      4  10-bit HEIF · Display P3  · lossless      Wide-gamut SDR (full quality)
      5  10-bit HEIF · BT.2100 HLG · lossless      HDR — recommended for most images
      6  10-bit HEIF · BT.2100 PQ  · compressed    HDR PQ (Dolby Vision-style)
      7  10-bit HEIF · BT.2100 HLG · lossless      HDR from RAW via CIRAWFilter
      8  10-bit HEIF · BT.2100 PQ  · lossless      HDR from RAW via CIRAWFilter

    Examples:
      swift HDR_iOS17.swift photo.tif  output.heic 0.85 5
      swift HDR_iOS17.swift raw.dng    output.heic 1.0  7
    """)
}

// ── Argument validation ────────────────────────────────────────────────────────

let args = CommandLine.arguments

if args.contains("--help") || args.contains("-h") {
    printUsage()
    exit(0)
}

guard args.count == 5 else {
    print("Error: Expected 4 arguments, got \(args.count - 1).\n")
    printUsage()
    exit(1)
}

let originPath = args[1]
let exportPath = args[2]
let qualityArg = args[3]
let modeArg    = args[4]

guard let qualityDouble = Double(qualityArg), qualityDouble > 0, qualityDouble <= 1.0 else {
    print("Error: <quality> must be a number between 0.1 and 1.0 (got '\(qualityArg)').")
    exit(1)
}

guard let mode = Int(modeArg), (1...8).contains(mode) else {
    print("Error: <mode> must be an integer from 1 to 8 (got '\(modeArg)').")
    printUsage()
    exit(1)
}

guard FileManager.default.fileExists(atPath: originPath) else {
    print("Error: Input file not found: '\(originPath)'")
    exit(1)
}

let quality = CGFloat(qualityDouble)

// ── Color spaces ───────────────────────────────────────────────────────────────

guard let colorSpaceP3 = CGColorSpace(name: CGColorSpace.displayP3) else {
    print("Error: Could not create Display P3 color space.")
    exit(1)
}
guard let colorSpaceHLG = CGColorSpace(name: CGColorSpace.itur_2100_HLG) else {
    print("Error: Could not create BT.2100 HLG color space.")
    exit(1)
}
guard let colorSpacePQ = CGColorSpace(name: CGColorSpace.itur_2100_PQ) else {
    print("Error: Could not create BT.2100 PQ color space.")
    exit(1)
}

let originalURL = URL(fileURLWithPath: originPath)
let exportURL   = URL(fileURLWithPath: exportPath)

let context = CIContext()

let optionsCompressed: [CIImageRepresentationOption: Any] = [
    kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: quality
]
let optionsFull: [CIImageRepresentationOption: Any] = [
    kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: CGFloat(1.0)
]

// ── Process image ──────────────────────────────────────────────────────────────

do {
    switch mode {

    // Modes 1–6: load via CIImage with HDR expansion
    case 1, 2, 3, 4, 5, 6:
        guard let image = CIImage(contentsOf: originalURL, options: [.expandToHDR: true]) else {
            print("Error: Could not load image at '\(originPath)'.")
            exit(1)
        }
        switch mode {
        case 1:
            print("Mode 1 · 8-bit HEIF · Display P3 · quality \(quality)")
            try context.writeHEIFRepresentation(of: image, to: exportURL, format: .RGBA8,
                                                colorSpace: colorSpaceP3, options: optionsCompressed)
        case 2:
            print("Mode 2 · 8-bit HEIF · Display P3 · lossless")
            try context.writeHEIFRepresentation(of: image, to: exportURL, format: .RGBA8,
                                                colorSpace: colorSpaceP3, options: optionsFull)
        case 3:
            print("Mode 3 · 10-bit HEIF · Display P3 · quality \(quality)")
            try context.writeHEIF10Representation(of: image, to: exportURL,
                                                  colorSpace: colorSpaceP3, options: optionsCompressed)
        case 4:
            print("Mode 4 · 10-bit HEIF · Display P3 · lossless")
            try context.writeHEIF10Representation(of: image, to: exportURL,
                                                  colorSpace: colorSpaceP3, options: optionsFull)
        case 5:
            print("Mode 5 · 10-bit HEIF · BT.2100 HLG · lossless (HDR)")
            try context.writeHEIF10Representation(of: image, to: exportURL,
                                                  colorSpace: colorSpaceHLG, options: optionsFull)
        case 6:
            print("Mode 6 · 10-bit HEIF · BT.2100 PQ · quality \(quality) (HDR)")
            try context.writeHEIF10Representation(of: image, to: exportURL,
                                                  colorSpace: colorSpacePQ, options: optionsCompressed)
        default: break
        }

    // Modes 7–8: load via CIRAWFilter for RAW files
    case 7, 8:
        guard let rawFilter = CIRAWFilter(imageURL: originalURL) else {
            print("Error: Could not open '\(originPath)' as a RAW file.")
            print("Tip: Modes 7 and 8 require a RAW input (e.g. .dng, .arw, .cr3).")
            exit(1)
        }
        rawFilter.extendedDynamicRangeAmount = 1.0

        guard let rawImage = rawFilter.outputImage else {
            print("Error: RAW filter produced no output image.")
            exit(1)
        }
        if mode == 7 {
            print("Mode 7 · 10-bit HEIF · BT.2100 HLG · lossless (HDR from RAW)")
            try context.writeHEIF10Representation(of: rawImage, to: exportURL,
                                                  colorSpace: colorSpaceHLG, options: optionsFull)
        } else {
            print("Mode 8 · 10-bit HEIF · BT.2100 PQ · lossless (HDR from RAW)")
            try context.writeHEIF10Representation(of: rawImage, to: exportURL,
                                                  colorSpace: colorSpacePQ, options: optionsFull)
        }

    default: break
    }

    print("Done → \(exportPath)")

} catch {
    print("Error: Failed to write output — \(error.localizedDescription)")
    exit(1)
}
