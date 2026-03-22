# Mettre le projet sur GitHub

**Dépôt configuré** : [https://github.com/ahmedelidrissi18-maker/MoroccoCheck](https://github.com/ahmedelidrissi18-maker/MoroccoCheck)

Le dépôt Git est initialisé, le remote `origin` pointe vers ce dépôt, et le code a été poussé sur la branche `main`. Ci-dessous le rappel des commandes pour référence.

---

## 1. Créer un dépôt sur GitHub

1. Va sur **https://github.com** et connecte-toi (ou crée un compte).
2. Clique sur **"New"** (ou **"+"** → **"New repository"**).
3. Remplis :
   - **Repository name** : par ex. `MoroccoCheck` ou `App_Touriste`
   - **Description** (optionnel) : ex. "Application MoroccoCheck - Backend + dossier conceptuel"
   - Choisis **Public** ou **Private**
   - **Ne coche pas** "Add a README", "Add .gitignore" ni "Choose a license" (le projet en a déjà).
4. Clique sur **"Create repository"**.

---

## 2. Lier ton projet local à GitHub

GitHub affiche des commandes. Utilise celles-ci **dans un terminal**, à la racine du projet (`App_Touriste`) :

Remplace `TON_UTILISATEUR` par ton nom d’utilisateur GitHub et `NOM_DU_REPO` par le nom du dépôt (ex. `MoroccoCheck`) :

```bash
cd C:\Users\User\App_Touriste

git remote add origin https://github.com/TON_UTILISATEUR/NOM_DU_REPO.git
```

**Ton dépôt** : [https://github.com/ahmedelidrissi18-maker/MoroccoCheck](https://github.com/ahmedelidrissi18-maker/MoroccoCheck)

```bash
git remote add origin https://github.com/ahmedelidrissi18-maker/MoroccoCheck.git
```

---

## 3. Pousser le code sur GitHub

```bash
git branch -M main
git push -u origin main
```

Si GitHub te demande de te connecter, utilise ton **nom d’utilisateur** et un **Personal Access Token** (mot de passe classique ne fonctionne plus). Pour créer un token : GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Generate new token**.

---

## 4. Vérifier

Ouvre l’URL du dépôt (ex. `https://github.com/TON_UTILISATEUR/NOM_DU_REPO`) : tu dois voir tous tes fichiers (backend, Dossier_conceptuelle_MC, README, etc.). Le fichier **`.env`** ne doit **pas** apparaître (il est dans `.gitignore`).

---

## Résumé des commandes (à adapter)

```bash
cd C:\Users\User\App_Touriste
git remote add origin https://github.com/TON_UTILISATEUR/NOM_DU_REPO.git
git branch -M main
git push -u origin main
```

Ensuite, pour envoyer tes prochains changements :

```bash
git add -A
git commit -m "Description de tes modifications"
git push
```
