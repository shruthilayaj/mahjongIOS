import PlaygroundSupport

func encryptDecrypt(_ input: String) -> String {
    let key = [UInt8]("KCQ".utf8) //Can be any chars, and any length array
    let input_ = [UInt8](input.utf8)
    let length = key.count
    var output = ""
    
    for i in input_.enumerated() {
        let byte = [i.element ^ key[i.offset % length]]
        output.append(String(bytes: byte, encoding: .utf8)!)
    }
    
    return output
}

let fileURL = playgroundSharedDataDirectory.appendingPathComponent("Card2020.txt")
do {
    var fileContent = try String(contentsOf: fileURL)
    fileContent = encryptDecrypt(fileContent)
    let newFileUrl = playgroundSharedDataDirectory.appendingPathComponent("Card2020Encrypted.txt")
    do {
        try fileContent.write(to: newFileUrl, atomically: true, encoding: .utf8)
    } catch {
        print("Error writing: \(error)")
    }
} catch {
    print("Error writing: \(error)")
}

