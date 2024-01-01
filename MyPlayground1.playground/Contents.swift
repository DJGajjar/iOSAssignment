import UIKit

var greeting = "Hello, playground"

//
//func setGenMethod<T>(data: T) {
//
//    print("value: \(data)")
//
//    var counts = [Character: Int]()
//
//        for char in data {
//            counts[char] = (counts[char] ?? 0) + 1
//        }
//
//        var output = ""
//        for (char, count) in counts {
//            output += "\(char)\(count)"
//        }
//
//        return output
//}
//
//let strValue = "Mississippi"
//setGenMethod(data: strValue)

func countCharacters(_ word: String) -> String {
    var counts = [Character: Int]()
    
    for char in word {
        counts[char] = (counts[char] ?? 0) + 1
        print(counts)
    }
    
    var output = ""
    //print(counts)
    for (char, count) in counts {
        output += "\(char)\(count)"
        print("vva: \(output)")
    }
    
    return output
}

let input = "Mississippi"
let output = countCharacters(input)
print(output)


func setCount(str: String) -> String {
    
    var counts = [Character: Int]()
    
    for char in str {
        counts[char] = (counts[char] ?? 0) + 1
    }
    
    var output = ""
    for(char, count) in counts {
        output += "\(char)\(count)"
    }
    return output
}

let chr = "Darshan"
let oo = setCount(str: chr)
print(oo)


// Property Wrapper

@propertyWrapper
struct EmailPropertyWrapper {
    
    private var _value: String
    
    var wrappedValue: String
    {
        
        get {
            return isValidEmail(email: _value) ? _value : String()
        }set {
            _value = newValue
        }
    }
        
    init(_emailValue: String) {
        _value = _emailValue
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct User {
    
    var name: String
    @EmailPropertyWrapper var email: String
    
    
    func validation() -> Bool {
        
        if(name.isEmpty || email.isEmpty) {
            print("name and a valid email is require or cant not be empty ")
            return false
        }
        return true
    }
    
    func regiseter() {
        
        if(validation()) {
            print("User data save")
        }
    }
}

var userDetail = User(name: "Darshan", email: (EmailPropertyWrapper(_emailValue: "jolapara25@gmial.com")))
userDetail.regiseter()
