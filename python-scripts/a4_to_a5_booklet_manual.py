#!/usr/bin/env python3
"""Create A4 landscape, A5 booklet imposition PDFs for manual duplex printing.

The source PDF must be in normal reading order. The script creates:
  <prefix>-fronts.pdf
  <prefix>-backs-same.pdf
  <prefix>-backs-reverse.pdf
  <prefix>-backs-same-rotated.pdf
  <prefix>-backs-reverse-rotated.pdf

Print all fronts, reload the whole stack without rearranging individual sheets,
then choose the back file that matches the printer's stack and feed behaviour.

Usage:
    python a4_to_a5_booklet_manual.py input.pdf output/booklet

"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable

from pypdf import PdfReader, PdfWriter, Transformation
from pypdf._page import PageObject

A4_PORTRAIT_W = 595.2756
A4_PORTRAIT_H = 841.8898
A4_LANDSCAPE_W = A4_PORTRAIT_H
A4_LANDSCAPE_H = A4_PORTRAIT_W
A5_SLOT_W = A4_LANDSCAPE_W / 2
A5_SLOT_H = A4_LANDSCAPE_H


def normalize_rotation(page: PageObject) -> None:
    if getattr(page, "rotation", 0):
        transfer = getattr(page, "transfer_rotation_to_content", None)
        if callable(transfer):
            transfer()


def place_page(sheet: PageObject, source: PageObject | None, slot: int) -> None:
    if source is None:
        return

    normalize_rotation(source)
    src_w = float(source.mediabox.width)
    src_h = float(source.mediabox.height)
    if src_w <= 0 or src_h <= 0:
        raise ValueError("Encountered a page with an invalid media box.")

    scale = min(A5_SLOT_W / src_w, A5_SLOT_H / src_h)
    rendered_w = src_w * scale
    rendered_h = src_h * scale
    x = slot * A5_SLOT_W + (A5_SLOT_W - rendered_w) / 2
    y = (A5_SLOT_H - rendered_h) / 2
    sheet.merge_transformed_page(
        source,
        Transformation().scale(scale, scale).translate(x, y),
        over=True,
    )


def rotate_sheet_180(page: PageObject) -> PageObject:
    """Return a new landscape sheet with page content rotated 180 degrees."""
    out = PageObject.create_blank_page(width=A4_LANDSCAPE_W, height=A4_LANDSCAPE_H)
    transform = (
        Transformation()
        .rotate(180)
        .translate(A4_LANDSCAPE_W, A4_LANDSCAPE_H)
    )
    out.merge_transformed_page(page, transform, over=True)
    return out


def make_side(left: PageObject | None, right: PageObject | None) -> PageObject:
    side = PageObject.create_blank_page(width=A4_LANDSCAPE_W, height=A4_LANDSCAPE_H)
    place_page(side, left, 0)
    place_page(side, right, 1)
    return side


def write_pdf(path: Path, pages: Iterable[PageObject]) -> None:
    writer = PdfWriter()
    for page in pages:
        writer.add_page(page)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handle:
        writer.write(handle)


def impose_manual(input_path: Path, prefix: Path) -> tuple[int, int, int, list[Path]]:
    reader = PdfReader(str(input_path))
    original_count = len(reader.pages)
    if original_count == 0:
        raise ValueError("The input PDF has no pages.")

    padded_count = ((original_count + 3) // 4) * 4
    pages: list[PageObject | None] = list(reader.pages)
    pages.extend([None] * (padded_count - original_count))
    sheet_count = padded_count // 4

    fronts: list[PageObject] = []
    backs: list[PageObject] = []

    # Physical sheets are generated outside to inside.
    # 8 pages:
    # sheet 1 front 8|1, back 2|7
    # sheet 2 front 6|3, back 4|5
    for i in range(sheet_count):
        fronts.append(make_side(
            pages[padded_count - 2 * i - 1],
            pages[2 * i],
        ))
        backs.append(make_side(
            pages[2 * i + 1],
            pages[padded_count - 2 * i - 2],
        ))

    outputs = [
        prefix.with_name(prefix.name + "-fronts.pdf"),
        prefix.with_name(prefix.name + "-backs-same.pdf"),
        prefix.with_name(prefix.name + "-backs-reverse.pdf"),
        prefix.with_name(prefix.name + "-backs-same-rotated.pdf"),
        prefix.with_name(prefix.name + "-backs-reverse-rotated.pdf"),
    ]

    write_pdf(outputs[0], fronts)
    write_pdf(outputs[1], backs)
    write_pdf(outputs[2], reversed(backs))
    write_pdf(outputs[3], (rotate_sheet_180(p) for p in backs))
    write_pdf(outputs[4], (rotate_sheet_180(p) for p in reversed(backs)))

    return original_count, padded_count, sheet_count, outputs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Create separate front/back PDFs for manual-duplex A5 booklets."
    )
    parser.add_argument("input", type=Path, help="Source PDF in reading order")
    parser.add_argument(
        "prefix",
        type=Path,
        help="Output path prefix, e.g. out/notes-booklet",
    )
    args = parser.parse_args()

    if not args.input.is_file():
        parser.error(f"Input file not found: {args.input}")

    original, padded, sheets, outputs = impose_manual(args.input, args.prefix)
    print(f"Source pages: {original}")
    print(f"Physical sheets: {sheets}")
    print(f"Blank booklet pages added: {padded - original}")
    print("Created:")
    for output in outputs:
        print(f"  {output}")
    print("\nFirst pass: print -fronts.pdf in normal order.")
    print("Second pass: reload the entire stack without rearranging sheets.")
    print("Use the calibration instructions to select same/reverse and rotated/not rotated.")


if __name__ == "__main__":
    main()
