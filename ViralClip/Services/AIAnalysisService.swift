import Foundation
import Vision
import UIKit
import CoreImage

@MainActor
class AIAnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var progress: Double = 0
    @Published var detectedTags: [AIFeatureTag] = []
    @Published var analysisComplete = false
    
    private let context = CIContext()
    
    func analyzeMedia(_ items: [MediaItem], photoService: PhotoLibraryService) async -> [AIFeatureTag] {
        await MainActor.run {
            self.isAnalyzing = true
            self.progress = 0
            self.detectedTags = []
            self.analysisComplete = false
        }
        
        var allTags: [AIFeatureTag] = []
        let totalItems = Double(items.count)
        
        for (index, item) in items.enumerated() {
            let tags = await analyzeSingleMedia(item, photoService: photoService)
            allTags.append(contentsOf: tags)
            
            await MainActor.run {
                self.progress = Double(index + 1) / totalItems
                self.detectedTags = allTags
            }
        }
        
        let uniqueTags = Array(Set(allTags)).sorted { $0.label < $1.label }
        
        await MainActor.run {
            self.isAnalyzing = false
            self.progress = 1.0
            self.analysisComplete = true
        }
        
        return uniqueTags
    }
    
    private func analyzeSingleMedia(_ item: MediaItem, photoService: PhotoLibraryService) async -> [AIFeatureTag] {
        var tags: [AIFeatureTag] = []
        
        guard let image = await photoService.loadFullImage(for: item) else {
            return tags
        }
        
        tags.append(contentsOf: await detectFaces(in: image))
        tags.append(contentsOf: await detectObjects(in: image))
        tags.append(contentsOf: await classifyScene(in: image))
        
        return tags
    }
    
    private func detectFaces(in image: UIImage) async -> [AIFeatureTag] {
        var tags: [AIFeatureTag] = []
        
        guard let cgImage = image.cgImage else { return tags }
        
        let request = VNDetectFaceRectanglesRequest()
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            if let results = request.results, !results.isEmpty {
                tags.append(AIFeatureTag(label: "People", category: .people))
                tags.append(AIFeatureTag(label: "Portrait", category: .people))
            }
        } catch {
            print("Face detection error: \(error)")
        }
        
        return tags
    }
    
    private func detectObjects(in image: UIImage) async -> [AIFeatureTag] {
        var tags: [AIFeatureTag] = []
        
        guard let cgImage = image.cgImage else { return tags }
        
        let request = VNClassifyImageRequest()
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            if let results = request.results {
                let topResults = results.prefix(5)
                for result in topResults {
                    let confidence = result.confidence
                    if confidence > 0.5 {
                        let tagLabel = mapObjectToTag(result.identifier)
                        if let tagLabel = tagLabel {
                            tags.append(AIFeatureTag(label: tagLabel, category: .activity))
                        }
                    }
                }
            }
        } catch {
            print("Object detection error: \(error)")
        }
        
        return tags
    }
    
    private func classifyScene(in image: UIImage) async -> [AIFeatureTag] {
        var tags: [AIFeatureTag] = []
        
        guard let cgImage = image.cgImage else { return tags }
        
        let request = VNClassifyImageRequest()
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            if let results = request.results {
                let sceneKeywords = ["outdoor", "indoor", "beach", "mountain", "city", "street", "restaurant", "gym", "park", "home"]
                
                for result in results {
                    let lowerId = result.identifier.lowercased()
                    for keyword in sceneKeywords {
                        if lowerId.contains(keyword) {
                            tags.append(AIFeatureTag(label: keyword.capitalized, category: .location))
                        }
                    }
                }
            }
        } catch {
            print("Scene classification error: \(error)")
        }
        
        return tags
    }
    
    private func mapObjectToTag(_ identifier: String) -> String? {
        let mapping: [String: String] = [
            "dog": "Pet",
            "cat": "Pet",
            "car": "Vehicle",
            "bicycle": "Sports",
            "person": "People",
            "food": "Food",
            "drink": "Food",
            "coffee": "Coffee",
            "phone": "Tech",
            "computer": "Tech",
            "beach": "Beach",
            "ocean": "Beach",
            "mountain": "Nature",
            "tree": "Nature",
            "flower": "Nature",
            "sports": "Sports",
            "fitness": "Fitness",
            "gym": "Fitness",
            "music": "Music",
            "guitar": "Music",
            "travel": "Travel",
            "vacation": "Travel"
        ]
        
        let lowerId = identifier.lowercased()
        for (key, value) in mapping {
            if lowerId.contains(key) {
                return value
            }
        }
        return nil
    }
    
    func generateTrendingTags() -> [AIFeatureTag] {
        let trendingTopics = [
            "Day in the Life",
            "GRWM",
            "Get Ready With Me",
            "Storytime",
            "POV",
            "Tutorial",
            "Behind the Scenes",
            "Vlog",
            "Motivation",
            "Comedy"
        ]
        
        return trendingTopics.shuffled().prefix(3).map { topic in
            AIFeatureTag(label: topic, category: .trending)
        }
    }
}
