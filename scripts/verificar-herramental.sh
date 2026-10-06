#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# ¿Está listo el entorno de Claude Code en esta máquina?
#
# Genérico: sirve en cualquier repositorio. No lee ningún archivo del
# proyecto, así que se puede copiar tal cual a otro repo — o correr suelto.
#
# Revisa por NOMBRE, no por conteo: si falta algo, dice cuál y con qué
# comando se instala.
#
# Personalizar sin editar el archivo:
#   PLUGINS_ESPERADOS="superpowers context7" bash verificar-herramental.sh
#   AGENTES_MINIMOS=0 bash verificar-herramental.sh
# ─────────────────────────────────────────────────────────────────────

PLUGINS_ESPERADOS="${PLUGINS_ESPERADOS-the-architect ui-ux-pro-max superpowers frontend-design playwright ralph-loop context7 marketing-skills claude-seo-ai claude-ads}"
AGENTES_MINIMOS="${AGENTES_MINIMOS-273}"

# Marketplace y comando de instalación de cada plugin, por si falta.
marketplace_de() {
  case "$1" in
    the-architect)    echo "Hainrixz/the-architect" ;;
    ui-ux-pro-max)    echo "nextlevelbuilder/ui-ux-pro-max-skill" ;;
    marketing-skills) echo "coreyhaines31/marketingskills" ;;
    claude-seo-ai)    echo "Hainrixz/claude-seo-ai" ;;
    claude-ads)       echo "Hainrixz/claude-ads" ;;
    *)                echo "anthropics/claude-plugins-official" ;;
  esac
}
instalar_de() {
  case "$1" in
    the-architect)    echo "claude plugin install the-architect@soyenriquerocha" ;;
    ui-ux-pro-max)    echo "claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill" ;;
    marketing-skills) echo "claude plugin install marketing-skills@marketingskills" ;;
    claude-seo-ai)    echo "claude plugin install claude-seo-ai@claude-seo-ai" ;;
    claude-ads)       echo "claude plugin install claude-ads@tododeia-claude-ads" ;;
    *)                echo "claude plugin install $1@claude-plugins-official" ;;
  esac
}

# Fuente de verdad: el registro en disco. El formato de `claude plugin list`
# es texto de interfaz y ha cambiado (usa ❯, no >); parsearlo es frágil.
REGISTRO="$HOME/.claude/plugins/installed_plugins.json"
instalados=""
origen=""

if [ -f "$REGISTRO" ]; then
  instalados=$(python3 -c '
import json,sys
try:
    d=json.load(open(sys.argv[1]))
    for k in d.get("plugins",{}): print(k.split("@")[0])
except Exception: pass
' "$REGISTRO" 2>/dev/null)
  origen="registro"
fi

# Respaldo: el CLI, tolerando tanto ❯ como > por si cambia otra vez.
if [ -z "$instalados" ] && command -v claude >/dev/null 2>&1; then
  # Sin clase de caracteres: '❯' ocupa 3 bytes en UTF-8 y sed lo trataría
  # byte a byte. Se descarta cualquier prefijo no alfanumérico.
  instalados=$(claude plugin list 2>/dev/null \
    | sed -n 's/^[^A-Za-z0-9]*\([A-Za-z0-9._-]*\)@.*/\1/p')
  origen="cli"
fi

echo "── Entorno de Claude Code ─────────────────────────"

# Sin ninguna de las dos fuentes no se puede afirmar nada. Callar es mejor
# que reportar diez falsos negativos.
if [ -z "$instalados" ]; then
  echo "  No se pudo leer el estado de los plugins."
  if [ ! -f "$REGISTRO" ]; then
    echo "    · No existe $REGISTRO"
  fi
  if ! command -v claude >/dev/null 2>&1; then
    echo "    · El comando 'claude' no está en el PATH"
    echo "      npm install -g @anthropic-ai/claude-code"
  fi
  echo "  Sin datos: no se listan plugins como faltantes."
  echo "───────────────────────────────────────────────────"
  exit 2
fi

faltantes=""
ok=0; total=0

for p in $PLUGINS_ESPERADOS; do
  total=$((total+1))
  if echo "$instalados" | grep -qx "$p"; then
    printf "  %-18s OK\n" "$p"; ok=$((ok+1))
  else
    printf "  %-18s FALTA\n" "$p"; faltantes="$faltantes $p"
  fi
done
printf "  %-18s %s de %s (vía %s)\n" "plugins" "$ok" "$total" "$origen"

n_agentes=$(ls "$HOME"/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$n_agentes" -ge "$AGENTES_MINIMOS" ]; then
  printf "  %-18s OK (%s)\n" "agentes" "$n_agentes"
else
  printf "  %-18s FALTAN (%s de %s)\n" "agentes" "$n_agentes" "$AGENTES_MINIMOS"
  faltantes="$faltantes agentes"
fi

if command -v graphify >/dev/null 2>&1; then
  printf "  %-18s OK\n" "graphify"
else
  printf "  %-18s FALTA\n" "graphify"; faltantes="$faltantes graphify"
fi

VENV_SCRAPLING="${VENV_SCRAPLING-$HOME/.venvs/scrapling}"
if "$VENV_SCRAPLING/bin/python" -c "import scrapling" 2>/dev/null; then
  printf "  %-18s OK (venv)\n" "scrapling"
elif python3 -c "import scrapling" 2>/dev/null; then
  printf "  %-18s OK (sistema)\n" "scrapling"
else
  printf "  %-18s falta (opcional)\n" "scrapling"
fi
echo "───────────────────────────────────────────────────"

if [ -z "$faltantes" ]; then
  echo "Todo listo, se puede trabajar."
  exit 0
fi

echo "Falta instalar. Pega esto:"
echo

# Los marketplaces van primero, cada uno una sola vez.
vistos=" "
for f in $faltantes; do
  case "$f" in agentes|graphify) continue ;; esac
  m=$(marketplace_de "$f")
  case "$vistos" in
    *" $m "*) ;;
    *) echo "claude plugin marketplace add $m"; vistos="$vistos$m " ;;
  esac
done

for f in $faltantes; do
  case "$f" in
    agentes)  ;;
    graphify) ;;
    *) instalar_de "$f" ;;
  esac
done

for f in $faltantes; do
  case "$f" in
    agentes)
      echo "git clone https://github.com/msitarzewski/agency-agents.git /tmp/agency-agents"
      echo "(cd /tmp/agency-agents && ./scripts/install.sh --tool claude-code --no-interactive)" ;;
    graphify)
      echo "uv tool install --with tree-sitter-sql graphifyy && graphify install" ;;
  esac
done
exit 1
