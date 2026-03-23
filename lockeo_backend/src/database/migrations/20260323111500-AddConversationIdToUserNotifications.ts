import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddConversationIdToUserNotifications20260323111500
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'user_notifications',
      new TableColumn({
        name: 'conversation_id',
        type: 'int',
        isNullable: true,
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropColumn('user_notifications', 'conversation_id');
  }
}
