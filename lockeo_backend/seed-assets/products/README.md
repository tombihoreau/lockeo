Place in this folder the source images used by `npm run seed`.

The current seeder expects these files:

- `paddle_touring.jpg`
- `kayak_randonnee.jpg`
- `kayaks_lot.jpg`
- `planche_surf.jpg`
- `planche.jpeg`
- `tente_dome.jpg`
- `kit_bivouac.jpg`
- `sac_randonnee.jpg`
- `vtt1.jpg`
- `vtt2.jpg`
- `velo_pliant.jpg`
- `velo_enfant.jpg`
- `velo_enfants.jpg`
- `football_ballon.jpg`

During the seed, the backend copies them into the runtime uploads folder:

- `${UPLOADS_DIR:-<repo>/uploads}/products`

Then the database stores paths like:

- `uploads/products/paddle-touring-gonflable-01.jpg`
