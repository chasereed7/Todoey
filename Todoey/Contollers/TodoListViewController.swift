//
//  ViewController.swift
//  Todoey
//
//  Created by Carter Reed on 8/4/19.
//  Copyright © 2019 Carter Reed. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

        var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        
        return cell
      }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add new todo item.", message: "this will add a new item", preferredStyle: .alert)
    
        let action = UIAlertAction(title: "Add item", style: .default) { (alert) in
            
            
            let newItem = Item(context: self.context )
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }

        
        alert.addTextField { (alertTextFeild) in
             alertTextFeild.placeholder = "Create new item"
            textField = alertTextFeild
        
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        
        
        do {
            try context.save()
        } catch {
        print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        print("load items initated")
       
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
       itemArray = try context.fetch(request)
            itemArray.sort { (item1, item2) -> Bool in
                if let title1 = item1.title {
                    if let title2 = item2.title {
                        if title1 > title2 {
                            return false
                        } else {
                            return true
                        }
                    }
                }
                return true
            }
            self.tableView.reloadData()
            print(itemArray.count)
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }

}
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
            let request: NSFetchRequest<Item> = Item.fetchRequest()
        
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search bar")
        if searchBar.text?.count == 0 {
            loadItems()
        
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()

            }

        } else {
            print("count is zero")
        }
    }
    
}
