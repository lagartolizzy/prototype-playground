# Publish Prototype to Playground

You are helping a designer publish an HTML prototype to the Prototype Playground.

## What the user will provide

1. **The HTML file path** — where the prototype file is on their computer
2. **The prototype name** — a short, descriptive name
3. **A screenshot** (optional) — a preview image for the dashboard card

If they don't provide a description, generate a brief one based on the prototype name.

## Playground location

- Repo: `~/Documents/prototype-playground`
- Prototypes folder: `~/Documents/prototype-playground/prototypes/`
- Images folder: `~/Documents/prototype-playground/images/`
- Manifest: `~/Documents/prototype-playground/prototypes.json`
- Live dashboard: `https://lagartolizzy.github.io/prototype-playground`

## Steps to publish

1. **Generate a filename slug** from the prototype name (lowercase, hyphens, no special characters). Example: "AI Agent Onboarding V2" → `ai-agent-onboarding-v2.html`

2. **Copy the HTML file**:
   ```bash
   cp "<SOURCE_FILE>" ~/Documents/prototype-playground/prototypes/<slug>.html
   ```

3. **If a screenshot is provided**, copy it to the images folder:
   ```bash
   mkdir -p ~/Documents/prototype-playground/images
   cp "<SCREENSHOT_PATH>" ~/Documents/prototype-playground/images/<slug>.png
   ```
   Supported formats: .png, .jpg, .jpeg, .webp. Keep the same extension.

4. **Update prototypes.json** — Read the current JSON array, then append a new entry:
   ```json
   {
     "name": "<PROTOTYPE_NAME>",
     "author": "Lisa",
     "date": "<TODAY YYYY-MM-DD>",
     "description": "<DESCRIPTION>",
     "file": "<slug>.html",
     "image": "<slug>.png"
   }
   ```
   Only include the `"image"` field if a screenshot was provided.
   Write the updated array back to prototypes.json with proper formatting.

5. **Push to GitHub**:
   ```bash
   cd ~/Documents/prototype-playground
   git pull --rebase
   git add -A
   git commit -m "add: <PROTOTYPE_NAME>"
   git push
   ```

6. **Share the links**:
   - Prototype: `https://lagartolizzy.github.io/prototype-playground/prototypes/<slug>.html`
   - Dashboard: `https://lagartolizzy.github.io/prototype-playground`

## Example prompts the user might say

- "Publish ~/Downloads/onboarding.html as 'AI Agent Onboarding V2' with screenshot ~/Desktop/Screenshot.png"
- "Publish this prototype as 'SMS Flow Builder'" (you'll need to ask which file)
- "Add a screenshot to the existing AI Agent Onboarding V2 prototype" (update the image field and copy the image)

## Updating an existing prototype

If the user wants to update a prototype that already exists:
1. Replace the HTML file in prototypes/
2. If a new screenshot is provided, replace the image in images/
3. Update the entry in prototypes.json (match by filename slug)
4. Commit and push
