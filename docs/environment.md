# environment variables

- All vars start with `KOOOLBOX_`
- `KOOLBOX_BUILD_...`
- `KOOLBOX_INSTALL_...`
- `KOOLBOX_RUN_...`
- `KOOLBOX_DEFAULT_...` can be set in config scripts, so they do not override

Example setting `KOOLBOX_RUN_KIND` using defaults:
```bash
source koolbox.config
: ${KOOLBOX_RUN_KIND:=${KOOLBOX_DEFAULT_RUN_KIND:-koolbox}}
parse_cmdline_args: explicitely set vars
```
- If you set nothing it will use koolbox
- if in `koolbox.config` it says `KOOLBOX_DEFAULT_RUN_KIND=kubibox` it will use kubibox
- If you set `export KOOLBOX_RUN_KIND=kubebox` it will not use the default from the configuration
- If you provide `--kind kloudbox` it will use that
