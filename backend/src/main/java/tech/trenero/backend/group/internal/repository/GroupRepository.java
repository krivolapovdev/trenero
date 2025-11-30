package tech.trenero.backend.group.internal.repository;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.group.internal.entity.Group;

@Repository
public interface GroupRepository extends JpaRepository<Group, UUID> {}
