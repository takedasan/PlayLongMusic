import Foundation

private let LINEFEED = "\r\n"

fileprivate class MultipartUitls {
    // MARK: API
    static func parseHeader(contentType: String) -> MultipartContentType {
        let headerLines = contentType.components(separatedBy: LINEFEED)
        
        let splitedSemicolon = headerLines[0].components(separatedBy: ";")
        let contentType = splitedSemicolon[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let boundary = splitedSemicolon[1].components(separatedBy: "=")[1]
        
        return MultipartContentType(contentType: contentType, boundary: boundary)
    }
    
    static func parseBody(body: Data, boundary: String) -> MultipartBody {
        let splitedBody = body.splitByData(boundary: "--" + boundary)
        
        guard let bodies = splitedBody else {
            return MultipartBody(file: [MultipartBodyFile]())
        }
        
        var files = [MultipartBodyFile]()
        for data in bodies {
            if let bodyFile = parseMultipartBodyData(bodyData: data) {
                files.append(bodyFile)
            }
        }
        
        return MultipartBody(file: files)
    }
    
    // MARK: Private method
    private static func parseMultipartBodyData(bodyData: Data) -> MultipartBodyFile? {
        // Line Feed
        let lineFeed = LINEFEED.data(using: .utf8)
        
        // Split a first line
        guard let firstLineRange = bodyData.range(of: lineFeed!) else {
            return nil
        }
        let firstLine = bodyData[bodyData.startIndex..<firstLineRange.lowerBound]
        
        // Split a second line
        guard let secondLineRange = bodyData[firstLineRange.upperBound...].range(of: lineFeed!) else {
            return nil
        }
        let secondLine = bodyData[firstLineRange.upperBound..<secondLineRange.lowerBound]
        
        // Get a third line range
        guard let thirdLineRange = bodyData[secondLineRange.upperBound...].range(of: lineFeed!) else {
            return nil
        }
        
        guard let fileName = parseFileName(firstLine: firstLine) else {
            return nil
        }
        guard let contentType = parseContentType(secondLine: secondLine) else {
            return nil
        }
        
        return MultipartBodyFile(contentType: contentType, fileName: fileName, data: bodyData[thirdLineRange.upperBound...])
    }
    
    private static func parseFileName(firstLine: Data) -> String? {
        // Example -> Content-Disposition: form-data; name="userfile"; filename="file.txt"
        guard let firstLineString = String(data: firstLine, encoding: .utf8) else {
            return nil
        }
        
        let splitedArray = firstLineString.components(separatedBy: ";")
        
        // Get name paramter
        var name = splitedArray[1].trimmingCharacters(in: .whitespacesAndNewlines)
        name = name.components(separatedBy: "name=")[1].replacingOccurrences(of: "\"", with:"")
        
        if(name == "userfile") {
            let fileNamePart = splitedArray[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let fileName = fileNamePart.components(separatedBy: "filename=")[1].replacingOccurrences(of: "\"", with:"")
            
            return fileName
        }
        
        return nil
    }
    
    private static func parseContentType(secondLine: Data) -> String? {
        // Example -> Content-Type: text/plain
        guard let secondLineString = String(data: secondLine, encoding: .utf8) else {
            return nil
        }
        
        let contentTypePart = secondLineString.trimmingCharacters(in: .whitespacesAndNewlines)
        let contentType = contentTypePart.components(separatedBy: "Content-Type:")[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        return contentType
    }
}

// MARK: Inner structs
struct Multipart {
    let contentType: MultipartContentType
    let body: MultipartBody
    
    init(contentType: String, body: Data) {
        self.contentType = MultipartUitls.parseHeader(contentType: contentType)
        self.body = MultipartUitls.parseBody(body: body, boundary: self.contentType.boundary)
    }
}

struct MultipartContentType {
    let contentType: String
    let boundary: String
}

struct MultipartBody {
    let file: [MultipartBodyFile]
}

struct MultipartBodyFile {
    let contentType: String
    let fileName: String
    let data: Data
}

// MARK: Extension
extension Data {
    func splitByData(boundary: String) -> [Data]? {
        guard let boundaryData = boundary.data(using: .utf8) else {
            return nil
        }
        
        // With a line feed
        let withLinefeed = boundary + LINEFEED
        guard let withLinefeedData = withLinefeed.data(using: .utf8) else {
            return nil
        }
        
        var chunks: [Data] = []
        var pos = startIndex
        
        while let r = self[pos...].range(of: withLinefeedData) {
            if r.lowerBound > pos {
                chunks.append(self[pos..<r.lowerBound])
            }
            
            pos = r.upperBound
        }
        
        if pos < endIndex {
            if let endRange = self[pos...].range(of: boundaryData) {
                chunks.append(self[pos..<endRange.lowerBound])
            }
        }
        return chunks
    }
}
