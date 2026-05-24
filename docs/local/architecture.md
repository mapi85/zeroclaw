# ZeroClaw — Architecture Overview for Agent Navigation

> Synthèse pour navigation rapide dans le code. Version upstream : 0.7.5 (Rust 2024, MSRV 1.87).

## Vue d'ensemble

ZeroClaw est un runtime d'agent IA autonome et auto-hébergé, écrit entièrement en Rust. Il connecte un LLM à 30+ canaux de communication (messagerie, email, voix, IRC...), exécute des actions via des outils (shell, browser, HTTP, filesystem, GPIO), avec des niveaux d'autonomie configurables et des gates d'approbation.

**Philosophie** : ownership total (données, machine, agent) + binaire minimaliste (opt-level=z, fat LTO).

---

## Structure workspace Cargo

```
zeroclaw/
├── src/               # binaire principal (main.rs = 168 KB)
├── crates/            # 16 library crates
│   ├── zeroclaw-api/          # traits publics (source de vérité des contrats)
│   ├── zeroclaw-config/       # schéma config, chargement TOML
│   ├── zeroclaw-runtime/      # boucle agent, sécurité, cron, SOP, skills
│   ├── zeroclaw-channels/     # 30+ intégrations (Discord, Telegram, Slack...)
│   ├── zeroclaw-providers/    # adaptateurs LLM (Anthropic, OpenAI, Ollama...)
│   ├── zeroclaw-tools/        # outils intégrés (shell, file, HTTP, browser)
│   ├── zeroclaw-memory/       # backends mémoire (markdown, sqlite, vecteurs)
│   ├── zeroclaw-gateway/      # serveur HTTP/WS (Axum), SSE, WebAuthn
│   ├── zeroclaw-hardware/     # GPIO, I2C, SPI, USB, serial, PWM
│   ├── zeroclaw-tui/          # wizard onboarding terminal
│   ├── zeroclaw-plugins/      # système de plugins WASM
│   ├── zeroclaw-infra/        # utilitaires partagés (debounce, sessions, watchdog)
│   ├── zeroclaw-macros/       # proc-macros (dérive Configurable)
│   ├── zeroclaw-tool-call-parser/ # parsing des tool calls du LLM
│   ├── robot-kit/             # SDK robotique (drive, sense, speak, emote)
│   └── aardvark-sys/          # FFI bindings vers aardvark.so (hardware)
├── apps/tauri/        # GUI desktop/mobile (wraps le core Rust)
├── docs/
│   ├── book/          # documentation upstream (mdBook)
│   └── local/         # documentation locale (ce dossier, non-upstream)
└── .claude/skills/    # skills AI pour le repo
```

---

## Points d'extension — traits clés

Tous définis dans `crates/zeroclaw-api/src/` :

| Trait | Fichier | Rôle |
|-------|---------|------|
| `Provider` | `provider.rs` | Adaptateur LLM |
| `Channel` | `channel.rs` | Intégration messagerie |
| `Tool` | `tool.rs` | Outil exécutable par l'agent |
| `Memory` | `memory_traits.rs` | Backend de persistance mémoire |
| `Observer` | `observability_traits.rs` | Observabilité / métriques |
| `RuntimeAdapter` | `runtime_traits.rs` | Adaptateur runtime |
| `Peripheral` | `peripherals_traits.rs` | Périphérique matériel |

Pour ajouter un nouveau Provider/Channel/Tool : implémenter le trait correspondant + enregistrer dans le module factory. Voir `docs/book/src/developing/extension-examples.md`.

---

## Boucle agent (`zeroclaw-runtime`)

```
Incoming message (Channel)
  → Runtime (zeroclaw-runtime)
      → Security gate (approval/workspace sandbox)
      → Provider (LLM call)
      → Tool call parser (zeroclaw-tool-call-parser)
      → Tool execution (zeroclaw-tools)
      → Memory update (zeroclaw-memory)
      → Response via Channel
```

Modules clés dans `src/` :
- `src/agent/` — logique de l'agent loop
- `src/security/` — workspace sandbox, autonomy levels (HIGH RISK — voir AGENTS.md)
- `src/approval/` — gates d'approbation manuelle
- `src/cron/` — tâches planifiées
- `src/hooks/` — hooks d'événements (agent loop hooks)
- `src/sop/` — Standard Operating Procedures
- `src/skills/` — système de skills
- `src/memory/` — orchestration mémoire
- `src/providers/` — routing et fallback chain LLM
- `src/channels/` — orchestration canaux

---

## Configuration

Fichier TOML unique, schéma défini dans `crates/zeroclaw-config/`. Variables sensibles via secrets (pas dans le TOML). Dérivation auto avec macro `#[derive(Configurable)]` depuis `crates/zeroclaw-macros/`.

Voir `src/config/` pour le chargement/merge et `src/commands/config.rs` pour la CLI.

---

## CLI (`src/main.rs` + `src/lib.rs`)

Sous-commandes Clap principales :
- `onboard` — assistant de configuration initial (TUI)
- `agent` — démarre l'agent
- `gateway` — démarre le serveur HTTP/WS
- `acp` — Agent Client Protocol (JSON-RPC 2.0 over stdio, pour IDE)
- `daemon` / `service` — mode démon OS
- `config` — gestion de la configuration

---

## Internationalisation

Toutes les strings user-facing utilisent `fl!()` / Fluent. Ne jamais utiliser de string literals directes pour les messages utilisateur. Les logs `tracing::` restent en anglais.

---

## Niveaux de risque (pour modifications)

| Niveau | Périmètre |
|--------|-----------|
| **Low** | `docs/`, chores, tests uniquement |
| **Medium** | `crates/*/src/**` comportement sans impact sécurité |
| **High** | `crates/zeroclaw-runtime/src/security/`, `crates/zeroclaw-gateway/src/`, `crates/zeroclaw-tools/src/`, `.github/workflows/` |

En cas de doute : classifier au niveau supérieur.

---

## Tiers de stabilité des crates

| Crate | Tier | Stabilité à |
|-------|------|------------|
| `zeroclaw-api` | Experimental | v1.0.0 |
| `zeroclaw-config` | Beta | v0.8.0 |
| `zeroclaw-runtime` | Experimental | — |
| `zeroclaw-channels` | Experimental | v1.0.0 (migration plugin) |
| `zeroclaw-tools` | Experimental | v1.0.0 (migration plugin) |
| `zeroclaw-gateway` | Experimental | v0.9.0 (binaire séparé) |
| `zeroclaw-plugins` | Experimental | — (WASM, fondation v1.0.0) |
| `zeroclaw-memory` | Beta | — |
| `zeroclaw-providers` | Beta | — |
| `zeroclaw-infra` | Beta | — |
| `zeroclaw-tool-call-parser` | Beta | v0.8.0 |
| `zeroclaw-macros` | Beta | — |

**Stable** = couvert par la politique de breaking changes. **Beta** = breaking changes autorisés en MINOR avec changelog. **Experimental** = aucune garantie.
