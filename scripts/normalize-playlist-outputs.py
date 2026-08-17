from pathlib import Path
import os
import re
import shutil


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output"
IPV6_LITERAL_URL = re.compile(r"://\[[0-9a-fA-F:]+\]")
M3U_TVG_URL = re.compile(r'x-tvg-url="[^"]*"')


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines() if path.exists() else []


def write_lines(path: Path, lines: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def remove_ipv6_literal_txt(path: Path) -> None:
    lines = read_lines(path)
    if lines:
        write_lines(path, [line for line in lines if not IPV6_LITERAL_URL.search(line)])


def remove_ipv6_literal_m3u(path: Path) -> None:
    lines = read_lines(path)
    if not lines:
        return
    cleaned: list[str] = []
    index = 0
    while index < len(lines):
        line = lines[index]
        if not line.startswith("#EXTINF"):
            if not IPV6_LITERAL_URL.search(line):
                cleaned.append(line)
            index += 1
            continue
        block = [line]
        index += 1
        while index < len(lines) and lines[index].startswith("#EXTVLCOPT:"):
            block.append(lines[index])
            index += 1
        if index >= len(lines):
            cleaned.extend(block)
            break
        url_line = lines[index]
        index += 1
        if not IPV6_LITERAL_URL.search(url_line):
            cleaned.extend(block)
            cleaned.append(url_line)
    write_lines(path, cleaned)


def copy_file(source: Path, destination: Path) -> None:
    if not source.exists():
        raise FileNotFoundError(source)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)


def rewrite_public_epg_url(path: Path) -> None:
    repository = os.getenv("GITHUB_REPOSITORY")
    lines = read_lines(path)
    if not repository or not lines or not lines[0].startswith("#EXTM3U"):
        return
    value = f'x-tvg-url="https://raw.githubusercontent.com/{repository}/main/output/epg/epg.gz"'
    lines[0] = M3U_TVG_URL.sub(value, lines[0]) if M3U_TVG_URL.search(lines[0]) else f"{lines[0]} {value}"
    write_lines(path, lines)


def main() -> None:
    ipv4_txt = OUTPUT / "my_iptv_ipv4.txt"
    ipv4_m3u = OUTPUT / "my_iptv_ipv4.m3u"
    default_m3u = OUTPUT / "my_iptv.m3u"
    ipv6_m3u = OUTPUT / "my_iptv_ipv6_hd.m3u"
    remove_ipv6_literal_txt(ipv4_txt)
    remove_ipv6_literal_m3u(ipv4_m3u)
    for path in (default_m3u, ipv4_m3u, ipv6_m3u):
        rewrite_public_epg_url(path)
    copy_file(OUTPUT / "my_iptv.txt", OUTPUT / "result.txt")
    copy_file(default_m3u, OUTPUT / "result.m3u")
    copy_file(ipv4_txt, OUTPUT / "ipv4/result.txt")
    copy_file(ipv4_m3u, OUTPUT / "ipv4/result.m3u")
    copy_file(OUTPUT / "my_iptv_ipv6_hd.txt", OUTPUT / "ipv6/result.txt")
    copy_file(ipv6_m3u, OUTPUT / "ipv6/result.m3u")


if __name__ == "__main__":
    main()
