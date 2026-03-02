# ◈ Prototype Playground

A lightweight, self-hosted prototype gallery for the design team. Publish HTML prototypes from Claude Cowork (or anywhere) and share them with a link.

**Live dashboard:** `https://YOUR_USERNAME.github.io/prototype-playground`

---

## Quick Start (5 minutes)

### 1. Create the GitHub repo

Go to [github.com/new](https://github.com/new) and create a new **public** repo called `prototype-playground`.

```bash
# Clone it locally
git clone https://github.com/YOUR_USERNAME/prototype-playground.git
cd prototype-playground
```

### 2. Copy these files in

Copy all the files from this package into your repo:

```
prototype-playground/
├── index.html          ← The dashboard
├── prototypes.json     ← Manifest (tracks all prototypes)
├── publish.sh          ← The publish script
├── prototypes/         ← Where HTML files live
│   └── .gitkeep
└── README.md
```

### 3. Update the config

Open `publish.sh` and change line 38:

```bash
GITHUB_USERNAME="YOUR_GITHUB_USERNAME"    # ← put your actual username here
```

### 4. Enable GitHub Pages

1. Push your code: `git add -A && git commit -m "init" && git push`
2. Go to your repo on GitHub → **Settings** → **Pages**
3. Under "Source", select **Deploy from a branch**
4. Choose `main` branch, `/ (root)` folder
5. Click **Save**

Your dashboard will be live at `https://YOUR_USERNAME.github.io/prototype-playground` within a minute.

---

## Publishing a Prototype

After creating a prototype in Claude Cowork (or any tool), save the HTML file and run:

```bash
./publish.sh "My Prototype Name" ./path/to/file.html
```

That's it. The script will:
- Copy the file to `prototypes/`
- Update the manifest
- Push to GitHub
- Print the shareable URL
- Copy the URL to your clipboard (on Mac)

### Options

```bash
# Full example with all options
./publish.sh "AI Agent Onboarding V2" ./onboarding.html \
  --author "Lisa" \
  --status "In Review" \
  --tags "AI Agent,Onboarding" \
  --description "Redesigned onboarding flow with guided setup"

# Update an existing prototype
./publish.sh "AI Agent Onboarding V2" ./onboarding-v3.html --update

# Minimal (uses git username, defaults to Draft)
./publish.sh "Quick Test" ./test.html
```

### Status options
- `Draft` — Work in progress (default)
- `In Review` — Ready for feedback
- `Final` — Approved / complete

---

## For Teammates (Viewing Only)

Just share the dashboard link. No GitHub account needed to view prototypes.

**Dashboard:** `https://YOUR_USERNAME.github.io/prototype-playground`

Each prototype also has a direct link like:
`https://YOUR_USERNAME.github.io/prototype-playground/prototypes/my-prototype.html`

---

## For Teammates (Publishing)

If other designers want to publish too:

1. **Install Git** — Download from [git-scm.com](https://git-scm.com/) or run `xcode-select --install` on Mac
2. **Get repo access** — Ask the repo owner to add you as a collaborator
3. **Clone the repo:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/prototype-playground.git
   ```
4. **Publish:**
   ```bash
   cd prototype-playground
   ./publish.sh "My Prototype" ./my-file.html --author "Your Name"
   ```

---

## Troubleshooting

**"prototypes.json not found"**
→ Make sure you're running the script from the repo root directory.

**Merge conflicts on prototypes.json**
→ The script does `git pull --rebase` before pushing. If there's a conflict, run `git pull` manually, resolve conflicts in prototypes.json, then try again.

**Changes not showing on the live site**
→ GitHub Pages can take 1-2 minutes to deploy. Check the Actions tab on your repo for deploy status.

**"Permission denied" on publish.sh**
→ Run `chmod +x publish.sh`

---

## How It Works

The system is intentionally simple — no build step, no backend, no database.

- `index.html` is a static page that fetches `prototypes.json` at load time and renders the gallery
- `prototypes.json` is the single source of truth for all prototype metadata
- `publish.sh` automates the boring parts: file copying, manifest updates, git operations
- GitHub Pages serves everything as static files for free

Future ideas:
- Slack integration to auto-post new prototype links
- Thumbnail screenshots via Puppeteer
- Password protection via Cloudflare Access
- Drag-and-drop web uploader (no terminal needed)
