# Mise en service depuis Android

## Publier la maquette
1. Créer un dépôt public GitHub nommé `endirect`.
2. Téléverser le contenu du kit à la racine du dépôt (pas le ZIP lui-même).
3. Settings → Pages → Deploy from a branch → `main` → `/ (root)` → Save.
4. Attendre l'URL fournie par GitHub Pages.

## Activer le backend multiutilisateur
1. Créer un projet Supabase gratuit.
2. Dans SQL Editor, exécuter `supabase/schema.sql`.
3. Dans Project Settings → API, copier l'URL du projet et la clé publique `anon`/publishable.
4. Dans `index.html`, remplacer les valeurs vides de `SUPABASE_URL` et `SUPABASE_ANON_KEY`.
5. Publier à nouveau `index.html` sur GitHub Pages.
6. Dans Supabase Auth, vérifier les paramètres d'inscription et les URL de redirection correspondant au domaine GitHub Pages.
7. Tester avec deux comptes distincts : création d'annonce, affichage depuis l'autre compte, envoi d'offre, réponse du vendeur, accès interdit aux offres d'autres personnes.
8. Si un test échoue, ne pas ouvrir le service au public avant correction.

Ne jamais intégrer la clé `service_role` dans le frontend ou dans un dépôt public. Seule la clé publique `anon`/publishable est destinée au navigateur, avec les politiques RLS activées.

## Limites avant ouverture
Le frontend sait appeler Supabase quand les deux paramètres sont configurés. Le backend n'est pas créé ou connecté par ce kit : il faut exécuter le SQL dans ton projet. Les documents juridiques sont des brouillons. Compléter les coordonnées réelles de l'éditeur et les règles de modération avant toute ouverture publique.
