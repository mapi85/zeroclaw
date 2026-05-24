# ZeroClaw — Stratégie Git : sync upstream + modifications locales

## Structure des remotes

```
origin    → https://github.com/zeroclaw-labs/zeroclaw.git   (upstream, lecture seule)
personal  → https://github.com/mapi85/zeroclaw.git           (fork personnel, lecture/écriture)
```

## Structure des branches

```
origin/master   ← upstream GitHub (zeroclaw-labs/zeroclaw)
       |
   master        ← miroir local propre de upstream
       |
   local/dev     ← modifications et optimisations locales (branche de travail)
```

## Règles

- **`master`** : ne jamais commiter directement. C'est le miroir propre de upstream.
- **`local/dev`** : toutes les modifications locales. Rebasée sur `master` après chaque pull upstream.
- **Feature branches** : pour des modifications spécifiques, créer `local/feature/<nom>` depuis `local/dev`.
- **Publier un patch** : commiter sur `local/dev` puis `git push personal local/dev`.

---

## Publier un patch sur le fork personnel

```bash
git add <fichiers>
git commit -m "fix(...): description"
git push personal local/dev
```

Sur le serveur Ubuntu pour récupérer :
```bash
git pull origin local/dev   # origin = mapi85/zeroclaw sur Ubuntu
cargo build --release
```

---

## Setup Ubuntu (première fois)

```bash
git clone https://github.com/mapi85/zeroclaw.git
cd zeroclaw
git remote add upstream https://github.com/zeroclaw-labs/zeroclaw.git
# "origin" pointe vers mapi85/zeroclaw, "upstream" vers zeroclaw-labs/zeroclaw
git checkout local/dev
cargo build --release
```

---

## Récupérer les mises à jour upstream

```bash
# 1. Mettre à jour le miroir local
git checkout master
git pull origin master

# 2. Rebaser les modifications locales
git checkout local/dev
git rebase master

# 3. Republier sur le fork personnel
git push personal local/dev --force-with-lease
```

Si des conflits apparaissent sur `docs/local/` ou `CLAUDE.md` (section "Local Project Setup") :
- Ces fichiers n'existent pas en upstream → pas de conflit normalement.
- Si upstream modifie `CLAUDE.md` (section upstream) → garder les deux blocs, reappliquer la section "Local Project Setup" après le merge.

---

## Fichiers locaux protégés (absents de upstream, jamais à supprimer)

| Fichier | Contenu |
|---------|---------|
| `docs/local/architecture.md` | Navigation codebase pour l'agent |
| `docs/local/modification-guide.md` | Guide d'intervention sûr |
| `docs/local/git-strategy.md` | Ce fichier |
| `CLAUDE.md` (section "Local Project Setup") | Config locale de l'agent |

---

## Vérifier l'état de sync

```bash
# Commits de local/dev non présents en upstream
git log master..local/dev --oneline

# Commits upstream non encore intégrés dans local/dev
git log local/dev..master --oneline
```

---

## Proposer un commit vers upstream

Si une modification locale mérite d'être contribuée upstream :

1. Créer une branche depuis `master` (pas depuis `local/dev`) : `git checkout -b contrib/<nom> master`
2. Cherry-pick ou réimplémenter le changement proprement (sans les éléments purement locaux)
3. Valider : `./dev/ci.sh all`
4. Ouvrir une PR vers `origin/master` en suivant le workflow upstream (voir `AGENTS.md`)

Ne jamais inclure les fichiers `docs/local/` dans une PR upstream.

---

## Résoudre un rebase conflictuel

```bash
git checkout local/dev
git rebase master
# En cas de conflit :
git status                  # voir les fichiers en conflit
# Résoudre manuellement, puis :
git add <fichier-résolu>
git rebase --continue
```

Pour annuler un rebase en cours : `git rebase --abort`

---

## Tagging local

Pour marquer un état stable de `local/dev` :

```bash
git tag local/stable-<date>   # ex: local/stable-2026-05-17
```
