#!/usr/bin/env bash
# Instala packs de rem-ai (agentes, reglas y skills) en un proyecto o en ~/.claude.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKS_DIR="$REPO_ROOT/packs"

usage() {
  cat <<EOF
Uso:
  $(basename "$0") [opciones] <directorio-proyecto> <pack>...
  $(basename "$0") [opciones] --global <pack>...
  $(basename "$0") --list

Instala los packs indicados en <directorio-proyecto>/.claude (o en ~/.claude con --global):
  agents/*.md      -> .claude/agents/
  rules/**/*.md    -> .claude/rules/<pack>/
  skills/<name>/   -> .claude/skills/<name>/

Opciones:
  --global   Instala en ~/.claude (disponible en todos los proyectos).
  --link     Crea enlaces simbólicos en lugar de copiar (se actualizan con git pull).
  --force    Sobrescribe ficheros existentes.
  --list     Lista los packs disponibles.
  -h, --help Muestra esta ayuda.
EOF
}

list_packs() {
  local pack
  for pack in "$PACKS_DIR"/*/; do
    pack="$(basename "$pack")"
    printf '  %-16s agentes: %-2s reglas: %-2s skills: %s\n' "$pack" \
      "$(find "$PACKS_DIR/$pack/agents" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')" \
      "$(find "$PACKS_DIR/$pack/rules" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')" \
      "$(find "$PACKS_DIR/$pack/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
  done
}

GLOBAL=0
LINK=0
FORCE=0
TARGET=""
PACKS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) GLOBAL=1 ;;
    --link)   LINK=1 ;;
    --force)  FORCE=1 ;;
    --list)   echo "Packs disponibles:"; list_packs; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Opción desconocida: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [[ $GLOBAL -eq 0 && -z "$TARGET" ]]; then
        TARGET="$1"
      else
        PACKS+=("$1")
      fi
      ;;
  esac
  shift
done

if [[ $GLOBAL -eq 1 ]]; then
  if [[ -n "$TARGET" ]]; then
    # Con --global el primer argumento posicional también es un pack.
    PACKS=("$TARGET" ${PACKS[@]+"${PACKS[@]}"})
  fi
  DEST="$HOME/.claude"
else
  if [[ -z "$TARGET" ]]; then
    echo "Falta el directorio del proyecto." >&2; usage >&2; exit 1
  fi
  if [[ ! -d "$TARGET" ]]; then
    echo "El directorio no existe: $TARGET" >&2; exit 1
  fi
  DEST="$(cd "$TARGET" && pwd)/.claude"
fi

if [[ ${#PACKS[@]} -eq 0 ]]; then
  echo "Indica al menos un pack. Disponibles:" >&2; list_packs >&2; exit 1
fi

for pack in "${PACKS[@]}"; do
  if [[ ! -d "$PACKS_DIR/$pack" ]]; then
    echo "Pack desconocido: $pack. Disponibles:" >&2; list_packs >&2; exit 1
  fi
done

installed=0
skipped=0

# install_item <origen> <destino>: copia o enlaza un fichero o directorio.
install_item() {
  local src="$1" dst="$2"
  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      return 0  # Ya enlazado al mismo origen.
    fi
    if [[ $LINK -eq 0 && ! -L "$dst" ]] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
      return 0  # Copia ya actualizada.
    fi
    if [[ $FORCE -eq 0 ]]; then
      echo "  omitido (ya existe, usa --force): ${dst#"$DEST"/}"
      skipped=$((skipped + 1))
      return 0
    fi
    rm -rf "$dst"
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ $LINK -eq 1 ]]; then
    ln -s "$src" "$dst"
  else
    cp -R "$src" "$dst"
  fi
  echo "  + ${dst#"$DEST"/}"
  installed=$((installed + 1))
}

echo "Instalando en $DEST"
for pack in "${PACKS[@]}"; do
  echo "[$pack]"
  pack_dir="$PACKS_DIR/$pack"

  if [[ -d "$pack_dir/agents" ]]; then
    while IFS= read -r -d '' file; do
      install_item "$file" "$DEST/agents/$(basename "$file")"
    done < <(find "$pack_dir/agents" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
  fi

  if [[ -d "$pack_dir/rules" ]]; then
    while IFS= read -r -d '' file; do
      install_item "$file" "$DEST/rules/$pack/${file#"$pack_dir/rules/"}"
    done < <(find "$pack_dir/rules" -type f -name '*.md' -print0 | sort -z)
  fi

  if [[ -d "$pack_dir/skills" ]]; then
    while IFS= read -r -d '' dir; do
      install_item "$dir" "$DEST/skills/$(basename "$dir")"
    done < <(find "$pack_dir/skills" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  fi
done

echo "Hecho: $installed instalados, $skipped omitidos."
