package org.trenero.backend;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

/**
 * The day a test talks about, as the value the API carries for it: midnight UTC. A test that only
 * cares about the day of a payment or a lesson builds the value with this instead of spelling out
 * an {@link OffsetDateTime} every time.
 */
public final class TestDays {

  private TestDays() {}

  public static OffsetDateTime day(int year, int month, int day) {
    return OffsetDateTime.of(year, month, day, 0, 0, 0, 0, ZoneOffset.UTC);
  }
}
