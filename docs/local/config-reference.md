# ZeroClaw — Référence complète `config.toml` (schema V3)

> Généré à partir du code source Rust (`crates/zeroclaw-config/src/schema.rs`, `providers.rs`, `scattered_types.rs`).
> Couvre le schema V3 — compatible ZeroClaw ≥ 0.7.
> Document universel — aucune configuration spécifique à un déploiement.

---

## Conventions

| Notation | Sens |
|----------|------|
| **(requis)** | Absence → erreur au démarrage |
| *(facultatif)* | Peut être omis ; valeur par défaut appliquée |
| `#[secret]` | Chiffré par le trousseau OS, jamais en clair dans le fichier |
| `Option<T>` | Champ absent ≡ `None` ; `Some` activé uniquement si défini |
| `[section.<alias>]` | Section répétable — créer autant d'alias que nécessaire |

---

## Champ racine

```toml
schema_version = 3      # u32 — version du schéma (géré automatiquement)
```

---

## `[providers]` — Fournisseurs IA

La section `providers` regroupe les fournisseurs de modèles de langage, de synthèse vocale et de transcription. Chaque type de fournisseur possède sa propre famille (clé de type), et chaque famille contient un ou plusieurs alias (instances nommées).

### Structure V3 des providers

```toml
[providers.models.<famille>.<alias>]
model  = "..."
...

[providers.tts.<famille>.<alias>]
...

# La transcription n'est PAS dans providers — voir section [transcription] plus bas
[transcription]
enabled = true
...
```

L'alias est utilisé comme référence dans les sections `[agents.<alias>]` sous la forme `"<famille>.<alias>"`.

---

### `[providers.models.anthropic.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `model` | `String` **(requis)** | — | Identifiant du modèle (ex. `claude-opus-4-7`, `claude-sonnet-4-6`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `ANTHROPIC_API_KEY` | Clé API Anthropic |
| `max_tokens` | `u32` *(facultatif)* | — | Plafond de tokens en sortie |
| `temperature` | `f64` *(facultatif)* | — | Température d'échantillonnage (0.0–2.0) |
| `top_p` | `f64` *(facultatif)* | — | Top-P sampling |
| `top_k` | `u32` *(facultatif)* | — | Top-K sampling |
| `timeout_secs` | `u64` *(facultatif)* | — | Timeout HTTP (secondes) |
| `retry_count` | `u32` *(facultatif)* | — | Nombre de tentatives en cas d'erreur |
| `retry_backoff_ms` | `u64` *(facultatif)* | — | Délai de backoff entre tentatives (ms) |
| `request_cost_override` | `String` *(facultatif)* | — | Alias de tarif personnalisé (voir `[cost.rates]`) |

---

### `[providers.models.openai.<alias>]`

