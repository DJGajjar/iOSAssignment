//
//  APIServiceModel.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 28/06/23.
//

import Foundation
import UIKit
import Alamofire

//MARK: - HostMode (Staging, Production)
enum HostMode {
    case staging
    case production
    
    static var `default`: HostMode = .staging
    
    var baseUrl: String {
        switch self {
        case .staging:
            return "https://my-json-server.typicode.com/"
        case .production:
            return ""
        }
    }
}
/// Hosting Mode
let hostMode = HostMode.default
let apiVersion = "iranjith4/"
let _baseUrl = hostMode.baseUrl + apiVersion

typealias WSBlock = (_ json: Any?, _ flag: Int) -> ()
typealias WSProgress = (Progress) -> ()?
typealias WSFileBlock = (_ path: URL?, _ success: Bool?) -> ()

//MARK: - AccessTokenAdapter
struct AccessTokenAdapter: RequestInterceptor {
    
    private let accessToken: String
    
    init(token: String) {
        accessToken = token
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        req.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(req))
    }
}

class APIServiceModel: NSObject {

    static var shared: APIServiceModel = APIServiceModel()
    
    let manager: Session
    var networkManager = NetworkReachabilityManager.default
    var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-language": "en"
        ]
    }
    var token: RequestInterceptor?
    var paramEncode: ParameterEncoding = JSONEncoding.default
    let timeOutInteraval: TimeInterval = 60
    var successBlock: (String, HTTPURLResponse?, AnyObject?, WSBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, WSBlock) -> Void
        
    override init() {
        manager = Alamofire.Session.default
        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res{
                DebugManager.log( "Response Code: \(response.statusCode)")
                DebugManager.log( "Response(\(relativePath)): \(String(describing: respObj))")
                if response.statusCode == 200 {
                    block(respObj, response.statusCode)
                } else {
                    if (response.statusCode == 401) {
                        //Remove User Objects
                        block([_appName: kInternetDown] as AnyObject, response.statusCode)
                    }else {
                        block(respObj, response.statusCode)
                    }
                }
            } else {
                // There might me no case this can get execute
                block(nil, 404)
            }
        }
        
        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            if let response = res {
                DebugManager.log( "Response Code: \(response.statusCode)")
                DebugManager.log( "Error Code: \(error.code)")
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                    let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if errorDict != nil {
                        DebugManager.log( "Error(\(relativePath)): \(errorDict!)")
                        block(errorDict!, response.statusCode)
                    } else {
                        let code = response.statusCode
                        block(nil, code)
                    }
                } else if (response.statusCode == 401) {
                    DebugManager.log("401 Session Expired errorBlock")
                    //Remove User Objects
                    block([_appName: kInternetDown] as AnyObject, response.statusCode)
                }else {
                    block(nil, response.statusCode)
                }
                // If response not found rely on error code to find the issue
            } else if error.code == -1009  {
                DebugManager.log( "Error(\(relativePath)): \(error)")
                block([_appName: kInternetDown] as AnyObject, error.code)
                return
            } else if error.code == -1003  {
                DebugManager.log( "Error(\(relativePath)): \(error)")
                block([_appName: kHostDown] as AnyObject, error.code)
                return
            } else if error.code == -1001  {
                DebugManager.log( "Error(\(relativePath)): \(error)")
                block([_appName: kTimeOut] as AnyObject, error.code)
                return
            } else {
                DebugManager.log( "Error(\(relativePath)): \(error)")
                block(nil, error.code)
            }
        }
        super.init()
        addInterNetListner()
    }
    
    deinit {
        networkManager?.stopListening()
    }
}

// MARK: - Internet Availability
extension APIServiceModel{
    
    func addInterNetListner(){
        networkManager?.startListening(onUpdatePerforming: { [weak self] (status) in
            guard let weakSelf = self else { return }
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable {
                print("No InterNet")
                DispatchQueue.main.async {
                    //"No internet connection"
                }
            } else {
                print("Internet Avail")
            }
        })
    }
    
    @discardableResult func isInternetAvailable() -> Bool {
       if let man = networkManager {
           return man.isReachable
        } else {
            return false
        }
    }
}

// MARK: Other methods
extension APIServiceModel {
    
    func getFullUrl(relPath : String) throws -> URL {
        do{
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www"){
                return try relPath.asURL()
            }else{
                return try (_baseUrl+relPath).asURL()
            }
        }catch let err{
            throw err
        }
    }
    
    func setAccesTokenToHeader(token:String) {
        self.token = AccessTokenAdapter(token: token)
    }
    
    func removeAccessTokenFromHeader() {
        self.token = nil
    }
}

// MARK: - Request, ImageUpload and Dowanload methods
extension APIServiceModel {
    
    @discardableResult private func request(relPath: String, method: HTTPMethod, param: [String: Any]?, headerParam: HTTPHeaders?, timeout: TimeInterval? = nil, block: @escaping WSBlock) -> DataRequest? {
        do {
            DebugManager.log( "Url: \(try getFullUrl(relPath: relPath))")
            DebugManager.log( "Param: \(String(describing: param))")
            
            var req = try URLRequest(url: getFullUrl(relPath: relPath), method: method, headers: headerParam ?? headers)
            req.timeoutInterval = timeout ?? timeOutInteraval
            DebugManager.log( "Headers: \(String(describing: req.allHTTPHeaderFields))")
            
            let encodedURLReq = try paramEncode.encode(req, with: param)
            
            return manager.request(encodedURLReq, interceptor: token).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            DebugManager.log( errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    DebugManager.log( err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        } catch let error {
            DebugManager.log( error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
}

//MARK: - Login
extension APIServiceModel {
    
    func adAssignmentList(block: @escaping WSBlock) {
        DebugManager.log( "-------------- List Assignment ------------------")
        let relPath = "ad-assignment/db"
        request(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}
