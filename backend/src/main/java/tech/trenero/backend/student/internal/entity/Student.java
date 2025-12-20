package tech.trenero.backend.student.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "students", schema = "students_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Student {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "owner_id", nullable = false)
  private UUID ownerId;

  @Column(name = "full_name", nullable = false)
  private String fullName;

  @Column(name = "birth_date")
  private LocalDate birthDate;

  @Column(name = "phone")
  private String phone;

  @Column(name = "note")
  private String note;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @Column(name = "deleted")
  private boolean deleted = false;
}
