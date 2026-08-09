# PrismStudio migration evidence inventory

Generated: 2026-08-07 (workflow artifact)
Source: `/home/micah/Desktop/Sylorlabs/PrismStudio`

## Source inventory

- Source modules discovered: 49
- Manifest sections discovered: 5
- Probe files discovered by manifest: 129
- Probe files declared by manifest heading: 128
- MCP protocol tools discovered: 92
- Command identifiers discovered: 46
- Workspace sections discovered from source comments: 11
- Hard-rule sets in AGENTS: 6

## Source module snapshot

| Module | Role |
| --- | --- |
| agent.zag | headless agent RPC for CLI and MCP wrappers. |
| app.zag | application core: state, zones, tools, input, and the command |
| builder.zag | Engine Builder / Density Synthesizer (Masterplan §22). |
| capability.zag | explicit local-agent grants and append-only request audit. |
| commands.zag | stable command-id registry for palette + agent dispatch. |
| components.zag | the photonic hardware library. |
| demo.zag | reference photonic processor design (shared by GUI + agent). |
| device_model.zag | versioned physical assumptions with explicit provenance. |
| editops.zag | editing operations above the raw scene: move with waveguide |
| export.zag | deterministic human/machine-readable project artifacts. |
| fb.zag | software framebuffer for Zag Photonics Architect. |
| flash_ir.zag | Flash FIR v1 importer and photonic execution verifier. |
| fontdata.zag | 5x9 bitmap font rows (bits 4..0) |
| fontatlas.zag | glyph atlas packer: bakes fontdata rows into a cacheable |
| gpu_backend.zag | User-selectable auto/CPU/virtual/physical backend policy; explicit CPU/virtual choices do not open or probe DRM. |
| gpu_compute.zag | high-level GPU compute operations built on the verified |
| gpu_isa_display.zag | Compiler-ISA-executed virtual framebuffer with owned memory, ordered fences, complete-frame presentation, and no DRM access. |
| gpu_isa_raster.zag | Strict virtual GFX10.1 tiled raster execution for compiler-emitted clear, depth, clipping, and fixed-point alpha compositing, with CPU shadow fallback. |
| gpu_raster.zag | Compiler-bundle-gated tiled raster software model: clear, geometry, depth, clipping, compositing, per-tile fences, shadow comparison, double buffering, fallback, and mismatch input/image/diff/log/tuple evidence. |
| gpu_virtual_cert.zag | Host-contained certification runner: 10,000 fills, one million actual VM submissions, exact ownership/fences, 86,400 logical soak ticks, raster differentials, and explicitly non-physical evidence. |
| gpu_rt.zag | a pure-Zag AMDGPU runtime. No libc, no libdrm, no Mesa: |
| io_chunks.zag | chunked design I/O keyed by world 32³ chunks. |
| ioline.zag | buffered stdin reads (chunked, not byte-per-syscall). |
| limits.zag | centralized, named, documented resource ceilings for untrusted |
| main.zag | photonic CPU designer entry point. 100% Zag, no C anywhere. |
| math3d.zag | vectors, orbit camera, projection, and picking rays. |
| mcp.zag | native MCP stdio server (JSON-RPC + Content-Length framing). |
| optimizer.zag | Continuous Optical-Computation Optimizer (Photon Solver). |
| process_stack.zag | physical process-stack layer model (plate, part, guide heights). |
| rdna.zag | a hand-written RDNA1 (GFX10.1) machine-code emitter, in pure Zag. |
| routing.zag | waveguide routing engine. A* over the free voxel lattice, |
| scene.zag | the design database. The scene is stored as (a) a voxel |
| session.zag | live shared design: one .zpa for GUI + agent + MCP. |
| sim.zag | wave-state simulation. The scene's directed optical graph is |
| sim_region.zag | incremental simulation recompile. |
| strutil.zag | leak-free string helpers (s2..s6, fmt_i, fmt_f1) for ownership. |
| ternary.zag | balanced ternary optical logic. |
| tiles.zag | tile-based render cache for the 3D viewport. |
| timing.zag | static timing analysis over the routed photonic fabric (Masterplan |
| ui.zag | dark workbench theme + minimal immediate-mode widgets over fb.zag. |
| uilayer.zag | retained UI panel surfaces: cached pixels + state hashes (Section 3.12). |
| viewport.zag | the 3D viewport. Software-rasterized in Zag: |
| voxel.zag | integer lattice coordinates for the design grid. |
| workspace.zag | panel rendering + per-frame orchestration. |
| workspace_menu.zag | menu bar, command palette, status bar, context menu. |
| workspace_opt.zag | optimizer proposal panel + builder panel + apply paths. |
| workspace_settings.zag | modal dialogs, Flash FIR workspace, model browser, settings. |
| world.zag | sparse chunk-based spatial index for million-scale scenes. |
| x11.zag | a pure-Zag X11 client. No libc, no Xlib, no C anywhere: |

## Probe manifest coverage

- ✅ **Production tests — gated by `tools/verify.zag`**: declared 94, parsed 95
  - sample: `agent.zag`, `ast.zag`, `bounds_test.zag`, `boxselect_test.zag`, `builder_test.zag`, `camera_test.zag`, `components.zag`, `copypaste_test.zag`, `crash_recovery_test.zag`, `demo.zag`, `design_db_test.zag`, `dpi_test.zag`…
- ✅ **Hardware-only — require a real (ideally non-display) GPU; excluded from the safe suite**: declared 6, parsed 6
  - sample: `gpu_compute_test.zag`, `gpu_fill_test.zag`, `gpu_parallel_test.zag`, `gpu_submit_test.zag`, `gpu_test.zag`, `gpu_wg_test.zag`
- ✅ **Dev benchmarks — timing tools, not pass/fail gates (superseded by `tools/bench.zag`)**: declared 2, parsed 2
  - sample: `perf_test.zag`, `scale_test.zag`
- ✅ **Compiler probes — exercise a `znc` language feature, not PrismStudio**: declared 2, parsed 2
  - sample: `_repro_znc1.zag`, `break_test.zag`
- ✅ **Obsolete — early debug/exploration scratch; kept for history, not run and not production**: declared 24, parsed 24
  - sample: `agent_place2.zag`, `agent_twoline.zag`, `app.zag`, `components_only.zag`, `hashmap.zag`, `hm_dbg.zag`, `io_chunks.zag`, `lex.zag`, `move_dbg.zag`, `opt_ui_shot.zag`, `probe3.zag`, `probe4.zag`…

## Workspace section map

- 3.7: . A category is a lens, not a partition
- 3.2: unlabeled section
- 3.8: , clears after ~3 s
- 3.4: unlabeled section
- 3.9: type icon, name (inline-renamable),
- 3.6: the row becomes a text field
- 3.10: the row whose beam path is selected in 3D
- 3.11: unlabeled section
- 3.5: unlabeled section
- 3.12: unlabeled section
- 20.5: . Kept off the interaction path: it

## PrismStudio command surface

- `cmd_none` = `0`
- `cmd_new` = `1`
- `cmd_open` = `2`
- `cmd_save` = `3`
- `cmd_save_as` = `4`
- `cmd_quit` = `5`
- `cmd_undo` = `10`
- `cmd_redo` = `11`
- `cmd_duplicate` = `12`
- `cmd_delete` = `13`
- `cmd_deselect` = `14`
- `cmd_copy` = `15`
- `cmd_paste` = `16`
- `cmd_group` = `17`
- `cmd_ungroup` = `18`
- `cmd_rename` = `19`
- `cmd_frame_selected` = `20`
- `cmd_frame_all` = `21`
- `cmd_view_top` = `22`
- `cmd_view_front` = `23`
- `cmd_view_right` = `24`
- `cmd_view_perspective` = `25`
- `cmd_toggle_ortho` = `26`
- `cmd_cycle_ui_scale` = `27`
- `cmd_reset_view` = `28`
- `cmd_section_view` = `29`
- `cmd_shortcuts` = `30`
- `cmd_demo` = `31`
- `cmd_open_flash_reference` = `32`
- `cmd_model_provenance` = `33`
- `cmd_recover_autosave` = `34`
- `cmd_tool_select` = `40`
- `cmd_tool_route` = `41`
- `cmd_sim_play_toggle` = `42`
- `cmd_optimizer` = `43`
- `cmd_settings` = `44`
- `cmd_palette` = `45`
- `cmd_tool_measure` = `46`
- `cmd_toggle_reduced_motion` = `47`
- `cmd_toggle_object_snap` = `48`
- `cmd_flash_workspace` = `49`
- `cmd_place_base` = `50`
- `cmd_builder` = `51`
- `cmd_toggle_visibility` = `70`
- `cmd_toggle_lock` = `71`
- `cmd_palette_jump_base` = `1000`

## MCP tools

- `prismstudio_command` (mutation)
- `prismstudio_mutate` (query)
- `prismstudio_help` (query)
- `prismstudio_capabilities` (query)
- `prismstudio_ping` (query)
- `prismstudio_new` (query)
- `prismstudio_demo` (query)
- `prismstudio_list` (query)
- `prismstudio_list_files` (query)
- `prismstudio_get` (query)
- `prismstudio_select` (query)
- `prismstudio_can_place` (query)
- `prismstudio_undo` (query)
- `prismstudio_redo` (query)
- `prismstudio_view` (query)
- `prismstudio_camera` (query)
- `prismstudio_render_at` (query)
- `prismstudio_pick` (query)
- `prismstudio_place_here` (query)
- `prismstudio_place_on` (query)
- `prismstudio_place` (query)
- `prismstudio_route` (query)
- `prismstudio_delete` (query)
- `prismstudio_sim_step` (query)
- `prismstudio_sim_state` (query)
- `prismstudio_sim` (query)
- `prismstudio_move` (query)
- `prismstudio_rotate` (query)
- `prismstudio_disconnect` (query)
- `prismstudio_reroute` (query)
- `prismstudio_inspect` (query)
- `prismstudio_close` (query)
- `prismstudio_build` (query)
- `prismstudio_preview` (query)
- `prismstudio_simstream` (query)
- `prismstudio_timing` (query)
- `prismstudio_del` (query)
- `prismstudio_sel` (query)
- `prismstudio_save` (query)
- `prismstudio_open` (query)
- `prismstudio_render` (query)
- `prismstudio_export` (query)
- `prismstudio_diagnostics` (query)
- `prismstudio_details` (query)
- `prismstudio_audit` (query)
- `prismstudio_logs` (query)
- `prismstudio_uilog` (query)
- `prismstudio_trace` (query)
- `prismstudio_flash_import` (query)
- `prismstudio_flash_verify` (query)
- `prismstudio_ui_list` (query)
- `prismstudio_ui_screenshot` (query)
- `prismstudio_ui_activate` (query)
- `prismstudio_optimizer_apply` (query)
- `prismstudio_optimizer_accept` (query)
- `prismstudio_optimizer_decline` (query)
- `prismstudio_optimizer_ignore` (query)
- `prismstudio_optimizer_details` (query)
- `prismstudio_builder_generate` (query)
- `prismstudio_builder_apply` (query)
- `prismstudio_builder_accept` (query)
- `prismstudio_builder_decline` (query)
- `prismstudio_builder_ignore` (query)
- `prismstudio_builder_details` (query)
- `prismstudio_copy` (query)
- `prismstudio_paste` (query)
- `prismstudio_duplicate` (query)
- `prismstudio_group` (query)
- `prismstudio_ungroup` (query)
- `prismstudio_rename` (query)
- `prismstudio_toggle_visibility` (query)
- `prismstudio_toggle_lock` (query)
- `prismstudio_select_add` (query)
- `prismstudio_select_remove` (query)
- `prismstudio_select_clear` (query)
- `prismstudio_view_frame` (query)
- `prismstudio_view_toggle` (query)
- `prismstudio_panel` (query)
- `prismstudio_ui_click` (query)
- `prismstudio_ui_type` (query)
- `prismstudio_camera_orbit` (query)
- `prismstudio_camera_pan` (query)
- `prismstudio_camera_zoom` (query)
- `prismstudio_model_status` (query)
- `prismstudio_model_migrate` (query)
- `prismstudio_test` (query)
- `prismstudio_status` (query)
- `prismstudio_coords` (query)
- `prismstudio_process_stack` (query)
- `prismstudio_power` (query)
- `prismstudio_perf` (query)
- `prismstudio_kinds` (query)

## Hard rules carried into migration planning

- No hardcoded physical constants
- Fix Zag at the compiler, never work around it in the app
- No committing binaries
- No `CAPS=all` default
- Math constant precision
- String ownership

## Open ownership questions (must close before G6-** tasks)

- Confirm that every visible or keyboard-operable control in the target PrismStudio migration matrix has a mapped Zagkit replacement before shell replacement.
- Confirm each protocol transport behavior above is represented by the same automation contract in Zagkit Talkback (not via pixel fallback).
- Confirm each critical visual asset state (lighting/shadows/glass, scale variants, transparency and reduced-motion variants) has a matching native fixture policy before finalizing visual direction selection.
