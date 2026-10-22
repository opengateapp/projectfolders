# Contributing

The easiest and most useful contribution is a **new preset**: a folder layout for a kind of work that is not covered yet.

## Add a preset

1. Copy `presets/minimal.txt` to `presets/your-preset-name.txt` (lowercase, dashes between words).
2. Start the file with a `#` line saying what it is for.
3. List one folder per line. Use `/` to nest. Number the top-level folders (`00_`, `01_`...) so they sort in workflow order.
4. Keep names free of `< > : " | ? *` and don't end a name with a dot or space, so the layout works on Mac, Windows and Linux.
5. Run the checks: `bash tests/run.sh`
6. Open a pull request. Say who the preset is for and why the folders are laid out the way they are.

## Preset guidelines

- **Software-neutral names** where possible (`EDIT`, not `PREMIERE`). A preset built around one program is fine if the name says so, like `resolve-cloud-team`.
- **Originals first, deliverables last.** Raw input at `00_`, finished output near the end.
- **Keep it short.** If a layout has more than about 25 folders, people stop using the extras.

## Other ways to help

- Try the Windows scripts on your machine and report what happens.
- Improve the README wording. Plain English beats technical jargon here.
- Planned presets are listed in the README roadmap.
