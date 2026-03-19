import { MigrationInterface, QueryRunner } from 'typeorm';

export class MakeUserLoginNullable20260123120000 implements MigrationInterface {
  name = 'MakeUserLoginNullable20260123120000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Autoriser login à être NULL
    await queryRunner.query(
      'ALTER TABLE `users` MODIFY `login` varchar(100) NULL',
    );

    // Remplacer l'unique sur login par un index UNIQUE qui autorise plusieurs NULL
    // (comportement MySQL : plusieurs NULL sont autorisés dans une clé unique)
    await queryRunner.query('ALTER TABLE `users` DROP INDEX `UQ_users_login`');
    await queryRunner.query(
      'ALTER TABLE `users` ADD UNIQUE INDEX `UQ_users_login` (`login`)',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Revenir à NOT NULL (⚠️ peut échouer si des lignes ont login=NULL)
    await queryRunner.query(
      'ALTER TABLE `users` MODIFY `login` varchar(100) NOT NULL',
    );

    await queryRunner.query('ALTER TABLE `users` DROP INDEX `UQ_users_login`');
    await queryRunner.query(
      'ALTER TABLE `users` ADD UNIQUE INDEX `UQ_users_login` (`login`)',
    );
  }
}
