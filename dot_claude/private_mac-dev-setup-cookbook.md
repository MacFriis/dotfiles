# Mac dev-setup cookbook (Per Friis)

Opskrift til at sætte en ny Mac (Apple Silicon) op uden Homebrew + synke Claude-config mellem maskiner.

> **Identitet:** Per Friis · `per.friis@friisconsult.com` · GitHub: **mcfriis**
> (NB: `friisconsult.aps@gmail.com` er Claude-kontoen — brug den ALDRIG til git/SSH.)

## Principper
- **Ingen Homebrew.** Alt via officielle installere (`.pkg`/`.dmg`) eller bruger-lokale scripts.
- **Bruger-lokale binaries** i `~/.local/bin` (skal være på PATH i `~/.zshrc`).
- **Hver maskine har sin egen SSH-nøgle** — private nøgler synkes aldrig.
- `sudo` virker IKKE via Claudes `!`-prefix → kør `sudo`-ting i et rigtigt Terminal-vindue, eller dobbeltklik `.pkg` i Finder.

---

## 1. Git (følger med Xcode / Command Line Tools)
Installer Xcode (eller bare CLT med `xcode-select --install`). Derefter:
```sh
git config --global user.name "Per Friis"
git config --global user.email "per.friis@friisconsult.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

## 2. SSH-nøgle (ed25519) + Apple Keychain
```sh
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "per.friis@friisconsult.com" -f ~/.ssh/id_ed25519 -N "" -q
cat > ~/.ssh/config <<'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub   # → indsæt på https://github.com/settings/ssh/new
ssh -o StrictHostKeyChecking=accept-new -T git@github.com   # test
```

## 3. Node (officiel LTS .pkg — ingen nvm/Homebrew)
```sh
# Find seneste LTS-version og hent universal .pkg:
VER=$(curl -s https://nodejs.org/dist/index.json | tr '}' '\n' | grep -m1 '"lts":"[A-Za-z]' | grep -o 'v[0-9][0-9.]*' | head -1)
curl -fsSL "https://nodejs.org/dist/${VER}/node-${VER}.pkg" -o ~/Downloads/node-${VER}.pkg
# Installér: dobbeltklik i Finder, ELLER i rigtigt Terminal:  sudo installer -pkg ~/Downloads/node-${VER}.pkg -target /
```
> Gotcha: macOS-installeren hedder `node-vXX.pkg` (universal) — IKKE `-darwin-arm64.pkg`.

## 4. .NET SDK (officiel .pkg)
```sh
curl -fsSL "https://aka.ms/dotnet/10.0/dotnet-sdk-osx-arm64.pkg" -o ~/Downloads/dotnet-sdk-osx-arm64.pkg
# Installér via Finder eller: sudo installer -pkg ~/Downloads/dotnet-sdk-osx-arm64.pkg -target /
# PATH (path_helper kører kun i login-shells — sik i zshrc):
echo '\n# .NET SDK\nexport PATH="/usr/local/share/dotnet:$PATH"\nexport DOTNET_CLI_TELEMETRY_OPTOUT=1' >> ~/.zshrc
```

## 5. VS Code (direkte download)
```sh
curl -fsSL "https://update.code.visualstudio.com/latest/darwin-universal/stable" -o ~/Downloads/VSCode.zip
ditto -x -k ~/Downloads/VSCode.zip /Applications/
# 'code'-kommando:
mkdir -p ~/.local/bin
ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ~/.local/bin/code
grep -q '.local/bin' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

## 6. React + Tailwind + Lucide (Vite + Tailwind v4)
```sh
npm create vite@latest min-app -- --template react
cd min-app && npm install
npm install tailwindcss @tailwindcss/vite lucide-react
```
- `vite.config.js`: tilføj `import tailwindcss from '@tailwindcss/vite'` og `tailwindcss()` i `plugins`.
- `src/index.css`: erstat alt med `@import "tailwindcss";`
- Ikoner: `import { Rocket } from 'lucide-react'` → `<Rocket className="size-6" />`
- **Gotcha:** Lucide har FJERNET brand-logoer (GitHub, X osv.). Brug https://simpleicons.org/ til firmalogoer.
- Kør: `npm run dev` → http://localhost:5173

---

## 7. Dotfiles-sync af ~/.claude (chezmoi)
Synker det bærbare: `CLAUDE.md`, `skills/`, `commands/`, `agents/`, `keybindings.json`.
Synker IKKE: historik (`sessions/`, `projects/`, `history.jsonl`), caches, maskine-specifik `settings.json`, SSH-nøgler.

**Installer chezmoi (begge maskiner):**
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
```

**Førstegangsopsætning — kør på maskinen DER HAR config'en (sandheden):**
```sh
chezmoi init
for p in CLAUDE.md keybindings.json skills commands agents; do
  [ -e "$HOME/.claude/$p" ] && chezmoi add --recursive "$HOME/.claude/$p"
done
# Opret privat repo 'dotfiles' på GitHub (tomt), så:
chezmoi cd
git add -A && git commit -m "Claude-config"
git branch -M main
git remote add origin git@github.com:mcfriis/dotfiles.git
git push -u origin main
exit
```

**Ny maskine — hent alt med én kommando:**
```sh
chezmoi init --apply git@github.com:mcfriis/dotfiles.git
```

**Daglig drift:**
```sh
chezmoi add ~/.claude/<fil>      # begynd at spore / opdatér en fil
chezmoi cd && git commit -am "…" && git push && exit   # gem ændringer
chezmoi update                   # hent nyeste (git pull + apply)
```
---

## 8. Automatik — auto-commit/push + baggrunds-sync (launchd)

Så slipper man for at huske `chezmoi cd && git push` og `chezmoi update` manuelt.

> **Sker nu automatisk:** `run_once_setup-chezmoi-automation.sh.tmpl` (i dotfiles-repoet)
> sætter BÅDE `chezmoi.toml` OG launchd-agenten op ved `chezmoi init --apply` på en ny maskine
> — stierne udfyldes via `{{ "{{ .chezmoi.homeDir }}" }}`, så det virker uanset brugernavn.
> Afsnittet nedenfor er manuel reference / til fejlfinding.

**1) Auto-commit + auto-push** — chezmoi committer/pusher selv når man `add`'er eller editerer en sporet fil:
```sh
mkdir -p ~/.config/chezmoi
printf '[git]\n    autoCommit = true\n    autoPush = true\n' > ~/.config/chezmoi/chezmoi.toml
```

**2) launchd-agent** — kører `chezmoi update` (git pull + apply) ved login og hver 6. time.

> **Gotcha:** launchd-plists kan IKKE bruge `$HOME`/`~` i `ProgramArguments` — stierne er hardcodede.
> På en maskine med andet brugernavn end `perfriis`: erstat `/Users/perfriis/` med den maskines hjemmemappe.

Læg denne fil i `~/Library/LaunchAgents/com.friisconsult.chezmoi-update.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTD/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.friisconsult.chezmoi-update</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/perfriis/.local/bin/chezmoi</string>
        <string>update</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>21600</integer>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/perfriis/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/perfriis/Library/Logs/chezmoi-update.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/perfriis/Library/Logs/chezmoi-update.log</string>
</dict>
</plist>
```

Load og verificér:
```sh
plutil -lint ~/Library/LaunchAgents/com.friisconsult.chezmoi-update.plist   # syntakstjek
launchctl unload ~/Library/LaunchAgents/com.friisconsult.chezmoi-update.plist 2>/dev/null  # hvis allerede loaded
launchctl load   ~/Library/LaunchAgents/com.friisconsult.chezmoi-update.plist
launchctl list | grep chezmoi      # 2. kolonne = sidste exit-kode (0 = ok)
cat ~/Library/Logs/chezmoi-update.log   # "Already up to date." = virker
```
> Skift interval ved at ændre `StartInterval` (sekunder); fx `86400` for én gang i døgnet. Husk unload+load efter ændring.