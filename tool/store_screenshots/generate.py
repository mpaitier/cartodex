"""Génère les visuels de présentation de Cartodex, dans le style des fiches Play Store.

Chaque capture brute (docs/screenshots/raw), obligatoirement une vraie capture de l'app, est placée dans un cadre de téléphone,
sur un fond en dégradé, sous un titre et un sous-titre. Le script produit aussi
une bannière 1280 x 640, utilisable en tête du README et comme aperçu social
du dépôt GitHub.

Les textes, les couleurs et la liste des captures sont dans screens.json.

Usage (depuis la racine du dépôt) :
    python tool/store_screenshots/generate.py

Dépendance : Pillow (pip install pillow).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError:
    sys.exit("Pillow est introuvable. Installez-le avec : pip install pillow")

TOOL_DIR = Path(__file__).resolve().parent
ROOT = TOOL_DIR.parents[1]
FONT_BOLD = TOOL_DIR / "fonts" / "Inter-Bold.otf"
FONT_MEDIUM = TOOL_DIR / "fonts" / "Inter-Medium.otf"

BEZEL_COLOR = (18, 18, 22)
BEZEL_EDGE = (60, 60, 68)
SUBTITLE_ALPHA = 215


# --------------------------------------------------------------------------- #
# Outils de dessin
# --------------------------------------------------------------------------- #


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def vertical_gradient(size: tuple[int, int], top: str, bottom: str) -> Image.Image:
    """Dégradé vertical, légèrement incliné pour éviter un rendu trop plat."""
    width, height = size
    top_rgb, bottom_rgb = hex_to_rgb(top), hex_to_rgb(bottom)
    column = Image.new("RGB", (1, 256))
    for y in range(256):
        t = y / 255
        column.putpixel(
            (0, y),
            tuple(round(a + (b - a) * t) for a, b in zip(top_rgb, bottom_rgb)),
        )
    gradient = column.resize((width * 2, height * 2), Image.BICUBIC)
    gradient = gradient.rotate(-8, resample=Image.BICUBIC)
    left = (gradient.width - width) // 2
    upper = (gradient.height - height) // 2
    return gradient.crop((left, upper, left + width, upper + height))


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255
    )
    return mask


def load_font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def wrap_text(
    draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int
) -> list[str]:
    # Découpe sur l'espace simple uniquement : une espace insécable (\u00a0)
    # dans screens.json garde deux mots ensemble, comme « TCG Pocket ».
    words = text.split(" ")
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if draw.textlength(candidate, font=font) <= max_width or not current:
            current = candidate
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def wrap_balanced(
    draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int
) -> list[str]:
    """Comme wrap_text, mais répartit deux lignes de façon équilibrée.

    Évite le mot isolé sur la seconde ligne d'un titre.
    """
    lines = wrap_text(draw, text, font, max_width)
    if len(lines) != 2:
        return lines
    words = text.split(" ")
    best = lines
    best_width = max(draw.textlength(line, font=font) for line in lines)
    for cut in range(1, len(words)):
        candidate = [" ".join(words[:cut]), " ".join(words[cut:])]
        width = max(draw.textlength(line, font=font) for line in candidate)
        if width <= max_width and width < best_width:
            best, best_width = candidate, width
    return best


def draw_centered_lines(
    canvas: Image.Image,
    lines: list[str],
    font: ImageFont.FreeTypeFont,
    top: int,
    line_height: int,
    fill: tuple[int, int, int, int],
) -> int:
    """Dessine les lignes centrées et renvoie l'ordonnée sous la dernière ligne."""
    draw = ImageDraw.Draw(canvas)
    y = top
    for line in lines:
        width = draw.textlength(line, font=font)
        draw.text(((canvas.width - width) / 2, y), line, font=font, fill=fill)
        y += line_height
    return y


# --------------------------------------------------------------------------- #
# Téléphone
# --------------------------------------------------------------------------- #