Hérite de la base commune, plus :

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `model` | `String` **(requis)** | — | Identifiant du modèle (ex. `gpt-4o`, `o3-mini`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `OPENAI_API_KEY` | Clé API OpenAI |
| `endpoint` | `String` *(facultatif)* | `https://api.openai.com/v1` | URL de l'endpoint (pour proxies Azure, etc.) |
| `max_tokens` | `u32` *(facultatif)* | — | Plafond de tokens en sortie |
| `temperature` | `f64` *(facultatif)* | — | Température (0.0–2.0) |
| `frequency_penalty` | `f64` *(facultatif)* | — | Pénalité de fréquence (-2.0–2.0) |
| `presence_penalty` | `f64` *(facultatif)* | — | Pénalité de présence (-2.0–2.0) |
| `timeout_secs` | `u64` *(facultatif)* | — | Timeout HTTP (secondes) |
| `retry_count` | `u32` *(facultatif)* | — | Tentatives en cas d'erreur |
| `retry_backoff_ms` | `u64` *(facultatif)* | — | Backoff entre tentatives (ms) |

---

### `[providers.models.ollama.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `model` | `String` **(requis)** | — | Identifiant du modèle local (ex. `llama3.3`, `gemma3:12b`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | — | Clé si endpoint Ollama protégé |
| `endpoint` | `String` *(facultatif)* | `http://localhost:11434/v1` | URL de l'instance Ollama |
| `max_tokens` | `u32` *(facultatif)* | — | Plafond de tokens |
| `temperature` | `f64` *(facultatif)* | — | Température |
| `timeout_secs` | `u64` *(facultatif)* | — | Timeout HTTP |

---

### `[providers.models.litellm.<alias>]`

LiteLLM agit comme proxy OpenAI-compatible et supporte 100+ fournisseurs.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `model` | `String` **(requis)** | — | Identifiant du modèle côté LiteLLM (ex. `ollama/mistral`, `gemini/gemini-2.0-flash`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `LITELLM_API_KEY` | Master key du proxy LiteLLM |
| `api_base` | `String` *(facultatif)* | `http://localhost:4000/v1` | URL du proxy LiteLLM |
| `max_tokens` | `u32` *(facultatif)* | — | Plafond de tokens |
| `temperature` | `f64` *(facultatif)* | — | Température |
| `timeout_secs` | `u64` *(facultatif)* | — | Timeout HTTP |
| `retry_count` | `u32` *(facultatif)* | — | Tentatives |

---

### `[providers.models.groq.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `model` | `String` **(requis)** | — | Modèle Groq (ex. `llama-3.3-70b-versatile`, `moonshotv1-8k`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `GROQ_API_KEY` | Clé API Groq |
| `max_tokens` | `u32` *(facultatif)* | — | Plafond |
| `temperature` | `f64` *(facultatif)* | — | Température |
| `timeout_secs` | `u64` *(facultatif)* | — | Timeout |

---

### `[providers.models.google.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `model` | `String` **(requis)** | — | Modèle Gemini (ex. `gemini-2.0-flash`, `gemini-2.5-pro`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `GOOGLE_API_KEY` | Clé API Google AI Studio |
| `max_tokens` | `u32` *(facultatif)* | — | Plafond |
| `temperature` | `f64` *(facultatif)* | — | Température |
| `timeout_secs` | `u64` *(facultatif)* | — | Timeout |

---

### Autres familles de modèles

Même structure base que ci-dessus (champs `model`, `api_key`, `max_tokens`, `temperature`, `timeout_secs`, `retry_count`, `retry_backoff_ms`) :

| Famille (clé TOML) | Fournisseur | Env var API key |
|--------------------|-------------|-----------------|
| `mistral` | Mistral AI | `MISTRAL_API_KEY` |
| `cohere` | Cohere | `COHERE_API_KEY` |
| `fireworks` | Fireworks AI | `FIREWORKS_API_KEY` |
| `together` | Together AI | `TOGETHER_API_KEY` |
| `perplexity` | Perplexity AI | `PERPLEXITY_API_KEY` |
| `deepseek` | DeepSeek | `DEEPSEEK_API_KEY` |
| `xai` | xAI (Grok) | `XAI_API_KEY` |
| `azure` | Azure OpenAI | `AZURE_OPENAI_API_KEY` |
| `bedrock` | AWS Bedrock | IAM / env AWS |
| `vertexai` | Google Vertex AI | GCP IAM |
| `huggingface` | Hugging Face Inference | `HUGGINGFACE_API_KEY` |
| `replicate` | Replicate | `REPLICATE_API_TOKEN` |
| `openai_compat` | Compatible OpenAI générique | configurable |

---

### `[providers.tts.<famille>.<alias>]` — Synthèse vocale

| Famille | Description | Champs spécifiques |
|---------|-------------|-------------------|
| `openai` | OpenAI TTS | `model`, `voice`, `speed`, `api_key` |
| `elevenlabs` | ElevenLabs | `voice_id`, `model_id`, `stability`, `similarity_boost`, `api_key` |
| `google` | Google Cloud TTS | `language_code`, `voice_name`, `speaking_rate`, `api_key` |
| `edge` | Microsoft Edge TTS (gratuit) | `voice`, `rate`, `pitch` |
| `piper` | Piper TTS (local, offline) | `model_path`, `speaker_id` |

---

### `[transcription]` — Transcription vocale

> **Attention** : la transcription n'est **pas** sous `[providers]`. C'est une section plate à la racine.
> Elle est activée canal par canal via `voice_enabled = true` (ex. `[channels.telegram.<alias>]`).

**Provider Groq (défaut, champs racine) :**

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer la transcription vocale |
| `api_key` | `String` `#[secret]` *(requis pour Groq)* | — | Clé API Groq |
| `api_url` | `String` | `https://api.groq.com/openai/v1/audio/transcriptions` | Endpoint Whisper |
| `model` | `String` | `whisper-large-v3-turbo` | Modèle Whisper Groq |
| `language` | `String` *(facultatif)* | — | Code ISO-639-1 (ex. `"fr"`, `"en"`) |
| `initial_prompt` | `String` *(facultatif)* | — | Prompt initial pour biaiser la transcription |
| `max_duration_secs` | `u64` | `120` | Durée max des messages vocaux (les plus longs sont ignorés) |
| `transcribe_non_ptt_audio` | `bool` | `false` | Transcrire aussi les fichiers audio non-PTT (WhatsApp) |

**Sous-section `[transcription.openai]` :**

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `api_key` | `String` `#[secret]` **(requis)** | — | Clé API OpenAI |
| `model` | `String` | `whisper-1` | Modèle Whisper OpenAI |

**Sous-section `[transcription.deepgram]` :**

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `api_key` | `String` `#[secret]` **(requis)** | — | Clé API Deepgram |
| `model` | `String` | `nova-2` | Modèle Deepgram |

**Sous-section `[transcription.assemblyai]` :**

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `api_key` | `String` `#[secret]` **(requis)** | — | Clé API AssemblyAI |

**Sous-section `[transcription.google]` :**

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `api_key` | `String` `#[secret]` **(requis)** | — | Clé API Google Cloud |
| `language_code` | `String` | `en-US` | Code BCP-47 (ex. `"fr-FR"`) |

**Sous-section `[transcription.local_whisper]` — endpoint auto-hébergé :**

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `url` | `String` **(requis)** | — | URL de l'endpoint (ex. `http://localhost:8001/v1/audio/transcriptions`) |
| `bearer_token` | `String` `#[secret]` *(facultatif)* | — | Token Bearer (omettre si endpoint sans auth) |
| `max_audio_bytes` | `usize` | `26214400` (25 MiB) | Taille max acceptée par l'endpoint |
| `timeout_secs` | `u64` | `300` | Timeout (plus long pour GPU local) |

**Ordre de sélection des providers :** Groq (champs racine) → openai → deepgram → assemblyai → google → local_whisper. Le premier qui s'initialise avec succès est utilisé. Si aucun ne réussit et que `enabled = true`, le démarrage du canal échoue avec un warning.

---

## `[agents.<alias>]` — Configuration des agents

Chaque alias définit un agent indépendant. Un même déploiement peut contenir plusieurs agents.

```toml
[agents.default]
enabled        = true
model_provider = "anthropic.main"
channels       = ["telegram.default"]
risk_profile   = "standard"
runtime_profile = "standard"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Active ou désactive l'agent |
| `model_provider` | `String` **(requis)** | — | Référence dotted `"<famille>.<alias>"` |
| `channels` | `[String]` | `[]` | Canaux de messagerie écoutés |
| `risk_profile` | `String` | `"default"` | Profil de risque appliqué |
| `runtime_profile` | `String` | `"default"` | Profil d'exécution appliqué |
| `skill_bundles` | `[String]` | `[]` | Bundles de skills chargés (vide = `data/skills/` uniquement) |
| `knowledge_bundles` | `[String]` | `[]` | Bundles de base de connaissances |
| `mcp_bundles` | `[String]` | `[]` | Bundles de serveurs MCP |
| `cron_jobs` | `[String]` | `[]` | Alias de tâches cron déclenchées par cet agent |
| `tts_provider` | `String` *(facultatif)* | — | Référence `"<famille>.<alias>"` TTS |
| `compact_context` | `bool` | `true` | Bootstrap compact (6 000 chars, 2 chunks RAG) |
| `max_tool_iterations` | `usize` | `10` | Max tours de boucle outil par message |
| `max_history_messages` | `usize` | `50` | Max messages d'historique retenus |
| `max_context_tokens` | `usize` | `32000` | Max tokens de contexte avant compactage |
| `parallel_tools` | `bool` | `false` | Exécution parallèle des appels outils |
| `tool_dispatcher` | `String` | `"auto"` | Stratégie de dispatch d'outils |
| `tool_call_dedup_exempt` | `[String]` | `[]` | Outils exemptés de la déduplication |
| `tool_filter_groups` | `[ToolFilterGroup]` | `[]` | Filtrage des schémas MCP par contexte |
| `max_system_prompt_chars` | `usize` | `0` | Max caractères prompt système (0 = illimité) |
| `context_aware_tools` | `bool` | `false` | Présenter uniquement les outils pertinents |
| `max_tool_result_chars` | `usize` | `50000` | Max caractères par résultat d'outil |
| `keep_tool_context_turns` | `usize` | `2` | Tours récents avec contexte outil complet |

### `[agents.<alias>.thinking]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `default_level` | `String` | `"Medium"` | Niveau de raisonnement : `Off`, `Minimal`, `Low`, `Medium`, `High`, `Max` |

### `[agents.<alias>.history_pruning]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Active l'élagage automatique de l'historique |
| `strategy` | `String` | `"sliding_window"` | `"sliding_window"` ou `"summarize"` |
| `summarize_threshold` | `usize` | `40` | Tours avant déclenchement du résumé |

### `[agents.<alias>.eval]`

Évaluateur qualité post-réponse (optionnel).

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Active l'évaluateur |
| `model_provider` | `String` *(facultatif)* | — | Provider dédié à l'évaluation |
| `min_score` | `f64` | `0.7` | Score minimum acceptable (0.0–1.0) |
| `retry_on_fail` | `bool` | `false` | Régénérer si score < `min_score` |
| `max_retries` | `u32` | `1` | Max tentatives de régénération |

### `[agents.<alias>.context_compression]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Active la compression de contexte |
| `trigger_at_percent` | `u8` | `80` | Déclenchement à X% de `max_context_tokens` |
| `target_percent` | `u8` | `50` | Objectif après compression |
| `strategy` | `String` | `"summarize"` | `"summarize"` ou `"drop_oldest"` |

### `[agents.<alias>.workspace]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `root` | `String` *(facultatif)* | `agents/<alias>/workspace/` | Racine du workspace agent |
| `allow_outside_root` | `bool` | `false` | Autoriser la lecture hors workspace |

### `[agents.<alias>.memory]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `backend` | `String` *(facultatif)* | hérite de `[memory].backend` | Backend SQLite/Postgres/etc. dédié |
| `namespace` | `String` | `"default"` | Espace de nommage mémoire |

### `[agents.<alias>.identity]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `format` | `String` | `"openclaw"` | Format d'identité : `"openclaw"` ou `"aieos"` |

### `[agents.<alias>.tool_receipts]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer les reçus HMAC d'exécution d'outils |
| `hmac_secret` | `String` `#[secret]` *(facultatif)* | généré auto | Secret HMAC |

### `[agents.<alias>.auto_classify]`

Reclassification automatique selon complexité de la requête.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer la reclassification |
| `low_model_provider` | `String` *(facultatif)* | — | Provider pour les requêtes simples |
| `high_model_provider` | `String` *(facultatif)* | — | Provider pour les requêtes complexes |

---

## `[risk_profiles.<alias>]` — Profils de risque

Définit les permissions et contraintes de sécurité d'un agent.

```toml
[risk_profiles.standard]
level              = "semi_autonomous"
workspace_only     = true
allowed_commands   = ["ls", "cat", "grep", "find"]
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `level` | `String` **(requis)** | — | `supervised`, `semi_autonomous`, `autonomous` |
| `workspace_only` | `bool` | `true` | Restreindre aux chemins workspace |
| `allowed_commands` | `[String]` | `[]` | Commandes shell autorisées |
| `forbidden_paths` | `[String]` | `[]` | Chemins absolus interdits |
| `require_approval_for_medium_risk` | `bool` | `true` | Confirmation pour actions risque moyen |
| `block_high_risk_commands` | `bool` | `true` | Bloquer commandes à haut risque |
| `shell_env_passthrough` | `[String]` | `[]` | Variables d'env transmises aux sous-processus |
| `auto_approve` | `[String]` | `[]` | Outils jamais soumis à confirmation |
| `always_ask` | `[String]` | `[]` | Outils toujours soumis à confirmation |
| `allowed_roots` | `[String]` | `[]` | Racines de répertoires accessibles en plus |
| `allowed_tools` | `[String]` | `[]` | Outils autorisés (vide = pas de contrainte) |
| `excluded_tools` | `[String]` | `[]` | Outils exclus des canaux non-CLI |
| `sandbox_enabled` | `bool` *(facultatif)* | hérite global | Activer le sandbox |
| `sandbox_backend` | `String` *(facultatif)* | — | Backend sandbox : `"firejail"`, `"landlock"` |
| `firejail_args` | `[String]` | `[]` | Arguments supplémentaires pour firejail |

---

## `[runtime_profiles.<alias>]` — Profils d'exécution

Paramètres de comportement agentic et de limites d'exécution.

```toml
[runtime_profiles.standard]
agentic               = false
max_tool_iterations   = 10
max_actions_per_hour  = 20
max_cost_per_day_cents = 500
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `agentic` | `bool` | `false` | Mode agentic multi-tours |
| `max_tool_iterations` | `usize` | `0` | Max itérations outils (0 = hérite global) |
| `max_actions_per_hour` | `u32` | `20` | Max actions par heure |
| `max_cost_per_day_cents` | `u32` | `500` | Budget quotidien en centimes USD |
| `shell_timeout_secs` | `u64` | `60` | Timeout des sous-processus shell |
| `max_delegation_depth` | `u32` | `0` | Profondeur max de délégation (0 = hérite) |
| `delegation_timeout_secs` | `u64` *(facultatif)* | — | Timeout appel délégué |
| `agentic_timeout_secs` | `u64` *(facultatif)* | — | Timeout run agentic |
| `max_history_messages` | `usize` *(facultatif)* | hérite | Max messages historique |
| `max_context_tokens` | `usize` *(facultatif)* | hérite | Max tokens contexte |
| `compact_context` | `bool` *(facultatif)* | hérite | Bootstrap compact |
| `parallel_tools` | `bool` *(facultatif)* | hérite | Outils parallèles |
| `tool_dispatcher` | `String` *(facultatif)* | hérite | Stratégie dispatch |
| `tool_call_dedup_exempt` | `[String]` | `[]` | Outils exemptés dédup |
| `max_system_prompt_chars` | `usize` *(facultatif)* | hérite | Max chars prompt système |
| `context_aware_tools` | `bool` *(facultatif)* | hérite | Filtrage contextuel outils |
| `max_tool_result_chars` | `usize` *(facultatif)* | hérite | Max chars résultat outil |
| `keep_tool_context_turns` | `usize` *(facultatif)* | hérite | Tours contexte outil complet |

---

## `[skill_bundles.<alias>]` — Bundles de skills

Les skills sont des fichiers de définition d'outils (YAML/JSON) que l'agent peut utiliser.

- Stockés dans `<install_root>/shared/skills/<alias>/`
- Référencés via `skill_bundles = ["<alias>"]` dans `[agents.<alias>]`
- Si `skill_bundles` est vide, seul `data/skills/` est chargé (pas les bundles partagés)

```toml
[skill_bundles.research]
directory = "shared/skills/research"
include   = []          # vide = tout inclure
exclude   = []
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `directory` | `String` *(facultatif)* | `shared/skills/<alias>/` | Chemin du répertoire (relatif à `install_root`) |
| `include` | `[String]` | `[]` | Noms de skills à inclure (vide = tous) |
| `exclude` | `[String]` | `[]` | Noms de skills à exclure |

---

## `[knowledge_bundles.<alias>]` — Bundles de connaissances

Fichiers markdown/texte injectés dans la mémoire de l'agent.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `directory` | `String` **(requis)** | — | Chemin du répertoire de documents |
| `include` | `[String]` | `[]` | Fichiers à inclure (vide = tous) |
| `exclude` | `[String]` | `[]` | Fichiers à exclure |
| `recursive` | `bool` | `false` | Parcourir les sous-répertoires |

---

## `[mcp_bundles.<alias>]` — Bundles de serveurs MCP

Serveurs MCP (Model Context Protocol) fournis à l'agent.

```toml
[mcp_bundles.tools]
servers = [
  { name = "filesystem", command = "npx", args = ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"] }
]
```

| Champ | Type | Description |
|-------|------|-------------|
| `servers` | `[McpServerConfig]` | Liste de serveurs MCP |

**McpServerConfig** :

| Champ | Type | Description |
|-------|------|-------------|
| `name` | `String` | Nom du serveur |
| `command` | `String` | Exécutable à lancer |
| `args` | `[String]` | Arguments |
| `env` | `{String: String}` | Variables d'environnement |
| `timeout_secs` | `u64` *(facultatif)* | Timeout de connexion |

---

## `[peer_groups.<alias>]` — Groupes de pairs

Groupes d'agents pouvant se déléguer des tâches entre eux.

```toml
[peer_groups.main]
agents   = ["default", "analyst"]
strategy = "round_robin"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `agents` | `[String]` **(requis)** | — | Alias des agents membres du groupe |
| `strategy` | `String` | `"round_robin"` | Stratégie de sélection : `"round_robin"`, `"least_busy"`, `"first_available"` |
| `max_parallel` | `u32` | `1` | Max agents actifs en parallèle dans le groupe |

---

## `[channels]` — Configuration globale des canaux

```toml
[channels]
cli                    = true
message_timeout_secs   = 300
ack_reactions          = true
show_tool_calls        = false
session_persistence    = true
session_backend        = "sqlite"   # ou "jsonl"
session_ttl_hours      = 0
debounce_ms            = 0
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `cli` | `bool` | `true` | Activer le canal CLI interactif |
| `message_timeout_secs` | `u64` | `300` | Timeout base de traitement des messages |
| `ack_reactions` | `bool` | `true` | Réactions d'accusé (👀 / ✅ / ⚠️) |
| `show_tool_calls` | `bool` | `false` | Envoyer les notifications d'appel d'outil au canal |
| `session_persistence` | `bool` | `true` | Persister l'historique de conversation |
| `session_backend` | `String` | `"sqlite"` | `"sqlite"` ou `"jsonl"` |
| `session_ttl_hours` | `u32` | `0` | Auto-archiver les sessions inactives (0 = désactivé) |
| `debounce_ms` | `u64` | `0` | Fenêtre de debounce pour les messages entrants (ms) |

---

### `[channels.telegram.<alias>]`

```toml
[channels.telegram.default]
token   = "..."     # #[secret]
enabled = true
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `token` | `String` `#[secret]` **(requis)** | — | Token du bot Telegram |
| `enabled` | `bool` | `true` | Activer ce canal |
| `allowed_users` | `[String]` | `[]` | Usernames/IDs autorisés (vide = tous) |
| `allowed_chats` | `[i64]` | `[]` | Chat IDs autorisés (vide = tous) |
| `parse_mode` | `String` | `"MarkdownV2"` | Format de rendu : `"MarkdownV2"`, `"HTML"`, `"Markdown"` |
| `polling_timeout_secs` | `u64` | `30` | Timeout long-polling Telegram |
| `max_message_length` | `usize` | `4096` | Max caractères par message Telegram |
| `split_long_messages` | `bool` | `true` | Découper les messages trop longs |
| `webhook_url` | `String` *(facultatif)* | — | URL webhook (mode webhook, sinon polling) |
| `webhook_secret` | `String` `#[secret]` *(facultatif)* | — | Secret de validation webhook |
| `proxy_url` | `String` *(facultatif)* | — | Proxy SOCKS5/HTTP pour l'API Telegram |
| `voice_enabled` | `bool` | `false` | Traiter les messages vocaux (→ transcription) |
| `image_enabled` | `bool` | `false` | Traiter les images (→ multimodal) |
| `file_enabled` | `bool` | `false` | Traiter les fichiers joints |
| `tts_enabled` | `bool` | `false` | Répondre en vocal (→ TTS) |

---

### `[channels.discord.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `token` | `String` `#[secret]` **(requis)** | — | Token du bot Discord |
| `enabled` | `bool` | `true` | Activer ce canal |
| `guild_ids` | `[u64]` | `[]` | Serveurs autorisés (vide = tous) |
| `allowed_channels` | `[String]` | `[]` | Noms/IDs de canaux autorisés |
| `command_prefix` | `String` | `"!"` | Préfixe de commande (mode préfixe) |
| `slash_commands` | `bool` | `true` | Activer les slash commands Discord |
| `voice_enabled` | `bool` | `false` | Accès aux canaux vocaux |
| `tts_enabled` | `bool` | `false` | Répondre en vocal dans les salons vocaux |

---

### `[channels.slack.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `bot_token` | `String` `#[secret]` **(requis)** | — | Token bot Slack (`xoxb-...`) |
| `app_token` | `String` `#[secret]` *(facultatif)* | — | Token app Slack (mode Socket) |
| `enabled` | `bool` | `true` | Activer |
| `signing_secret` | `String` `#[secret]` *(facultatif)* | — | Secret de validation des webhooks |
| `allowed_channels` | `[String]` | `[]` | Canaux autorisés (vide = tous) |
| `allowed_users` | `[String]` | `[]` | User IDs autorisés |
| `socket_mode` | `bool` | `false` | Utiliser Socket Mode au lieu des webhooks |

---

### `[channels.webhook.<alias>]`

Canal HTTP entrant générique.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer |
| `path` | `String` | `"/webhook"` | Chemin de l'endpoint (relatif au gateway) |
| `secret` | `String` `#[secret]` *(facultatif)* | — | Secret de validation HMAC |
| `hmac_header` | `String` | `"X-Hub-Signature-256"` | Header HMAC |
| `allowed_ips` | `[String]` | `[]` | IPs autorisées (vide = toutes) |
| `response_mode` | `String` | `"async"` | `"sync"` ou `"async"` |

---

### `[channels.matrix.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `homeserver_url` | `String` **(requis)** | — | URL du serveur Matrix |
| `access_token` | `String` `#[secret]` **(requis)** | — | Token d'accès Matrix |
| `user_id` | `String` **(requis)** | — | MXID du bot (ex. `@bot:matrix.org`) |
| `enabled` | `bool` | `true` | Activer |
| `allowed_rooms` | `[String]` | `[]` | Room IDs autorisées |
| `allowed_users` | `[String]` | `[]` | MXIDs autorisés |

---

### `[channels.email.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `imap_host` | `String` **(requis)** | — | Serveur IMAP |
| `imap_port` | `u16` | `993` | Port IMAP |
| `smtp_host` | `String` **(requis)** | — | Serveur SMTP |
| `smtp_port` | `u16` | `587` | Port SMTP |
| `username` | `String` **(requis)** | — | Identifiant email |
| `password` | `String` `#[secret]` **(requis)** | — | Mot de passe |
| `enabled` | `bool` | `true` | Activer |
| `poll_interval_secs` | `u64` | `60` | Intervalle de polling IMAP |
| `allowed_senders` | `[String]` | `[]` | Expéditeurs autorisés |

---

### `[channels.mattermost.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `url` | `String` **(requis)** | — | URL de l'instance Mattermost |
| `token` | `String` `#[secret]` **(requis)** | — | Personal Access Token |
| `enabled` | `bool` | `true` | Activer |
| `allowed_channels` | `[String]` | `[]` | Channels autorisés |

---

### Autres canaux disponibles

| Famille | Description |
|---------|-------------|
| `signal` | Signal Messenger (via signal-cli) |
| `whatsapp` | WhatsApp Business API |
| `irc` | IRC (Internet Relay Chat) |
| `lark` | Lark / Feishu |
| `line` | LINE Messenger |
| `dingtalk` | DingTalk (Alibaba) |
| `wecom` | WeCom / Enterprise WeChat |
| `wechat` | WeChat Public Account |
| `qq` | QQ Messenger |
| `twitter` | Twitter/X via API v2 |
| `reddit` | Reddit via PRAW |
| `bluesky` | Bluesky AT Protocol |
| `voice_call` | Appel vocal entrant (Twilio, etc.) |
| `voice_duplex` | Vocal bidirectionnel temps réel |
| `mqtt` | MQTT broker |

---

## `[memory]` — Mémoire persistante

```toml
[memory]
backend              = "sqlite.default"
auto_save            = true
search_mode          = "bm25"
embedding_provider   = "none"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `backend` | `String` | `"sqlite.default"` | Backend de stockage (ex. `"sqlite.default"`, `"postgres.work"`) |
| `auto_save` | `bool` | `true` | Sauvegarder automatiquement les messages utilisateur |
| `hygiene_enabled` | `bool` | `true` | Passe d'hygiène périodique |
| `archive_after_days` | `u32` | `7` | Archiver les fichiers de session après N jours |
| `purge_after_days` | `u32` | `30` | Supprimer les archives après N jours |
| `conversation_retention_days` | `u32` | `30` | Rétention des conversations SQLite |
| `embedding_provider` | `String` | `"none"` | Source des embeddings : `"none"`, `"openai"`, `"custom:<URL>"` |
| `embedding_model` | `String` | `"text-embedding-3-small"` | Modèle d'embedding |
| `embedding_dimensions` | `usize` | `1536` | Dimension des vecteurs |
| `vector_weight` | `f64` | `0.7` | Poids similarité vectorielle (recherche hybride) |
| `keyword_weight` | `f64` | `0.3` | Poids BM25 (recherche hybride) |
| `search_mode` | `String` | `"bm25"` | `"bm25"`, `"embedding"`, `"hybrid"` |
| `min_relevance_score` | `f64` | `0.4` | Score minimal pour la recherche hybride |
| `embedding_cache_size` | `usize` | `10000` | Taille du cache d'embeddings |
| `chunk_max_tokens` | `usize` | `512` | Tokens max par chunk de document |
| `response_cache_enabled` | `bool` | `false` | Cache des réponses LLM |
| `response_cache_ttl_minutes` | `u32` | `60` | Durée de vie du cache réponse |
| `response_cache_max_entries` | `usize` | `5000` | Max entrées dans le cache |
| `response_cache_hot_entries` | `usize` | `256` | Entrées chaudes (cache L1) |
| `snapshot_enabled` | `bool` | `false` | Exporter les mémoires clés vers `MEMORY_SNAPSHOT.md` |
| `snapshot_on_hygiene` | `bool` | `false` | Déclencher le snapshot pendant l'hygiène |
| `auto_hydrate` | `bool` | `true` | Réimporter `MEMORY_SNAPSHOT.md` si `brain.db` absent |
| `retrieval_stages` | `[String]` | `["cache","fts","vector"]` | Étapes du pipeline de récupération |
| `rerank_enabled` | `bool` | `false` | Activer le reranking LLM |
| `rerank_threshold` | `usize` | `5` | Min candidats avant reranking |
| `fts_early_return_score` | `f64` | `0.85` | Score FTS pour retour anticipé |
| `default_namespace` | `String` | `"default"` | Espace de nommage par défaut |
| `conflict_threshold` | `f64` | `0.85` | Seuil de similarité pour détection de conflits |
| `audit_enabled` | `bool` | `false` | Log d'audit des opérations mémoire |
| `audit_retention_days` | `u32` | `30` | Rétention des logs d'audit |

### `[memory.policy]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `max_entries_per_namespace` | `usize` | `0` | Max entrées par namespace (0 = illimité) |
| `max_entries_per_category` | `usize` | `0` | Max entrées par catégorie (0 = illimité) |
| `retention_days_by_category` | `{String: u32}` | `{}` | Rétention par catégorie |
| `read_only_namespaces` | `[String]` | `[]` | Namespaces en lecture seule |

---

## `[storage]` — Backends de stockage

### `[storage.sqlite.<alias>]`

```toml
[storage.sqlite.default]
# path = "/custom/path/brain.db"   # optionnel
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `path` | `String` *(facultatif)* | `data/memory/brain.db` | Chemin du fichier SQLite |
| `open_timeout_secs` | `u64` *(facultatif)* | `5` | Attente max pour base verrouillée |

### `[storage.postgres.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `db_url` | `String` `#[secret]` **(requis)** | — | URL de connexion PostgreSQL |
| `schema` | `String` | `"public"` | Schéma cible |
| `table` | `String` | `"memories"` | Table cible |
| `connect_timeout_secs` | `u64` *(facultatif)* | `10` | Timeout de connexion |
| `vector_enabled` | `bool` | `false` | Activer pgvector |
| `vector_dimensions` | `usize` | `1536` | Dimensions des vecteurs pgvector |

### `[storage.qdrant.<alias>]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `url` | `String` *(facultatif)* | env `QDRANT_URL` | URL de l'instance Qdrant |
| `collection` | `String` | `"zeroclaw_memories"` | Nom de la collection |
| `api_key` | `String` `#[secret]` *(facultatif)* | — | Clé API Qdrant |

### `[storage.markdown.<alias>]`

Stockage en fichiers markdown (lecture humaine, non recommandé pour la prod).

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `directory` | `String` *(facultatif)* | `data/memory/markdown/` | Répertoire de stockage |

---

## `[gateway]` — Passerelle HTTP

La gateway expose une API REST/WebSocket pour les clients externes.

```toml
[gateway]
port           = 42617
host           = "127.0.0.1"
require_pairing = true
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `port` | `u16` | `42617` | Port d'écoute |
| `host` | `String` | `"127.0.0.1"` | Interface d'écoute |
| `require_pairing` | `bool` | `true` | Exiger l'appairage avant d'accepter des requêtes |
| `allow_public_bind` | `bool` | `false` | Permettre une écoute non-localhost sans tunnel |
| `paired_tokens` | `[String]` `#[secret]` | géré auto | Tokens bearer appairés |
| `pair_rate_limit_per_minute` | `u32` | `10` | Max requêtes `/pair` par minute par client |
| `webhook_rate_limit_per_minute` | `u32` | `60` | Max requêtes `/webhook` par minute |
| `trust_forwarded_headers` | `bool` | `false` | Faire confiance aux headers proxy (X-Forwarded-For) |
| `path_prefix` | `String` *(facultatif)* | — | Préfixe URL pour reverse-proxy |
| `rate_limit_max_keys` | `usize` | `10000` | Max clés clients suivies pour le rate limiting |
| `idempotency_ttl_secs` | `u64` | `300` | TTL des clés d'idempotence webhook |
| `idempotency_max_keys` | `usize` | `10000` | Max clés d'idempotence |
| `session_persistence` | `bool` | `true` | Persister les sessions WebSocket en SQLite |
| `session_ttl_hours` | `u32` | `0` | Auto-archiver les sessions inactives (0 = désactivé) |
| `web_dist_dir` | `String` *(facultatif)* | — | Répertoire `dist` du dashboard web |
| `request_timeout_secs` | `u64` | `30` | Timeout HTTP standard |
| `long_running_request_timeout_secs` | `u64` | `600` | Timeout pour les endpoints cron/long |

### `[gateway.tls]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer TLS |
| `cert_path` | `String` **(requis si activé)** | — | Chemin du certificat PEM |
| `key_path` | `String` `#[secret]` **(requis si activé)** | — | Chemin de la clé privée PEM |

### `[gateway.pairing_dashboard]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer le dashboard d'appairage |
| `path` | `String` | `"/pair"` | Chemin du dashboard |

---

## `[tunnel]` — Tunnel (ngrok / cloudflared)

Expose la gateway à Internet via un tunnel sécurisé.

```toml
[tunnel]
enabled  = false
provider = "ngrok"
token    = "..."    # #[secret]
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer le tunnel |
| `provider` | `String` | `"ngrok"` | Fournisseur : `"ngrok"`, `"cloudflared"` |
| `token` | `String` `#[secret]` *(facultatif)* | — | Token ngrok |
| `domain` | `String` *(facultatif)* | — | Domaine fixe ngrok (plan payant) |
| `port` | `u16` *(facultatif)* | hérite `[gateway].port` | Port à exposer |

---

## `[security]` — Sécurité

### `[security.audit]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'audit logging |
| `level` | `String` | `"standard"` | `"minimal"`, `"standard"`, `"verbose"` |
| `retention_days` | `u32` | `90` | Rétention des logs |
| `backend` | `String` | `"file"` | `"file"` ou `"sqlite"` |

### `[security.otp]`

Protection par OTP (One-Time Password) pour les actions sensibles.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer la protection OTP |
| `method` | `String` | `"totp"` | `"totp"`, `"pairing"`, `"cli_prompt"` |
| `token_ttl_secs` | `u64` | `30` | Pas de temps TOTP |
| `cache_valid_secs` | `u64` | `300` | Réutilisation d'un code valide récent |
| `gated_actions` | `[String]` | `["shell","file_write","browser_open","browser","memory_forget"]` | Outils protégés |
| `gated_domains` | `[String]` | `[]` | Domaines protégés |
| `gated_domain_categories` | `[String]` | `[]` | Catégories de domaines protégées |
| `challenge_max_attempts` | `u32` | `3` | Max tentatives avant verrouillage |

### `[security.estop]`

Arrêt d'urgence (estop) — coupe toute activité agentic.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'estop |
| `trigger_on_anomaly` | `bool` | `false` | Déclencher automatiquement sur anomalie |
| `notify_channel` | `String` *(facultatif)* | — | Canal à notifier lors d'un estop |

### `[security.webauthn]`

Authentification WebAuthn/FIDO2 pour la gateway.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer WebAuthn |
| `rp_id` | `String` | `"localhost"` | ID de la Relying Party |
| `rp_origin` | `String` | `"http://localhost:42617"` | Origine de la Relying Party |
| `rp_name` | `String` | `"ZeroClaw"` | Nom affiché |

---

## `[cost]` — Suivi des coûts

```toml
[cost]
enabled             = true
daily_limit_usd     = 10.0
monthly_limit_usd   = 100.0
warn_at_percent     = 80
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer le suivi des coûts |
| `daily_limit_usd` | `f64` | `10.0` | Limite quotidienne en USD |
| `monthly_limit_usd` | `f64` | `100.0` | Limite mensuelle en USD |
| `warn_at_percent` | `u8` | `80` | Alerter à X% de la limite |
| `allow_override` | `bool` | `false` | Permettre de dépasser le budget avec `--override` |
| `track_per_agent` | `bool` | `true` | Attribuer les coûts par agent |

### `[cost.enforcement]`

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `mode` | `String` | `"warn"` | `"warn"` (alerte), `"block"` (bloque), `"route_down"` (dégrade) |
| `route_down_model` | `String` *(facultatif)* | — | Provider de repli si budget dépassé |
| `reserve_percent` | `u8` | `10` | Pourcentage de réserve non utilisable |

---

## `[multimodal]` — Vision et multimodal

```toml
[multimodal]
max_images           = 4
max_image_size_mb    = 5
allow_remote_fetch   = false
vision_model_provider = "anthropic.main"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `max_images` | `usize` | `4` | Max images par requête |
| `max_image_size_mb` | `usize` | `5` | Taille max d'une image (MiB) |
| `allow_remote_fetch` | `bool` | `false` | Autoriser le téléchargement d'images distantes |
| `vision_model_provider` | `String` *(facultatif)* | — | Provider pour les messages visuels (ex. `"ollama.vision"`) |
| `vision_model` | `String` *(facultatif)* | — | Modèle vision (ex. `"llava:7b"`) |

---

## `[runtime]` — Environnement d'exécution

```toml
[runtime]
kind = "native"     # ou "docker"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `kind` | `String` | `"native"` | `"native"` ou `"docker"` |
| `reasoning_enabled` | `bool` *(facultatif)* | — | Override global du raisonnement |
| `reasoning_effort` | `String` *(facultatif)* | — | Niveau d'effort de raisonnement |

### `[runtime.docker]`

Actif uniquement si `kind = "docker"`.

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `image` | `String` | `"alpine:3.20"` | Image Docker |
| `network` | `String` | `"none"` | Mode réseau Docker |
| `memory_limit_mb` | `u64` *(facultatif)* | `512` | Limite mémoire (MiB) |
| `cpu_limit` | `f64` *(facultatif)* | `1.0` | Limite CPU |
| `read_only_rootfs` | `bool` | `true` | Filesystem racine en lecture seule |
| `mount_workspace` | `bool` | `true` | Monter le workspace dans `/workspace` |
| `allowed_workspace_roots` | `[String]` | `[]` | Racines de workspace autorisées |

---

## `[scheduler]` — Planificateur de tâches

```toml
[scheduler]
enabled              = true
max_tasks            = 64
max_concurrent       = 4
catch_up_on_startup  = true
max_run_history      = 50
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer le planificateur |
| `max_tasks` | `usize` | `64` | Max tâches en file par cycle |
| `max_concurrent` | `usize` | `4` | Max tâches exécutées en parallèle |
| `catch_up_on_startup` | `bool` | `true` | Exécuter les tâches en retard au démarrage |
| `max_run_history` | `u32` | `50` | Max entrées d'historique d'exécution cron |

---

## `[heartbeat]` — Surveillance du démon

```toml
[heartbeat]
enabled          = true
interval_secs    = 30
stale_after_secs = 120
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer la surveillance heartbeat |
| `interval_secs` | `u64` | `30` | Intervalle d'émission |
| `stale_after_secs` | `u64` | `120` | Délai avant détection "stale" |
| `notify_channel` | `String` *(facultatif)* | — | Canal notifié si heartbeat stale |

---

## `[acp]` — Agent Communication Protocol

```toml
[acp]
enabled          = true
session_persist  = true
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer le protocole ACP |
| `session_persist` | `bool` | `true` | Persister les sessions ACP |
| `session_ttl_hours` | `u32` | `24` | TTL des sessions ACP |

---

## `[mcp]` — Model Context Protocol (global)

Configuration MCP globale (hors bundles par agent).

```toml
[mcp]
enabled        = true
timeout_secs   = 30
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer MCP globalement |
| `timeout_secs` | `u64` | `30` | Timeout de connexion/requête |
| `max_servers` | `usize` | `20` | Max serveurs MCP simultanés |

---

## `[web_fetch]` — Outil de récupération web

```toml
[web_fetch]
enabled         = true
timeout_secs    = 30
max_content_kb  = 500
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'outil web_fetch |
| `timeout_secs` | `u64` | `30` | Timeout HTTP |
| `max_content_kb` | `usize` | `500` | Taille max du contenu (KiB) |
| `follow_redirects` | `bool` | `true` | Suivre les redirections |
| `user_agent` | `String` *(facultatif)* | — | User-Agent HTTP personnalisé |
| `blocked_domains` | `[String]` | `[]` | Domaines bloqués |
| `allowed_domains` | `[String]` | `[]` | Domaines autorisés (vide = tous) |

---

## `[web_search]` — Outil de recherche web

```toml
[web_search]
enabled  = true
provider = "duckduckgo"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer la recherche web |
| `provider` | `String` | `"duckduckgo"` | `"duckduckgo"`, `"brave"`, `"serper"`, `"google"` |
| `api_key` | `String` `#[secret]` *(facultatif)* | — | Clé API (Brave/Serper/Google) |
| `max_results` | `usize` | `10` | Max résultats par requête |
| `safe_search` | `String` | `"moderate"` | `"off"`, `"moderate"`, `"strict"` |
| `timeout_secs` | `u64` | `15` | Timeout de la requête |

---

## `[http_request]` — Outil HTTP générique

```toml
[http_request]
enabled          = true
timeout_secs     = 30
max_response_kb  = 1024
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'outil http_request |
| `timeout_secs` | `u64` | `30` | Timeout HTTP |
| `max_response_kb` | `usize` | `1024` | Taille max de la réponse (KiB) |
| `follow_redirects` | `bool` | `true` | Suivre les redirections |
| `allowed_domains` | `[String]` | `[]` | Domaines autorisés (vide = tous) |
| `blocked_domains` | `[String]` | `[]` | Domaines bloqués |

---

## `[observability]` — Observabilité et traces

```toml
[observability]
enabled    = true
log_level  = "info"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'observabilité |
| `log_level` | `String` | `"info"` | `"error"`, `"warn"`, `"info"`, `"debug"`, `"trace"` |
| `log_format` | `String` | `"text"` | `"text"` ou `"json"` |
| `traces_enabled` | `bool` | `false` | Activer l'export OTLP traces |
| `otlp_endpoint` | `String` *(facultatif)* | — | Endpoint OpenTelemetry (ex. `http://localhost:4317`) |
| `metrics_enabled` | `bool` | `false` | Activer les métriques Prometheus |
| `metrics_port` | `u16` | `9090` | Port de l'endpoint `/metrics` |

---

## `[reliability]` — Fiabilité

```toml
[reliability]
circuit_breaker_enabled  = true
retry_max_attempts       = 3
retry_backoff_ms         = 500
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `circuit_breaker_enabled` | `bool` | `true` | Activer le circuit breaker |
| `retry_max_attempts` | `u32` | `3` | Max tentatives globales |
| `retry_backoff_ms` | `u64` | `500` | Backoff entre tentatives (ms) |
| `retry_backoff_multiplier` | `f64` | `2.0` | Multiplicateur de backoff exponentiel |
| `retry_max_backoff_ms` | `u64` | `30000` | Backoff maximum (ms) |
| `failure_threshold` | `u32` | `5` | Seuil d'échecs pour ouverture du circuit |
| `recovery_timeout_secs` | `u64` | `60` | Délai de récupération du circuit |

---

## `[backup]` — Sauvegardes automatiques

```toml
[backup]
enabled       = true
max_keep      = 10
compress      = true
destination_dir = "state/backups"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'outil backup |
| `max_keep` | `usize` | `10` | Nombre max de sauvegardes (les plus anciennes sont purgées) |
| `include_dirs` | `[String]` | `["config","memory","audit","knowledge"]` | Répertoires inclus |
| `destination_dir` | `String` | `"state/backups"` | Destination (relatif au workspace) |
| `schedule_cron` | `String` *(facultatif)* | — | Expression cron pour sauvegarde planifiée |
| `schedule_timezone` | `String` *(facultatif)* | — | Timezone IANA pour le cron |
| `compress` | `bool` | `true` | Compresser les archives |
| `encrypt` | `bool` | `false` | Chiffrer les archives |

---

## `[data_retention]` — Rétention des données

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer la gestion de rétention |
| `retention_days` | `u64` | `90` | Jours de données à conserver |
| `dry_run` | `bool` | `false` | Simuler sans supprimer |
| `categories` | `[String]` | `[]` | Catégories ciblées (vide = toutes) |

---

## `[browser]` — Outil navigateur

```toml
[browser]
enabled   = true
headless  = true
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer l'outil navigateur |
| `headless` | `bool` | `true` | Mode headless (sans affichage) |
| `timeout_secs` | `u64` | `30` | Timeout de navigation |
| `viewport_width` | `u32` | `1280` | Largeur de la fenêtre |
| `viewport_height` | `u32` | `800` | Hauteur de la fenêtre |
| `allowed_domains` | `[String]` | `[]` | Domaines autorisés |
| `blocked_domains` | `[String]` | `[]` | Domaines bloqués |
| `screenshot_enabled` | `bool` | `true` | Capturer des screenshots |

---

## `[proxy]` — Proxy HTTP sortant

```toml
[proxy]
enabled = false
url     = "http://proxy.example.com:8080"
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer le proxy sortant |
| `url` | `String` *(facultatif)* | — | URL du proxy (HTTP/SOCKS5) |
| `username` | `String` *(facultatif)* | — | Identifiant proxy |
| `password` | `String` `#[secret]` *(facultatif)* | — | Mot de passe proxy |
| `no_proxy` | `[String]` | `[]` | Domaines exclus du proxy |

---

## `[nodes]` — Architecture multi-nœuds

```toml
[nodes]
enabled = false
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer le mode multi-nœuds |
| `discovery` | `String` | `"static"` | `"static"` ou `"mdns"` |
| `listen_addr` | `String` | `"0.0.0.0:42618"` | Adresse d'écoute inter-nœuds |

---

## `[hooks]` — Hooks événementiels

Exécution de commandes shell en réponse à des événements du runtime.

```toml
[hooks]
on_startup  = []
on_shutdown = []
on_message  = []
on_error    = []
```

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `on_startup` | `[HookConfig]` | `[]` | Hooks exécutés au démarrage |
| `on_shutdown` | `[HookConfig]` | `[]` | Hooks exécutés à l'arrêt |
| `on_message` | `[HookConfig]` | `[]` | Hooks déclenchés par un message entrant |
| `on_error` | `[HookConfig]` | `[]` | Hooks déclenchés sur erreur |

**HookConfig** :

| Champ | Type | Description |
|-------|------|-------------|
| `command` | `String` | Commande shell à exécuter |
| `args` | `[String]` | Arguments |
| `timeout_secs` | `u64` | Timeout (défaut : 10) |
| `on_failure` | `String` | `"ignore"` ou `"abort"` |

---

## `[composio]` — Intégration Composio

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer l'intégration Composio |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `COMPOSIO_API_KEY` | Clé API Composio |
| `entity_id` | `String` *(facultatif)* | — | Entity ID Composio |

---

## `[google_workspace]` — Google Workspace

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer l'intégration Google Workspace |
| `credentials_path` | `String` *(facultatif)* | — | Chemin du fichier de credentials OAuth2 |
| `token_path` | `String` *(facultatif)* | — | Chemin du fichier de token |
| `scopes` | `[String]` | `[]` | Scopes OAuth2 demandés |

---

## `[notion]` — Intégration Notion

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer |
| `api_key` | `String` `#[secret]` *(facultatif)* | env `NOTION_API_KEY` | Clé API Notion |
| `default_database_id` | `String` *(facultatif)* | — | Database Notion par défaut |

---

## `[jira]` — Intégration Jira

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer |
| `url` | `String` *(facultatif)* | — | URL de l'instance Jira |
| `email` | `String` *(facultatif)* | — | Email du compte |
| `api_token` | `String` `#[secret]` *(facultatif)* | env `JIRA_API_TOKEN` | Token API Jira |

---

## `[image_gen]` — Génération d'images

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `false` | Activer la génération d'images |
| `provider` | `String` | `"openai"` | `"openai"`, `"stability"`, `"replicate"` |
| `model` | `String` *(facultatif)* | — | Modèle (ex. `"dall-e-3"`) |
| `api_key` | `String` `#[secret]` *(facultatif)* | — | Clé API |
| `size` | `String` | `"1024x1024"` | Dimensions de l'image |
| `quality` | `String` | `"standard"` | `"standard"` ou `"hd"` |

---

## `[knowledge]` — Base de connaissances globale

| Champ | Type | Défaut | Description |
|-------|------|--------|-------------|
| `enabled` | `bool` | `true` | Activer la base de connaissances |
| `index_on_startup` | `bool` | `false` | Réindexer au démarrage |
| `chunk_size` | `usize` | `512` | Taille des chunks (tokens) |
| `chunk_overlap` | `usize` | `64` | Chevauchement des chunks |

---

## Exemple de config minimale fonctionnelle

```toml
schema_version = 3

[providers.models.anthropic.main]
model   = "claude-sonnet-4-6"
api_key = "sk-ant-..."

[agents.default]
enabled         = true
model_provider  = "anthropic.main"
risk_profile    = "standard"
runtime_profile = "standard"

[risk_profiles.standard]
level          = "semi_autonomous"
workspace_only = true

[runtime_profiles.standard]
agentic              = false
max_actions_per_hour = 20
max_cost_per_day_cents = 500

[memory]
backend = "sqlite.default"

[storage.sqlite.default]
```

---

## Exemple de config multi-agents avec Telegram et LiteLLM

```toml
schema_version = 3

# Providers
[providers.models.litellm.fast]
model    = "ollama/mistral"
api_key  = "sk-litellm-master-key"
api_base = "http://localhost:4000/v1"

[providers.models.litellm.powerful]
model    = "anthropic/claude-opus-4-7"
api_key  = "sk-litellm-master-key"
api_base = "http://localhost:4000/v1"

# Agents
[agents.assistant]
enabled         = true
model_provider  = "litellm.fast"
channels        = ["telegram.main"]
risk_profile    = "standard"
runtime_profile = "standard"
skill_bundles   = ["common"]

[agents.analyst]
enabled         = true
model_provider  = "litellm.powerful"
# Pas de channels — uniquement accessible via délégation
risk_profile    = "restricted"
runtime_profile = "agentic"

# Canaux
[channels.telegram.main]
token         = "123456:ABCdef..."
allowed_users = ["myusername"]
parse_mode    = "MarkdownV2"

# Profils
[risk_profiles.standard]
level = "semi_autonomous"

[risk_profiles.restricted]
level          = "supervised"
workspace_only = true

[runtime_profiles.standard]
agentic = false

[runtime_profiles.agentic]
agentic               = true
max_tool_iterations   = 20
max_actions_per_hour  = 50

# Skills
[skill_bundles.common]
directory = "shared/skills/common"

# Peer group pour délégation
[peer_groups.team]
agents   = ["assistant", "analyst"]
strategy = "first_available"

# Mémoire
[memory]
backend     = "sqlite.default"
search_mode = "bm25"

[storage.sqlite.default]

# Coût
[cost]
enabled            = true
daily_limit_usd    = 5.0
monthly_limit_usd  = 50.0
```

---

## Arborescence de l'installation

```
<install_root>/           # dossier contenant config.toml
├── config.toml
├── agents/
│   └── <alias>/
│       └── workspace/    # workspace propre à chaque agent
├── data/
│   ├── skills/           # skills chargés si skill_bundles = [] dans un agent
│   └── memory/
│       └── brain.db      # SQLite par défaut
├── shared/
│   └── skills/
│       └── <bundle-alias>/   # skills chargés via skill_bundles = ["<bundle-alias>"]
├── state/
│   ├── backups/
│   └── *.state
└── logs/
```

`install_root` = répertoire parent du fichier `config.toml`.
