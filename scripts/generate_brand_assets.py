#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def _resize_by_width(img: Image.Image, *, width: int) -> Image.Image:
    w, h = img.size
    if w == width:
        return img
    height = max(1, round(h * (width / w)))
    return img.resize((width, height), Image.Resampling.LANCZOS)


def _clamp(v: int, lo: int, hi: int) -> int:
    return lo if v < lo else hi if v > hi else v


def _autocrop_by_saturation(
    img: Image.Image,
    *,
    threshold: int,
    pad_ratio: float,
    force_square: bool,
) -> Image.Image:
    """
    Crop to the saturated (colorful) region (the gold S), then expand by pad_ratio
    to include the surrounding badge. This works well for these logo renders since
    the background is mostly desaturated gray.
    """
    rgb = img.convert("RGB")
    hsv = rgb.convert("HSV")
    s = hsv.getchannel("S")
    mask = s.point(lambda v: 255 if v > threshold else 0)
    bbox = mask.getbbox()
    if bbox is None:
        return img

    left, top, right, bottom = bbox
    bw = right - left
    bh = bottom - top
    pad = max(1, round(max(bw, bh) * pad_ratio))

    w, h = img.size
    left = _clamp(left - pad, 0, w)
    top = _clamp(top - pad, 0, h)
    right = _clamp(right + pad, 0, w)
    bottom = _clamp(bottom + pad, 0, h)

    if force_square:
        cw = right - left
        ch = bottom - top
        side = max(cw, ch)
        cx = (left + right) // 2
        cy = (top + bottom) // 2
        half = side // 2
        left = _clamp(cx - half, 0, w - side)
        top = _clamp(cy - half, 0, h - side)
        right = left + side
        bottom = top + side

    return img.crop((left, top, right, bottom))


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate Solidus brand assets for public/assets.")
    parser.add_argument(
        "--logo",
        type=Path,
        default=Path("/home/joao/Downloads/solidus_logo.png"),
        help="Path to solidus_logo.png (default: /home/joao/Downloads/solidus_logo.png)",
    )
    parser.add_argument(
        "--mark",
        type=Path,
        default=Path("/home/joao/Downloads/solidus_small_logo.png"),
        help="Path to solidus_small_logo.png (default: /home/joao/Downloads/solidus_small_logo.png)",
    )
    parser.add_argument("--outdir", type=Path, default=Path("public/assets"))
    parser.add_argument("--logo-width", type=int, default=720)
    parser.add_argument("--mark-size", type=int, default=64)
    args = parser.parse_args()

    outdir: Path = args.outdir
    outdir.mkdir(parents=True, exist_ok=True)

    logo_src: Path = args.logo
    mark_src: Path = args.mark

    if not logo_src.exists():
        raise SystemExit(f"Missing logo source: {logo_src}")
    if not mark_src.exists():
        raise SystemExit(f"Missing mark source: {mark_src}")

    # Regular logo: keep full canvas, just downscale for web usage.
    with Image.open(logo_src) as img:
        img = img.convert("RGBA")
        logo = _autocrop_by_saturation(img, threshold=40, pad_ratio=0.65, force_square=False)
        logo = _resize_by_width(logo, width=args.logo_width)
        logo.save(outdir / "solidus-logo.png", format="PNG", optimize=True)

    # Navbar mark: crop around the emblem and downscale to a small square.
    with Image.open(mark_src) as img:
        img = img.convert("RGBA")
        cropped = _autocrop_by_saturation(img, threshold=55, pad_ratio=1.25, force_square=True)
        mark = cropped.resize((args.mark_size, args.mark_size), Image.Resampling.LANCZOS)
        mark.save(outdir / "solidus-mark.png", format="PNG", optimize=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
