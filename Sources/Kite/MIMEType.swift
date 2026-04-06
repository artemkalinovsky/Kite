import Foundation

enum MIMEType {
    private static let types: [String: String] = [
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "gif": "image/gif",
        "webp": "image/webp",
        "svg": "image/svg+xml",
        "bmp": "image/bmp",
        "ico": "image/x-icon",
        "tiff": "image/tiff",
        "tif": "image/tiff",
        "heic": "image/heic",
        "heif": "image/heif",
        "avif": "image/avif",
        "pdf": "application/pdf",
        "json": "application/json",
        "xml": "application/xml",
        "zip": "application/zip",
        "gz": "application/gzip",
        "tar": "application/x-tar",
        "html": "text/html",
        "htm": "text/html",
        "css": "text/css",
        "js": "application/javascript",
        "csv": "text/csv",
        "txt": "text/plain",
        "mp3": "audio/mpeg",
        "wav": "audio/wav",
        "aac": "audio/aac",
        "ogg": "audio/ogg",
        "mp4": "video/mp4",
        "mov": "video/quicktime",
        "avi": "video/x-msvideo",
        "webm": "video/webm",
        "doc": "application/msword",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xls": "application/vnd.ms-excel",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "ppt": "application/vnd.ms-powerpoint",
        "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    ]

    static func from(fileExtension: String) -> String {
        types[fileExtension.lowercased()] ?? "application/octet-stream"
    }
}
