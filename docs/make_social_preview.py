"""
Generate the GitHub social preview image for NeuroAnalyzerLab_MATLAB.
Output: docs/social-preview.png  (1280x640, what GitHub recommends)

Palette is taken from core/UITheme.m so the card matches the app:
  headerBg  = [0.18 0.28 0.48]
  accent    = [0.20 0.55 0.60]
  subtitle  = [0.88 0.92 0.96]
  muted     = [0.50 0.52 0.58]
"""

from PIL import Image, ImageDraw, ImageFont
import math
from pathlib import Path

OUT = Path(__file__).resolve().parent / 'social-preview.png'
W, H = 1280, 640

HEADER_BG   = (46, 71, 122)        # T.headerBg
HEADER_BG_2 = (28, 44, 80)         # darker variant for depth
ACCENT      = (51, 140, 153)       # T.accent (teal)
ACCENT_SOFT = (90, 175, 188)
WHITE       = (255, 255, 255)
SUBTITLE    = (224, 235, 245)      # T.headerSubtitleColor
MUTED       = (180, 188, 205)
PILL_BG     = (32, 100, 110)


def load_font(size, bold=False):
    candidates = [
        '/System/Library/Fonts/Supplemental/Helvetica.ttc',
        '/System/Library/Fonts/Helvetica.ttc',
        '/Library/Fonts/Arial.ttf',
        '/System/Library/Fonts/Supplemental/Arial.ttf',
        '/System/Library/Fonts/Avenir.ttc',
    ]
    for path in candidates:
        if Path(path).exists():
            try:
                idx = 1 if (bold and path.endswith('.ttc')) else 0
                return ImageFont.truetype(path, size, index=idx)
            except Exception:
                continue
    return ImageFont.load_default()


def vertical_gradient(img, top_color, bottom_color):
    draw = ImageDraw.Draw(img)
    for y in range(img.height):
        t = y / max(1, img.height - 1)
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        draw.line([(0, y), (img.width, y)], fill=(r, g, b))


def waveforms(img, x0, y0, w, h):
    """Three layered sine-like traces in the right half — implies signal analysis."""
    draw = ImageDraw.Draw(img, 'RGBA')

    def trace(amp, freq, phase, color, width):
        pts = []
        for x in range(0, w, 2):
            y = y0 + h / 2 + amp * math.sin(2 * math.pi * freq * x / w + phase)
            pts.append((x0 + x, int(y)))
        draw.line(pts, fill=color, width=width)

    trace(amp=h * 0.18, freq=2.2, phase=0.0,        color=ACCENT      + (220,), width=3)
    trace(amp=h * 0.32, freq=1.4, phase=1.1,        color=ACCENT_SOFT + (180,), width=3)
    trace(amp=h * 0.10, freq=3.6, phase=2.2,        color=WHITE       + (140,), width=2)


def pill(draw, x, y, text, font, fill, text_color):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    pad_x, pad_y = 18, 8
    box = (x, y, x + tw + 2 * pad_x, y + th + 2 * pad_y)
    draw.rounded_rectangle(box, radius=(box[3] - box[1]) // 2, fill=fill)
    draw.text((x + pad_x, y + pad_y - bbox[1]), text, font=font, fill=text_color)
    return box[2] - box[0], box[3] - box[1]


def main():
    img = Image.new('RGB', (W, H), HEADER_BG)
    vertical_gradient(img, HEADER_BG, HEADER_BG_2)

    # Right-side waveform graphic
    waveforms(img, x0=int(W * 0.55), y0=int(H * 0.18), w=int(W * 0.40), h=int(H * 0.62))

    draw = ImageDraw.Draw(img)

    # Accent stripe on the left edge
    draw.rectangle([0, 0, 8, H], fill=ACCENT)

    # Typography
    f_title    = load_font(76, bold=True)
    f_tagline  = load_font(34)
    f_sub      = load_font(24)
    f_pill     = load_font(22, bold=True)
    f_footer   = load_font(20)

    margin_x = 70
    y = 110

    # Title (app name, not repo name)
    draw.text((margin_x, y), 'Neuronal Data', font=f_title, fill=WHITE)
    y += 88
    draw.text((margin_x, y), 'Analyzer Lab', font=f_title, fill=ACCENT_SOFT)
    y += 110

    # Tagline
    draw.text((margin_x, y), 'Neuroscience analysis toolbox', font=f_tagline, fill=WHITE)
    y += 56

    # Sub-tagline
    draw.text((margin_x, y), 'Laser Doppler Flowmetry  ·  Electrophysiology', font=f_sub, fill=SUBTITLE)
    y += 32
    draw.text((margin_x, y), 'Imaging  ·  Signal Characterization', font=f_sub, fill=SUBTITLE)

    # Version pill (top-right)
    pill(draw, W - 170, 60, 'v0.1.0', f_pill, fill=PILL_BG, text_color=WHITE)

    # Footer URL (bottom)
    draw.text((margin_x, H - 60), 'github.com/alesuarez92/NeuronalDataAnalyzerLab', font=f_footer, fill=MUTED)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, 'PNG', optimize=True)
    print(f'wrote {OUT} ({W}x{H})')


if __name__ == '__main__':
    main()
