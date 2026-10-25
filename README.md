# EnDirect — guide de mise en service V1

## Ce qui est prêt dans ce kit
- `index.html`: interface mobile, annonces de démonstration, dépôt d'annonce local, favoris, propositions locales, export/import de sauvegarde.
- `supabase/schema.sql`: schéma backend Supabase pour comptes, annonces, offres, favoris et signalements, avec politiques de sécurité RLS.
- Le frontend sait utiliser Supabase après configuration des deux paramètres publics dans `index.html`; sans eux, il reste en mode local.
- `docs/`: cadre produit, juridique et procédures.

## Ce qui n'est pas encore en ligne
La maquette actuelle fonctionne en mode local sur un seul navigateur/appareil. Elle n'a pas de backend branché : les annonces et offres ne sont pas partagées entre utilisateurs. Le SQL est préparé mais non exécuté dans aucun compte. Aucun compte ou projet externe n'a été créé.

## Chemin gratuit recommandé
1. Créer un dépôt public GitHub nommé `endirect`.
2. Importer tous les fichiers du ZIP dans le dépôt.
3. Activer GitHub Pages : Settings → Pages → Deploy from a branch → `main` → `/ (root)` → Save.
4. Créer un projet Supabase gratuit.
5. Dans Supabase → SQL Editor, exécuter `supabase/schema.sql`.
6. Récupérer l'URL du projet et la clé `anon/public` depuis Project Settings → API. Ne jamais exposer une clé `service_role`.
7. Le frontend contient déjà les parcours de connexion/inscription, publication d'annonces et offres distantes. Il faut renseigner l'URL et la clé publique anon du projet, puis tester les flux. Les favoris restent locaux dans cette version. Ne pas entrer de mot de passe Supabase dans un chat.
8. Avant d'accepter de vrais utilisateurs, compléter les mentions légales, CGU, confidentialité, modération et vérifier le cadre juridique exact.

## Pourquoi il reste une étape de connexion
Je ne peux pas créer un projet dans ton compte GitHub ou Supabase sans une autorisation et une session que tu contrôles. Je peux préparer les fichiers et le code, mais je ne dois pas prétendre avoir publié un service réel quand aucun compte n'a été connecté.
