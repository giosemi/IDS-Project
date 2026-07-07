package it.artid.backend.institution;

public record AfamInstitutionDto(String id, String name, String city) {
    static AfamInstitutionDto from(AfamInstitutionEntity entity) {
        return new AfamInstitutionDto(entity.getId(), entity.getName(), entity.getCity());
    }
}
