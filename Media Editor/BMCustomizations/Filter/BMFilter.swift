//
//  BMFilter.swift
//  Media Editor
//
//  Created by Baptiste on 11/03/2020.
//  Copyright © 2020 BM. All rights reserved.
//

import Foundation
import UIKit

/// Represents an object that handle filters and customizations
protocol BMFilter {
    
    /// Category of customization
    var parentType: BMCustomizationCategory { get }
    
    /// If true, this filter is configured as a default filter
    var emptyFilter: Bool { get set }
    
    /// update customizations to current filter
    func add(choice: BMCustomization)
    
    // Render the image with current filter customizations
    func applied(to image: CIImage) -> CIImage?
}

/// Filter that render Colors customization
class BMColorFilter: BMFilter {
    
    static let requiredKeys = [kCIInputColorKey, kCIInputIntensityKey]
        
    var choices = [String: Any]()

    var isSepia: Bool = false
    
    var emptyFilter: Bool = false
    
    init(choices: [BMCustomization]) {

        choices.forEach({
            add(choice: $0)
        })
    }

    func add(choice: BMCustomization) {

        if choice is BMNoneCustomization {
            emptyFilter = true
        }
        
        if choice is BMColorCustomization {
            isSepia = false
        }

        if choice is BMSepiaColorCustomization {
            isSepia = true
            choices.removeValue(forKey: kCIInputColorKey)
            return
        }
        
        guard Self.requiredKeys.contains(choice.coreImageKey)
            else { return }

        choices[choice.coreImageKey] = choice.ciValue
    }
    
    var parentType: BMCustomizationCategory {
        return .filters
    }
        
    func applied(to image: CIImage) -> CIImage? {

        guard !emptyFilter
            else { return image }

        var parameters = choices
        parameters[kCIInputImageKey] = image

        let filterName = isSepia ? "CISepiaTone" : "CIColorMonochrome"
        let filter = CIFilter(name: filterName,
                              parameters: parameters)

        return filter?.outputImage
    }
}

/// Filter that render Stickers customization
class BMStickerFilter: BMFilter {
    
    static let requiredKeys = [kCIInputImageKey]
        
    var choices = [String: Any]()
    
    var emptyFilter: Bool = false
    
    init(choices: [BMCustomization]) {

        choices.forEach({
            add(choice: $0)
        })
    }

    func add(choice: BMCustomization) {

        if choice is BMNoneCustomization {
            emptyFilter = true
        }

        guard Self.requiredKeys.contains(choice.coreImageKey)
            else { return }

        choices[kCIInputImageKey] = choice.ciValue
    }
      
    var parentType: BMCustomizationCategory {
        return .stickers
    }
        
    func applied(to image: CIImage) -> CIImage? {

        var parameters = choices
        parameters[kCIInputBackgroundImageKey] = image

        let filter = CIFilter(name: "CISourceOverCompositing",
                              parameters: parameters)

        return filter?.outputImage
    }
}

/// Filter that render Effects customization
class BMEffectsFilter: BMFilter {
    
    static let requiredKeys = ["__EFFECT_NAME__"]
        
    var ciEffectName: String?

    var emptyFilter: Bool = false
    
    init(choices: [BMCustomization]) {

        choices.forEach({
            add(choice: $0)
        })
    }

    func add(choice: BMCustomization) {

        if choice is BMNoneCustomization {
            emptyFilter = true
        }

        guard Self.requiredKeys.contains(choice.coreImageKey)
            else { return }

        ciEffectName = choice.ciValue as? String
    }
      
    var parentType: BMCustomizationCategory {
        return .filters
    }
      
    func applied(to image: CIImage) -> CIImage? {

        guard let ciEffectName = ciEffectName,
            !emptyFilter
            else { return image }
        
        let parameters = [kCIInputImageKey: image]
        let filter = CIFilter(name: ciEffectName,
                              parameters: parameters)
        return filter?.outputImage
    }
}

/// Filter that render Adjustment customization (Brightness, Contrast etc)
class BMAdjustmentFilter: BMFilter {
    
    static let requiredKeys = [kCIInputSaturationKey,
                               kCIInputBrightnessKey,
                               kCIInputContrastKey]

    var choices = [String: Any]()
    
    var emptyFilter: Bool = false
    
    init(choices: [BMCustomization]) {

        choices.forEach({
            add(choice: $0)
        })
    }

    func add(choice: BMCustomization) {

        if choice is BMNoneCustomization {
            emptyFilter = true
        }
        
        guard Self.requiredKeys.contains(choice.coreImageKey)
            else { return }

        choices[choice.coreImageKey] = choice.ciValue
    }
      
    var parentType: BMCustomizationCategory {
        return .filters
    }
        
    func applied(to image: CIImage) -> CIImage? {

        guard !emptyFilter
            else { return image }

        var parameters = choices
        parameters[kCIInputImageKey] = image

        let filterName = "CIColorControls"
        let filter = CIFilter(name: filterName,
                              parameters: parameters)

        return filter?.outputImage
    }
}

