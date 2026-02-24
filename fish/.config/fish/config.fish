# -----------------------------------------------------------------
# 1️⃣  Prüfen, ob `eza` installiert ist
# -----------------------------------------------------------------
if type -q eza
    # `eza` ist im PATH → Alias setzen
    # Hinweis: `abbr` erzeugt ein echtes Kürzel, das erst beim Drücken von <Space>/<Enter> expandiert.
    # Wenn du lieber ein klassisches Shell‑Alias willst, nutze `function`:
    #
    #   function ls
    #       eza -la --group-directories-first $argv
    #   end
    #
    # Hier verwenden wir `abbr`, weil es in Fish sehr leichtgewichtig ist.
    abbr ls 'eza -la --group-directories-first'
    abbr lt 'eza --tree --level=2 --long --icons --git'
    abbr ltt 'eza --tree --level=3 --long --icons --git'
else
    # Optional: falls `eza` fehlt, kannst du hier ein Fallback‑Alias setzen,
    # z. B. `abbr ls 'ls -la'` – oder einfach nichts tun.
    abbr ls 'ls -la --color=auto'
    abbr grep 'grep --color=auto'
end

# -----------------------------------------------------------------
# 2️⃣  Starship‑Prompt aktivieren
# -----------------------------------------------------------------

if type -q starship
    # Starship initialisieren – das fügt die nötigen Funktionen und Prompt‑Hooks ein.
    starship init fish | source
else
    # Falls Starship nicht installiert ist, könntest du hier einen Hinweis ausgeben:
    echo "Starship nicht gefunden – bitte installieren: https://starship.rs"
end

# -----------------------------------------------------------------
# Farbige Ausgaben erzeugen
# -----------------------------------------------------------------

function ip
    if test (count $argv) -eq 0
        command grc ip address
    else
        command ip $argv
    end
end


# -----------------------------------------------------------------
# Weitere Abkürzungen
# -----------------------------------------------------------------

abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr home 'cd $HOME'

