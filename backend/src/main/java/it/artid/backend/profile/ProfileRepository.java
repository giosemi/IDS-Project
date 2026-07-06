package it.artid.backend.profile;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ProfileRepository extends JpaRepository<StudentProfileEntity, String> {}
