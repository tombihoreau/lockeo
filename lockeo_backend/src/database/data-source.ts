import 'dotenv/config';
import { DataSource } from 'typeorm';

// DataSource utilisé par la CLI TypeORM (migrations)
// Note: ne pas activer synchronize ici. En prod/CI on passe uniquement par les migrations.
export const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  entities: [__dirname + '/../entities/*.entity.{ts,js}'],
  migrations: [__dirname + '/migrations/*.{ts,js}'],
  synchronize: false,
  migrationsTableName: process.env.DB_MIGRATIONS_TABLE || 'migrations',
});
