# Project Folders

Right-click a folder, pick **Create Project Folders**, and your whole project layout appears. No prompts, no typing, no forgetting a folder.

The layout is just **one plain text file**. Change the file and every future project uses your layout. There are also ready-made layouts for video, photography, podcasts and motion design.

*A free tool from OPEN GATE.*

## What you get

By default, a general video project:

```
00_MEDIA/            everything that comes IN. Originals live here, never touched
  CAMERA/
  AUDIO/  PRODUCTION  VO  FOLEY  SFX  MUSIC
  PHOTOS/
  GRAPHICS/
  STOCK/
01_PROXY/            proxies and optimized media (safe to rebuild)
02_PROJECT_FILES/    sorted by job, so any software fits
  EDIT/  COLOR/  MOTION/  SOUND/
03_VFX/
04_RENDERS/          intermediate renders
05_OUTPUT/
  REVIEW/            cuts for feedback
  FINAL/             finished deliverables only
06_DOCUMENTS/
  SCRIPTS/  SHOT_LISTS/  RELEASES_AND_CONTRACTS/  REFERENCE/
```

The numbers make every computer sort the folders in workflow order. Originals and generated files are kept apart, which stops the "why do I have two copies of this clip?" problem on shared and cloud projects.

## What happens when you click it

- Right-click an **empty** folder: it gets filled directly.
- Right-click a folder that **already has stuff in it**: a new `Untitled Project` folder is made inside and filled, so nothing gets mixed into your existing files.

The tool only ever creates folders. It never deletes, moves or renames anything.

---

## Mac setup (about 3 minutes)

**Step 1: Install the files**

1. Download this repo (green **Code** button, then **Download ZIP**) and unzip it.
2. Open **Terminal**. Type `bash ` (with a space), drag `mac/install.sh` from Finder into the Terminal window, press Return.

This puts everything in a hidden folder called `.project-folders` in your home folder. Want a different starting layout? Add its name to the end of that command, like `... install.sh podcast`.

**Step 2: Add the right-click menu item**

1. Open **Automator** and choose **New Document**, then **Quick Action**.
2. At the top, set **Workflow receives current** to **folders** in **Finder**.
3. In the left search box type `Run Shell Script` and double-click it.
4. Set **Shell** to `/bin/bash` and **Pass input** to **as arguments**.
5. Delete what is in the box and paste this one line:

   ```
   "$HOME/.project-folders/create_project_folders.sh" "$@"
   ```
6. **File, then Save**, and name it `Create Project Folders`.

Now right-click any folder in Finder, then **Quick Actions**, then **Create Project Folders**.

If it does not show up, open **System Settings, Privacy & Security, Extensions, Finder** and make sure it is ticked.

## Windows setup (about 1 minute)

1. Download this repo (green **Code** button, then **Download ZIP**) and unzip it.
2. Open the `windows` folder, right-click `install.ps1`, choose **Run with PowerShell**.

That is it. Right-click a folder (or the empty space inside a folder). On Windows 11 choose **Show more options** first, and you will see **Create Project Folders**.

If PowerShell says scripts are blocked, open PowerShell, run this once, then try again:

```
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

To remove the menu item later, right-click `windows/uninstall.ps1` and choose **Run with PowerShell**.

> The Windows scripts are newer and have had less testing than the Mac ones. If something is off, please open an issue.

---

## Pick a layout (presets)

Presets are ready-made layouts. Pick the one closest to your work, then tweak it.

| Preset | Good for |
|--------|----------|
| `default` | General video production, works with any editing software |
| `resolve-cloud-team` | Remote teams using a NAS and DaVinci Resolve cloud projects, with separate DaVinci and Premiere folders |
| `photography` | Shoots, selects, edits, and web/print/proof exports |
| `podcast` | Recordings, edit sessions, show assets, episodes and social clips |
| `motion-design` | Animation, titles and 3D, with preview and master renders |
| `classic` | The original simple single-computer layout |
| `minimal` | Small jobs: Media, Project, Exports, Documents |

**Switch layouts**

- **Mac:** in Terminal, run `~/.project-folders/use-preset.sh podcast`. Run it with no name to see the list.
- **Windows:** in PowerShell, run `& "$env:USERPROFILE\.project-folders\use-preset.ps1" podcast`. Run it with no name to see the list.

Your previous layout is saved as `folders.txt.bak`, so you can always get it back.

## Make it your own

Your live layout is one file:

| Computer | Your editable file |
|----------|--------------------|
| Mac | `~/.project-folders/folders.txt` (in Finder: Go, Go to Folder, paste that path) |
| Windows | `C:\Users\YOURNAME\.project-folders\folders.txt` |

Open it in any text editor. The rules are simple:

- **One folder per line.**
- Use `/` to put a folder inside another: `02_PROJECT_FILES/EDIT`
- Lines starting with `#` are notes and are ignored. Blank lines are ignored.
- Save the file. Your very next project uses it. No reinstalling.

Add a folder: type a new line. Remove one: delete the line. Rename one: change the line.

The default layout has a few optional lines already written for you (one folder per editing program, like `FINAL_CUT` and `AVID`). Remove the `#` to turn one on.

Re-running the installer **never overwrites** your edited `folders.txt`.

**Names to avoid:** `< > : " | ? *`, and names ending in a dot or space. They break on Windows or other systems, so the tool skips those lines and tells you.

## Tips for team projects

- Keep everyone's layout identical: share one `folders.txt` in your team chat or shared drive and have everyone drop it into their `.project-folders` folder.
- Create the project folders once, on the machine or NAS that holds the originals.
- New footage goes into `00_MEDIA/CAMERA` first and gets imported from there, not from someone's desktop. That keeps the file paths the same for everybody.

## Roadmap

Layouts we would like to add. Want to build one? See [CONTRIBUTING.md](CONTRIBUTING.md).

- Documentary and multi-camera events
- Short-form and social content
- Animation and game cinematics
- Music production
- Live streaming
- A simple way to share a team's layout with one link or file

## How it works (for the curious)

The layout file is just a list. The script reads it line by line and makes each folder (`mkdir -p` on Mac, `New-Item` on Windows). The right-click item simply runs that script on the folder you clicked.

```
presets/    default, resolve-cloud-team, photography, podcast,
            motion-design, classic, minimal
mac/        create_project_folders.sh, use-preset.sh, install.sh
windows/    create-project-folders.ps1, use-preset.ps1, install.ps1, uninstall.ps1
tests/      run.sh   (checks every preset and the Mac scripts)
```

Run `bash tests/run.sh` to check everything. It also runs automatically on GitHub for every change.

## License

MIT. See [LICENSE](LICENSE).
