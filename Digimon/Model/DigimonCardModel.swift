//
//  DigimonCardModel.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 13/01/26.
//

struct DigimonCardViewModel {
    let name: String
    let imageUrl: String?
    let metaInfo: String?
    let fields: [FieldViewModel]
    
    struct FieldViewModel {
        let name: String
        let iconUrl: String?
    }
    
    init(from model: DigimonModel) {
        self.name = model.name
        self.imageUrl = model.image
        
        guard let detail = model.cachedDetail else {
            self.metaInfo = nil
            self.fields = []
            return
        }
        
        var metaParts: [String] = []
        if let level = detail.levels?.first?.level {
            metaParts.append(level)
        }
        if let type = detail.types?.first?.type {
            metaParts.append(type)
        }
        if let attribute = detail.attributes?.first?.attribute {
            metaParts.append(attribute)
        }
        self.metaInfo = metaParts.isEmpty ? nil : metaParts.joined(separator: " | ")
        
        self.fields = detail.fields?.map { field in
            FieldViewModel(name: field.field, iconUrl: field.image)
        } ?? []
    }
}
