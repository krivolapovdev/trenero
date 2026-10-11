# PDF fonts

Fonts embedded into the PDF exported from the group report. The fonts built into
the PDF format only cover Latin, so a bundled Unicode font is required to draw
Cyrillic group and student names.

| File                 | Source                                                                       |
| -------------------- | ---------------------------------------------------------------------------- |
| `Roboto-Regular.ttf` | <https://github.com/googlefonts/roboto-2/blob/main/src/hinted/Roboto-Regular.ttf> |
| `Roboto-Bold.ttf`    | <https://github.com/googlefonts/roboto-2/blob/main/src/hinted/Roboto-Bold.ttf>    |

Roboto is licensed under the Apache License 2.0:
<https://www.apache.org/licenses/LICENSE-2.0>

The fonts are only used as assets (`assets/fonts/`) and loaded with
`rootBundle` by `GroupReportPdfService`, never as Flutter text fonts.
