//
//  ViewController.swift
//  HitList
//
//  Created by Yuangang Sheng on 2021/10/22.
//

import CoreData
import UIKit

class ViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  var people: [NSManagedObject] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    title = "The List"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  override func viewWillAppear(_ animated: Bool) {
    //获取Core Data中的对象列表
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")

    do {
      people = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }

  @IBAction func addName(_ sender: Any) {
    let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
    let saveAction = UIAlertAction(title: "Save", style: .default) {
      [unowned self] _ in
      guard let textField = alert.textFields?.first,
            let nameToSave = textField.text
      else {
        return
      }

      self.save(name: nameToSave)
      self.tableView.reloadData()
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert, animated: true)
  }
  
  //把名字存储到Core Data里面的Person对象中
  func save(name: String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext

    guard let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) else { return }
    let person = NSManagedObject(entity: entity, insertInto: managedContext)

    person.setValue(name, forKey: "name")

    do {
      try managedContext.save()
      people.append(person)
    } catch let error as NSError {
      print("Could not save \(error), \(error.userInfo)")
    }
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let person = people[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = person.value(forKeyPath: "name") as? String
    return cell
  }
}
