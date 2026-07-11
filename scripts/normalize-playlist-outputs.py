from pathlib import Path
import os
import re
import shutil


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output"
IPV6_LITERAL_URL = re.compile(r"://\[[0-9a-fA-F:]+\]")
M3U_TVG_URL = re.compile(r'x-tvg-url="[^"]*"')


def read_lines(path: Path) -> list[str]:
    if not path.exists():
        return []
    return path.read_text(encoding="utf-8").splitlines()


def write_lines(path: Path, lines: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def remove_ipv6_literal_txt(path: Path) -> None:
    lines = read_lines(path)
    if not lines:
        return
    write_lines(path, [line for line in lines if not IPV6_LITERAL_URL.search(line)])


def remove_ipv6_literal_m3u(path: Path) -> None:
    lines = read_lines(path)
    if not lines:
        return

    cleaned: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if not line.startswith("#EXTINF"):
            if not IPV6_LITERAL_URL.search(line):
                cleaned.append(line)
            i += 1
            continue

        block = [line]
        i += 1
        while i < len(lines) and lines[i].startswith("#EXTVLCOPT:"):
            block.append(lines[i])
            i += 1

        if i >= len(lines):
            cleaned.extend(block)
            break

        url_line = lines[i]
        i += 1
        if IPV6_LITERAL_URL.search(url_line):
            continue

        cleaned.extend(block)
        cleaned.append(url_line)

    write_lines(path, cleaned)


def copy_file(src: Path, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dest)


def rewrite_public_epg_url(path: Path) -> None:
    repository = os.getenv("GITHUB_REPOSITORY")
    if not repository or not path.exists():
        return

    lines = read_lines(path)
    if not lines or not lines[0].startswith("#EXTM3U"):
        return

    epg_url = f"https://raw.githubusercontent.com/{repository}/main/output/epg/epg.gz"
    replacement = f'x-tvg-url="{epg_url}"'
    if M3U_TVG_URL.search(lines[0]):
        lines[0] = M3U_TVG_URL.sub(replacement, lines[0])
    else:
        lines[0] = f'{lines[0]} {replacement}'
    write_lines(path, lines)


def main() -> None:
    ipv4_txt = OUTPUT / "my_iptv_ipv4.txt"
    ipv4_m3u = OUTPUT / "my_iptv_ipv4.m3u"
    default_m3u = OUTPUT / "my_iptv.m3u"
    ipv6_m3u = OUTPUT / "my_iptv_ipv6_hd.m3u"

    remove_ipv6_literal_txt(ipv4_txt)
    remove_ipv6_literal_m3u(ipv4_m3u)
    for m3u_path in (default_m3u, ipv4_m3u, ipv6_m3u):
        rewrite_public_epg_url(m3u_path)

    copy_file(OUTPUT / "my_iptv.txt", OUTPUT / "result.txt")
    copy_file(default_m3u, OUTPUT / "result.m3u")
    copy_file(ipv4_txt, OUTPUT / "ipv4" / "result.txt")
    copy_file(ipv4_m3u, OUTPUT / "ipv4" / "result.m3u")
    copy_file(OUTPUT / "my_iptv_ipv6_hd.txt", OUTPUT / "ipv6" / "result.txt")
    copy_file(ipv6_m3u, OUTPUT / "ipv6" / "result.m3u")


if __name__ == "__main__":
    main()
