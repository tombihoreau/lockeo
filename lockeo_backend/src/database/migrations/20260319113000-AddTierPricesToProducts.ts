import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddTierPricesToProducts20260319113000
  implements MigrationInterface
{
  name = 'AddTierPricesToProducts20260319113000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumns('products', [
      new TableColumn({
        name: 'price_3_days',
        type: 'decimal',
        precision: 8,
        scale: 2,
        isNullable: true,
      }),
      new TableColumn({
        name: 'price_7_days',
        type: 'decimal',
        precision: 8,
        scale: 2,
        isNullable: true,
      }),
    ]);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropColumn('products', 'price_7_days');
    await queryRunner.dropColumn('products', 'price_3_days');
  }
}
