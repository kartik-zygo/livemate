# -*- coding: utf-8 -*-
"""Renders the Livemate launcher icons from the same geometry as the SVG mark.

The mark lives in assets/brand/livemate_mark.svg and is authoritative for
in-app use. There is no SVG rasteriser on this toolchain, so the launcher
icons are drawn here from the identical 512-unit coordinate system. If the SVG
changes, change the coordinates below to match.

Run:  python tool/brand/generate_brand_assets.py
Then: dart run flutter_launcher_icons
"""

import os

from PIL import Image, ImageDraw

OUT = os.path.join('assets', 'brand')

ORANGE = (249, 115, 22, 255)      # brand500
ORANGE_DEEP = (234, 88, 12, 255)  # brand600
ORANGE_LIGHT = (251, 146, 60, 255)
INK = (31, 22, 19, 255)           # ink950
WHITE = (255, 255, 255, 255)

# Supersample, then downsample: ImageDraw has no anti-aliasing of its own.
SS = 4
SIZE = 1024


def s(v, canvas):
    """512-unit design coordinate -> pixel on a `canvas`-wide bitmap."""
    return v * canvas / 512.0


def draw_mark(draw, canvas, house_color, figure_left, figure_right, window_color):
    """Draws the mark on a canvas-sized square. Coordinates match the SVG."""

    def p(*xy):
        return [s(v, canvas) for v in xy]

    def circle(cx, cy, r, fill):
        x, y, rr = s(cx, canvas), s(cy, canvas), s(r, canvas)
        draw.ellipse([x - rr, y - rr, x + rr, y + rr], fill=fill)

    def rrect(x, y, w, h, r, fill):
        draw.rounded_rectangle(
            p(x, y, x + w, y + h), radius=s(r, canvas), fill=fill
        )

    # House outline: apex, eaves, walls, floor — a closed stroked polygon.
    house = [(256, 66), (444, 202), (444, 424), (68, 424), (68, 202)]
    pts = [(s(x, canvas), s(y, canvas)) for x, y in house]
    draw.line(pts + [pts[0]], fill=house_color, width=int(s(38, canvas)),
              joint='curve')
    # `joint='curve'` rounds the interior joins but not the ends, so cap the
    # vertices by hand or the roof apex comes out mitred and sharp.
    cap = s(38, canvas) / 2.0
    for x, y in pts:
        draw.ellipse([x - cap, y - cap, x + cap, y + cap], fill=house_color)

    # Four-pane window, upper left.
    for wx in (132, 174):
        for wy in (186, 228):
            rrect(wx, wy, 30, 30, 8, window_color)

    # Left figure.
    circle(170, 294, 30, figure_left)
    rrect(139, 344, 62, 60, 31, figure_left)
    draw.rectangle(p(139, 380, 201, 404), fill=figure_left)

    # Right figure.
    circle(338, 282, 32, figure_right)
    rrect(305, 338, 66, 66, 33, figure_right)
    draw.rectangle(p(305, 375, 371, 404), fill=figure_right)

    # The clasp — one arm each, meeting in the middle.
    arm = int(s(24, canvas))
    for (x1, y1, x2, y2), colour in (
        ((196, 360, 256, 390), figure_left),
        ((256, 390, 316, 352), figure_right),
    ):
        draw.line(p(x1, y1, x2, y2), fill=colour, width=arm)
        r = arm / 2.0
        for x, y in ((s(x1, canvas), s(y1, canvas)), (s(x2, canvas), s(y2, canvas))):
            draw.ellipse([x - r, y - r, x + r, y + r], fill=colour)


def orange_gradient(size):
    """The brand gradient, top-left light to bottom-right deep."""
    # A linear ramp survives bilinear upscaling exactly, so build it at 64px
    # and resize rather than looping over 16 million pixels.
    n = 64
    small = Image.new('RGBA', (n, n))
    px = small.load()
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2.0 * (n - 1))
            px[x, y] = tuple(
                int(round(ORANGE_LIGHT[i] + (ORANGE_DEEP[i] - ORANGE_LIGHT[i]) * t))
                for i in range(3)
            ) + (255,)
    return small.resize((size, size), Image.BILINEAR)


def render(name, build):
    canvas = SIZE * SS
    img = build(canvas)
    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    path = os.path.join(OUT, name)
    img.save(path)
    print('wrote', path)


def main():
    os.makedirs(OUT, exist_ok=True)

    # 1. The mark alone, in brand colours, on transparency — for docs and any
    #    place that wants a raster of the logo.
    def mark(canvas):
        img = Image.new('RGBA', (canvas, canvas), (0, 0, 0, 0))
        draw_mark(ImageDraw.Draw(img), canvas, ORANGE, ORANGE, INK, ORANGE)
        return img

    render('livemate_mark.png', mark)

    # 2. The launcher icon: white mark on the brand gradient, matching the app
    #    icon on the brand sheet.
    def icon(canvas):
        img = orange_gradient(canvas)
        draw_mark(ImageDraw.Draw(img), canvas, WHITE, WHITE, WHITE, ORANGE_DEEP)
        return img

    render('icon.png', icon)

    # 3. Android adaptive layers.
    #
    #    The generated adaptive-icon XML already insets the foreground by 16%,
    #    which is what puts the mark inside the 66dp safe zone of the 108dp
    #    canvas. So this layer must be full-bleed, not pre-inset, or the two
    #    insets compound and the mark ends up tiny in the launcher.
    #
    #    The mark carries its own margin — the house spans about 81% of its
    #    coordinate space — so it is drawn oversized and centre-cropped to
    #    bring the house out toward the edges: 0.81 x 1.12 x 0.68 ~= 0.62,
    #    just inside the 66% safe zone.
    def foreground(canvas):
        img = Image.new('RGBA', (canvas, canvas), (0, 0, 0, 0))
        inner = int(canvas * 1.12)
        layer = Image.new('RGBA', (inner, inner), (0, 0, 0, 0))
        draw_mark(ImageDraw.Draw(layer), inner, WHITE, WHITE, WHITE, ORANGE_DEEP)
        img.paste(layer, ((canvas - inner) // 2, (canvas - inner) // 2), layer)
        return img

    render('icon_foreground.png', foreground)
    render('icon_background.png', orange_gradient)


if __name__ == '__main__':
    main()
