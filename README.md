# My Week

A Flutter app that shows your week of classes, detects clashes, and totals your hours.

## Think

### Clash condition in plain words
Two courses clash when each one starts before the other one ends.
In code: `a['start'] < b['end'] && b['start'] < a['end']`

We use `<` and not `<=` because a course that ends at 11:00 and one that starts at 11:00
are back-to-back, not overlapping. They share only a boundary point, not any actual time.
Using `<=` would wrongly flag those as a clash.

### Why store times as minutes instead of text like "08:30"?
Because arithmetic on plain integers is trivial: `570 < 600` tells you immediately that
9:30 is before 10:00, and `end - start` gives the duration in one step.
Comparing or subtracting text strings like `"9:30"` and `"10:00"` requires parsing them
first every single time. Storing minutes means you parse once on input and do all
comparisons and calculations cheaply after that.
