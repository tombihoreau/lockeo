import { existsSync, mkdirSync } from 'fs';
import { basename, join, resolve } from 'path';

export function resolveUploadsDir(): string {
  const explicitDir = process.env.UPLOADS_DIR?.trim();
  if (explicitDir) {
    return resolve(explicitDir);
  }

  const cwd = process.cwd();
  if (basename(cwd) === 'lockeo_backend') {
    return resolve(join(cwd, '..', 'uploads'));
  }

  return resolve(join(cwd, 'uploads'));
}

export function resolveProductUploadsDir(): string {
  return join(resolveUploadsDir(), 'products');
}

export function ensureProductUploadsDir(): string {
  const productUploadsDir = resolveProductUploadsDir();
  if (!existsSync(productUploadsDir)) {
    mkdirSync(productUploadsDir, { recursive: true });
  }
  return productUploadsDir;
}
