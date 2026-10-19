package types

import (
	"fmt"
	"strings"
	"time"
)

type Date struct {
	time.Time
}

var dateFormats = []string{
	time.DateOnly,
	time.RFC3339,
	time.RFC3339Nano,
	"2006-01-02T15:04:05.000",
	"2006-01-02T15:04:05",
	"02.01.2006",
	"2006/01/02",
}

func ParseDate(s string) (Date, error) {
	s = strings.TrimSpace(s)
	if s == "" || s == "null" {
		return Date{}, nil
	}

	s = strings.Trim(s, `"`)
	if s == "" || s == "null" {
		return Date{}, nil
	}

	for _, layout := range dateFormats {
		if t, err := time.Parse(layout, s); err == nil {
			return Date{Time: t}, nil
		}
	}
	return Date{}, fmt.Errorf("invalid date format: %s", s)
}

func (d Date) MarshalJSON() ([]byte, error) {
	if d.IsZero() {
		return []byte("null"), nil
	}
	return []byte(`"` + d.Format(time.DateOnly) + `"`), nil
}

func (d *Date) UnmarshalJSON(data []byte) error {
	s := strings.TrimSpace(string(data))
	if s == "null" || s == `""` {
		*d = Date{}
		return nil
	}
	parsed, err := ParseDate(s)
	if err != nil {
		return err
	}
	*d = parsed
	return nil
}

func (d Date) String() string {
	if d.IsZero() {
		return ""
	}
	return d.Format(time.DateOnly)
}
