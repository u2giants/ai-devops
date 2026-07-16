---
name: project_seeded_item_images
description: "Test images bulk-loaded into every sandbox item's itemAttachment; how to identify/remove them"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5398de33-e7ff-49c8-a5a3-1529add38755
---

On 2026-07-10 I bulk-loaded test images into all 19,451 items in the sandbox item library so every item has ≥5 images. Sandbox DB = Supabase project `qsllyeztdwjgirsysgai` (pooler host `aws-1-us-east-1.pooler.supabase.com`, schema `dflow`), images from DigitalOcean Spaces bucket `dflowbucket` (sfo3, public URL `https://dflowbucket.sfo3.digitaloceanspaces.com`).

- **174,130 image rows** inserted into `dflow."itemAttachment"` (87,065 Image/Thumb pairs). Real style-number matches where available (9,042), rest filled from arbitrary bucket images.
- Also loaded **1 PDF "tech pack" per item** (19,432 rows, `attachment_type='application/pdf'`, `attachment_display_name='application'`, no uuid) so every item has ≥1 document in the item-detail "Tech Pack & Files" section; 369 are real style-matched PDFs, rest arbitrary fill. Only ~26 genuine tech packs exist in the bucket (the other ~700 PDFs are licensing/costing sheets). Total seeded rows = 193,562.
- Verified live in the app (alsand.designflow.app, login = 1Password "designflow PLM frontend gui access credentials"): item-library grid shows a thumbnail per row; item detail shows the 5-image gallery and the tech-pack PDF download link. itemDetail route uses the item **pk** (`/apps/itemDetail/<item_id_pk>`), library route is `/apps/itemLibrary`.
- **Cleanup marker:** every seeded row has `"item_attachment_createdUser" = 'seed-images-test'`. To remove all test data:
  `DELETE FROM dflow."itemAttachment" WHERE "item_attachment_createdUser" = 'seed-images-test';`
- Image render contract (verified from code): grid thumbnail needs a `Thumb`+`primary_image=true` row (`item-master helpers/utility.js remapProdItem`); detail gallery pairs `Image`/`Thumb` rows by shared `uuid`. `item_attachment_id` is GENERATED ALWAYS AS IDENTITY — never set it. Legacy `getItemImages` (filters attachment_type 'image'/'thumb') is dead; live read path is `getItemAttachments/:id`.
- Tech packs / costing / licensing sheets also exist in the bucket as PDFs (e.g. `*_techpack.pdf`) — ~725 PDFs total — available if we later want to attach docs to items.
