package tech.trenero.backend.group.repository;

import java.util.UUID;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.group.entity.Group;
import org.springframework.data.jpa.repository.JpaRepository;

@Repository
public interface GroupRepository extends JpaRepository<Group, UUID> {
}
