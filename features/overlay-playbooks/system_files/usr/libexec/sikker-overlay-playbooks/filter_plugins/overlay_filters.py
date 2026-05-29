from __future__ import annotations

import posixpath

from ansible.errors import AnsibleFilterError


def overlay_asset_relpath(raw: object) -> str:
    if not isinstance(raw, str):
        return ""

    if raw.startswith("config/assets/"):
        rel = posixpath.normpath(raw[len("config/assets/") :])
    elif raw.startswith("assets/"):
        rel = posixpath.normpath(raw[len("assets/") :])
    else:
        return ""

    if rel in ("", ".") or rel.startswith("../") or "/../" in rel:
        raise AnsibleFilterError(f"Invalid asset path: {raw}")

    return rel


class FilterModule(object):
    def filters(self):
        return {
            "overlay_asset_relpath": overlay_asset_relpath,
        }