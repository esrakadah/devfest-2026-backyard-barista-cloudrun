"""Combine build/slides/*.png (from tool/export_slides_test.dart) into one PDF backup deck.

Run from slides/:  python3 tool/pngs_to_pdf.py
Needs Pillow (pip install pillow).
"""
import pathlib
import sys

from PIL import Image

SLIDES_DIR = pathlib.Path("build/slides")
OUTPUT = SLIDES_DIR / "backyard_barista_deck.pdf"


def main() -> int:
    pages = sorted(SLIDES_DIR.glob("[0-9][0-9]_*.png"))
    if not pages:
        print("No PNGs found. Run: flutter test tool/export_slides_test.dart", file=sys.stderr)
        return 1
    images = [Image.open(page).convert("RGB") for page in pages]
    images[0].save(OUTPUT, save_all=True, append_images=images[1:], resolution=144)
    print(f"Wrote {OUTPUT} ({len(images)} pages)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
