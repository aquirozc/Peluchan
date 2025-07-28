//
//  FeedViewController.swift
//  Peluchan
//
//  Created by Alejandro Quiroz Carmona on 23/07/25.
//

import UIKit

class FeedViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var table : UITableView!
    @IBOutlet weak var top : UISegmentedControl!
    @IBOutlet weak var spin : UIActivityIndicatorView!
    
    // MARK: Fields
    
    private static let SORT_BY : [String] = ["relevance_v3","date_news", "score"]
    
    private var isInTopSection = false
    private var isLoading = false;
    private var nextId : String? = "";
    private var comments = [Comment]()
    private var posts = [Post]()
    private var soft = SORT_BY[0]
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoadingIndicator()
        fetchMorePost(after: nextId!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPost"{
            (segue.destination as? PostViewController)?.id = sender as? String
        }
    }
    
    // MARK: Progress Indicator
    
    func showLoadingIndicator(){
        table.isHidden = true
        spin.isHidden = false
    }
    
    func hideLoadingIndicator(){
        table.isHidden = false
        spin.isHidden = true
    }
    
    // MARK: Fetching
    
    func fetchMorePost(after id: String, withInterval interval : Int = 1, withMax count : Int = 15){
        if isLoading{
            return
        }
        
        let url = "https://www.peluchan.net/api/post/search?interval=\(interval)d&soft=\(soft)&count=\(count)&v=1&nextId=\(id)"
        isLoading = true;
        
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            do {
                let payload = try JSONDecoder().decode(FeedResponse.self, from: data!)
                DispatchQueue.main.async {
                    self.nextId = payload.data.nextId
                    self.posts += payload.data.list
                    self.table.reloadData()
                    self.hideLoadingIndicator()
                    self.isLoading = false
                }
            } catch {
                self.isLoading = false
            }
        }.resume()
    }
    
    func fetchTopContent(){
        var req = URLRequest(url: URL(string:"https://www.peluchan.net/api/comment/gets")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = #"{"count":8,"list_global":true,"parent_type":"Post"}"#.data(using: .utf8)
        
        URLSession.shared.dataTask(with: req) { data, response, error in
            do {
                let payload = try JSONDecoder().decode(CommentsApiResponse.self, from: data!)
                self.comments = payload.data.comments
                self.fetchMorePost(after: self.nextId!, withInterval: 7, withMax: 5)
            } catch{
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    // MARK: UISegmentedControl Handler
    
    @IBAction func sort(_ sender: UISegmentedControl) {
        let i = sender.selectedSegmentIndex ;
        
        comments.removeAll()
        posts.removeAll()
        nextId = ""
        soft = FeedViewController.SORT_BY[i]
        showLoadingIndicator()
        
        if i == 2 {
            isInTopSection = true
            table.reloadData()
            fetchTopContent()
        }else{
            isInTopSection = false
            table.reloadData()
            fetchMorePost(after: nextId!)
        }
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 1: return posts.count
            case 2: return comments.count
            default: return !isInTopSection ? posts.count : 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 1: return "Mejores de la semana"
            case 2: return "Ultimos comentarios"
            default: return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return !isInTopSection ? 1 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isInTopSection, indexPath.row == posts.count - 1, let nextId = nextId {
            fetchMorePost(after: nextId)
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTopComment", for: indexPath) as! FeedTableViewCell
            let post = comments[indexPath.row]
            cell.title?.text = post.author.name
            cell.subtitle?.text = post.body.content
            cell.thumbnail?.sd_setImage(with: URL(string: post.author.photo.replacingOccurrences(of: "s2://profile", with: "https://media.peluchan.net/cdn/profile")))
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell", for: indexPath) as! FeedTableViewCell
            let post = posts[indexPath.row]
            cell.title?.text = post.title
            cell.subtitle?.text = post.author.name
            cell.thumbnail?.sd_setImage(with: URL(string: post.portada?.replacingOccurrences(of: "s2://post", with: "https://media.peluchan.net/cdn/post/thumbnail" ) ?? post.author.photo.replacingOccurrences(of: "s2://profile", with: "https://media.peluchan.net/cdn/profile")))
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPost", sender: indexPath.section < 2 ? posts[indexPath.row]._id : comments[indexPath.row].parent)
    }

}

