//
//  VariableBlurView.swift
//  VariableBlurView
//
//  Created by Andreas Verhoeven on 12/01/2024.
//

import UIKit

/// Shows variable blur in a direction
open class VariableBlurView: UIView {
	public enum BlurEdge {
		case top /// blur is heaviest at top edge, lowest at bottom edge
		case bottom /// blur is heaviest at bottom edge, lowest at top edge
		case leading /// blur is heaviest at leading edge, lowest at bottom edge
		case trailing /// blur is heaviest at trailing edge, lowest at leading edge
	}

	/// the edge where blur is the heaviest at
	open var blurEdge = BlurEdge.top {
		didSet {
			guard blurEdge != oldValue else { return }
			update()
		}
	}

	/// the blur radius at the edge - will decrease to 0 in the opposite edge
	open var blurRadius: CGFloat = 20 {
		didSet {
			guard blurRadius != oldValue else { return }
			update()
		}
	}


	// MARK: - Privates
	private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

	private enum Strings {
		fileprivate static let _string1 = Self.DecodeString("=MUQGlGb0Vmc") // EncodeString("CAFilter"))
		fileprivate static let _string2 = Self.DecodeString("mlGb0VmcXlGdoRVewVmO") // EncodeString("filterWithType:"))
		fileprivate static let _string3 = Self.DecodeString("2FmcpFmYsVmQsVnc") // EncodeString("variableBlur"))
		fileprivate static let _string4 = Self.DecodeString("=kmbwVHdSFGZpV3c") // EncodeString("inputRadius"))
		fileprivate static let _string5 = Self.DecodeString("=kmbwVHdNF2crlUbhdWZ") // EncodeString("inputMaskImage"))
		fileprivate static let _string6 = Self.DecodeString("==QauBXd050by1WYslmelVEZnV2c") // EncodeString("inputNormalizeEdges"))
		fileprivate static let _string7 = Self.DecodeString("=M3YhxWZ") // EncodeString("scale"))

		private static func DecodeString(_ string: String) -> String {
			guard let data = Data(base64Encoded: String(string.reversed())) else { return "" }
			guard let decodedString = String(data: data, encoding: .utf8) else { return "" }
			return String(decodedString.reversed())
		}

		private static func EncodeString(_ string: String) -> String {
			let value = String(string.reversed()).data(using: .utf8).flatMap { String($0.base64EncodedString().reversed()) } ?? ""
			return value
		}
	}

	private func createGradientMaskImage() -> UIImage? {
		let fadesOut: Bool
		let size: CGSize
		let endPoint: CGPoint
		switch blurEdge {
			case .top:
				fadesOut = true
				endPoint = CGPoint(x: 0, y: bounds.height)
				size = CGSize(width: 1, height: bounds.height)

			case .bottom:
				fadesOut = false
				endPoint = CGPoint(x: 0, y: bounds.height)
				size = CGSize(width: 1, height: bounds.height)

			case .leading:
				fadesOut = (effectiveUserInterfaceLayoutDirection == .leftToRight)
				endPoint = CGPoint(x: bounds.width, y: 0)
				size = CGSize(width: bounds.width, height: 1)

			case .trailing:
				fadesOut = (effectiveUserInterfaceLayoutDirection != .leftToRight)
				endPoint = CGPoint(x: bounds.width, y: 0)
				size = CGSize(width: bounds.width, height: 1)
		}

		return UIGraphicsImageRenderer(size: size).image { context in
			let colors = [
				UIColor.black.withAlphaComponent(fadesOut == true ? 1 : 0),
				UIColor.black.withAlphaComponent(fadesOut == true ? 0 : 1)
			]

			if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map { $0.cgColor } as CFArray, locations: nil) {
				context.cgContext.drawLinearGradient(gradient, start: .zero, end: endPoint, options: [])
			}
		}
	}

	private func update() {
		guard bounds.size != .zero else { return }

		guard let classObject = NSClassFromString(Strings._string1) as AnyObject as? NSObjectProtocol else { return }

		let selector = NSSelectorFromString(Strings._string2)
		guard classObject.responds(to: selector) else { return }

		guard let filter = classObject.perform(selector, with: Strings._string3 as NSString) else { return }
		guard let variableBlurFilter = filter.takeUnretainedValue() as? NSObject else { return }

		variableBlurFilter.setValue(blurRadius, forKey: Strings._string4)
		if let maskImage = createGradientMaskImage() {
			variableBlurFilter.setValue(maskImage.cgImage, forKey: Strings._string5)
		}
		variableBlurFilter.setValue(true, forKey: Strings._string6)
		blurView.subviews.first?.layer.filters = [variableBlurFilter]

		if blurView.subviews.count > 1 {
			blurView.subviews[1].alpha = 0
		}
	}

	public init(edge: BlurEdge = .top, radius: CGFloat = 20, frame: CGRect = .zero) {
		self.blurEdge = edge
		self.blurRadius = radius
		super.init(frame: frame)

		addSubview(blurView)
		update()
	}


	// MARK: - UIView

	public override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(blurView)
		update()
	}

	@available(*, unavailable) 
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open override func layoutSubviews() {
		super.layoutSubviews()

		switch blurEdge {
			case .top, .bottom:
				if blurView.bounds.height != bounds.height {
					update()
				}

			case .leading, .trailing:
				if blurView.bounds.width != bounds.width {
					update()
				}
		}

		blurView.frame = CGRect(origin: .zero, size: bounds.size)
	}

	open override func didMoveToWindow() {
		super.didMoveToWindow()

		if let window {
			blurView.subviews.first?.layer.setValue(window.screen.scale, forKey: Strings._string7)
		}
	}

	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		DispatchQueue.main.async { [weak self] in
			self?.update()
		}
	}
}
