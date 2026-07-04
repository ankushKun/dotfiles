#!/bin/bash
set -e

# Register bundled MesloLGS NF fonts with CoreText (macOS 27 workaround).
# Fonts are stowed from dotfiles into ~/Library/Fonts via GNU Stow.
FONTS_DIR="$HOME/Library/Fonts"
REGISTERED=0

for f in "$FONTS_DIR"/MesloLGS\ NF*.ttf; do
  if [ -f "$f" ]; then
    swift -e "
import Foundation
import CoreText
let url = URL(fileURLWithPath: \"$f\")
var err: Unmanaged<CFError>?
if CTFontManagerRegisterFontsForURL(url as CFURL, .session, &err) {
    print(\"Registered: $(basename "$f")\")
} else {
    let e = err?.takeRetainedValue() as! Error
    print(\"Skipped: $(basename "$f") - \\(e.localizedDescription)\")
}
" 2>/dev/null
    REGISTERED=$((REGISTERED + 1))
  fi
done

echo "Done. Registered $REGISTERED MesloLGS NF fonts."
