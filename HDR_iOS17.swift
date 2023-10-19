import Cocoa
import CoreImage
//guard let colorSpace_2100_PQ = CGColorSpace(name: CGColorSpace.itur_2100_PQ) else {
//    print("Couldn't create a color space. :(")
//    exit(1)
//}
//exit(1)

let file_names = CommandLine.arguments
print(file_names)
let origin_path = file_names[1]
let export_path = file_names[2]
let choose_export = "6"
print(origin_path)
print(export_path)
print(choose_export)

let originalImageURL = URL(fileURLWithPath: origin_path)
let exportedImageURL = URL(fileURLWithPath: export_path)
//guard let colorSpace_extended = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3) else {
//    print("Couldn't create a color space. :(")
//    exit(1)
//}
guard let colorSpace_dp3 = CGColorSpace(name: CGColorSpace.displayP3) else {
    print("Couldn't create a color space. :(")
    exit(1)
}
//guard let colorSpace_HLG = CGColorSpace(name: CGColorSpace.displayP3_HLG) else {
//    print("Couldn't create a color space. :(")
//    exit(1)
//}
guard let colorSpace_2100_PQ = CGColorSpace(name: CGColorSpace.itur_2100_PQ) else {
    print("Couldn't create a color space. :(")
    exit(1)
}
guard let colorSpace_2100_HLG = CGColorSpace(name: CGColorSpace.itur_2100_HLG) else {
    print("Couldn't create a color space. :(")
    exit(1)
}
//let edr_meta = CAEDRMetadata.hlg
//guard let edr_meta = CAEDRMetadata.hlg else {
//    print("Couldn't create a hlg EDR metadata. :(")
//    exit(1)
//}

let context = CIContext()
let options_full = [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 1.0 as CGFloat]
let options_compress = [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.5 as CGFloat]


guard let image = CIImage(contentsOf: originalImageURL,
        options: [.expandToHDR: true])
else {
    print("Couldn't create an image. :(")
    exit(1)
}
//guard let image = CIImage(contentsOf: originalImageURL)
//else {
//    print("Couldn't create an image. :(")
//    exit(1)
//}
let rawFilter = CIRAWFilter(imageURL: originalImageURL)
rawFilter?.extendedDynamicRangeAmount = 1.0
//rawFilter?.contrastAmount=0.8
guard let image2 = rawFilter?.outputImage else { exit(1) }
//let image2 = rawFilter?.outputImage
//guard let image = CIImage(data: rawFilter.outputImage,
//        options: [.expandToHDR: true])
//else {
//    print("Couldn't create an image. :(")
//    exit(1)
//}
//rawFilter.outputImage
//print(rawFilter?.outputImage)
//exit(1)
//guard let image = CIImage(contentsOf: originalImageURL)
//else {
//    print("Couldn't create an image. :(")
//    exit(1)
//}

if (choose_export == "1") {

    do {
        _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace_dp3, options: options_compress)
        print("It worked")
    }
//        _ = try context.writeHEIF10Representation(of: image, to: exportedImageURL, colorSpace: colorSpace, options: options)
//        print("It worked")
//    }
    catch {
        print("It failed.")
        }
}
else if (choose_export == "2") {
    do {
        _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace_dp3, options: options_full)
        print("It worked")
//        _ = try context.writeHEIF10Representation(of: image, to: exportedImageURL, colorSpace: colorSpace, options: options)
//        print("It worked")
    }
    catch {
        print("It failed.")
        }
}
else if (choose_export == "3") {
    do {
    //    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
    //    print("It worked")
        _ = try context.writeHEIF10Representation(of: image, to: exportedImageURL, colorSpace: colorSpace_dp3, options: options_compress)
        print("It worked")
    }
    catch {
        print("It failed.")
    }
}
else if (choose_export == "4") {
    do {
    //    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
    //    print("It worked")
        _ = try context.writeHEIF10Representation(of: image, to: exportedImageURL, colorSpace: colorSpace_dp3, options: options_full)
        print("It worked")
    }
    catch {
        print("It failed.")
    }
}
else if (choose_export == "5") {
    do {
    //    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
    //    print("It worked")
        _ = try context.writeHEIF10Representation(of: image, to: exportedImageURL, colorSpace: colorSpace_2100_HLG, options: options_full)
        print("It worked")
    }
    catch {
        print("It failed.")
    }
}
else if (choose_export == "6") {
    do {
    //    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
    //    print("It worked")
        _ = try context.writeHEIF10Representation(of: image, to: exportedImageURL, colorSpace: colorSpace_2100_PQ, options: options_full)
        print("It worked")
    }
    catch {
        print("It failed.")
    }
}
else if (choose_export == "7") {
    do {
    //    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
    //    print("It worked")
        _ = try context.writeHEIF10Representation(of: image2, to: exportedImageURL, colorSpace: colorSpace_2100_HLG, options: options_full)
        print("It worked")
    }
    catch {
        print("It failed.")
    }
}
else if (choose_export == "8") {
    do {
    //    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
    //    print("It worked")
        _ = try context.writeHEIF10Representation(of: image2, to: exportedImageURL, colorSpace: colorSpace_2100_PQ, options: options_full)
        print("It worked")
    }
    catch {
        print("It failed.")
    }
}
//do {
////    _ = try context.writeHEIFRepresentation(of: image, to: exportedImageURL, format: CIFormat.RGBA8, colorSpace: colorSpace, options: options)
////    print("It worked")
//    _ = try context.writeHEIF10Representation(of: rawFilter.outputImage, to: exportedImageURL, colorSpace: colorSpace_2100_PQ, options: options_full)
//    print("It worked")
//}
//catch {
//    print("It failed.")
//}
