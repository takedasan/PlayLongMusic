import Foundation

struct Multipart {
    let contentType: MultipartContentType
    let body: MultipartBody
    
    init(contentType: String, body: Data) {
        self.contentType = MultipartUitls.parseHeader(contentType: contentType)
        self.body = MultipartUitls.parseBody(body: body, boundary: self.contentType.boundary)
    }
}

fileprivate class MultipartUitls {
    private static let LINEFEED = "0K"
    
    // MARK: API
    static func parseHeader(contentType: String) -> MultipartContentType {
        let headerLines = contentType.components(separatedBy: "\r\n")
        
        let splitedSemicolon = headerLines[0].components(separatedBy: ";")
        let contentType = splitedSemicolon[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let boundary = splitedSemicolon[1].components(separatedBy: "=")[1]
        
        return MultipartContentType(contentType: contentType, boundary: boundary)
    }
    
    static func parseBody(body: Data, boundary: String) -> MultipartBody {
        let boundaryWithPrefix = "--" + boundary
        
        // Remove tail padding "="
        guard let removedPadding = boundaryWithPrefix.data(using: .utf8)?.base64EncodedString().replacingOccurrences(of: "=", with: "")  else {
            return MultipartBody(file: [MultipartBodyFile]())
        }
        // Add line feed
        let delimiter = removedPadding + LINEFEED
        let partArray = body.base64EncodedString().components(separatedBy: delimiter)
        
        var bodies = [MultipartBodyFile]()
        for part in partArray {
            if let bodyFile = parseMultipartBodyFile(part: part) {
                bodies.append(bodyFile)
            }
        }
        
        return MultipartBody(file: bodies)
    }
    
    // MARK: Private method
    static func parseMultipartBodyFile(part: String) -> MultipartBodyFile? {
        let payload = part.data(using: .utf8)
        guard var payloadData = payload else {
            return nil
        }
        
        guard let range = payloadData.range(of: LINEFEED.data(using: .utf8)!) else {
            return nil
        }
        
        // Get line until line feed
        payloadData.subdata(in: 0..<range.lowerBound)
        // Remove line from the payload
        payloadData.removeSubrange(0..<range.upperBound)
        
        // Formatting data
        let leftOver = String(data: payloadData, encoding: .utf8)
        guard let formattingData = Data(base64Encoded: leftOver!) else {
            return nil
        }
        
        return MultipartBodyFile(contentDisposition: "", name: "", filename: "", contentType: "", data: formattingData)
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
    let contentDisposition: String
    let name: String
    let filename: String
    let contentType: String
    let data: Data
}
