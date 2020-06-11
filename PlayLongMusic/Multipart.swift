import Foundation

struct Multipart {
    let contentType: MultipartContentType
    let body: MultipartBody
    
    init(contentType: String, bodyBase64: Data) {
        self.contentType = MultipartUitls.parseHeader(contentType: contentType)
        self.body = MultipartUitls.parseBody(bodyBase64: bodyBase64, boundary: self.contentType.boundary)
    }
}

fileprivate class MultipartUitls {
    // MARK: private method
    static func parseHeader(contentType: String) -> MultipartContentType {
        let headerLines = parseLine(targetString: contentType)
        
        let splitedSemicolon = headerLines[0].components(separatedBy: ";")
        let contentType = splitedSemicolon[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let boundary = splitedSemicolon[1].components(separatedBy: "=")[1]
        
        return MultipartContentType(contentType: contentType, boundary: boundary)
    }
    
    static func parseBody(bodyBase64: Data, boundary: String) -> MultipartBody {
        let boundaryWithPrefix = "--" + boundary
        
        // 末尾padding分の=を削除する
        let delimiter = boundaryWithPrefix.data(using: .utf8)?.base64EncodedString().replacingOccurrences(of: "=", with: "")
        let boundaryWithLineFeed = delimiter!+"0K"
        
        let partArray = bodyBase64.base64EncodedString().components(separatedBy: boundaryWithLineFeed)
        var dataPayload = partArray[1].data(using: .utf8)
        
        if var dataPayload2 = dataPayload {
            if let range = dataPayload2.range(of: "0K".data(using: .utf8)!) {
                // Convert complete line (excluding the delimiter) to a string:
                let line = String(data: dataPayload2.subdata(in: 0..<range.lowerBound), encoding: .utf8)
                // Remove line (and the delimiter) from the buffer:
                dataPayload2.removeSubrange(0..<range.upperBound)
                let payloadString = String(data: dataPayload2, encoding: .utf8)
                let payloadData = Data(base64Encoded: payloadString!)
                return MultipartBody(file: [MultipartBodyFile(contentDisposition: "", name: "", filename: "", contentType: "", data: payloadData!)])
            }
        }
        
        return MultipartBody(file: [MultipartBodyFile(contentDisposition: "", name: "", filename: "", contentType: "", data: Data(base64Encoded: "HOGE")!)])
    }
    
    static func decodeBase64(base64String: Data) -> String {
        let hoge = Data(base64Encoded: base64String.base64EncodedString(), options: .ignoreUnknownCharacters)
        
        return String(data: hoge!, encoding: .utf8)!
    }
    
    static func parseLine(targetString: String) -> [String] {
        return targetString.components(separatedBy: "\r\n")
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