def build_phone(raw_path: Path, screen_width: int) -> Image.Image:
    """Renvoie un téléphone (RGBA) contenant la capture, à la largeur d'écran demandée."""
    shot = Image.open(raw_path).convert("RGB")
    screen_height = round(screen_width * shot.height / shot.width)
    screen = shot.resize((screen_width, screen_height), Image.LANCZOS)

    bezel = max(10, screen_width // 34)
    screen_radius = screen_width // 11
    phone_size = (screen_width + bezel * 2, screen_height + bezel * 2)

    phone = Image.new("RGBA", phone_size, (0, 0, 0, 0))
    body = Image.new("RGBA", phone_size, BEZEL_COLOR + (255,))
    phone.paste(body, (0, 0), rounded_mask(phone_size, screen_radius + bezel))
    ImageDraw.Draw(phone).rounded_rectangle(
        (0, 0, phone_size[0] - 1, phone_size[1] - 1),
        radius=screen_radius + bezel,
        outline=BEZEL_EDGE + (255,),
        width=max(2, bezel // 5),
    )
    phone.paste(screen, (bezel, bezel), rounded_mask(screen.size, screen_radius))
    return phone


def paste_with_shadow(canvas: Image.Image, item: Image.Image, position: tuple[int, int]) -> None:
    blur = max(12, item.width // 18)
    offset = blur // 2
    shadow = Image.new("RGBA", (item.width + blur * 4, item.height + blur * 4), (0, 0, 0, 0))
    alpha = item.getchannel("A").point(lambda a: a * 0.55)
    shadow.paste((0, 0, 0, 255), (blur * 2, blur * 2), alpha)
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(
        shadow, (position[0] - blur * 2, position[1] - blur * 2 + offset)
    )
    canvas.alpha_composite(item, position)


# --------------------------------------------------------------------------- #
# Visuels
# --------------------------------------------------------------------------- #


def render_screen(entry: dict, config: dict, raw_dir: Path) -> Image.Image:
    width, height = config["size"]
    canvas = vertical_gradient((width, height), *config["background"]).convert("RGBA")
    draw = ImageDraw.Draw(canvas)
    margin = round(width * 0.08)

    title_font = load_font(FONT_BOLD, round(width * 0.074))
    subtitle_font = load_font(FONT_MEDIUM, round(width * 0.04))

    top = round(height * 0.065)
    title_lines = wrap_balanced(draw, entry["title"], title_font, width - margin * 2)
    y = draw_centered_lines(
        canvas, title_lines, title_font, top, round(title_font.size * 1.18), (255, 255, 255, 255)
    )

    accent = hex_to_rgb(config["accent"])
    bar_width = round(width * 0.09)
    bar_y = y + round(height * 0.012)
    draw.rounded_rectangle(
        ((width - bar_width) / 2, bar_y, (width + bar_width) / 2, bar_y + round(height * 0.005)),
        radius=4,
        fill=accent + (255,),
    )

    subtitle_lines = wrap_balanced(draw, entry["subtitle"], subtitle_font, width - margin * 2)
    y = draw_centered_lines(
        canvas,
        subtitle_lines,
        subtitle_font,
        bar_y + round(height * 0.025),
        round(subtitle_font.size * 1.35),
        (255, 255, 255, SUBTITLE_ALPHA),
    )

    # Le téléphone déborde en bas de l'image, comme sur la plupart des fiches Store.
    phone = build_phone(raw_dir / entry["raw"], round(width * 0.70))
    # Hauteur fixe pour que tous les téléphones de la série soient alignés,
    # sauf si le texte est trop long et descend plus bas.
    phone_top = max(round(height * 0.29), y + round(height * 0.03))
    paste_with_shadow(canvas, phone, ((width - phone.width) // 2, phone_top))
    return canvas.convert("RGB")


def render_banner(banner: dict, config: dict, raw_dir: Path) -> Image.Image:
    width, height = banner["size"]
    canvas = vertical_gradient((width, height), *config["background"]).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    left = round(width * 0.07)
    text_width = round(width * 0.40)
    title_font = load_font(FONT_BOLD, round(height * 0.17))
    subtitle_font = load_font(FONT_MEDIUM, round(height * 0.055))

    subtitle_lines = wrap_balanced(draw, banner["subtitle"], subtitle_font, text_width)
    block_height = (
        title_font.size * 1.1
        + height * 0.05
        + len(subtitle_lines) * subtitle_font.size * 1.35
    )
    y = (height - block_height) / 2

    draw.text((left, y), banner["title"], font=title_font, fill=(255, 255, 255, 255))
    y += title_font.size * 1.1 + height * 0.02
    accent = hex_to_rgb(config["accent"])
    draw.rounded_rectangle(
        (left + 4, y, left + 4 + width * 0.06, y + height * 0.012), radius=4, fill=accent + (255,)
    )
    y += height * 0.03
    for line in subtitle_lines:
        draw.text((left, y), line, font=subtitle_font, fill=(255, 255, 255, SUBTITLE_ALPHA))
        y += subtitle_font.size * 1.35

    # Jusqu'à trois téléphones en éventail. La première capture de la liste
    # est au centre, devant les deux autres.
    names = banner["screens"][:3]
    phone_width = round(height * 0.38)
    center_x = round(width * 0.76)
    # (capture, décalage horizontal en largeurs de téléphone, haut en fraction
    # de la hauteur, angle, échelle), dans l'ordre de dessin.
    placements = [(1, -0.62, 0.20, 8, 1.0), (2, 0.62, 0.20, -8, 1.0), (0, 0.0, 0.10, 0, 1.08)]
    for index, dx, dy, angle, scale in placements:
        if index >= len(names):
            continue
        phone = build_phone(raw_dir / names[index], round(phone_width * scale))
        rotated = phone.rotate(angle, resample=Image.BICUBIC, expand=True)
        x = round(center_x + dx * phone_width - rotated.width / 2)
        paste_with_shadow(canvas, rotated, (x, round(height * dy)))
    return canvas.convert("RGB")


def main() -> None:
    config_path = TOOL_DIR / "screens.json"
    config = json.loads(config_path.read_text(encoding="utf-8"))
    raw_dir = ROOT / config["raw_dir"]
    output_dir = ROOT / config["output_dir"]
    # Aucun visuel n'est généré tant qu'une capture manque : le README ne doit
    # montrer que de vraies captures de l'app.
    needed = [entry["raw"] for entry in config["screens"]]
    needed += config.get("banner", {}).get("screens", [])
    missing = sorted({name for name in needed if not (raw_dir / name).exists()})
    if missing:
        listed = "\n".join(f"  - {raw_dir.relative_to(ROOT) / name}" for name in missing)
        sys.exit(f"Captures manquantes, rien n'a été généré :\n{listed}")

    output_dir.mkdir(parents=True, exist_ok=True)

    for entry in config["screens"]:
        target = output_dir / entry["raw"]
        print(f"- {target.relative_to(ROOT)}")
        render_screen(entry, config, raw_dir).save(target, optimize=True)

    banner = config.get("banner")
    if banner:
        target = output_dir / banner["file"]
        print(f"- {target.relative_to(ROOT)}")
        render_banner(banner, config, raw_dir).save(target, optimize=True)

    print("Terminé.")


if __name__ == "__main__":
    main()
