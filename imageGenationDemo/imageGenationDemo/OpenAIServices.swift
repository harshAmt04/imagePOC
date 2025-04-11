import Foundation
import UIKit

struct OpenAIResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
        
        struct Message: Decodable {
            let content: String
        }
    }
}

struct ChatMessage : Codable{
    let role: String
    let content: String
}

class OpenAIService: ObservableObject {
    
    var messages: [ChatMessage] = []
    
    var imgbbAPIKey : String = "170fb15cba0f2753d19fafb41c258a6d"
    
    let processingQueue = DispatchQueue(label: "chunkProcessingQueue")
    var counter : Int = 0
    var chunks : [String] = []
    var chatMessage : String = ""
    var messageStream : String = ""
    
    var isConcernedMessage : Bool = false
    
    var takeSummaryCompletionBindingClosure : ((String) -> Void)? = nil
    
    var takeChunksFetchCompletionBindingClosure : (() -> Void)? = nil
    
    func getGroqResponse(userText: String, imageUrl: String?) async throws -> String {
        
        let groqApiKey = "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"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var contents: [Content] = []
        
        let contentText = Content(type: "text", text: userText, imageURL: nil)
        
        contents.append(contentText)

        if let imageUrl{
            let imageURL = Content(type: "image_url", text: nil, imageURL: ImageURL(url: imageUrl))
            contents.append(imageURL)
        }

        let message = Message(role: "user", content: contents)

        let requestBody = ChatMessageRequest(model: "gpt-4o-mini", messages: [message], maxTokens: 300)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(groqApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encodeData(data: requestBody)
        
        print(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "-1111")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as? HTTPURLResponse
        
        guard let json = try? JSONSerialization.jsonObject(with: data,options: .mutableContainers) as? [String: Any] else {
            print("Error getting JSON Object")
            return ""
        }
        
        if httpResponse?.statusCode == 200 {
            if let choices = json["choices"] as? [[String: Any]],
               let content = choices.first?["message"] as? [String: Any],
               let result = content["content"] as? String {
                return result
            } else {
                print("Error: Couldn't parse JSON")
            }
        }else{
            print("Error: \(String(describing: response)) :- \(String(describing: json))")
            return "\(json)"
        }
        return ""
    }
    
    
    
    func sendImageToServer(image : UIImage) async throws -> String{
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Couldn't convert image to data")
            return ""
        }
        
        let baseUrl = "https://api.imgbb.com/1/upload?key=\(imgbbAPIKey)"
        
        var request = URLRequest(url: URL(string: baseUrl)!)
        let boundary: String = UUID().uuidString
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let bodyBuilder = MultipartFormDataBodyBuilder(boundary: boundary, entries: [
            .file(paramName: "image", fileName: "image.jpg", fileData: imageData, contentType: "image/jpeg")
        ])
        
        request.httpBody = bodyBuilder.build()
        
        print(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "-1111")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as? HTTPURLResponse
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
            print("Error parsing JSON response")
            return ""
        }
        
        if httpResponse?.statusCode == 200{
            if let dataDict = json["data"] as? [String: Any],
               let imageUrl = dataDict["url"] as? String {
                return imageUrl
            } else {
                print("Error: Couldn't parse JSON")
            }
        }else{
            print("Error: \(String(describing: response)) :- \(String(describing: json))")
            return "\(json)"
        }
        return ""
        
    }
    
    func takeGroqResponse(image: UIImage, completion : ((String)->Void)? = nil) async throws{
        
        let imageUrl = try await sendImageToServer(image: image)
        
        let prompt = """
Analyse the above image and find what is written on the sticker on the tray, and which colour does tray has, the sticker has.
Also there is one more sticker which is sticked to bottom of tray, which number does it have.
I can provide you some more inputs
- The trays will be either transparent or blue in colour
- The sticker could be either red, blue, yellow, green, orange in colour
- The units could be A, B, C etc in alphabets
- The sticker on tray will have combination of Units with numbers like Alphanumeric D1, D2 etc
- The sticker below the tray is always numeric
Just give us output as tray colour, corresponding Sticker's Alphanumeric code and Bottom sticker number only with its corresponding text.
"""
        
        let message = try await getGroqResponse(userText: prompt, imageUrl: imageUrl)
        
        completion?(message)
        print(message)
        
    }
}


func encodeData<T:Codable>(data : T) -> Data?{
    do{
        return try JSONEncoder().encode(data)
    }catch let error{
        print("Error found ehile encoding ",error)
    }
    return nil
}

func decodeData<T: Codable>(type : T.Type, data: Data) -> T?{
    do{
        return try JSONDecoder().decode(T.self, from: data)
    }catch let error{
        print("Error found ehile encoding ",error)
    }
    return nil
}

// MARK: - ChatMessageRequest
struct ChatMessageRequest: Codable {
    
    let model: String
    let messages: [Message]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
    }
    
}

// MARK: - Message
struct Message: Codable {
    let role: String
    let content: [Content]
}

// MARK: - Content
struct Content: Codable {
    let type: String
    let text: String?
    let imageURL: ImageURL?

    enum CodingKeys: String, CodingKey {
        case type, text
        case imageURL = "image_url"
    }
}

// MARK: - ImageURL
struct ImageURL: Codable {
    let url: String
}
