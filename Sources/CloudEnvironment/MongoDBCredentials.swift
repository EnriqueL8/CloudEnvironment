/*
* Copyright IBM Corporation 2017
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/// MongoDBCredentials class
///
/// Contains the credentials for a MongoDB service instance.
public class MongoDBCredentials {
  public let uri: String
  public let host: String
  public let username: String
  public let password: String
  public let port: Int
  
  public init(
    uri: String,
    host: String,
    username: String,
    password: String,
    port: Int) {

    self.uri = uri
    self.host = host
    self.username = username
    self.password = password
    self.port = port
  }
}

extension CloudEnv {

  /// Returns a MongoDBCredentials object with the corresponding credentials.
  ///
  /// - Parameter name: The key to lookup the credentials object.
  public func getMongoDBCredentials(name: String) -> MongoDBCredentials? {

    guard let credentials = getDictionary(name: name) else {
      return nil
    }

    // For detail on the format for the URI connection string that MongoDB supports, 
    // see: https://docs.mongodb.com/manual/reference/connection-string/
    // It is possible to specify more than one host in the URI connection string

    // Use SSL uri if available
    guard let uri = credentials["uri"] as? String else {
      return nil
    }

    let uriItems = uri.components(separatedBy: ",")
    let filtered  = uriItems.filter({ $0.contains("ssl=true") })
    let uriValue: String?
    if filtered.count == 1, let dbInfo = filtered.first, var credentialInfo = uriItems.first,
      let atRange = credentialInfo.range(of: "@") {
        // Substitute non-ssl hostname:port with correct hostname:port
        credentialInfo.removeSubrange(atRange.upperBound..<credentialInfo.endIndex)
        uriValue = credentialInfo + dbInfo
    } else {
      uriValue = uriItems.first
    }

    guard let stringURL = uriValue, stringURL.count > 0,
      let url         = URL(string: stringURL),
      let host        = url.host,
      let username    = url.user,
      let password    = url.password,
      let port        = url.port else {

      return nil
    }

    return MongoDBCredentials(
      uri: uri,
      host: host,
      username: username,
      password: password,
      port: port)
  }

}
