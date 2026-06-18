from __future__ import annotations

import re
from pathlib import Path

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
OUTPUT = DOCS / "assets" / "T3DBarGraph-Manual.pdf"

PAGES = [
    ("Overview", DOCS / "index.md"),
    ("Getting Started", DOCS / "getting-started.md"),
    ("Basic Usage", DOCS / "basic-usage.md"),
    ("API Reference", DOCS / "api.md"),
    ("Interaction", DOCS / "interaction.md"),
    ("Performance", DOCS / "performance.md"),
    ("Releases", DOCS / "releases.md"),
    ("Roadmap", DOCS / "roadmap.md"),
    ("Contributing", DOCS / "contributing.md"),
]


def inline_markdown_to_html(text: str) -> str:
    text = re.sub(r"`([^`]+)`", r"<font name='Courier'>\1</font>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)(\{[^}]+\})?", r"\1", text)
    return text


def markdown_blocks(path: Path) -> list[tuple[str, str]]:
    blocks: list[tuple[str, str]] = []
    in_code = False

    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()

        if line.startswith("```"):
            in_code = not in_code
            continue

        if in_code:
            if line:
                blocks.append(("Code", line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")))
            continue

        if not line or line.startswith("!["):
            continue

        heading = re.match(r"^(#{1,3})\s+(.*)$", line)
        if heading:
            level = len(heading.group(1))
            text = inline_markdown_to_html(heading.group(2))
            blocks.append((f"Heading{level}", text))
            continue

        bullet = re.match(r"^-\s+(.*)$", line)
        if bullet:
            blocks.append(("Bullet", inline_markdown_to_html("&bull; " + bullet.group(1))))
            continue

        numbered = re.match(r"^\d+\.\s+(.*)$", line)
        if numbered:
            blocks.append(("Bullet", inline_markdown_to_html("&bull; " + numbered.group(1))))
            continue

        blocks.append(("BodyText", inline_markdown_to_html(line)))

    return blocks


def build_pdf() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    styles = getSampleStyleSheet()
    story = []

    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=letter,
        rightMargin=0.7 * inch,
        leftMargin=0.7 * inch,
        topMargin=0.7 * inch,
        bottomMargin=0.7 * inch,
        title="T3DBarGraph Manual",
        author="gcanedo/T3DBarGraph",
    )

    story.append(Paragraph("T3DBarGraph Manual", styles["Title"]))
    story.append(Paragraph("Delphi FireMonkey 3D Bar Charts", styles["Heading2"]))
    story.append(Spacer(1, 0.25 * inch))

    for page_title, page_path in PAGES:
        story.append(Paragraph(page_title, styles["Heading1"]))
        story.append(Spacer(1, 0.08 * inch))

        for style_name, text in markdown_blocks(page_path):
            style = styles.get(style_name, styles["BodyText"])
            story.append(Paragraph(text, style))
            story.append(Spacer(1, 0.04 * inch))

        story.append(Spacer(1, 0.18 * inch))

    doc.build(story)


if __name__ == "__main__":
    build_pdf()
