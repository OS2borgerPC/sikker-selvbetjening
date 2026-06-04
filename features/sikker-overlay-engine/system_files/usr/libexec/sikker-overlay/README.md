# Overlay Playbooks

This directory now contains the Ansible implementation for rendering a normalized overlay payload into a staged filesystem tree.

## Contract

`/usr/libexec/sikker-create-overlay` still accepts exactly three positional arguments:

1. Path to normalized overlay payload JSON
2. Path to mounted assets root
3. Path to output root

The entrypoint passes the JSON payload to Ansible with `--extra-vars @payload.json` and injects `assets_root` and `output_root` as additional variables. The playbook must stay idempotent and must only write under `output_root`.

## Layout

- `sikker-create-overlay.yml`: master playbook executed by `sikker-create-overlay`
- `tasks/`: auto-discovered overlay task files (no `sikker-create-overlay.yml` edit needed)
- `templates/`: staged file templates written into `output_root`
- `filter_plugins/`: small Python filters used from playbooks
- `ansible.cfg`: local Ansible settings for this overlay runner

## Domain Autoloading

`sikker-create-overlay.yml` discovers every `*.yml` file in `tasks/` and includes them in lexical order. To add a new overlay domain, add a new task file in `tasks/` (for example `30-printer.yml`).

Each domain task file should either guard itself with `when` (no-op when JSON is absent) or implement the default-first pattern below when sensible defaults should still be rendered.

## Default-First Task Pattern

When a domain has sensible defaults, prefer a default-first pattern over a full file-level guard.

1. Resolve effective values up front with `set_fact` using `default(...)`.
2. Render default output unconditionally.
3. Apply config-driven overrides only behind narrow `when` checks.

This keeps behavior predictable: missing config still produces valid output with defaults.

Example:

```yaml
- name: Resolve effective values
	ansible.builtin.set_fact:
		feature_input: "{{ ((feature | default({})).input | default('default')) }}"

- name: Render defaults
	ansible.builtin.copy:
		dest: "{{ output_root }}/..."
		content: "...{{ feature_input }}..."

- name: Apply optional override artifact
	when: ((feature | default({})).artifact | default('')) | length > 0
	ansible.builtin.copy:
		src: "{{ assets_root }}/..."
		dest: "{{ output_root }}/..."
```

## Important Constraint

This code runs inside the build container to generate files for a later image build. Because of that, tasks must render files into `output_root` instead of configuring the live container directly. Modules that mutate the running system, such as `nmcli`, are the wrong abstraction here unless they are wrapped to target the staged root instead of the host.

## Extending The Overlay

Add a new section by including another task file from `sikker-create-overlay.yml` and writing all outputs beneath `{{ output_root }}`. Keep any schema changes coordinated with the downstream configuration repository, because the JSON payload shape is part of the compatibility contract.
