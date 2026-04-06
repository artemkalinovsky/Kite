import Testing
@testable import Kite

@Suite("MIMETypeTests")
struct MIMETypeTests {
    @Test("Known extensions return correct MIME types", arguments: [
        ("png", "image/png"),
        ("jpg", "image/jpeg"),
        ("jpeg", "image/jpeg"),
        ("pdf", "application/pdf"),
        ("json", "application/json"),
        ("xml", "application/xml"),
        ("mp4", "video/mp4"),
        ("mp3", "audio/mpeg"),
        ("html", "text/html"),
        ("htm", "text/html"),
        ("zip", "application/zip"),
    ])
    func testKnownExtensionsReturnCorrectMIMEType(ext: String, expectedMIMEType: String) {
        #expect(MIMEType.from(fileExtension: ext) == expectedMIMEType)
    }

    @Test("Lookup is case-insensitive", arguments: ["PNG", "Png", "JPEG", "PDF", "MP4"])
    func testLookupIsCaseInsensitive(ext: String) {
        #expect(MIMEType.from(fileExtension: ext) != "application/octet-stream")
    }

    @Test("Unknown extension falls back to application/octet-stream", arguments: [
        "xyz", "unknown", "bin", "",
    ])
    func testUnknownExtensionFallsBack(ext: String) {
        #expect(MIMEType.from(fileExtension: ext) == "application/octet-stream")
    }
}
