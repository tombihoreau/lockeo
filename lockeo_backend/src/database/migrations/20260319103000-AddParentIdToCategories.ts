import { MigrationInterface, QueryRunner, TableColumn, TableIndex } from 'typeorm';

export class AddParentIdToCategories20260319103000
  implements MigrationInterface
{
  name = 'AddParentIdToCategories20260319103000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'categories',
      new TableColumn({
        name: 'parent_id',
        type: 'int',
        isNullable: false,
        default: 0,
      }),
    );

    await queryRunner.createIndex(
      'categories',
      new TableIndex({
        name: 'IDX_categories_parent_id',
        columnNames: ['parent_id'],
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropIndex('categories', 'IDX_categories_parent_id');
    await queryRunner.dropColumn('categories', 'parent_id');
  }
}
