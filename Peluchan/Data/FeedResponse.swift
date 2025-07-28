//
//  FeedResponse.swift
//  Peluchan
//
//  Created by Alejandro Quiroz Carmona on 21/07/25.
//

import Foundation

struct FeedResponse : Codable {
    
    var data : Data
    var error : Bool
    var ms : Int
    
    struct Data : Codable {
        var list : [Post]
        var nextId : String?
    }

}

struct CommentsApiResponse : Codable {
    
    var data : Data
    var error : Bool
    var ms : Int
    
    struct Data : Codable {
        var comments : [Comment]
    }

}

struct PostResponse : Codable {
    
    var data : Data
    var error : Bool
    var ms : Int
    
    struct Data : Codable {
        var post : Post
    }

}

struct Author : Codable {
    var name : String
    var photo : String
}

struct Body : Codable {
    var content : String
}

struct Comment : Codable {
    var author : Author
    var body : Body
    var parent : String
}

struct Post : Codable {
    var _id : String
    var author : Author
    var title : String
    var portada : String?
    var body : Body?
}


