"""Render a VCD file from build/ as a GTKWave-style PNG in docs/waveforms/.

Usage: python tools/plot_vcd.py counter dff_rst ...
"""
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent


def parse_vcd(path):
    signals, changes, t = {}, {}, 0
    in_defs, scope = True, []
    for line in path.read_text().splitlines():
        tok = line.split()
        if not tok:
            continue
        if in_defs:
            if tok[0] == "$scope":
                scope.append(tok[2])
            elif tok[0] == "$upscope":
                scope.pop()
            elif tok[0] == "$var" and len(scope) == 1:  # top-level testbench signals only
                width, code, name = int(tok[2]), tok[3], tok[4]
                if code not in signals:
                    signals[code] = (name, width)
                    changes[code] = []
            elif tok[0] == "$enddefinitions":
                in_defs = False
            continue
        s = tok[0]
        if s.startswith("#"):
            t = int(s[1:])
        elif s[0] in "bB" and len(tok) == 2:
            if tok[1] in changes:
                v = s[1:]
                changes[tok[1]].append((t, int(v, 2) if set(v) <= {"0", "1"} else None))
        elif s[0] in "01xXzZ" and s[1:] in changes:
            changes[s[1:]].append((t, int(s[0]) if s[0] in "01" else None))
    return signals, changes, t


def plot(name):
    signals, changes, t_end = parse_vcd(ROOT / "build" / f"{name}.vcd")
    rank = {"clk": 0, "rst": 1, "q": 9, "y": 9, "count": 9}  # clock first, outputs last
    order = sorted(signals, key=lambda c: rank.get(signals[c][0], 5))
    fig, ax = plt.subplots(figsize=(10, 0.75 * len(order) + 0.8))
    for i, code in enumerate(order):
        label, width = signals[code]
        y0 = (len(order) - 1 - i) * 1.5
        pts = changes[code] + [(t_end, changes[code][-1][1] if changes[code] else None)]
        if width == 1:
            xs, ys = [], []
            for (t, v), (t2, _) in zip(pts, pts[1:]):
                lvl = y0 + (0.9 if v == 1 else 0)
                xs += [t, t2]
                ys += [lvl, lvl]
            ax.plot(xs, ys, color="#1f9d55" if label != "clk" else "#2b6cb0", lw=1.6)
        else:
            for (t, v), (t2, _) in zip(pts, pts[1:]):
                if t2 <= t:
                    continue
                ax.fill([t, t + 0.6, t2 - 0.6, t2, t2 - 0.6, t + 0.6],
                        [y0 + 0.45, y0 + 0.9, y0 + 0.9, y0 + 0.45, y0, y0],
                        facecolor="#e6f4ea", edgecolor="#1f9d55", lw=1.2)
                ax.text((t + t2) / 2, y0 + 0.45, "x" if v is None else str(v),
                        ha="center", va="center", fontsize=8)
        ax.text(-1.5, y0 + 0.45, f"{label}" + (f"[{width-1}:0]" if width > 1 else ""),
                ha="right", va="center", fontsize=9, family="monospace")
    ax.set_xlim(0, t_end)
    ax.set_ylim(-0.4, len(order) * 1.5)
    ax.set_yticks([])
    ax.set_xlabel("time (ns)")
    for side in ("left", "right", "top"):
        ax.spines[side].set_visible(False)
    ax.grid(axis="x", color="#ddd", lw=0.6)
    ax.set_title(f"{name} — simulation waveform (Icarus Verilog)", fontsize=10, loc="left")
    fig.tight_layout()
    out = ROOT / "docs" / "waveforms" / f"{name}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out, dpi=130)
    print("wrote", out.relative_to(ROOT))


if __name__ == "__main__":
    for n in sys.argv[1:]:
        plot(n)
