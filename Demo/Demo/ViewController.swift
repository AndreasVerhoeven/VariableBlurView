//
//  ViewController.swift
//  Demo
//
//  Created by Andreas Verhoeven on 16/05/2021.
//

import UIKit

class ViewController: UITableViewController {
	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.isNavigationBarHidden = true
		tableView.separatorStyle = .none

		let topBlurView = VariableBlurView(edge: .top, radius: 20)
		topBlurView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(topBlurView)
		NSLayoutConstraint.activate([
			tableView.frameLayoutGuide.topAnchor.constraint(equalTo: topBlurView.topAnchor),
			view.leadingAnchor.constraint(equalTo: topBlurView.leadingAnchor),
			topBlurView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
			topBlurView.heightAnchor.constraint(equalToConstant: 200),
		])

		let bottomBlurView = VariableBlurView(edge: .bottom, radius: 5)
		bottomBlurView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bottomBlurView)
		NSLayoutConstraint.activate([
			tableView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomBlurView.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: bottomBlurView.leadingAnchor),
			bottomBlurView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
			bottomBlurView.heightAnchor.constraint(equalToConstant: 200),
		])
	}

	// MARK: - UITableViewDataSource

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

		let imageView = UIImageView(image: UIImage(named: "photo"))
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(imageView)

		NSLayoutConstraint.activate([
			imageView.heightAnchor.constraint(equalToConstant: 300),
			imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
		])
		return cell
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}
}

