# ZeroClaw — Guide d'intervention pour l'agent

> Comment modifier ce codebase proprement, sans introduire de régressions.

## Avant toute modification

1. **Lire AGENTS.md** — conventions, anti-patterns, workflow PR.
2. **Identifier le tier de stabilité** du crate concerné (voir `docs/local/architecture.md`).
3. **Identifier le niveau de risque** (Low / Medium / High) avant d'éditer.
4. **Lire le module avant d'écrire** — inspecter le module, le câblage factory, et les tests adjacents.

---

## Checklist par type de modification

### Ajouter un nouveau Provider LLM

1. Créer `crates/zeroclaw-providers/src/providers/<nom>.rs`
2. Implémenter le trait `Provider` de `zeroclaw-api`
3. Enregistrer dans le factory : `crates/zeroclaw-providers/src/factory.rs` (ou équivalent)
4. Ajouter la feature flag dans `Cargo.toml` si conditionnel
5. Ajouter les strings Fluent pour les messages user-facing
6. Écrire un test d'intégration minimal

### Ajouter un nouveau Channel

1. Créer `crates/zeroclaw-channels/src/channels/<nom>/`
2. Implémenter le trait `Channel` de `zeroclaw-api`
3. Enregistrer dans l'orchestrator : `crates/zeroclaw-channels/src/orchestrator/`
4. Feature flag dans `Cargo.toml`
5. Strings Fluent obligatoires

### Ajouter un nouvel outil (Tool)

1. Créer `crates/zeroclaw-tools/src/tools/<nom>.rs`
2. Implémenter le trait `Tool` de `zeroclaw-api`
3. Enregistrer dans le registry d'outils
4. **High attention** : les outils ont accès au shell et au filesystem — vérifier les contraintes de sandbox avant d'étendre les permissions.

### Modifier la configuration

1. Modifier le schéma dans `crates/zeroclaw-config/src/`
2. Si ajout de champ : donner une valeur par défaut raisonnable (pas de breaking change silent)
3. Mettre à jour `.env.example` si variable d'env associée
4. Beta tier : breaking changes autorisés en MINOR avec note de changelog

### Modifier la boucle agent ou la sécurité

**RISK: HIGH** — Toujours :
- Lire `src/security/` en entier avant de modifier
- Ne jamais affaiblir silencieusement les contraintes d'accès
- Documenter l'impact dans la PR (comportement, risque, rollback)
- Faire valider par une review

---

## Conventions de code Rust

- **Erreurs** : propager avec `anyhow` ou types d'erreur dédiés. Pas de `unwrap()` / `expect()` en production path — soit propager, soit documenter l'invariant qui rend le panic impossible.
- **Strings user-facing** : obligatoirement via `fl!()` (Fluent). Jamais de string literals directes.
- **Logs** : `tracing::` uniquement, en anglais, avec `error_key` stables.
- **Dead code** : supprimer plutôt que préfixer `_` ou `#[allow(dead_code)]`. Exception : paramètres de trait/callback obligatoires.
- **Dépendances** : ne pas ajouter de crate lourd pour une commodité mineure.
- **Feature flags** : pas de flags spéculatifs "au cas où".

---

## Validation avant commit

```bash
# Formatage
cargo fmt --all -- --check

# Linter
cargo clippy --all-targets -- -D warnings

# Tests
cargo test

# Validation complète (recommandée pour tout changement de code)
./dev/ci.sh all
```

---

## Patterns à éviter (anti-patterns upstream)

- Mixer refactoring + feature dans le même commit
- Modifier des modules "tant qu'on y est" sans lien avec la tâche
- Contourner des checks qui échouent sans explication explicite
- Cacher des side-effects comportementaux dans des commits de refactoring
- Ajouter des données d'identité réelles dans les tests ou exemples

---

## Gestion des modifications locales vs upstream

Les modifications locales vivent sur la branche `local/dev`. Lors d'un pull upstream :

1. Mettre à jour `master` : `git checkout master && git pull origin master`
2. Rebaser `local/dev` : `git checkout local/dev && git rebase master`
3. Résoudre les conflits file par file — donner la priorité à upstream sur `CLAUDE.md` et `AGENTS.md`, puis réappliquer les additions locales manuellement si nécessaire.

Voir `docs/local/git-strategy.md` pour le workflow complet.
